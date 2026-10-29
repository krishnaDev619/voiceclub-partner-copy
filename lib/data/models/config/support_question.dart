class SupportQuestionModel {
  final String? question;
  final String? answer;

  SupportQuestionModel({this.question, this.answer});

  SupportQuestionModel.fromJson(Map<String, dynamic> json)
    : question = json['question'] as String?,
      answer = json['answer'] as String?;

  Map<String, dynamic> toJson() => {'question': question, 'answer': answer};
}
