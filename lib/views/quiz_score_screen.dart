import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class QuizScoresScreen extends StatelessWidget {
  const QuizScoresScreen({super.key,required this.groupId});

 final String groupId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Scores'),
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance.collection('quiz_attempts').where('group_id',isEqualTo: groupId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            List<QueryDocumentSnapshot> quizAttempts = snapshot.data!.docs;

            // Group quiz attempts by user ID
            Map<String, List<Map<String, dynamic>>> userScores = {};
            quizAttempts.forEach((attempt) {
              String userId = attempt['userId'];
              if (!userScores.containsKey(userId)) {
                userScores[userId] = [];
              }
              userScores[userId]!.add({
                'quiz_topic': attempt['quiz_topic'],
                'score': attempt['score'],
              });
            });

            return ListView.builder(
              itemCount: userScores.length,
              itemBuilder: (context, index) {
                String userId = userScores.keys.elementAt(index);
                List<Map<String, dynamic>> scores = userScores[userId]!;

                return Card(
                  child: ListTile(
                    title: Text('User ID: ${userId.toString()}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: scores.map((scoreData) {
                        return Text(
                          '${scoreData['quiz_topic']}: ${scoreData['score']}',
                        );
                      }).toList(),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
