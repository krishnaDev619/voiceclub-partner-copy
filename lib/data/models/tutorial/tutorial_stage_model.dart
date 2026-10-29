import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/data/models/tutorial/tutorial_lesson.dart';
import 'package:voiceclub_partner/data/models/tutorial/tutorial_quiz_model.dart';

class TutorialStageModel {
  final int? id;
  final TutorialStage? stage;
  final List<TutorialLesson>? lessons;
  final TutorialQuizModel? quiz;

  TutorialStageModel({this.id, this.stage, this.lessons, this.quiz});

  TutorialStageModel.fromJson(Map<String, dynamic> json)
    : id = json['id'] as int?,
      lessons =
          (json['lessons'] as List?)
              ?.map(
                (dynamic e) =>
                    TutorialLesson.fromJson(e as Map<String, dynamic>),
              )
              .toList(),
      stage =
          json['stage'] != null
              ? (json['stage'] as String).toTutorialStage()
              : null,
      quiz =
          (json['quiz'] as Map<String, dynamic>?) != null
              ? TutorialQuizModel.fromJson(json['quiz'] as Map<String, dynamic>)
              : null;

  Map<String, dynamic> toJson() => {
    'id': id,
    'stage': stage?.name,
    'lessons': lessons?.map((e) => e.toJson()).toList(),
    'quiz': quiz?.toJson(),
  };
}
