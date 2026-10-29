import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/data/models/notifications/user_data.dart';

class Engagements {
  final String? storyId;
  final UserDataModel? user;
  final String? comment;
  final String? commentType;
  final ReactionType? reactionType;
  final String? createdAt;
  final String? updatedAt;

  Engagements({
    this.storyId,
    this.user,
    this.comment,
    this.commentType,
    this.reactionType,
    this.createdAt,
    this.updatedAt,
  });

  Engagements.fromJson(Map<String, dynamic> json)
    : storyId = json['story_id'] as String?,
      user =
          (json['user'] as Map<String, dynamic>?) != null
              ? UserDataModel.fromJson(json['user'] as Map<String, dynamic>)
              : null,
      comment = json['comment'] as String?,
      commentType = json['comment_type'] as String?,
      reactionType = (json['reaction_type'] as String?)?.toReactionType(),
      createdAt = json['created_at'] as String?,
      updatedAt = json['updated_at'] as String?;

  Map<String, dynamic> toJson() => {
    'story_id': storyId,
    'user': user?.toJson(),
    'comment': comment,
    'comment_type': commentType,
    'reaction_type': reactionType?.name,
    'created_at': createdAt,
    'updated_at': updatedAt,
  };
}
