class UserSurveySubmissionsModel {
  final List<String> submittedSurveyIds;

  UserSurveySubmissionsModel({required this.submittedSurveyIds});

  factory UserSurveySubmissionsModel.fromJson(Map<String, dynamic> json) {
    return UserSurveySubmissionsModel(
      submittedSurveyIds: List<String>.from(json['submittedSurveyIds'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {'submittedSurveyIds': submittedSurveyIds};
  }

  UserSurveySubmissionsModel copyWith({List<String>? submittedSurveyIds}) {
    return UserSurveySubmissionsModel(
      submittedSurveyIds: submittedSurveyIds ?? this.submittedSurveyIds,
    );
  }
}
