import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:studybuddyapp/service/admin_controls.dart';
import 'package:studybuddyapp/service/database_service.dart';
import 'package:studybuddyapp/widgets/widgets.dart';

import 'home_page.dart';

class GroupInfo extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String adminName;
  const GroupInfo(
      {Key? key,
      required this.adminName,
      required this.groupName,
      required this.groupId})
      : super(key: key);

  @override
  State<GroupInfo> createState() => _GroupInfoState();
}

class _GroupInfoState extends State<GroupInfo> {
  Stream? members;
  var users;

  bool userIsAdmin=false;
  @override
  void initState() {
    super.initState();
    getMembers();
    checkIsUserAdmin();
  }

  getMembers() async {
    DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
        .getGroupMembers(widget.groupId)
        .then((val) {
      setState(() {
        members = val;
      });
    });
  }

  String getName(String r) {
    return r.substring(r.indexOf("_") + 1);
  }

  String getId(String res) {
    return res.substring(0, res.indexOf("_"));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text("Group Info"),
        actions: [
         userIsAdmin? IconButton(onPressed: () {
         showModalBottomSheet(context: context, builder: (context){
           return Column(
             children: [
               IntlPhoneField(
                 onChanged: (query) async {
                   // print("query${query!.completeNumber}");
                   if (query.isValidNumber()) {
                     QuerySnapshot searchedUsers =
                     await Admin().searchMember(query.completeNumber);
                     print(searchedUsers.docs.length);
                     print(searchedUsers.docs[0]['fullName']);

                     if (searchedUsers.docs.isNotEmpty) {
                       setState(() {
                         users = searchedUsers;
                       });
                       setState(() {
                       });
                     } else {
                       Fluttertoast.showToast(msg: 'User not found!');
                     }
                   }
                 },
                 initialCountryCode: 'PK',
                 decoration: InputDecoration(
                   suffixIcon: IconButton(onPressed: ()=>setState(() {

                   }), icon: const Icon(Icons.search)),
                   labelText: "Phone Number",
                 ),
               ),
               users != null
                   ? ListTile(
                 onTap: () {
                   // DatabaseService service=DatabaseService();
                   // service.toggleGroupJoin(widget.groupId, users.docs[0]['fullName'], widget.groupName);
                   //
                   Admin().addMember(users.docs[0]['uid'], context,
                       widget.groupId, users.docs[0]['fullName'],widget.groupName);
                   Navigator.pop(context);
                 },
                 title: Text(
                   users.docs[0]['fullName'].toString(),
                   style: const TextStyle(fontSize: 13),
                 ),
               )
                   : const SizedBox(),
             ],
           );
         });
          }, icon: const Icon(Icons.person_add_alt)):const SizedBox(),
          IconButton(
              onPressed: () {
                showDialog(
                    barrierDismissible: false,
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text("Exit"),
                        content:
                            const Text("Are you sure you exit the group? "),
                        actions: [
                          IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: const Icon(
                              Icons.cancel,
                              color: Colors.red,
                            ),
                          ),
                          IconButton(
                            onPressed: () async {
                              DatabaseService(
                                      uid: FirebaseAuth
                                          .instance.currentUser!.uid)
                                  .toggleGroupJoin(
                                      widget.groupId,
                                      getName(widget.adminName),
                                      widget.groupName)
                                  .whenComplete(() {
                                nextScreenReplace(context, const HomePage());
                              });
                            },
                            icon: const Icon(
                              Icons.done,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      );
                    });
              },
              icon: const Icon(Icons.exit_to_app))
        ],
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: Theme.of(context).primaryColor.withOpacity(0.2)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Theme.of(context).primaryColor,
                    child: Text(
                      widget.groupName.substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                          fontWeight: FontWeight.w500, color: Colors.white),
                    ),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Group: ${widget.groupName}",
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Text("Admin: ${getName(widget.adminName)}")
                    ],
                  )
                ],
              ),
            ),
            memberList(),
          ],
        ),
      ),
    );
  }

  memberList() {
    return StreamBuilder(
      stream: members,
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data['members'] != null) {
            if (snapshot.data['members'].length != 0) {
              return ListView.builder(
                itemCount: snapshot.data['members'].length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                    child: ListTile(
                      onLongPress: (){
                        showDialog(context: context, builder: (context){
                          return  AlertDialog(
                            content: const Text('Do you want to remove this member'),
                            title: const Text('Remove Member'),
                            actions: [
                              TextButton(onPressed: (){
                                if(userIsAdmin) {
                                  Admin().removeMember(getId(snapshot.data['members'][index]), widget.groupId, context, getName(snapshot.data['members'][index]), widget.groupName);
                                }
                                else{
                                  Fluttertoast.showToast(msg: 'You cant remove member because you are not admin!',backgroundColor: Colors.red);
                                }
                              }, child: const Text('Yes')),
                              TextButton(onPressed: (){
                                Navigator.pop(context);
                              }, child: const Text('No')),
                            ],
                          );
                        });
                      },
                      leading: CircleAvatar(
                        radius: 30,
                        backgroundColor: Theme.of(context).primaryColor,
                        child: Text(
                          getName(snapshot.data['members'][index])
                              .substring(0, 1)
                              .toUpperCase(),
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      title: Text(getName(snapshot.data['members'][index])),
                      subtitle: Text(getId(snapshot.data['members'][index])
                      ),
                    ),
                  );
                },
              );
            } else {
              return const Center(
                child: Text("NO MEMBERS"),
              );
            }
          } else {
            return const Center(
              child: Text("NO MEMBERS"),
            );
          }
        } else {
          return Center(
              child: CircularProgressIndicator(
            color: Theme.of(context).primaryColor,
          ));
        }
      },
    );
  }


  checkIsUserAdmin()async{
    final store=FirebaseFirestore.instance;
    var user=await store.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).get();
    var admin=await store.collection('groups').doc(widget.groupId).get();
    var userName=FirebaseAuth.instance.currentUser!.uid+'_'+user.get('fullName').toString().toLowerCase();
    print('username'+userName);
    print('admin name ${admin.get('admin')}');
    if(userName==admin.get('admin')){
      setState(() {
        userIsAdmin= true;
        print("${userIsAdmin}user is admin");
      });
    }
    else{
      setState(() {
        userIsAdmin= false;
        print("${userIsAdmin}user is admin");
      });
    }
  }
}
