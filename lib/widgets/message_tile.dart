import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:studybuddyapp/scheduler/screen/scheduler.dart';
import 'package:studybuddyapp/service/database_service.dart';

class MessageTile extends StatefulWidget {
  final String message;
  final String sender;
  final String groupId;
  final String messageType;
  final bool sentByMe;
  final String fileUrl;
  final String admin;
  final String fileExtension;
  final String senderId;
  final DateTime time;

  const MessageTile(
      {Key? key,
      required this.message,
      required this.sender,
      required this.sentByMe,
      required this.messageType,
      required this.fileUrl,
      required this.groupId, required this.admin, required this.fileExtension, required this.time, required this.senderId})
      : super(key: key);

  @override
  State<MessageTile> createState() => _MessageTileState();
}

class _MessageTileState extends State<MessageTile> {
  String? userName;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: ()async{
        if(widget.fileUrl!=''){
          showDialog(context: context, builder: (context){
            return const Center(child: CircularProgressIndicator(),);
          });
          await DatabaseService().downloadFileFromFirebaseStorage(
              widget.fileUrl, widget.message,widget.fileExtension);
          Navigator.pop(context);
        }
      },
      onLongPress: ()async {
        bool value=await checkIsUserAdmin();
        print("is user admin"+value.toString());
       if (widget.sentByMe) {
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text("Delete Message"),
                  content: const Text("Do you want to delete this message?"),
                  actions: [
                    TextButton(
                        onPressed: () {
                          FirebaseFirestore.instance
                              .collection('groups')
                              .doc(widget.groupId)
                              .collection('messages')
                              .where('sender_id',
                                  isEqualTo:
                                      FirebaseAuth.instance.currentUser!.uid)
                              .where('message')
                              .get()
                              .then((value) {
                            Navigator.pop(context);
                            value.docs.forEach((msg) {
                              if (msg['message'] == widget.message) {
                                msg.reference.delete().then((value) {
                                  print('delete status true');
                                  Fluttertoast.showToast(
                                      msg: 'Message deleted successfully!',
                                      backgroundColor: Colors.green);

                                });
                              }

                            });
                          });
                        },
                        child: const Text('Yes')),
                    TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('No')),
                  ],
                );
              });
        }
       else if(await checkIsUserAdmin()){
         showDialog(
             context: context,
             builder: (context) {
               return AlertDialog(
                 title: const Text("Delete Message"),
                 content: const Text("Do you want to delete this message?"),
                 actions: [
                   TextButton(
                       onPressed: () {
                         FirebaseFirestore.instance
                             .collection('groups')
                             .doc(widget.groupId)
                             .collection('messages')
                             .where('sender_id',
                             isEqualTo:widget.senderId)
                             .where('message')
                             .get()
                             .then((value) {
                           Navigator.pop(context);
                           value.docs.forEach((msg) {
                             if (msg['message'] == widget.message) {
                               msg.reference.delete().then((value) {
                                 Fluttertoast.showToast(
                                     msg: 'Message deleted successfully!',
                                     backgroundColor: Colors.green);
                               });
                             }
                           });
                         });
                       },
                       child: const Text('Yes')),
                   TextButton(
                       onPressed: () {
                         Navigator.pop(context);
                       },
                       child: const Text('No')),
                 ],
               );
             });
       }

      },
      child: Container(
        padding: EdgeInsets.only(
            top: 4,
            bottom: 4,
            left: widget.sentByMe ? 0 : 24,
            right: widget.sentByMe ? 24 : 0),
        alignment:
            widget.sentByMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: widget.sentByMe
              ? const EdgeInsets.only(left: 30)
              : const EdgeInsets.only(right: 30),
          padding:
              const EdgeInsets.only(top: 17, bottom: 17, left: 20, right: 20),
          decoration: BoxDecoration(
              borderRadius: widget.sentByMe
                  ? const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                      bottomLeft: Radius.circular(20),
                    )
                  : const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
              color: widget.sentByMe
                  ? Theme.of(context).primaryColor
                  : Colors.grey[700]),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.sender.toUpperCase(),
                textAlign: TextAlign.start,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: -0.5),
              ),
              const SizedBox(
                height: 8,
              ),
              if (widget.messageType == 'file')
                IconButton(
                  onPressed: () async {
                    showDialog(context: context, builder: (context){
                      return const Center(child: CircularProgressIndicator(),);
                    });
                    await DatabaseService().downloadFileFromFirebaseStorage(
                        widget.fileUrl, widget.message,widget.fileExtension);
                    Navigator.pop(context);
                  },
                  icon:  const Icon(Icons.file_download,color:Colors.white,size: 30,),
                ),
              Text(widget.message,
                  textAlign: TextAlign.start,
                  style: const TextStyle(fontSize: 12, color: Colors.white)),
              Container(
                width: MediaQuery.sizeOf(context).width*0.2,
                alignment: Alignment.bottomRight,
                child:  Text("${widget.time.hour}:${widget.time.minute}"),
              )
            ],
          ),
        ),
      ),
    );
  }
  gettingUserData() async {
    var userId=FirebaseAuth.instance.currentUser!.uid;
    if(FirebaseAuth.instance.currentUser!=null){
      var data=await FirebaseFirestore.instance.collection('users').doc(userId).get();
      setState(() {
        userName=data['fullName'];
      });
    }
  }
  Future<bool> checkIsUserAdmin()async{
    await gettingUserData();
    bool flag= widget.admin.split('_')[1].toString()==userName!.toLowerCase();
    return flag;
  }
}
