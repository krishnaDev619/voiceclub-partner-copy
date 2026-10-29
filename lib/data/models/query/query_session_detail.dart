import 'package:voiceclub_partner/core/constants/enums.dart';

class QuerySessionDetail {
  final int? id;
  final String? sessionId;
  final QuerySessionStatus? status;
  final QueryCategory? category;
  final String? title;
  final String? comment;
  final PartnerCurrentStatus? stage;
  final String? kamName;
  final bool? callAllowed;
  final bool? messageAllowed;
  final String? workingHourMessage;
  final bool? mediaAllowed;
  final bool? endButtonAllowed;

  QuerySessionDetail({
    this.id,
    this.sessionId,
    this.status,
    this.category,
    this.title,
    this.comment,
    this.stage,
    this.kamName,
    this.callAllowed,
    this.messageAllowed,
    this.workingHourMessage,
    this.mediaAllowed,
    this.endButtonAllowed,
  });

  QuerySessionDetail.fromJson(Map<String, dynamic> json)
    : id = json['id'] as int?,
      sessionId = json['session_id'] as String?,
      status = (json['status'] as String?)?.toQuerySessionStatus(),
      category = (json['category'] as String?)?.toQueryCategory(),
      title = json['title'] as String?,
      comment = json['comment'] as String?,
      stage = (json['stage'] as String?)?.toPartnerCurrentStatus(),
      kamName = json['kam_name'] as String?,
      callAllowed = json['call_allowed'] as bool?,
      messageAllowed = json['message_allowed'] as bool?,
      workingHourMessage = json['working_hours_message'] as String?,
      mediaAllowed = json['media_allowed'] as bool?,
      endButtonAllowed = json['end_button_allowed'] as bool?;

  Map<String, dynamic> toJson() => {
    'id': id,
    'session_id': sessionId,
    'status': status?.name,
    'category': category?.name,
    'title': title,
    'comment': comment,
    'stage': stage?.name,
    'kam_name': kamName,
    'call_allowed': callAllowed,
    'message_allowed': messageAllowed,
    'working_hours_message': workingHourMessage,
    'media_allowed': mediaAllowed,
    'end_button_allowed': endButtonAllowed,
  };
}
