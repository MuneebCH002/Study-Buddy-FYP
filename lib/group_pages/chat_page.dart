import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_emoji/flutter_emoji.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:profanity_filter/profanity_filter.dart';
import 'package:studybuddyapp/group_pages/group_info.dart';
import 'package:studybuddyapp/service/database_service.dart';
import 'package:studybuddyapp/views/home_screen.dart';
import 'package:studybuddyapp/views/quiz_score_screen.dart';
import 'package:studybuddyapp/widgets/widgets.dart';

import '../models/flutter_topics_model.dart';
import '../service/notification_service.dart';
import '../views/quiz_screen.dart';
import '../widgets/chat_screen.dart';

class ChatPage extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String userName;

  ChatPage({
    Key? key,
    required this.groupId,
    required this.groupName,
    required this.userName,
  }) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  Stream<QuerySnapshot>? chats;
  TextEditingController messageController = TextEditingController();
  String admin = "";
  final formKey = GlobalKey<FormState>();

  String fileUrl = '';
  String fileExtension = '';
  String messageType = '';
  NotificationService? notificationService;
  StreamSubscription<QuerySnapshot>? messageSubscription;
  int retryCount = 0;
  final int maxRetries = 5;
  final Duration retryDelay = const Duration(seconds: 5);

  List<String> customWords = [
    'love', 'idiot', 'bastard', 'moron', 'donkey', 'hate', 'fool', 'mingle', 'movie', 'noodles', 'distraction', 'diversion'
  ];

  @override
  void initState() {
    super.initState();
    getChatAndAdmin();
    notificationService = NotificationService();
    subscribeToMessages(widget.groupId);
  }

  void subscribeToMessages(String groupId) {
    messageSubscription = getMessageStream(groupId).listen((snapshot) async {
      if (snapshot.docChanges.isNotEmpty) {
        var latestChange = snapshot.docChanges.last;
        if (latestChange.type == DocumentChangeType.added) {
          var newMessage = latestChange.doc.data() as Map<String, dynamic>?;
          if (newMessage != null) {
            String messageContent = newMessage['message'];
            String senderId = newMessage['sender_id'];
            String messageId = latestChange.doc.id;

            // Check if the message is from the current user
            if (senderId != FirebaseAuth.instance.currentUser!.uid) {
              bool shouldNotify = await shouldSendNotification(widget.groupId, messageId, senderId);
              if (shouldNotify) {
                notificationService!.sendNotification('New Message', messageContent);
              }
            }
          }
        }
      }
    }, onError: (error) {
      handleStreamError(error, groupId);
    });
  }

  Future<bool> shouldSendNotification(String groupId, String messageId, String senderId) async {
    String lastSeenMessageId = await getLastSeenMessageId(groupId);
    return senderId != FirebaseAuth.instance.currentUser!.uid && lastSeenMessageId != messageId;
  }


  Future<String> getLastSeenMessageId(String groupId) async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('groups')
        .doc(groupId)
        .get();

    if (!userDoc.exists) {
      return '';
    }

    // Cast the data to a Map<String, dynamic>
    Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
    return userData['lastSeenMessageId'] ?? '';
  }

  void handleStreamError(error, String groupId) {
    if (retryCount < maxRetries) {
      retryCount++;
      print('Stream error: $error. Retrying in ${retryDelay.inSeconds} seconds...');
      Future.delayed(retryDelay, () => subscribeToMessages(groupId));
    } else {
      print('Max retry attempts reached. Could not reconnect to Firestore.');
    }
  }

  Stream<QuerySnapshot> getMessageStream(String groupId) {
    return FirebaseFirestore.instance
        .collection('groups')
        .doc(groupId)
        .collection('messages')
        .orderBy('time')
        .snapshots();
  }

  getChatAndAdmin() {
    setState(() {
      chats = getMessageStream(widget.groupId);
    });
    DatabaseService().getGroupAdmin(widget.groupId).then((val) {
      setState(() {
        admin = val;
      });
    });
  }

  void updateLastSeenMessage(String groupId, String messageId) async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('groups')
        .doc(groupId)
        .set({'lastSeenMessageId': messageId}, SetOptions(merge: true));
  }

  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        elevation: 0,
        title: Text(widget.groupName, style: const TextStyle(color: Colors.white)),
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return QuizScoresScreen(groupId: widget.groupId,);
              }));
            },
            icon: const Icon(Icons.score_outlined, color: Colors.white),
          ),
          IconButton(
            onPressed: () {
              nextScreen(context, GroupInfo(groupId: widget.groupId, groupName: widget.groupName, adminName: admin));
            },
            icon: const Icon(Icons.info, color: Colors.white),
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(child: ChatScreen(groupId: widget.groupId, userName: widget.userName, chats: chats, adminName: admin)),
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 18),
              width: MediaQuery.of(context).size.width,
              color: Colors.grey.withOpacity(0.8),
              child: Form(
                key: formKey,
                child: Column(
                  children: [
                    if (fileUrl.isNotEmpty)
                      Icon(Icons.file_open, color: Theme.of(context).primaryColor),
                    if (fileUrl.isNotEmpty)
                      const Text('File Uploaded! Enter title to send.'),
                    Row(children: [
                      InkWell(
                        onTap: () {
                          if (admin.split('_')[1].toString() == widget.userName.toLowerCase()) {
                            Navigator.push(context, MaterialPageRoute(builder: (context) {
                              return HomePageQuiz(groupId: widget.groupId);
                            }));
                          } else {
                            _attemptQuiz();
                          }
                        },
                        child: Image.asset('assets/quizIcon.png', color: Theme.of(context).primaryColor, height: 40),
                      ),
                      InkWell(
                        onTap: () async {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return const Center(child: CircularProgressIndicator());
                            },
                          );
                          var file = await DatabaseService().pickFileForUpload();
                          List<String> parts = file!.path.split('.');
                          String extension = parts.last;
                          setState(() {
                            fileExtension = extension;
                          });
                          var fileUrl = await DatabaseService().uploadFileToFirebaseStorage(file!);
                          setState(() {
                            this.fileUrl = fileUrl!;
                          });
                          Navigator.pop(context, false);
                        },
                        child: Image.asset('assets/upload_file_svg.png', height: 40, color: Theme.of(context).primaryColor),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: TextFormField(
                          scrollPhysics: const AlwaysScrollableScrollPhysics(),
                          controller: messageController,
                          minLines: 1,
                          maxLines: 5,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            errorMaxLines: 2,
                            hintText: "Send a message...",
                            hintStyle: const TextStyle(color: Colors.white, fontSize: 16),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30)
                            ),
                          ),
                          validator: validateMessage,
                        ),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: () {
                          if (formKey.currentState!.validate()) {
                            if (fileUrl.isEmpty) {
                              sendMessage('text');
                            } else {
                              sendMessage('file');
                            }
                          }
                        },
                        child: Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: const Center(
                            child: Icon(Icons.send, color: Colors.white),
                          ),
                        ),
                      ),
                    ]),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // sendMessage(String messageType) {
  //   if (messageController.text.isNotEmpty) {
  //     String messageId = FirebaseAuth.instance.currentUser!.uid + '_' + widget.userName;
  //     Map<String, dynamic> chatMessageMap = {
  //       'sender_id': FirebaseAuth.instance.currentUser!.uid.toString(),
  //       'message_id': messageId,
  //       'type': messageType,
  //       'fileUrl': fileUrl,
  //       'fileExtension': fileExtension,
  //       'message': messageController.text,
  //       'sender': widget.userName,
  //       'time': FieldValue.serverTimestamp(),
  //     };
  //     DatabaseService().sendMessage(widget.groupId, chatMessageMap);
  //     updateLastSeenMessage(widget.groupId, messageId);
  //     setState(() {
  //       messageController.clear();
  //       fileUrl = '';
  //     });
  //   }
  // }

  Future<void> sendMessage(String messageType) async {
    if (messageController.text.isNotEmpty) {
      String userId = FirebaseAuth.instance.currentUser!.uid;
      String userName = widget.userName;
      String groupId = widget.groupId;

      String messageId = userId + '_' + userName;
      Map<String, dynamic> chatMessageMap = {
        'sender_id': userId,
        'message_id': messageId,
        'type': messageType,
        'fileUrl': fileUrl,
        'fileExtension': fileExtension,
        'message': messageController.text,
        'sender': userName,
        'time': FieldValue.serverTimestamp(),
        'unread': true,
      };

      // Send message to Firestore
      await FirebaseFirestore.instance.collection('groups').doc(groupId).collection('messages').add(chatMessageMap);

      // Update last seen message for the sender
      updateLastSeenMessage(groupId, messageId);

      // Clear the message input field and reset file variables
      setState(() {
        messageController.clear();
        fileUrl = '';
      });

      // Get the group document
      DocumentSnapshot groupDoc = await FirebaseFirestore.instance.collection('groups').doc(groupId).get();

      if (groupDoc.exists && groupDoc['members'] != null) {
        List<dynamic> memberIds = groupDoc['members'];

        List<String> tokens = [];
        for (String memberId in memberIds) {
          if (memberId != userId) {
            DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(memberId).get();
            if (userDoc.exists && userDoc['fcmToken'] != null) {
              tokens.add(userDoc['fcmToken']);
            }
          }
        }

        // Send push notification
        // if (tokens.isNotEmpty) {
        //   await sendPushNotification(tokens, userName, messageController.text);
        // }
      }
    }
  }


  String? validateMessage(String? value) {
    var parser = EmojiParser();
    List<String> input = value!.split(' ');

    if (checkMsgProfanity(value)) {
      return 'Please avoid using bad/curse words.';
    } else if (value.isEmpty) {
      return 'Please Enter Message/File Title';
    } else if (parser.hasEmoji(value)) {
      return 'Emojis are not allowed';
    } else if (checkHasEmojis(value)) {
      return 'Emojis are not allowed';
    }
    for (var i in input) {
      if (parser.hasEmoji(i)) {
        return 'Emojis are not allowed';
      }
    }

    return null;
  }

  bool checkMsgProfanity(String message) {
    final filter = ProfanityFilter.filterAdditionally(customWords);
    return filter.hasProfanity(message);
  }

  bool checkHasEmojis(String string) {
    RegExp rx = RegExp(
        r'(\u00a9|\u00ae|[\u2000-\u3300]|\ud83c[\ud000-\udfff]|\ud83d[\ud000-\udfff]|\ud83e[\ud000-\udfff])');
    return rx.hasMatch(string);
  }

  Future<DocumentSnapshot?> getLatestActiveQuiz() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('groups')
          .doc(widget.groupId)
          .collection('quizzes')
          .where('status', isEqualTo: 'active')
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first;
      } else {
        // No active quiz found
        return null;
      }
    } catch (error) {
      // Handle errors
      print('Error fetching latest active quiz: $error');
      return null;
    }
  }

  Future<void> _attemptQuiz() async {
    try {
      DocumentSnapshot<Object?>? latestActiveQuiz = await getLatestActiveQuiz();
      if (latestActiveQuiz != null && latestActiveQuiz.exists) {
        Map<String, dynamic> quizDataMap = latestActiveQuiz.data() as Map<String, dynamic>;
        FlutterTopics quizData = FlutterTopics.fromMap(quizDataMap);
        String? userId = await getCurrentUserId();
        QuerySnapshot quizAttemptsSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('quiz_attempts')
            .where('quiz_topic', isEqualTo: quizData.topicName.toLowerCase())
            .get();

        if (quizAttemptsSnapshot.docs.isNotEmpty) {
          Fluttertoast.showToast(msg: 'You have already attempted this quiz!', backgroundColor: Colors.red);
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => QuizScreen(
                topicType: quizData.topicName,
                questionlenght: quizData.topicQuestions,
                optionsList: quizData.topicQuestions.map((question) => question.options).toList(), groupId: widget.groupId,
              ),
            ),
          );
        }
      } else {
        Fluttertoast.showToast(msg: 'No Quiz Started yet!');
      }
    } catch (error) {
      // Handle errors
    }
  }

  Future<String> getCurrentUserId() async {
    return FirebaseAuth.instance.currentUser!.uid;
  }
}

// Future<void> sendPushNotification(List<String> tokens, String title, String body) async {
//   const String serverKey = '5ec9224165afe44922a45db1a0c370dedc6d7329'; // Replace with your FCM server key
//
//   final headers = {
//     'Content-Type': 'application/json',
//     'Authorization': 'key=$serverKey',
//   };
//
//   final payload = {
//     'registration_ids': tokens,
//     'notification': {
//       'title': title,
//       'body': body,
//     },
//   };
//
//   final response = await http.post(
//     Uri.parse('https://fcm.googleapis.com/fcm/send'),
//     headers: headers,
//     body: json.encode(payload),
//   );
//
//   if (response.statusCode != 200) {
//     print('Failed to send notification: ${response.body}');
//   }
// }