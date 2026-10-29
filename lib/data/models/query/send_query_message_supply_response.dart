class SendQueryMessageSupplyResponse {
  final String? message;
  final String? sessionId;

  SendQueryMessageSupplyResponse({this.message, this.sessionId});

  SendQueryMessageSupplyResponse.fromJson(Map<String, dynamic> json)
    : message = json['message'] as String?,
      sessionId = json['session_id'] as String?;

  Map<String, dynamic> toJson() => {
    'message': message,
    'session_id': sessionId,
  };
}
