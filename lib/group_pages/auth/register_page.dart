import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:studybuddyapp/helper/helper_function.dart';
import 'package:studybuddyapp/service/auth_service.dart';
import 'package:studybuddyapp/widgets/widgets.dart';

import '../home_page.dart';
import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool _isLoading = false;
  final formKey = GlobalKey<FormState>();
  String email = "";
  String password = "";
  String fullName = "";
  String phoneNum ='';
  String ppUrl ='';
  bool hidePassword = true;

  AuthService authService = AuthService();

  var imageUrl;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                  color: Theme.of(context).primaryColor))
          : SingleChildScrollView(
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
                          "Study buddy",
                          style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 82, 4, 96),
                              fontStyle: FontStyle.italic),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                            "Create your account now to chat and explore",
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: Color.fromARGB(255, 82, 4, 96))),
                        const SizedBox(
                          height: 30,
                        ),
                        Image.asset("assets/register1.png"),
                        const SizedBox(
                          height: 30,
                        ),
                        TextFormField(
                          decoration: textInputDecoration.copyWith(
                              border: const OutlineInputBorder(),
                              errorBorder: const OutlineInputBorder(),
                              labelText: "Full Name",
                              prefixIcon: Icon(
                                Icons.person,
                                color: Theme.of(context).primaryColor,
                              )),
                          onChanged: (val) {
                            setState(() {
                              fullName = val;
                            });
                          },
                          validator: (val) {
                            if (val!.isNotEmpty) {
                              return null;
                            } else {
                              return "Name cannot be empty";
                            }
                          },
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        TextFormField(
                          decoration: textInputDecoration.copyWith(
                              border: const OutlineInputBorder(),
                              errorBorder: const OutlineInputBorder(),
                              labelText: "Email",
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
                              return "Please enter email";
                            }
                            else  if(!HelperFunctions.validateEmail(val.toString())){
                             return "Please Enter a valid email";
                           }
                           else {
                             return null;
                           }
                          },
                        ),
                        const SizedBox(height: 15),
                       IntlPhoneField(
                          initialCountryCode: 'PK',
                          decoration: const InputDecoration(
                            labelText: 'Phone Number',
                            border:OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.deepPurple, width: 2),
                            ),
                            labelStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.w300),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.deepPurple, width: 2),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.deepPurple, width: 2),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.deepPurple, width: 2),
                            ),
                          ),
                            onChanged: (phnNum){
                            setState(() {
                              phoneNum=phnNum.completeNumber;
                            });
                            },
                         autovalidateMode: AutovalidateMode.onUserInteraction,
                        ),
                        const SizedBox(height: 10),
                        InkWell(
                          onTap: ()async{
                           var image= await authService.getImage();
                           setState(() {
                             imageUrl=image;
                           });
                          var url= await authService.uploadImage(image);
                          setState(() {
                            ppUrl=url;
                          });
                          },
                          child: Container(
                            height: 30,
                            alignment:Alignment.centerLeft ,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(imageUrl!=null?'Picture Selected':'Select Profile Picture',style: const TextStyle(fontSize: 14,color: Colors.white),),
                                const Icon(Icons.image,color: Colors.white,)
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        TextFormField(
                          obscureText: hidePassword,
                          decoration: textInputDecoration.copyWith(
                              suffixIcon: IconButton(
                                  onPressed: ()=>setState(() {
                                    hidePassword=!hidePassword;
                                  }), icon: const Icon(Icons.remove_red_eye,color: Colors.black,)),
                              border: const OutlineInputBorder(),
                              errorBorder: const OutlineInputBorder(),
                              labelText: "Password",
                              prefixIcon: Icon(
                                Icons.lock,
                                color: Theme.of(context).primaryColor,
                              )),
                          validator: (val) {
                            if(val!.isEmpty){
                              return 'Please enter password';
                            }
                            else if (val.length < 8) {
                              return "Password must be at least 8 characters";
                            }
                            else if(!HelperFunctions.validatePassword(password)){
                              return 'Please enter valid password';
                            }
                            else {
                              return null;
                            }
                          },
                          onChanged: (val) {
                            setState(() {
                              password = val;
                            });
                          },
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).primaryColor,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30))),
                            child: const Text(
                              "Register",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16),
                            ),
                            onPressed: () {
                              register();
                            },
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text.rich(TextSpan(
                          text: "Already have an account? ",
                          style: const TextStyle(
                              color: Colors.black, fontSize: 16),
                          children: <TextSpan>[
                            TextSpan(
                                text: "Login now",
                                style: const TextStyle(
                                    color: Colors.blue,
                                    decoration: TextDecoration.underline),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    nextScreen(context, const LoginPage());
                                  }),
                          ],
                        )),
                      ],
                    )),
              ),
            ),
    );
  }

  register() async {
    if (formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      await authService
          .registerUserWithEmailandPassword(fullName, email, password,phoneNum,ppUrl)
          .then((value) async {
        if (value == true) {
          String userId = FirebaseAuth.instance.currentUser!.uid;

          // Store the FCM token
          await storeToken(userId);
          await HelperFunctions.saveUserLoggedInStatus(true);
          await HelperFunctions.saveUserEmailSF(email);
          await HelperFunctions.saveUserNameSF(fullName);
          nextScreenReplace(context, const HomePage());
        } else {
          showSnackbar(context, Colors.red, value.toString());
          // nextScreen(context, const RegisterPage());
          setState(() {
            _isLoading = false;
          });
        }
      });
    }
  }
  Future<void> storeToken(String userId) async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    String? token = await messaging.getToken();

    if (token != null) {
      await FirebaseFirestore.instance.collection('users').doc(userId).set({
        'fcmToken': token,

      } ,SetOptions(merge: true));
    }
  }
}
