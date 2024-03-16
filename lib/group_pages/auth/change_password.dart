import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:studybuddyapp/service/auth_service.dart';

import '../../widgets/widgets.dart';

class ChangePasswordSheet extends StatefulWidget {
  const ChangePasswordSheet({super.key});

  @override
  State<ChangePasswordSheet> createState() => _ChangePasswordSheetState();
}

class _ChangePasswordSheetState extends State<ChangePasswordSheet> {
  String? oldPassword;
  String? newPassword;
  bool verified = false;
  TextEditingController oldPasswordController = TextEditingController();

  bool hidePassword=true;
  bool hidePassword1=true;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Change Password',
                style: TextStyle(fontSize: 14),
              ),
              IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.keyboard_arrow_down_sharp))
            ],
          ),
        ),
        const Divider(
          height: 20,
          thickness: 0.5,
        ),
        const SizedBox(
          height: 20,
        ),
        const Text(
          'Enter your old password for verification.',
          style: TextStyle(fontSize: 14),
        ),
        const SizedBox(
          height: 20,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: TextFormField(
            obscureText: hidePassword,
            controller: oldPasswordController,
            decoration: textInputDecoration.copyWith(
                suffixIcon: IconButton(
                    onPressed: ()=>setState(() {
                      hidePassword=!hidePassword;
                    }), icon: const Icon(Icons.remove_red_eye,color: Colors.black,)),
                labelText: "Old Password",
                hintText: "Enter your Password",
                prefixIcon: Icon(
                  Icons.lock,
                  color: Theme.of(context).primaryColor,
                )),
            validator: (val) {
              if (val!.length < 6) {
                return "Password must be at least 6 characters";
              } else if (val.isEmpty) {
                return 'Enter Password';
              } else {
                return null;
              }
            },
            onChanged: (val) {
              setState(() {
                oldPassword = val;
              });
            },
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30))),
          child: const Text(
            "Verify",
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          onPressed: () async {
            showDialog(context: context, builder: (context){
              return const Center(child: CircularProgressIndicator());
            });
            await AuthService()
                .verifyUser(oldPassword.toString())
                .then((value) {
                  Navigator.pop(context);
              setState(() {
                if (value) {
                  oldPasswordController.clear();
                }
                verified = value;
              });
            });
          },
        ),
        const SizedBox(
          height: 10,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: GestureDetector(
            onTap: () {
              if (!verified) {
                Fluttertoast.showToast(
                    msg: 'Please Verify old password to continue!',
                    backgroundColor: Colors.red,
                    toastLength: Toast.LENGTH_LONG);
              }
            },
            child: TextFormField(
              obscureText: hidePassword1,
              enabled: verified,
              decoration: textInputDecoration.copyWith(
                  suffixIcon: IconButton(
                      onPressed: ()=>setState(() {
                        hidePassword1=!hidePassword1;
                      }), icon: const Icon(Icons.remove_red_eye,color: Colors.black,)),
                  labelText: "New Password",
                  hintText: "Enter your Password",
                  prefixIcon: Icon(
                    Icons.lock,
                    color: Theme.of(context).primaryColor,
                  )),
              validator: (val) {
                if (val!.length < 6) {
                  return "Password must be at least 6 characters";
                } else if(val.isEmpty) {
                  return "Enter Password";
                }
                else {
                  return null;
                }
              },
              onChanged: (val) {
                setState(() {
                  newPassword = val;
                });
              },
            ),
          ),
        ),
        verified
            ? ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30))),
                child: const Text(
                  "Change Password",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                onPressed: () async {
                  showDialog(context: context, builder: (context){
                    return const Center(child: CircularProgressIndicator());
                  });
                  await AuthService()
                      .updatePassword(newPassword.toString(),oldPassword.toString())
                      .then((value) {
                        Navigator.pop(context);
                        Navigator.pop(context);
                  });
                },
              )
            : const SizedBox(),
      ],
    );
  }
}
