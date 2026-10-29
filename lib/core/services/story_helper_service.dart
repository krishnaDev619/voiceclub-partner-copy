import 'package:flutter/material.dart';

class StoryHelperService {
  static String colorToHex(Color color) {
    return '#${color.toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase()}';
  }

  static Color hexToColor(String hexString) {
    hexString = hexString.toUpperCase().replaceAll("#", "");
    if (hexString.length == 6) {
      hexString = "FF$hexString";
    }
    return Color(int.parse(hexString, radix: 16));
  }

  static String calculateTimeElapsed(String createdAt) {
    DateTime now = DateTime.now();
    DateTime createdAtTime = DateTime.parse(createdAt);

    Duration difference = now.difference(createdAtTime);

    if (difference.inHours < 1) {
      int minutes = difference.inMinutes;
      return '$minutes m';
    } else {
      int hours = difference.inHours;
      return '$hours h';
    }
  }

  static String calculateTimeToExpire(String createdAt) {
    DateTime now = DateTime.now();
    DateTime createdAtTime = DateTime.parse(createdAt);

    // Calculate expiry time (24 hours after created_at)
    DateTime expiryTime = createdAtTime.add(const Duration(hours: 24));

    Duration difference = expiryTime.difference(now);

    if (difference.inHours < 1) {
      int minutes = difference.inMinutes;
      return '$minutes m';
    } else {
      int hours = difference.inHours;
      return '$hours h';
    }
  }
}
