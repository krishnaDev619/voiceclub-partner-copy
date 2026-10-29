import 'package:voiceclub_partner/data/models/config/support_question.dart';

class GetSupportQuestionsConfigResponseModel {
  final List<SupportQuestionModel>? questions;

  GetSupportQuestionsConfigResponseModel({this.questions});

  GetSupportQuestionsConfigResponseModel.fromJson(Map<String, dynamic> json)
    : questions =
          (json['questions'] as List?)
              ?.map(
                (dynamic e) =>
                    SupportQuestionModel.fromJson(e as Map<String, dynamic>),
              )
              .toList();

  Map<String, dynamic> toJson() => {
    'questions': questions?.map((e) => e.toJson()).toList(),
  };
}
