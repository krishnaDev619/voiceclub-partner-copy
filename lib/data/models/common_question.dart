class CommonQuestionModel {
  final String? question;
  final String? localizedQuestion;

  CommonQuestionModel({this.question, this.localizedQuestion});

  CommonQuestionModel.fromJson(Map<String, dynamic> json)
    : question = json['question'] as String?,
      localizedQuestion = json['localized_question'] as String?;

  Map<String, dynamic> toJson() => {
    'question': question,
    'localized_question': localizedQuestion,
  };
}
