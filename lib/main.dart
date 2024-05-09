import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:studybuddyapp/firebase_options.dart';
import 'package:studybuddyapp/helper/helper_function.dart';
import 'package:studybuddyapp/service/notification_service.dart';
import 'package:studybuddyapp/shared/constants.dart';
import 'group_pages/auth/login_page.dart';
import 'group_pages/home_page.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await checkNotificationAllow();
  // await NotificationServices.initializeNotification();
  await AndroidFlutterLocalNotificationsPlugin().requestExactAlarmsPermission();
  NotificationService notificationService=NotificationService();
  notificationService.initializeNotifications();
   tz.initializeTimeZones();
   tz.setLocalLocation(tz.getLocation('Asia/Karachi'));


  if (kIsWeb) {
    await Firebase.initializeApp(
        options: FirebaseOptions(
            apiKey: Constants.apiKey,
            appId: Constants.appId,
            messagingSenderId: Constants.messagingSenderId,
            projectId: Constants.projectId));
  } else {
    await Firebase.initializeApp();
  }

  runApp(const MyApp());
}
bool isSignedIn=false;
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);



  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Constants().primaryColor,
        scaffoldBackgroundColor: Colors.white,
      ),
      debugShowCheckedModeBanner: false,
      home: FirebaseAuth.instance.currentUser!=null?const HomePage():const SplashScreen(), // Run SplashScreen initially
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool isSignedIn=false;


  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    Future.delayed(const Duration(seconds: 5), () {
      checkLoggedInStatus(); // Check logged-in status after 5 seconds
    });
  }

  void checkLoggedInStatus() async {
    bool isSignedIn = await HelperFunctions.getUserLoggedInStatus() ?? false;
    this.isSignedIn=isSignedIn;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (BuildContext context) =>
            isSignedIn ? const HomePage() : const LoginPage(),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Text(
              "Study Buddy",
              style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 82, 4, 96),
                  fontStyle: FontStyle.italic),
            ),
            const SizedBox(
              height: 40,
            ),
            Lottie.asset(
              'animation/lottie.json', // Replace with your animation file
              width: 400,
              height: 400,
              fit: BoxFit.fill,
            ),
          ]),
        ],
      ),
    );
  }
}
checkNotificationAllow()async{
  await AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
    if(!isAllowed){
      AwesomeNotifications().requestPermissionToSendNotifications();
    }
  });
}
