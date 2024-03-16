import 'package:flutter/material.dart';
import 'package:studybuddyapp/helper/helper_function.dart';
import 'package:studybuddyapp/service/auth_service.dart';

import '../../widgets/widgets.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final formKey=GlobalKey<FormState>();

  String email='';

  TextEditingController emailController=TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 80),
          child: Form(
              key: formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  const Text(
                    "Study Buddy",
                    style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 82, 4, 96),
                        fontStyle: FontStyle.italic),
                  ),
                  const SizedBox(height: 10),
                  const Text("Forgot Password? Don't worry we got you!\n Enter Your Connected Email.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Color.fromARGB(255, 82, 4, 96))),
                  const SizedBox(
                    height: 50,
                  ),
                  Image.asset("assets/login1.png"),
                  const SizedBox(
                    height: 80,
                  ),
                  TextFormField(
                    controller: emailController,
                    decoration: textInputDecoration.copyWith(
                      errorBorder: const OutlineInputBorder(),
                        border: const OutlineInputBorder(),
                        labelText: "Email",
                        hintText: "Enter your Email",
                        prefixIcon: Icon(
                          Icons.email,
                          color: Theme.of(context).primaryColor,
                        )),
                    onChanged: (val) {
                      setState(() {
                        email = val;
                      });
                    },
      
                    // check tha validation
                    validator: (val) {
                      if(val!.isEmpty){
                        return 'Please Enter Email';
                      }
                      else if(!HelperFunctions.validateEmail(val.toString())){
                        return 'Please Enter Valid Email';
                      }
                    },
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                    width: MediaQuery.sizeOf(context).width*0.5,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30))),
                      child: const Text(
                        "Send",
                        style:
                        TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      onPressed: () {
                        print('send pressed');
                        if(formKey.currentState!.validate()) {
                          AuthService().resetPassword(email).then((value){
                            setState(() {
                              emailController.clear();
                              email='';
                            });
                          });
                        }
                      },
                    ),
                  ),
      
                ],
              )),
        ),
      ),
    );
  }
}
