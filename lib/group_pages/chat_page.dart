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
import '../views/quiz_screen.dart';
import '../widgets/chat_screen.dart';

class ChatPage extends StatefulWidget {
  final String groupId;
  final String groupName;
   String userName;
   ChatPage(
      {Key? key,
      required this.groupId,
      required this.groupName,
      required this.userName})
      : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  Stream<QuerySnapshot>? chats;
  TextEditingController messageController = TextEditingController();
  String admin = "";
  final formKey = GlobalKey<FormState>();

  String fileUrl='';
  String fileExtension='';
  String messageType='';
  // int _maxLines = 1;

  List<String> customWords=['love','idiot','bastard','moron','donkey','hate','fool','mingle','movie','noodles','distraction','diversion'];

  @override
  void initState() {
    getChatandAdmin();
    super.initState();
  }

  getChatandAdmin(){
    setState(() {
      chats=DatabaseService().getMessageStream(widget.groupId);
      // print(DatabaseService().getMessageStream(widget.groupId))
    });
    DatabaseService().getGroupAdmin(widget.groupId).then((val) {
      setState(() {
        admin = val;
      });
    });
  }
  final ScrollController _scrollController = ScrollController();


  @override
  Widget build(BuildContext context) {
    return Scaffold(

      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,color: Colors.white,), onPressed: () {
            Navigator.pop(context);
        },
        ),
        centerTitle: true,
        elevation: 0,
        title: Text(widget.groupName,style: const TextStyle(
          color: Colors.white
        ),),
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          IconButton(onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context){
              return QuizScoresScreen();
            }));
          }, icon: const Icon(Icons.score_outlined,color: Colors.white,)),
          IconButton(
              onPressed: () {
                nextScreen(
                    context,
                    GroupInfo(
                      groupId: widget.groupId,
                      groupName: widget.groupName,
                      adminName: admin,
                    ));
              },
              icon: const Icon(Icons.info,color: Colors.white,)),
        ],
      ),
      body: Column(
        children: <Widget>[
          // chat messages here
          Expanded(child: ChatScreen(groupId: widget.groupId, userName: widget.userName, chats: chats,adminName:admin)),
          // chatMessages(),
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Container(
              // height: fileUrl==''?MediaQuery.sizeOf(context).height*0.18:MediaQuery.sizeOf(context).height*0.2,
              padding:
              const EdgeInsets.symmetric(horizontal: 5, vertical: 18),
              width: MediaQuery.of(context).size.width,
              color: Colors.grey.withOpacity(0.8 ),
              child: Form(
                key: formKey,
                child: Column(
                  children: [
                    if(fileUrl!='')
                       Icon(Icons.file_open,color: Theme.of(context).primaryColor,),
                    if(fileUrl!='')
                      const Text('File Uploaded! Enter title to send.'),
                    Row(children: [
                        InkWell(onTap:(){
                          if(admin.split('_')[1].toString()==widget.userName.toLowerCase()) {
                            Navigator.push(context, MaterialPageRoute(builder: (context){
                              return  HomePageQuiz(groupId: widget.groupId,);
                            }));
                          }
                          else{
                            _attemptQuiz();
                          }
                        } , child:Image.asset('assets/quizIcon.png',color: Theme.of(context).primaryColor,height: 40,)),
                      InkWell(onTap: ()async{
                        showDialog(context: context, builder: (context){
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        });
                        var file=await DatabaseService().pickFileForUpload();
                        List<String> parts = file!.path.split('.');
                        String extension = parts.last;
                        setState(() {
                          fileExtension=extension;
                        });
                        var fileUrl=await DatabaseService().uploadFileToFirebaseStorage(file!);
                       setState(() {
                         this.fileUrl=fileUrl!;
                       });
                       Navigator.pop(context,false);
                      }, child: Image.asset('assets/upload_file_svg.png',height: 40,color:Theme.of(context).primaryColor,)),
                      const SizedBox(width: 5,),
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
                            hintStyle: const TextStyle(color: Colors.white, fontSize: 16,),
                            border:OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30)
                            ),
                          ),
                          validator: validateMessage,
                        ),
                      ),
                      const SizedBox(
                        width: 12,
                      ),
                      GestureDetector(
                        onTap: () {
                          if (formKey.currentState!.validate()) {
                            if(fileUrl.isEmpty) {
                              sendMessage('text');
                            }
                            else{
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
                              child: Icon(
                                Icons.send,
                                color: Colors.white,
                              )),
                        ),
                      )
                    ]),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }


  sendMessage(messageType) {
    if (messageController.text.isNotEmpty) {
      Map<String, dynamic> chatMessageMap = {
        'sender_id':FirebaseAuth.instance.currentUser!.uid.toString(),
        'message_id':'${FirebaseAuth.instance.currentUser!.uid}_${widget.userName}',
        'type':messageType,
        'fileUrl':fileUrl,
        'fileExtension':fileExtension,
        "message": messageController.text,
        "sender": widget.userName,
        "time": DateTime.timestamp(),
      };
      DatabaseService().sendMessage(widget.groupId, chatMessageMap);
      setState(() {
        messageController.clear();
        fileUrl='';
      });
    }
    // else if(messageController.text.isEmpty){
    //   Map<String, dynamic> chatMessageMap = {
    //     'sender_id':FirebaseAuth.instance.currentUser!.uid.toString(),
    //     'message_id':'${FirebaseAuth.instance.currentUser!.uid}_${widget.userName}',
    //     'type':'file',
    //     'fileUrl':fileUrl,
    //     "message": messageController.text,
    //     "sender": widget.userName,
    //     "time": DateTime.timestamp(),
    //   };
    //
    //   DatabaseService().sendMessage(widget.groupId, chatMessageMap);
    //   setState(() {
    //     messageController.clear();
    //     fileUrl='';
    //   });
    // }
  }

  String? validateMessage(String? value) {
    var parser = EmojiParser();
    List input=value!.split(' ');

    if (checkMsgProfanity(value.toString())) {
      return 'Please avoid using bad/curse words.';
    }
    else if(value.isEmpty){
      return 'Please Enter Message/File Title';
    }
    else if(parser.hasEmoji(value)) {
      return 'Emojis are not allowed';
    }
    else if(checkHasEmojis(value)){
      return 'Emojis are not allowed';
    }
    for(var i in input) {
      if (parser.hasEmoji(i)) {
        return 'Emojis are not allowed';
      }
    }

    return null;
  }

  bool checkMsgProfanity(String message){
    final filter=ProfanityFilter.filterAdditionally(customWords);
    if(filter.hasProfanity(message)){
      return true;
    }
    else {
      return false;
    }
  }

  bool checkHasEmojis(string){
    RegExp rx =  RegExp(
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
      // Get the current user's ID (assuming you have implemented user authentication)



          // The user has not attempted the quiz yet
          DocumentSnapshot<Object?>? latestActiveQuiz = await getLatestActiveQuiz();
          if (latestActiveQuiz != null) {
            if (latestActiveQuiz.exists) {
              Map<String, dynamic> quizDataMap = latestActiveQuiz.data() as Map<String, dynamic>;
              FlutterTopics quizData = FlutterTopics.fromMap(quizDataMap);
              String? userId = getCurrentUserId().toString(); // Implement this function to get the current user's ID

              QuerySnapshot quizAttemptsSnapshot = await FirebaseFirestore.instance
                  .collection('users')
                  .doc(userId)
                  .collection('quiz_attempts')
                  .where('topicName', isEqualTo:quizData.topicName ) // Replace 'your_quiz_topic' with the actual quiz topic
                  .get();
              // Navigate to the quiz screen
              if (quizAttemptsSnapshot.docs.isNotEmpty) {
                // The user has already attempted the quiz
                Fluttertoast.showToast(msg: 'You have already attempted this quiz!',backgroundColor: Colors.red);
              }
              else {
                Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => QuizScreen(
                    topicType: quizData.topicName,
                    questionlenght: quizData.topicQuestions,
                    optionsList: quizData.topicQuestions.map((question) => question.options).toList(),
                  ),
                ),
              );
              }
            } else {
              Fluttertoast.showToast(msg: 'No Quiz Started yet!');
            }
          }

    } catch (error) {
      // Handle errors
    }
  }

  Future<String> getCurrentUserId()async{
    return FirebaseAuth.instance.currentUser!.uid;
  }



}
