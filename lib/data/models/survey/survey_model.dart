import 'package:voiceclub_partner/core/constants/enums.dart';

class SurveyModel {
  final String id;
  final SurveyType type;
  final List<SurveyQuestion> questions;
  final String target;
  final bool active;
  final String? date;

  SurveyModel({
    required this.id,
    required this.type,
    required this.questions,
    required this.target,
    required this.active,
    this.date,
  });

  factory SurveyModel.fromJson(Map<String, dynamic> json) {
    return SurveyModel(
      id: json['id'],
      type: SurveyType.values.firstWhere(
        (e) =>
            e.toString().split('.').last.toLowerCase() ==
            json['type'].toString().toLowerCase(),
      ),
      questions:
          (json['questions'] as List)
              .map((q) => SurveyQuestion.fromJson(q))
              .toList(),
      target: json['target'],
      active: json['active'],
      date: json['date'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString().split('.').last.toLowerCase(),
      'questions': questions.map((q) => q.toJson()).toList(),
      'target': target,
      'active': active,
      'date': date,
    };
  }
}

class SurveyQuestion {
  final String id;
  final String text;
  final List<String>? options;

  SurveyQuestion({required this.id, required this.text, this.options});

  factory SurveyQuestion.fromJson(Map<String, dynamic> json) {
    return SurveyQuestion(
      id: json['id'],
      text: json['text'],
      options:
          json['options'] != null ? List<String>.from(json['options']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'text': text, 'options': options};
  }
}
