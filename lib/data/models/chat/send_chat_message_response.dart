class SendChatMessageResponseModel {
  final String? code;
  final int? count;
  final String? message;
  final String? attachmentUrl;
  final int? id;
  final int? limit;

  SendChatMessageResponseModel({
    this.code,
    this.count,
    this.message,
    this.attachmentUrl,
    this.id,
    this.limit,
  });

  SendChatMessageResponseModel.fromJson(Map<String, dynamic> json)
    : code = json['code'] as String?,
      count = json['count'] as int?,
      attachmentUrl = json['attachmentUrl'] as String?,
      message = json['message'] as String?,
      limit = json['limit'] as int?,
      id = json['id'] as int?;

  Map<String, dynamic> toJson() => {
    'code': code,
    'count': count,
    'message': message,
    'attachmentUrl': attachmentUrl,
    'id': id,
    'limit': limit,
  };
}
