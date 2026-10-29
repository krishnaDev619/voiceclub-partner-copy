class GetAccountPreferenceResponseModel {
  final int? id;
  final int? accountId;
  final String? status;
  final String? chatPreference;
  final String? callPreference;

  GetAccountPreferenceResponseModel({
    this.id,
    this.accountId,
    this.status,
    this.chatPreference,
    this.callPreference,
  });

  GetAccountPreferenceResponseModel.fromJson(Map<String, dynamic> json)
    : id = json['id'] as int?,
      accountId = json['account_id'] as int?,
      status = json['status'] as String?,
      chatPreference = json['chat_preference'] as String?,
      callPreference = json['call_preference'] as String?;

  Map<String, dynamic> toJson() => {
    'id': id,
    'account_id': accountId,
    'status': status,
    'chat_preference': chatPreference,
    'call_preference': callPreference,
  };
}
