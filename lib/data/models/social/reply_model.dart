import 'package:timeago/timeago.dart' as timeago;
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/data/models/notifications/user_data.dart';
import 'package:voiceclub_partner/data/models/social/reaction_counts_model.dart';

class ReplyModel {
  final String? id;
  final String? postId;
  final String? commentId;
  final String? textContent;
  ReactionCountsModel? reactionCounts;
  ReactionType? myReaction;
  final UserDataModel? user;
  final DateTime? createdAt;

  ReplyModel({
    required this.id,
    required this.postId,
    required this.commentId,
    required this.textContent,
    required this.reactionCounts,
    required this.user,
    required this.myReaction,
    required this.createdAt,
  });

  factory ReplyModel.fromJson(Map<String, dynamic> json) {
    return ReplyModel(
      id: json['id'] as String?,
      postId: json['post_id'] as String?,
      commentId: json['comment_id'] as String?,
      textContent: json['text_content'] as String?,
      reactionCounts:
          json['reaction_counts'] != null
              ? ReactionCountsModel.fromJson(
                json['reaction_counts'] as Map<String, dynamic>,
              )
              : null,
      user:
          json['user'] != null
              ? UserDataModel.fromJson(json['user'] as Map<String, dynamic>)
              : null,
      createdAt:
          json['created_at'] != null
              ? DateTime.tryParse(json['created_at'] as String)
              : null,
      myReaction:
          json['my_reaction'] != null
              ? (json['my_reaction'] as String).toReactionType()
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'post_id': postId,
      'comment_id': commentId,
      'text_content': textContent,
      'reaction_counts': reactionCounts?.toJson(),
      'user': user?.toJson(),
      'created_at': createdAt?.toIso8601String(),
      'my_reaction': myReaction?.name,
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
      "replyId": id,
      "replyText": textContent,
      "replyUser": user?.name,
      "replyUserRole": user?.role?.name,
      "replyUserPhone": user?.phoneNumber,
      "replyUploadedAt": createdAt?.toUtc().toIso8601String(),
      "replyTotalLikeCount": reactionCounts?.like,
    };
  }
}
