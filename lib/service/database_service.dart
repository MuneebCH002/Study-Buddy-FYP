import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseService {
  final String? uid;
  DatabaseService({this.uid});

  // reference for our collections
  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection("users");
  final CollectionReference groupCollection =
      FirebaseFirestore.instance.collection("groups");

  // saving the userdata
  Future<bool> savingUserData(String fullName, String email, String phoneNum, String profilePicUrl) async {
    try {
      // Check if the phone number already exists in Firestore
      QuerySnapshot snapshot = await userCollection.where('phoneNum', isEqualTo: phoneNum).get();

      if (snapshot.docs.isNotEmpty) {
        Fluttertoast.showToast(msg: 'Phone number already exists');
        return false;
      } else {
        await userCollection.doc(uid).set({
          "fullName": fullName,
          "email": email,
          "groups": [],
          "profilePic": profilePicUrl,
          "phoneNum": phoneNum,
          "uid": uid,
        });
        return true;
      }
    } catch (e) {
      throw Exception('Error saving user data: $e');
    }
  }

  // getting user data
  Future gettingUserData(String email) async {
    QuerySnapshot snapshot =
        await userCollection.where("email", isEqualTo: email).get();
    return snapshot;
  }

  // get user groups
  getUserGroups() async {
    return userCollection.doc(uid).snapshots();
  }

  // creating a group
  Future createGroup(String userName, String id, String groupName) async {
    DocumentReference groupDocumentReference = await groupCollection.add({
      "groupName": groupName,
      "groupIcon": "",
      "admin": "${id}_$userName",
      "members": [],
      "groupId": "",
      "recentMessage": "",
      "recentMessageSender": "",
    });
    // update the members
    await groupDocumentReference.update({
      "members": FieldValue.arrayUnion(["${uid}_$userName"]),
      "groupId": groupDocumentReference.id,
    });

    DocumentReference userDocumentReference = userCollection.doc(uid);
    return await userDocumentReference.update({
      "groups":
          FieldValue.arrayUnion(["${groupDocumentReference.id}_$groupName"])
    });
  }

  // getting the chats
  Stream<QuerySnapshot> getMessageStream(String groupId) {
    return FirebaseFirestore.instance
        .collection('groups')
        .doc(groupId)
        .collection('messages')
        .orderBy('time')
        .snapshots();
  }

  Future getGroupAdmin(String groupId) async {
    DocumentReference d = groupCollection.doc(groupId);
    DocumentSnapshot documentSnapshot = await d.get();
    return newMethod(documentSnapshot)['admin'];
  }

  DocumentSnapshot<Object?> newMethod(
          DocumentSnapshot<Object?> documentSnapshot) =>
      documentSnapshot;

  // get group members
  getGroupMembers(groupId) async {
    return groupCollection.doc(groupId).snapshots();
  }

  // search
  searchByName(String groupName) {
    return groupCollection.where("groupName", isEqualTo: groupName).get();
  }

  // function -> bool
  Future<bool> isUserJoined(
      String groupName, String groupId, String userName) async {
    DocumentReference userDocumentReference = userCollection.doc(uid);
    DocumentSnapshot documentSnapshot = await userDocumentReference.get();

    List<dynamic> groups = await documentSnapshot['groups'];
    if (groups.contains("${groupId}_$groupName")) {
      return true;
    } else {
      return false;
    }
  }

  // toggling the group join/exit
  Future toggleGroupJoin(
      String groupId, String userName, String groupName) async {
    // doc reference
    DocumentReference userDocumentReference = userCollection.doc(uid);
    DocumentReference groupDocumentReference = groupCollection.doc(groupId);

    DocumentSnapshot documentSnapshot = await userDocumentReference.get();
    List<dynamic> groups = await documentSnapshot['groups'];

    // if user has our groups -> then remove then or also in other part re join
    if (groups.contains("${groupId}_$groupName")) {
      await userDocumentReference.update({
        "groups": FieldValue.arrayRemove(["${groupId}_$groupName"])
      });
      await groupDocumentReference.update({
        "members": FieldValue.arrayRemove(["${uid}_$userName"])
      });
    } else {
      await userDocumentReference.update({
        "groups": FieldValue.arrayUnion(["${groupId}_$groupName"])
      });
      await groupDocumentReference.update({
        "members": FieldValue.arrayUnion(["${uid}_$userName"])
      });
    }
  }

  // send message
  sendMessage(String groupId, Map<String, dynamic> chatMessageData) async {
    groupCollection.doc(groupId).collection("messages").add(chatMessageData);
    groupCollection.doc(groupId).update({
      "recentMessage": chatMessageData['message'],
      "recentMessageSender": chatMessageData['sender'],
      "recentMessageTime": chatMessageData['time'].toString(),
    });
  }

  //upload shared file

  Future<String?> uploadFileToFirebaseStorage(File file) async {
    // Validate file extension (consider adding more extensions if needed)
    final allowedExtensions = ['pdf', 'docx', 'pptx','mp4', 'avi', 'mov'];
    if (!allowedExtensions.contains(file.path.split('.').last)) {
      Fluttertoast.showToast(msg:'Unsupported file extension. Only PDF, DOCX, and PPTX files are allowed.');
      throw Exception('Unsupported file extension. Only PDF, DOCX, PPTX, And Video files are allowed.');
    }

    // Create a unique file name to prevent conflicts
    final fileName = '${DateTime.now().millisecondsSinceEpoch}-${file.path.split('/').last}';
    final reference = FirebaseStorage.instance.ref().child(fileName);

    // Upload the file with progress tracking (optional for UI feedback)
    final uploadTask = reference.putFile(file);
    await uploadTask.whenComplete(() => null).onError((error, stackTrace) {
      throw Exception('An error occurred while uploading the file: ${error.toString()}');
    });

    // Get the download URL for the uploaded file
    final downloadUrl = await reference.getDownloadURL();
    return downloadUrl;
  }

  //pick file

  Future<File?> pickFileForUpload() async {
    final result = await FilePicker.platform.pickFiles(
      allowedExtensions: ['pdf', 'docx', 'pptx','mp4', 'avi', 'mov'],
      allowMultiple: false,
      type: FileType.custom,
    );

    if (result != null) {
      final platformFile = result.files.single;
      final file = File(platformFile.path!);
      print('file extension ${file.path}');
      return file;
    } else {
      // Handle no file selected case (optional)
      return null;
    }
  }

  //download file

  Future<void> downloadFileFromFirebaseStorage(String url, String fileName,String fileEx) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      // final directory = await getApplicationDocumentsDirectory();
      final studyBuddyDirectory = Directory('/storage/emulated/0/Download/studybuddy');
      if (!(await studyBuddyDirectory.exists())) {
        await studyBuddyDirectory.create(recursive: true);
      }
      final filePath = '${studyBuddyDirectory.path}/$fileName.$fileEx';
      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);
      print('File downloaded successfully: $filePath');
      Fluttertoast.showToast(msg: 'File downloaded successfully: $filePath');
    } else {
      throw Exception('Error downloading file: ${response.statusCode}');
    }
  }
}
