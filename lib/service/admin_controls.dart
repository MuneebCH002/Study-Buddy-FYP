import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:studybuddyapp/service/database_service.dart';

class Admin{

  void addMember(String memberId,BuildContext context,String groupId,String memberName,String groupName) async{
  print('member id $memberId');
    var groupData=await FirebaseFirestore.instance.collection('groups').doc(groupId).get();
    
  if(!groupData.get('members').contains('${memberId}_$memberName')){
    await FirebaseFirestore.instance.collection('users').doc(memberId).update({
      'groups':FieldValue.arrayUnion(['${groupId}_$groupName'])
    });
    await FirebaseFirestore.instance
        .collection('groups')
        .doc(groupId)
        .update({
      'members': FieldValue.arrayUnion(['${memberId}_$memberName'])
    }).then((_) {
     Fluttertoast.showToast(msg: 'Member added successfully!',backgroundColor: Colors.green,toastLength: Toast.LENGTH_LONG);
    }).catchError((error) {
      Fluttertoast.showToast(msg: 'Failed to add member: $error',backgroundColor: Colors.red,toastLength: Toast.LENGTH_LONG);
      print("Failed to add member: $error");
    });
  }
  else{
    Fluttertoast.showToast(msg: 'Member Already Added!',backgroundColor: Colors.red,toastLength: Toast.LENGTH_LONG);
  }
  }

  void removeMember(String memberId,String groupId,BuildContext context,String memberName,String groupName )async {
    await FirebaseFirestore.instance.collection('users').doc(memberId).update({
      'groups': FieldValue.arrayRemove(['${groupId}_$groupName'])
    });
   await FirebaseFirestore.instance
        .collection('groups')
        .doc(groupId)
        .update({
      'members': FieldValue.arrayRemove([memberId+'_'+memberName])
    }).then((_) {
      Navigator.pop(context);
     Fluttertoast.showToast(msg: 'Member removed successfully',backgroundColor: Colors.green,toastLength: Toast.LENGTH_LONG);
    }).catchError((error) {
      Fluttertoast.showToast(msg: 'Failed to remove member: $error',backgroundColor: Colors.red,toastLength: Toast.LENGTH_LONG);
      Navigator.pop(context);
    });
  }

   searchMember(String query) async{
    try{
    var member=await FirebaseFirestore.instance
        .collection('users').where('phoneNum',isEqualTo: query)
        .get();

    return member;
  }
  catch(e){
      if(e is FirebaseException){
        print(e.code);
      }
  }
  }

}