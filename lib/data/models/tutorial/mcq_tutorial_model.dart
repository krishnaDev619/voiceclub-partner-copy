// MCQ Question Model
import 'package:voiceclub_partner/data/models/tutorial/mcq_answer_model.dart';

class MCQQuestionModel {
  final String? question;
  final List<MCQAnswerModel>? answers;
  final int? correctAnswerId;
  int? selectedAnswerId;

  MCQQuestionModel({
    this.question,
    this.answers,
    this.correctAnswerId,
    this.selectedAnswerId,
  });

  factory MCQQuestionModel.fromJson(Map<String, dynamic> json) {
    return MCQQuestionModel(
      question: json['question'] as String?,
      answers:
          (json['answers'] as List?)
              ?.map(
                (dynamic e) =>
                    MCQAnswerModel.fromJson(e as Map<String, dynamic>),
              )
              .toList(),
      correctAnswerId: json['correctAnswerId'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'question': question,
      'answers': answers?.map((e) => e.toJson()).toList(),
      'correctAnswerId': correctAnswerId,
    };
  }
}
