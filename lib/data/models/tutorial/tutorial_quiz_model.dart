// Main Quiz Model
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/data/models/tutorial/demo_question_model.dart';
import 'package:voiceclub_partner/data/models/tutorial/mcq_tutorial_model.dart';

class TutorialQuizModel {
  final TutorialQuizType? type;
  final List<MCQQuestionModel>? mcqQuestions;
  final List<DemoQuestionModel>? demoQuestions;

  TutorialQuizModel({this.type, this.mcqQuestions, this.demoQuestions});

  factory TutorialQuizModel.fromJson(Map<String, dynamic> json) {
    final type = QuizTypeExtension.fromString(json['type']);
    return TutorialQuizModel(
      type: type,
      mcqQuestions:
          type == TutorialQuizType.MCQ
              ? (json['mcqQuestions'] as List?)
                  ?.map(
                    (dynamic e) =>
                        MCQQuestionModel.fromJson(e as Map<String, dynamic>),
                  )
                  .toList()
              : null,
      demoQuestions:
          type == TutorialQuizType.DEMO
              ? (json['demoQuestions'] as List?)
                  ?.map(
                    (dynamic e) =>
                        DemoQuestionModel.fromJson(e as Map<String, dynamic>),
                  )
                  .toList()
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type?.name,
      'mcqQuestions': mcqQuestions?.map((e) => e.toJson()).toList(),
      'demoQuestions': demoQuestions?.map((e) => e.toJson()).toList(),
    };
  }
}
