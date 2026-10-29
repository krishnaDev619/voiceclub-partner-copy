// Demo Question Model
import 'package:voiceclub_partner/core/constants/enums.dart';

class DemoQuestionModel {
  final TutorialDemoFeature? featureAction;
  final String? question;
  final String? audioExplanationUrl;

  DemoQuestionModel({
    this.featureAction,
    this.question,
    this.audioExplanationUrl,
  });

  factory DemoQuestionModel.fromJson(Map<String, dynamic> json) {
    return DemoQuestionModel(
      featureAction: TutorialDemoFeatureExtension.fromString(
        (json['feature'] as String? ?? "EMPTY"),
      ),
      question: json['question'] as String?,
      audioExplanationUrl: json['audioExplanationUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'feature': featureAction?.name,
      'question': question,
      'audioExplanationUrl': audioExplanationUrl,
    };
  }
}
