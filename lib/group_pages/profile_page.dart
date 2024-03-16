import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:studybuddyapp/service/auth_service.dart';
import 'package:studybuddyapp/widgets/drawer.dart';

import 'auth/change_password.dart';

// ignore: must_be_immutable
class ProfilePage extends StatefulWidget {
  String userName;
  String email;

  ProfilePage({Key? key, required this.email, required this.userName})
      : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  AuthService authService = AuthService();
  String profilePic='';
  getProfilePic()async{
    var pp=await authService.getProfilePic();
    setState(() {
      profilePic=pp;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    getProfilePic();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
        title: const Text(
          "Profile",
          style: TextStyle(
              color: Colors.white, fontSize: 27, fontWeight: FontWeight.bold),
        ),
      ),
      drawer: MyDrawer(selected: 'profile',),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 170),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Stack(
              children: [
               profilePic!=''?
               Container(
                 clipBehavior: Clip.antiAlias,
                 height: 180,
                 width: 180,
                 decoration: BoxDecoration(
                   shape: BoxShape.circle,
                   color: Colors.grey.withOpacity(0.4),
                   image: DecorationImage(
                       image: NetworkImage(profilePic),
                       fit: BoxFit.contain
                   ),
                 ),
               )
                   : Icon(
                  Icons.account_circle,
                  size: 200,
                  color: Colors.grey[700],
                ),
                Positioned(
                    bottom: 0,
                    right: 20,
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: Colors.grey.withOpacity(profilePic!=''?0.8:0.2)),
                      child: IconButton(
                        onPressed: () async{
                          showDialog(context: context, builder: (context){return const Center(child: CircularProgressIndicator());});
                          var image= await authService.getImage();
                          var url= await authService.uploadImage(image);
                          await authService.updateProfile(url).then((value) {
                            Navigator.pop(context);
                            Fluttertoast.showToast(msg: 'Profile Picture Updated Successfully',backgroundColor: Colors.green);
                          }).catchError((error){
                            if(error is FirebaseException){
                              print(error.code);
                              Fluttertoast.showToast(msg: error.code,backgroundColor: Colors.red);
                            }
                          });
                        },
                        icon: const Icon(
                          Icons.edit,
                          color: Colors.black,
                        ),
                      ),
                    ))
              ],
            ),
            const SizedBox(
              height: 15,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Full Name", style: TextStyle(fontSize: 17)),
                Text(widget.userName, style: const TextStyle(fontSize: 17)),
              ],
            ),
            const Divider(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Email", style: TextStyle(fontSize: 17)),
                Text(widget.email, style: const TextStyle(fontSize: 17)),
              ],
            ),
            const Divider(
              height: 20,
            ),
            Container(
                width: MediaQuery.sizeOf(context).width,
                alignment: Alignment.center,
                child: TextButton(
                    onPressed: () {
                   showModalBottomSheet(context: context, builder: (context){
                     return const ChangePasswordSheet();
                   });
                    },
                    child: const Text(
                      'Change Password',
                      style: TextStyle(fontSize: 17),
                    )))
          ],
        ),
      ),
    );
  }
}
