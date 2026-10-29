class UpdateFeedbackResponseModel {
  final String? message;

  UpdateFeedbackResponseModel({this.message});

  UpdateFeedbackResponseModel.fromJson(Map<String, dynamic> json)
    : message = json['message'] as String?;

  Map<String, dynamic> toJson() => {'message': message};
}
