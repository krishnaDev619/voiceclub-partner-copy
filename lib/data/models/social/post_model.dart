import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/data/models/notifications/user_data.dart';
import 'package:voiceclub_partner/data/models/social/comment_model.dart';
import 'package:voiceclub_partner/data/models/social/reaction_counts_model.dart';

class PostModel {
  final String? id;
  final int? userId;
  final PostMediaType? postType;
  final String? caption;
  final String? textOverlay;
  final String? mediaUrl;
  final String? postColor;
  final String? fontStyle;
  final DateTime? createdAt;
  final int? totalCommentCount;
  ReactionType? myReaction;
  ReactionCountsModel? reactionCounts;
  final CommentModel? mostRelevantComment;
  final UserDataModel? user;
  final int? accountId;
  final String? thumbnailUrl;
  final String? avatarUrl;

  PostModel({
    this.id,
    this.userId,
    this.postType,
    this.caption,
    this.textOverlay,
    this.mediaUrl,
    this.postColor,
    this.createdAt,
    this.totalCommentCount,
    this.reactionCounts,
    this.mostRelevantComment,
    this.user,
    this.fontStyle,
    this.myReaction,
    this.accountId,
    this.thumbnailUrl,
    this.avatarUrl,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'] as String?,
      userId: json['user_id'] as int?,
      postType: (json['post_type'] as String?)?.toPostMediaType(),
      caption: json['text_content'] as String?,
      textOverlay: json['text_overlay'] as String?,
      mediaUrl: json['media_url'] as String?,
      postColor: json['post_color'] as String?,
      fontStyle: json['font_style'] as String?,
      myReaction:
          json['my_reaction'] != null
              ? (json['my_reaction'] as String).toReactionType()
              : null,
      createdAt:
          json['created_at'] != null
              ? DateTime.tryParse(json['created_at'] as String)
              : null,
      totalCommentCount: json['total_comment_count'] as int?,
      reactionCounts:
          json['reaction_counts'] != null
              ? ReactionCountsModel.fromJson(
                json['reaction_counts'] as Map<String, dynamic>,
              )
              : null,
      mostRelevantComment:
          json['most_relevant_comment'] != null
              ? CommentModel.fromJson(
                json['most_relevant_comment'] as Map<String, dynamic>,
              )
              : null,
      user:
          json['user'] != null
              ? UserDataModel.fromJson(json['user'] as Map<String, dynamic>)
              : null,
      accountId: json['account_id'] as int?,
      thumbnailUrl: json['thumbnail_url'] as String?,
      avatarUrl: json['avatar_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'post_type': postType?.name,
      'text_content': caption,
      'text_overlay': textOverlay,
      'media_url': mediaUrl,
      'post_color': postColor,
      'font_style': fontStyle,
      'created_at': createdAt?.toIso8601String(),
      'total_comment_count': totalCommentCount,
      'reaction_counts': reactionCounts?.toJson(),
      'most_relevant_comment': mostRelevantComment?.toJson(),
      'user': user?.toJson(),
      'my_reaction': myReaction?.name,
      'account_id': accountId,
      'thumbnail_url': thumbnailUrl,
      'avatar_url': avatarUrl,
    };
  }

  // Helper getters
  Color get backgroundColor {
    return _hexToColor(postColor ?? "");
  }

  String get timeAgo {
    return timeago.format(createdAt?.toLocal() ?? DateTime.now());
  }

  bool get isLiked {
    return myReaction == ReactionType.LIKE;
  }

  // Helper method to convert hex color to Color
  Color _hexToColor(String hexString) {
    try {
      hexString = hexString.toUpperCase().replaceAll("#", "");
      if (hexString.length == 6) {
        hexString = "FF$hexString";
      }
      return Color(int.parse(hexString, radix: 16));
    } catch (_) {
      return Colors.white;
    }
  }

  // Get TextStyle from fontStyle string
  TextStyle getTextStyle({double fontSize = 24.0}) {
    // Default font style if none is specified
    if (fontStyle == null || fontStyle!.isEmpty) {
      return GoogleFonts.roboto(
        fontSize: fontSize,
        color: Colors.white,
        fontWeight: FontWeight.w500,
      );
    }

    // Map of font names to their style functions
    final Map<String, Function> fontMap = {
      'Roboto': GoogleFonts.roboto,
      'Playfair Display': GoogleFonts.playfairDisplay,
      'Montserrat': GoogleFonts.montserrat,
      'Dancing Script': GoogleFonts.dancingScript,
      'Poppins': GoogleFonts.poppins,
      'Lato': GoogleFonts.lato,
      'Raleway': GoogleFonts.raleway,
    };

    // Get the font function from the map
    final fontFunction = fontMap[fontStyle];

    // If the font is found, use it, otherwise fall back to Roboto
    if (fontFunction != null) {
      return fontFunction(
        fontSize: fontSize,
        color: Colors.white,
        fontWeight: FontWeight.w500,
      );
    } else {
      return GoogleFonts.roboto(
        fontSize: fontSize,
        color: Colors.white,
        fontWeight: FontWeight.w500,
      );
    }
  }

  void reactToPost(ReactionType reactionType) {
    final oldReaction = myReaction;
    myReaction = reactionType;

    if (reactionCounts != null) {
      // Remove count from old reaction if any
      final currentCounts = Map<String, int?>.from({
        'like': reactionCounts?.like,
        'love': reactionCounts?.love,
        'haha': reactionCounts?.haha,
        'heart': reactionCounts?.heart,
        'clap': reactionCounts?.clap,
        'cry': reactionCounts?.cry,
      });

      if (oldReaction != null) {
        final oldKey = _getReactionKey(oldReaction);
        currentCounts[oldKey] = (currentCounts[oldKey] ?? 1) - 1;
      }

      // Add count to new reaction
      final newKey = _getReactionKey(reactionType);
      currentCounts[newKey] = (currentCounts[newKey] ?? 0) + 1;

      reactionCounts = ReactionCountsModel(
        like: currentCounts['like'],
        love: currentCounts['love'],
        haha: currentCounts['haha'],
        heart: currentCounts['heart'],
        clap: currentCounts['clap'],
        cry: currentCounts['cry'],
      );
    } else {
      // Create new reaction counts
      reactionCounts = ReactionCountsModel(
        like: reactionType == ReactionType.LIKE ? 1 : 0,
        love: reactionType == ReactionType.LOVE ? 1 : 0,
        haha: reactionType == ReactionType.HAHA ? 1 : 0,
        heart: reactionType == ReactionType.HEART ? 1 : 0,
        clap: reactionType == ReactionType.CLAP ? 1 : 0,
        cry: reactionType == ReactionType.CRY ? 1 : 0,
      );
    }
  }

  void removeReaction() {
    if (myReaction != null && reactionCounts != null) {
      final currentCounts = Map<String, int?>.from({
        'like': reactionCounts?.like,
        'love': reactionCounts?.love,
        'haha': reactionCounts?.haha,
        'heart': reactionCounts?.heart,
        'clap': reactionCounts?.clap,
        'cry': reactionCounts?.cry,
      });

      final reactionKey = _getReactionKey(myReaction!);
      currentCounts[reactionKey] = (currentCounts[reactionKey] ?? 1) - 1;

      reactionCounts = ReactionCountsModel(
        like: currentCounts['like'],
        love: currentCounts['love'],
        haha: currentCounts['haha'],
        heart: currentCounts['heart'],
        clap: currentCounts['clap'],
        cry: currentCounts['cry'],
      );
    }
    myReaction = null;
  }

  String _getReactionKey(ReactionType reactionType) {
    switch (reactionType) {
      case ReactionType.LIKE:
        return 'like';
      case ReactionType.LOVE:
        return 'love';
      case ReactionType.HAHA:
        return 'haha';
      case ReactionType.HEART:
        return 'heart';
      case ReactionType.CLAP:
        return 'clap';
      case ReactionType.CRY:
        return 'cry';
    }
  }

  bool get hasReaction => myReaction != null;

  Map<String, dynamic> get eventProperties {
    return {
      "postId": id,
      "postType": postType?.name,
      "postUser": user?.name,
      "postUserRole": user?.role?.name,
      "postUserPhone": user?.phoneNumber,
      "postCaption": caption,
      "postText": textOverlay,
      "postMediaUrl": mediaUrl,
      "postTotalCommentCount": totalCommentCount,
      "postTotalLikeCount": reactionCounts?.totalReactions,
      "postUploadedAt": createdAt?.toUtc().toIso8601String(),
    };
  }
}
