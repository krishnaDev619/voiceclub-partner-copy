// Answer Model
class MCQAnswerModel {
  final int? id;
  final String? value;

  MCQAnswerModel({this.id, this.value});

  factory MCQAnswerModel.fromJson(Map<String, dynamic> json) {
    return MCQAnswerModel(
      id: json['id'] as int?,
      value: json['value'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'value': value};
  }
}
