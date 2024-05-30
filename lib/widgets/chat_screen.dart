import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'message_tile.dart';


class ChatScreen extends StatefulWidget {
   ChatScreen(
      {super.key,
      required this.groupId,
      required this.userName,
      required this.chats,
      required this.adminName});
  final String groupId;
  String userName;
  final String adminName;
  final chats;
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _showFloatingButton = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.offset >=
        _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      // Reached the bottom
      setState(() {
        _showFloatingButton = false;
      });
    } else {
      setState(() {
        _showFloatingButton = true;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton:
      _showFloatingButton?
      FloatingActionButton.small(

        onPressed: () {
          // Scroll to the bottom of the list
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        },
        child: const Icon(Icons.arrow_downward),
      ):null,
      body: Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
        child: StreamBuilder(
          stream: widget.chats,
          builder: (context, AsyncSnapshot snapshot) {
            if (snapshot.data == null) {
              return const Center(child: CircularProgressIndicator());
            } else {
              return snapshot.data.docs.length > 0
                  ? ListView.builder(
                      controller: _scrollController,
                      itemCount: snapshot.data.docs.length,
                      itemBuilder: (context, index) {
                        return MessageTile(
                          time: snapshot.data.docs[index]['time'].toDate(),
                          admin: widget.adminName,
                          fileUrl: snapshot.data.docs[index]['fileUrl'],
                          groupId: widget.groupId,
                          fileExtension: snapshot.data.docs[index]
                              ['fileExtension'],
                          message: snapshot.data.docs[index]['message'],
                          sender: snapshot.data.docs[index]['sender'],
                          sentByMe: widget.userName ==
                              snapshot.data.docs[index]['sender'],
                          senderId:snapshot.data.docs[index]['sender_id'],
                          messageType: snapshot.data.docs[index]['type'],
                        );
                      },
                    )
                  : Center(
                      child: Text(
                        'No Messages Yet!',
                        style: TextStyle(color: Theme.of(context).primaryColor),
                      ),
                    );
            }
          },
        ),
      ),
    );
  }

}
