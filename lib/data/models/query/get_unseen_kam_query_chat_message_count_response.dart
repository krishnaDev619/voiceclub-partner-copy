class GetUnseenKamQueryChatMessageCountResponse {
  final int? kamMessageCount;

  GetUnseenKamQueryChatMessageCountResponse({this.kamMessageCount});

  factory GetUnseenKamQueryChatMessageCountResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    return GetUnseenKamQueryChatMessageCountResponse(
      kamMessageCount: json['kam_message_count'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {'kam_message_count': kamMessageCount};
}
