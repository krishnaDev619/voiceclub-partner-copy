import 'package:voiceclub_partner/data/models/tutorial/tutorial_stage_model.dart';

class JourneyChangesModel {
  final List<TutorialStageModel>? stages;

  JourneyChangesModel({required this.stages});

  factory JourneyChangesModel.fromJson(Map<String, dynamic> json) =>
      JourneyChangesModel(
        stages:
            (json['stages'] as List? ?? [])
                .whereType<Map<String, dynamic>>()
                .map(TutorialStageModel.fromJson)
                .toList(),
      );
}
