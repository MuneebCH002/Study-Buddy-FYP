import 'package:flutter/material.dart';

import 'layout_questions_model.dart';

const Color cardColor = Color(0xFF4993FA);

class FlutterTopics {
  final int id;
  final String topicName;
  final List<dynamic> topicQuestions;
  final String status;
  // final DateTime timeStamp;

  FlutterTopics(
      {required this.id,
      required this.topicName,
      required this.topicQuestions,
      required this.status,
      // required this.timeStamp
      });

  @override
  String toString() {
    return "id : $id \n topic name $topicName \ntopic Question: ${topicQuestions.toString()} \nstatus: $status";
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'topicName': topicName,
      'topicQuestions':
          topicQuestions.map((question) => question.toMap()).toList(),
      'status': status,
      // 'timeStamp': timeStamp
    };
  }

  factory FlutterTopics.fromMap(Map<String, dynamic> map) {
    print('innit map');
    var flutterMap= FlutterTopics(
      id: map['id'] ?? 0,
      topicName: map['topicName'] ?? '',
      topicQuestions: List<LayOutQuestion>.from(map['topicQuestions']
          .map((question) => LayOutQuestion.fromJson(question))),
      status: map['status'] ?? 'active',
      // timeStamp: map['timeStamp'],
    );
    print('Map Flutter'+flutterMap.toString());
    return flutterMap;
  }
}
