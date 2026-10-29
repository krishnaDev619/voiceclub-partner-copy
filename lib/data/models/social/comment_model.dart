import 'dart:io';

import 'package:timeago/timeago.dart' as timeago;
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/data/models/notifications/user_data.dart';
import 'package:voiceclub_partner/data/models/social/reaction_counts_model.dart';
import 'package:voiceclub_partner/data/models/social/reply_model.dart';

class CommentModel {
  final String? id;
  final String? postId;
  final CommentType? commentType;
  final String? textContent;
  final String? mediaUrl;
  final ReplyModel? mostRelevantReply;
  ReactionType? myReaction;
  ReactionCountsModel? reactionCounts;
  final UserDataModel? user;
  final DateTime? createdAt;
  final int? totalReplyCount;
  File? attachment;

  CommentModel({
    this.id,
    this.postId,
    this.commentType,
    this.textContent,
    this.mediaUrl,
    this.mostRelevantReply,
    this.reactionCounts,
    this.user,
    this.myReaction,
    this.createdAt,
    this.totalReplyCount,
    this.attachment,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'] as String?,
      postId: json['post_id'] as String?,
      commentType: (json['comment_type'] as String?)?.toCommentType(),
      textContent: json['text_content'] as String?,
      mediaUrl: json['media_url'] as String?,
      mostRelevantReply:
          json['most_relevant_reply'] != null
              ? ReplyModel.fromJson(
                json['most_relevant_reply'] as Map<String, dynamic>,
              )
              : null,
      reactionCounts:
          json['reaction_counts'] != null
              ? ReactionCountsModel.fromJson(
                json['reaction_counts'] as Map<String, dynamic>,
              )
              : null,
      myReaction:
          json['my_reaction'] != null
              ? (json['my_reaction'] as String).toReactionType()
              : null,
      user:
          json['user'] != null
              ? UserDataModel.fromJson(json['user'] as Map<String, dynamic>)
              : null,
      createdAt:
          json['created_at'] != null
              ? DateTime.tryParse(json['created_at'] as String)
              : null,
      totalReplyCount: json['total_reply_count'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'post_id': postId,
      'comment_type': commentType?.name,
      'text_content': textContent,
      'media_url': mediaUrl,
      'most_relevant_reply': mostRelevantReply?.toJson(),
      'reaction_counts': reactionCounts?.toJson(),
      'user': user?.toJson(),
      'created_at': createdAt?.toIso8601String(),
      'my_reaction': myReaction?.name,
      'total_reply_count': totalReplyCount,
    };
  }

  String get timeAgo {
    return timeago.format(createdAt?.toLocal() ?? DateTime.now());
  }

  bool get isLiked {
    return myReaction == ReactionType.LIKE;
  }

  void toggleLike() {
    if (isLiked) {
      myReaction = null;
      if (reactionCounts != null) {
        reactionCounts = ReactionCountsModel(
          like: (reactionCounts?.like ?? 1) - 1,
          love: reactionCounts?.love,
          haha: reactionCounts?.haha,
        );
      }
    } else {
      myReaction = ReactionType.LIKE;
      if (reactionCounts != null) {
        reactionCounts = ReactionCountsModel(
          like: (reactionCounts?.like ?? 0) + 1,
          love: reactionCounts?.love,
          haha: reactionCounts?.haha,
        );
      } else {
        reactionCounts = ReactionCountsModel(like: 1, love: 0, haha: 0);
      }
    }
  }

  Map<String, dynamic> get eventProperties {
    return {
      "commentId": id,
      "commentType": commentType?.name,
      "commentText": textContent,
      "commentMediaUrl": mediaUrl,
      "commentUser": user?.name,
      "commentUserRole": user?.role?.name,
      "commentUserPhone": user?.phoneNumber,
      "commentUploadedAt": createdAt?.toUtc().toIso8601String(),
      "commentTotalLikeCount": reactionCounts?.like,
      "commentTotalReplyCount": totalReplyCount,
    };
  }
}
