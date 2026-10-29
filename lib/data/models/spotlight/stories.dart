import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/data/models/notifications/user_data.dart';

class Stories {
  final String? id;
  final int? userId;
  final UserDataModel? user;
  final StoryType? storyType;
  final String? textOverlay;
  final String? mediaUrl;
  final String? fontStyle;
  final String? storyColor;
  final String? date;
  final String? expiresAt;
  final String? createdAt;
  final String? updatedAt;
  final bool? seen;
  final num? likeCount;
  final num? commentCount;
  final num? viewCount;
  final bool? isReacted;

  Stories({
    this.id,
    this.userId,
    this.user,
    this.storyType,
    this.textOverlay,
    this.mediaUrl,
    this.fontStyle,
    this.storyColor,
    this.date,
    this.expiresAt,
    this.createdAt,
    this.updatedAt,
    this.seen,
    this.likeCount,
    this.commentCount,
    this.viewCount,
    this.isReacted,
  });

  Stories.fromJson(Map<String, dynamic> json)
    : id = json['id'] as String?,
      userId = json['user_id'] as int?,
      user =
          json['user'] != null
              ? UserDataModel.fromJson(json['user'] as Map<String, dynamic>)
              : null,
      storyType = (json['story_type'] as String?)?.toStoryType(),
      textOverlay = json['text_overlay'] as String?,
      mediaUrl = json['media_url'] as String?,
      fontStyle = json['font_style'] as String?,
      storyColor = json['story_color'] as String?,
      date = json['date'] as String?,
      expiresAt = json['expires_at'] as String?,
      createdAt = json['created_at'] as String?,
      updatedAt = json['updated_at'] as String?,
      seen = json['seen'] as bool?,
      likeCount = json['like_count'] as num?,
      commentCount = json['comment_count'] as num?,
      viewCount = json['view_count'] as num?,
      isReacted = json['is_reacted'] as bool?;

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'user': user?.toJson(),
    'story_type': storyType,
    'text_overlay': textOverlay,
    'media_url': mediaUrl,
    'font_style': fontStyle,
    'story_color': storyColor,
    'date': date,
    'expires_at': expiresAt,
    'created_at': createdAt,
    'updated_at': updatedAt,
    'seen': seen,
    'like_count': likeCount,
    'comment_count': commentCount,
    'view_count': viewCount,
    'is_reacted': isReacted,
  };

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

  // Helper getters
  Color get textColor {
    return _hexToColor(storyColor ?? "");
  }
}
