class QuestionModel {
  final String? question;
  final List<OptionModel>? options;
  final int? correctAnswerId;
  int? selectedAnswerId;

  QuestionModel({
    this.question,
    this.options,
    this.correctAnswerId,
    this.selectedAnswerId,
  });
}

class OptionModel {
  final int? id;
  final String? option;

  OptionModel({this.id, this.option});
}
