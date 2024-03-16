import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:studybuddyapp/widgets/drawer.dart';
import '../../shared/colors.dart';
import '../widgets/stream_note.dart';
import 'add_note_screen.dart';

class Scheduler extends StatefulWidget {
  const Scheduler({super.key});

  @override
  State<Scheduler> createState() => _SchedulerState();
}

bool show = true;



class _SchedulerState extends State<Scheduler> {

  @override
  void initState() {
    // TODO: implement initState
    initializeValue();
    super.initState();
  }
  bool isNotDone=false;
  initializeValue()async{
    var value= await checkIfAnyNoteIsNotDone(FirebaseAuth.instance.currentUser!.uid);
    setState(() {
      isNotDone=value;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text("Schedule Task",style: TextStyle(
            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 27),),
      ),
      drawer: MyDrawer(selected: 'scheduler',),
      backgroundColor: backgroundColors,
      floatingActionButton: Visibility(
        visible: show,
        child: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) =>  Add_creen(onAdd: (){
                setState(() {
                });
              },),
            ));
          },
          backgroundColor: Theme.of(context).primaryColor,
          child: const Icon(
            Icons.add,
            color: Colors.white,
            size: 30,
          ),
        ),
      ),
      body: SafeArea(
        child: NotificationListener<UserScrollNotification>(
          onNotification: (notification) {
            if (notification.direction == ScrollDirection.forward) {
              setState(() {
                show = true;
              });
            }
            if (notification.direction == ScrollDirection.reverse) {
              setState(() {
                show = false;
              });
            }
            return true;
          },
          child:isNotDone?
          Stream_note(false): Center(
            child: Text(
              'No Task Scheduled Yet!',
              style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.bold),
            ),
          )
        ),
      ),
    );
  }
  Future<bool> checkIfAnyNoteIsNotDone(String userId) async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('notes')
          .where('isDone', isEqualTo: false)
          .get();

      // Check if any documents with 'isDone' set to true exist
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error checking notes: $e');
      return false; // Return false in case of any error
    }
  }
}
