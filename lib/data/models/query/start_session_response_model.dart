class StartSessionResponseModel {
  final String? sessionId;

  StartSessionResponseModel({this.sessionId});

  StartSessionResponseModel.fromJson(Map<String, dynamic> json)
    : sessionId = json['session_id'] as String?;

  Map<String, dynamic> toJson() => {'session_id': sessionId};
}
