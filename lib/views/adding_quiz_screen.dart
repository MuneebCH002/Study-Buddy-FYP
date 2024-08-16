import 'dart:math';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/flutter_topics_model.dart';
import '../models/layout_questions_model.dart';

class AddQuizDialog extends StatefulWidget {
   AddQuizDialog({super.key,required this.groupId});
   final String groupId;
  @override
  _AddQuizDialogState createState() => _AddQuizDialogState();
}

class _AddQuizDialogState extends State<AddQuizDialog> {
  TextEditingController _topicNameController = TextEditingController();
  List<LayOutQuestion> _questions = [];


  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Quiz'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextField(
              controller: _topicNameController,
              decoration: const InputDecoration(labelText: 'Topic Name'),
            ),
            const SizedBox(height: 10),
            const Text('Add Questions:'),
            Column(
              children: _questions.map((question) => _buildQuestionField(question)).toList(),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _addQuestion,
              child: const Text('Add Question'),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        ElevatedButton(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        ElevatedButton(
          onPressed: () async {
            Random random=Random();
            FlutterTopics newTopic = FlutterTopics(
              id: random.nextInt(1000000)+1,
              topicName: _topicNameController.text,
              topicQuestions: _questions,
              status: 'active',
              // timeStamp:DateTime.now().toString()
            );

            await FirebaseFirestore.instance
                .collection('groups')
                .doc(widget.groupId)
                .collection('quizzes')
                .add(newTopic.toMap());

            _topicNameController.clear();
            _questions.clear();
            Navigator.of(context).pop();
          },
          child: const Text('Save'),
        ),
      ],
    );
  }


  Widget _buildQuestionField(LayOutQuestion question) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: TextField(
            onChanged: (value) => question.text = value,
            decoration: const InputDecoration(
              labelText: 'Question',
              hintText: 'Enter question here',
            ),
            controller: TextEditingController(text: question.text),
          ),
        ),
        Column(
          children: question.options.map((option) => _buildOptionField(question, option)).toList(),
        ),
        const SizedBox(height: 10),
        DropdownButton<LayOutOption>(
          value: question.correctAnswer,
          hint: const Text('Select Correct Option'),
          onChanged: (value) {
            setState(() {
              question.correctAnswer = value;
            });
          },
          items: question.options.map((option) {
            return DropdownMenuItem<LayOutOption>(
              value: option,
              child: Text(option.text),
            );
          }).toList(),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: () => _addOption(question),
          child: const Text('Add Option'),
        ),
      ],
    );
  }

  Widget _buildOptionField(LayOutQuestion question, LayOutOption option) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              onChanged: (value) => option.text = value,
              decoration: const InputDecoration(
                labelText: 'Option',
                hintText: 'Enter option here',
              ),
              controller: TextEditingController(text: option.text),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _removeOption(question, option),
          ),
          Checkbox(
            value: option.isCorrect,
            onChanged: (value) {
              setState(() {
                option.isCorrect = value ?? false;
              });
            },
          ),
        ],
      ),
    );
  }


  void _addQuestion() {
    setState(() {
      _questions.add(LayOutQuestion(
        id: _questions.length,
        text: 'Enter your question here',
        options: [
          LayOutOption(text: 'Option 1', isCorrect: false),
          LayOutOption(text: 'Option 2', isCorrect: false),
        ],
        isLocked: false,
        selectedWidgetOption: null,
        correctAnswer: null,
      ));
    });
  }

  void _addOption(LayOutQuestion question) {
    setState(() {
      question.options.add(LayOutOption(text: '', isCorrect: false));
    });
  }

  void _removeOption(LayOutQuestion question, LayOutOption option) {
    setState(() {
      question.options.remove(option);
    });
  }
}
