import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../widgets/results_card.dart';

class ResultsScreen extends StatelessWidget {
  const ResultsScreen(
      {super.key,
      required this.score,
      required this.totalQuestions,
      required this.whichTopic});
  final int score;
  final int totalQuestions;
  final String whichTopic;

  @override
  Widget build(BuildContext context) {
    const Color bgColor3 = Color(0xFF5170FD);
    print(score);
    print(totalQuestions);
    final double percentageScore = (score / totalQuestions) * 100;
    final int roundedPercentageScore = percentageScore.round();
    const Color cardColor = Color(0xFF4993FA);
    return WillPopScope(
      onWillPop: () {
        Navigator.popUntil(context, (route) => route.isFirst);
        return Future.value(false);
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: bgColor3,
          elevation: 0,
          actions: [
            IconButton(
              onPressed: () async{
                String? userId = await getCurrentUserId(); // Implement this function to get the current user's ID

                if (userId != '') {
                  // Save the user's score and mark the quiz as attempted
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(userId)
                      .collection('quiz_attempts')
                      .add({
                    'quiz_topic': whichTopic,
                    'score': score,
                    'total_questions': totalQuestions,
                    'attempted': true,
                  });

                  await FirebaseFirestore.instance.collection('quiz_attempts').add({
                    'userId':userId,
                    'quiz_topic': whichTopic,
                    'score': score,
                  });

                  // Navigate back to the previous screen
                  Navigator.popUntil(context, (route) => route.isFirst);
                } else {
                  Navigator.popUntil(context, (route) => route.isFirst);
                }
              },
              icon: const Icon(
                Icons.close,
                color: Colors.white,
              ),
            ),
          ],
        ),
        backgroundColor: bgColor3,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "Result",
                      style:
                          Theme.of(context).textTheme.headlineSmall!.copyWith(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    // for (var i = 0; i < "Riddles!!!".length; i++) ...[
                    //   TextSpan(
                    //     text: "Riddles!!!"[i],
                    //     style:
                    //         Theme.of(context).textTheme.headlineSmall!.copyWith(
                    //               fontSize: 18 + i.toDouble(),
                    //               color: Colors.white,
                    //               fontWeight: FontWeight.w400,
                    //             ),
                    //   ),
                    // ]
                  ],
                ),
              ),
              // Padding(
              //   padding: const EdgeInsets.all(8.0),
              //   child: Text(
              //     whichTopic.toUpperCase(),
              //     style: Theme.of(context).textTheme.headlineSmall!.copyWith(
              //           fontSize: 15,
              //           color: Colors.white,
              //           fontWeight: FontWeight.w400,
              //         ),
              //   ),
              // ),
              const SizedBox(height: 20,
              ),
              ResultsCard(
                  roundedPercentageScore: roundedPercentageScore,
                  score:score,
                  totalScore:totalQuestions,
                  bgColor3: bgColor3),
              const SizedBox(
                height: 25,
              ),
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(cardColor),
                  fixedSize: MaterialStateProperty.all(
                    Size(MediaQuery.sizeOf(context).width * 0.80, 40),
                  ),
                  elevation: MaterialStateProperty.all(4),
                ),
                onPressed: () async{
                  String? userId = await getCurrentUserId(); // Implement this function to get the current user's ID

                  if (userId != '') {
                    // Save the user's score and mark the quiz as attempted
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(userId)
                        .collection('quiz_attempts')
                        .add({
                      'quiz_topic': whichTopic,
                      'score': score,
                      'total_questions': totalQuestions,
                      'attempted': true,
                    });

                    await FirebaseFirestore.instance.collection('quiz_attempts').add({
                      'userId':userId,
                      'quiz_topic': whichTopic,
                      'score': score,
                    });

                    // Navigate back to the previous screen
                    Navigator.popUntil(context, (route) => route.isFirst);
                  } else {
                    Navigator.popUntil(context, (route) => route.isFirst);
                  }
                },
                child: const Text(
                  "Exit",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Future<String> getCurrentUserId()async{
    return FirebaseAuth.instance.currentUser!.uid;
  }
}
