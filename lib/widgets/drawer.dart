import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:studybuddyapp/widgets/widgets.dart';
import '../group_pages/auth/login_page.dart';
import '../group_pages/home_page.dart';
import '../group_pages/profile_page.dart';
import '../scheduler/screen/scheduler.dart';
import '../service/auth_service.dart';

class MyDrawer extends StatefulWidget {
    MyDrawer({super.key,required this.selected});

   String? userName ;
   final String selected ;

  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  AuthService authService = AuthService();
  bool groupSelected=false;
  bool profileSelected=false;
  bool schedulerSelected=false;

  String email='';
  String userName='';
  String profilePicUrl='';

  getProfilePic()async{
    var pp=await authService.getProfilePic();
    setState(() {
      profilePicUrl=pp;
    });
  }
  gettingUserData() async {
    var userId=FirebaseAuth.instance.currentUser!.uid;
    if(FirebaseAuth.instance.currentUser!=null){
      var data=await FirebaseFirestore.instance.collection('users').doc(userId).get();
      setState(() {
        email=data['email'];
        userName=data['fullName'];
      });
    }
  }
  selectValue(){
    switch(widget.selected){
      case 'profile':
        setState(() {
          profileSelected=true;
        });
        break;
      case 'groups':
        setState(() {
          groupSelected=true;
        });
        break;
        case 'scheduler':
        setState(() {
          schedulerSelected=true;
        });
        break;
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    selectValue();
    gettingUserData();
    getProfilePic();
  }
  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 50),
          children: <Widget>[
            profilePicUrl!=''?
            Container(
              clipBehavior: Clip.antiAlias,
              height: 100,
              width: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.withOpacity(0.4),
                image: DecorationImage(
                  image: NetworkImage(profilePicUrl),
                  fit: BoxFit.contain
                ),
              ),
            )
            : Icon(
              Icons.account_circle,
              size: 150,
              color: Colors.grey[700],
            ),
            const SizedBox(
              height: 15,
            ),
            Text(
              userName,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 30,
            ),
            const Divider(
              height: 2,
            ),
            ListTile(
              onTap: () {
                if(widget.selected!='groups') {
                  nextScreen(context, const HomePage());
                }
              },
              selected: groupSelected,
              selectedColor: Theme.of(context).primaryColor,
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              leading: const Icon(Icons.group),
              title: const Text(
                "Groups",
                style: TextStyle(color: Colors.black),
              ),
            ),
            ListTile(
              onTap: () {
                if(widget.selected!='profile') {
                  nextScreen(context, ProfilePage(email: email, userName: userName));
                }
              },
              selected: profileSelected,
              selectedColor: Theme.of(context).primaryColor,
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              leading: const Icon(Icons.group),
              title: const Text(
                "Profile",
                style: TextStyle(color: Colors.black),
              ),
            ),
            ListTile(
              onTap: () {
                if(widget.selected!='scheduler'){
                  nextScreen(context, const Scheduler());
                }
              },
              selected: schedulerSelected,
              selectedColor: Theme.of(context).primaryColor,
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              leading: const Icon(Icons.schedule),
              title: const Text(
                "Scheduler",
                style: TextStyle(color: Colors.black),
              ),
            ),
            ListTile(
              onTap: () async {
                showDialog(
                    barrierDismissible: false,
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text("Logout"),
                        content: const Text("Are you sure you want to logout?"),
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
                              await authService.signOut();
                              Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                      builder: (context) => const LoginPage()),
                                      (route) => false);
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
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              leading: const Icon(Icons.exit_to_app),
              title: const Text(
                "Logout",
                style: TextStyle(color: Colors.black),
              ),
            )
          ],
        ));
  }
}
