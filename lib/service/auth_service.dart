import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:studybuddyapp/helper/helper_function.dart';
import 'package:studybuddyapp/service/database_service.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class AuthService {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  File? _image;
  final picker = ImagePicker();

  // login
  Future loginWithUserNameandPassword(String email, String password) async {
    try {
      User user = (await firebaseAuth.signInWithEmailAndPassword(
              email: email, password: password))
          .user!;

      if (user != null) {
        return true;
      }
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  // register
  Future registerUserWithEmailandPassword(
      String fullName, String email, String password,String phoneNum,String profilePicUrl) async {
    try {
      final CollectionReference userCollection =
      FirebaseFirestore.instance.collection("users");
      QuerySnapshot snapshot = await userCollection.where('phoneNum', isEqualTo: phoneNum).get();

      if (snapshot.docs.isEmpty) {
        User user = (await firebaseAuth.createUserWithEmailAndPassword(
            email: email, password: password))
            .user!;
        var check=await DatabaseService(uid: user.uid).savingUserData(fullName, email,phoneNum,profilePicUrl);
        return check;
            }
      else{
        Fluttertoast.showToast(msg: 'Phone number already exists');
        return 'Phone number already exists';
      }

    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  // signout
  Future signOut() async {
    try {
      await HelperFunctions.saveUserLoggedInStatus(false);
      await HelperFunctions.saveUserEmailSF("");
      await HelperFunctions.saveUserNameSF("");
      await firebaseAuth.signOut();
    } catch (e) {
      return null;
    }
  }

  Future updateProfile(imageUrl)async{
    await FirebaseFirestore.instance.collection('users').doc(firebaseAuth.currentUser!.uid).update({
      'profilePic':imageUrl
    });
  }

  Future resetPassword(String userEmail)async {
    try{
      await firebaseAuth.sendPasswordResetEmail(email: userEmail).then((value) {
        Fluttertoast.showToast(msg: 'Email with reset link sent! Check your Email.',backgroundColor: Colors.green,toastLength: Toast.LENGTH_LONG);
      }).catchError((error){
        if(error is FirebaseException){
          Fluttertoast.showToast(msg: error.code,backgroundColor: Colors.red,toastLength: Toast.LENGTH_LONG);
        }
      });
    }
    catch(e){
      Fluttertoast.showToast(msg: e.toString(),backgroundColor: Colors.red,toastLength: Toast.LENGTH_LONG);
    }
  }

  Future updatePassword(String newPassword,String oldPassword)async{
    try{
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email:firebaseAuth.currentUser!.email!,
        password: oldPassword,
      );
      if (userCredential.user != null) {
        await FirebaseAuth.instance.currentUser!.updatePassword(newPassword);
        Fluttertoast.showToast(msg: 'Password updated successfully',backgroundColor: Colors.green,toastLength: Toast.LENGTH_LONG);
      } else {
        Fluttertoast.showToast(msg: 'Incorrect Old Password Entered',backgroundColor: Colors.red,toastLength: Toast.LENGTH_LONG);
      }
      await firebaseAuth.currentUser!.updatePassword(newPassword).catchError((error){
        if(error is FirebaseAuthException){
          Fluttertoast.showToast(msg: error.code,backgroundColor: Colors.red,toastLength: Toast.LENGTH_LONG);
        }
      });
    }
        catch(e){
      if(e is FirebaseAuthException){
        Fluttertoast.showToast(msg: e.code,backgroundColor: Colors.red,toastLength: Toast.LENGTH_LONG);
      }
        }
  }

  Future<bool> verifyUser(String oldPassword)async{
    try{
      UserCredential userCredential = await firebaseAuth.signInWithEmailAndPassword(
        email:firebaseAuth.currentUser!.email!,
        password: oldPassword,
      );
      if (userCredential.user != null) {
        Fluttertoast.showToast(msg: 'Verified Successfully!',backgroundColor: Colors.green,toastLength: Toast.LENGTH_LONG);
       return true;
      }
      else {
        Fluttertoast.showToast(msg: 'Verification Failed!',backgroundColor: Colors.red,toastLength: Toast.LENGTH_LONG);
        return false;
      }
    }
    catch(e){
      if(e is FirebaseAuthException){
        Fluttertoast.showToast(msg: e.code,backgroundColor: Colors.red,toastLength: Toast.LENGTH_LONG);
      }
    }
    return false;
  }

  Future getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
       var image = File(pickedFile.path);
        Fluttertoast.showToast(msg: 'Image Selected Successfully',backgroundColor: Colors.green);
        return image;
      } else {
        Fluttertoast.showToast(msg: 'Image Not Selected',backgroundColor: Colors.red);
      }
  }

  Future getProfilePic()async{
    var userData=await FirebaseFirestore.instance.collection('users').doc(firebaseAuth.currentUser!.uid).get();
    return userData['profilePic'];
  }

  Future uploadImage(image) async {
   final Uuid id=Uuid();
    final uid = id;
    final Reference storageRef =
    FirebaseStorage.instance.ref().child('user_profile_pics/$uid.png');
    await storageRef.putFile(image!);
    final String downloadURL = await storageRef.getDownloadURL();
    return downloadURL;
  }
}
