import 'package:voiceclub_partner/core/constants/enums.dart';

class QuerySession {
  final int? id;
  final DateTime? createdAt;
  final String? sessionId;
  final QuerySessionStatus? status;
  final QueryCategory? category;
  final String? title;
  final String? comment;
  final String? stage;
  final String? kamName;
  final int? kamMessageCount;

  QuerySession({
    this.id,
    this.createdAt,
    this.sessionId,
    this.status,
    this.category,
    this.title,
    this.comment,
    this.stage,
    this.kamName,
    this.kamMessageCount,
  });

  QuerySession.fromJson(Map<String, dynamic> json)
    : id = json['id'] as int?,
      createdAt =
          json['created_at'] != null
              ? DateTime.tryParse(json['created_at'] as String)
              : null,
      sessionId = json['session_id'] as String?,
      status = (json['status'] as String?)?.toQuerySessionStatus(),
      category = (json['category'] as String?)?.toQueryCategory(),
      title = json['title'] as String?,
      comment = json['comment'] as String?,
      stage = json['stage'] as String?,
      kamName = json['kam_name'] as String?,
      kamMessageCount = json['kam_message_count'] as int?;

  Map<String, dynamic> toJson() => {
    'id': id,
    'created_at': createdAt?.toIso8601String(),
    'session_id': sessionId,
    'status': status?.name,
    'category': category?.name,
    'title': title,
    'comment': comment,
    'stage': stage,
    'kam_name': kamName,
    'kam_message_count': kamMessageCount,
  };
}
