import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:studybuddyapp/views/adding_quiz_screen.dart';

import '../models/flutter_topics_model.dart';
import '../models/layout_questions_model.dart';
import 'flashcard_screen.dart';

class HomePageQuiz extends StatelessWidget {
  HomePageQuiz({super.key,required this.groupId});

  List flutterTopicsList = [];
  String groupId;

  Future<void> _updateQuizStatus(String quizName, String newStatus) async {
    try {
      QuerySnapshot quizSnapshot = await FirebaseFirestore.instance
          .collection('groups')
          .doc(groupId)
          .collection('quizzes')
          .where('topicName', isEqualTo: quizName)
          .get();

      if (quizSnapshot.docs.isNotEmpty) {
        for (QueryDocumentSnapshot doc in quizSnapshot.docs) {
          await doc.reference.update({'status': newStatus});
        }
      } else {
      }
    } catch (error) {
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color bgColor = Color(0xFF4993FA);
    const Color bgColor3 = Color(0xFF5170FD);
    return Scaffold(
      backgroundColor: bgColor3,
      floatingActionButton: FloatingActionButton.small(
        onPressed: () => showDialog(
            context: context,
            builder: (context) {
              return AddQuizDialog(groupId: groupId,);
            }),
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 0, left: 15, right: 15),
          child: ListView(
            physics: const BouncingScrollPhysics(),
            children: [
              Container(
                decoration: BoxDecoration(
                  color: bgColor3,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.24),
                      blurRadius: 20.0,
                      offset: const Offset(0.0, 10.0),
                      spreadRadius: -10,
                      blurStyle: BlurStyle.outer,
                    )
                  ],
                ),
                child: Image.asset("assets/quiz_assets/dash.png"),
              ),
              const SizedBox(
                height: 10,
              ),
              Center(
                child: RichText(
                  text: TextSpan(
                    children: [
                      for (var i = 0; i < "Create Quizzes!!!".length; i++) ...[
                        TextSpan(
                          text: "Create Quizzes!!!"[i],
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall!
                              .copyWith(
                                fontSize: 21 + i.toDouble(),
                                color: Colors.white,
                                fontWeight: FontWeight.w400,
                              ),
                        ),
                      ]
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              StreamBuilder(
                stream: FirebaseFirestore.instance.collection('groups').doc(groupId).collection('quizzes').snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  final docs = snapshot.data?.docs ?? [];
                  if (docs.isEmpty) {
                    return const Center(child: Text('No quizzes available'));
                  }
                  return SizedBox(
                    height: MediaQuery.sizeOf(context).height,
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 0.85,
                      ),
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final quizData = docs[index].data() as Map<String, dynamic>?; // Explicit cast to Map<String, dynamic>
                        if (quizData == null) {
                          return Container();
                        }
                        final topicQuestions = (quizData['topicQuestions'] as List<dynamic>?)
                            ?.map((question) => LayOutQuestion.fromJson(question))
                            .toList() ?? [];
                        return GestureDetector(
                          onLongPress: (){
                            showDialog(context: context, builder: (context){
                              return AlertDialog(
                                backgroundColor: Colors.black,
                                content: const Text('Do you want to deactivate the quiz?',style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13
                                ),),
                                title: const Text('Deactivate Quiz',style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16
                                ),),
                                actions: [
                                  TextButton(onPressed: ()async{
                                    const Center(child: CircularProgressIndicator());
                                    await _updateQuizStatus(quizData['topicName'], 'finished');
                                    Navigator.pop(context);
                                    // FlutterToast.showToast(msg:);
                                    Fluttertoast.showToast(msg: 'Quiz Deactivated Successfully',backgroundColor: Colors.green);
                                    }, child: const Text('Yes',style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12
                                  ),)),
                                  TextButton(onPressed: (){
                                    Navigator.pop(context);
                                  }, child: const Text('No',style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12
                                  ),)),
                                ],
                              );
                            });
                          },
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => NewCard(
                                  typeOfTopic: topicQuestions,
                                  topicName: quizData['topicName'],
                                ),
                              ),
                            );
                          },
                          child: Card(
                            elevation: 10,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const SizedBox(height: 15),
                                  Text(
                                    quizData['topicName'] ?? '', // Provide a default name if null
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontSize: 18),
                                  )
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              )
              // GridView.builder(
              //   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              //     crossAxisCount: 2,
              //     mainAxisSpacing: 10,
              //     crossAxisSpacing: 10,
              //     childAspectRatio: 0.85,
              //   ),
              //   shrinkWrap: true,
              //   physics: const BouncingScrollPhysics(),
              //   itemCount: flutterTopicsList.length,
              //   itemBuilder: (context, index) {
              //     final topicsData = flutterTopicsList[index];
              //     return GestureDetector(
              //       onTap: () {
              //         Navigator.push(
              //           context,
              //           MaterialPageRoute(
              //             builder: (context) => NewCard(
              //               typeOfTopic: topicsData.topicQuestions,
              //               topicName: topicsData.topicName,
              //             ),
              //           ),
              //         );
              //         // print(topicsData.topicName);
              //         print("topic data: " + topicsData.toString());
              //       },
              //       child: Card(
              //         color: bgColor,
              //         elevation: 10,
              //         shape: RoundedRectangleBorder(
              //           borderRadius: BorderRadius.circular(10),
              //         ),
              //         child: Center(
              //           child: Column(
              //             mainAxisAlignment: MainAxisAlignment.center,
              //             crossAxisAlignment: CrossAxisAlignment.center,
              //             children: [
              //               Icon(
              //                 topicsData.topicIcon,
              //                 color: Colors.white,
              //                 size: 55,
              //               ),
              //               const SizedBox(
              //                 height: 15,
              //               ),
              //               Text(
              //                 topicsData.topicName,
              //                 textAlign: TextAlign.center,
              //                 style: Theme.of(context)
              //                     .textTheme
              //                     .headlineSmall!
              //                     .copyWith(
              //                       fontSize: 18,
              //                       color: Colors.white,
              //                       fontWeight: FontWeight.w300,
              //                     ),
              //               )
              //             ],
              //           ),
              //         ),
              //       ),
              //     );
              //   },
              // ),
            ],
          ),
        ),
      ),
    );
  }



}
