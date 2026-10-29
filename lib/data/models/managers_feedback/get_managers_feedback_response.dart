import 'package:voiceclub_partner/data/models/managers_feedback/manager_feedback_model.dart';

class GetManagersFeedbackResponseModel {
  final List<ManagerFeedbackModel>? feedbacks;
  final int? page;
  final int? totalItems;
  final int? totalPages;

  GetManagersFeedbackResponseModel({
    this.feedbacks,
    this.page,
    this.totalItems,
    this.totalPages,
  });

  GetManagersFeedbackResponseModel.fromJson(Map<String, dynamic> json)
    : feedbacks =
          (json['feedbacks'] as List?)
              ?.map(
                (dynamic e) =>
                    ManagerFeedbackModel.fromJson(e as Map<String, dynamic>),
              )
              .toList(),
      page = json['page'] as int?,
      totalItems = json['total_items'] as int?,
      totalPages = json['total_pages'] as int?;

  Map<String, dynamic> toJson() => {
    'feedbacks': feedbacks?.map((e) => e.toJson()).toList(),
    'page': page,
    'total_items': totalItems,
    'total_pages': totalPages,
  };
}
