class LayOutQuestion {
   int id;
   String text;
   List<LayOutOption> options;
  bool isLocked;
  LayOutOption? selectedWidgetOption;
  LayOutOption? correctAnswer;
  // final int timeSeconds;

  LayOutQuestion({
    required this.text,
    required this.options,
    this.isLocked = false,
    this.selectedWidgetOption,
    required this.id,
    required this.correctAnswer,
    //  required this.timeSeconds
  });

   Map<String, dynamic> toMap() {
     return {
       'id': id,
       'text': text,
       'options': options.map((option) => option.toMap()).toList(),
       'isLocked': isLocked,
       'selectedWidgetOption': selectedWidgetOption?.toMap(),
       'correctAnswer': correctAnswer?.toMap(),
     };
   }

   factory LayOutQuestion.fromJson(Map<String, dynamic> json) {
     print('in LayOutQuestion');
     return LayOutQuestion(
       id: json['id'] ?? 0,
       text: json['text'] ?? '',
       options: (json['options'] as List<dynamic>?)
           ?.map((option) => LayOutOption.fromJson(option))
           ?.toList() ?? [],
       isLocked: json['isLocked'] ?? false,
       selectedWidgetOption: json['selectedWidgetOption'] != null ? LayOutOption.fromJson(json['selectedWidgetOption']) : null,
       correctAnswer: json['correctAnswer'] != null ? LayOutOption.fromJson(json['correctAnswer']) : null,
     );
   }

  LayOutQuestion copyWith() {
    return LayOutQuestion(
      id: id,
      text: text,
      options: options
          .map(
            (option) =>
                LayOutOption(text: option.text, isCorrect: option.isCorrect),
          )
          .toList(),
      isLocked: isLocked,
      selectedWidgetOption: selectedWidgetOption,
      correctAnswer: correctAnswer,
    );
  }
}

class LayOutOption {
   String text;
   bool isCorrect;

   LayOutOption({
    required this.text,
    required this.isCorrect,
  });


   Map<String, dynamic> toMap() {
     return {
       'text': text,
       'isCorrect': isCorrect,
     };
   }

   factory LayOutOption.fromJson(Map<String, dynamic> json) {
     return LayOutOption(
       text: json['text'] ?? '',
       isCorrect: json['isCorrect'] ?? false,
     );
   }
}


