import 'package:voiceclub_partner/core/constants/enums.dart';

class GetPendingPostStatusResponseModel {
  final String? id;
  final int? userId;
  final String? createdAt;
  final String? postType;
  final String? textContent;
  final String? fontStyle;
  final String? mediaUrl;
  final String? postColor;
  final PostModerationStatus? moderationStatus;
  final String? moderationComment;

  GetPendingPostStatusResponseModel({
    this.id,
    this.userId,
    this.createdAt,
    this.postType,
    this.textContent,
    this.fontStyle,
    this.mediaUrl,
    this.postColor,
    this.moderationStatus,
    this.moderationComment,
  });

  GetPendingPostStatusResponseModel.fromJson(Map<String, dynamic> json)
    : id = json['id'] as String?,
      userId = json['user_id'] as int?,
      createdAt = json['created_at'] as String?,
      postType = json['post_type'] as String?,
      textContent = json['text_content'] as String?,
      fontStyle = json['font_style'] as String?,
      mediaUrl = json['media_url'] as String?,
      postColor = json['post_color'] as String?,
      moderationStatus =
          (json['moderation_status'] as String?)?.toPostModerationStatus(),
      moderationComment = json['moderation_comment'] as String?;

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'created_at': createdAt,
    'post_type': postType,
    'text_content': textContent,
    'font_style': fontStyle,
    'media_url': mediaUrl,
    'post_color': postColor,
    'moderation_status': moderationStatus,
    'moderation_comment': moderationComment,
  };
}
