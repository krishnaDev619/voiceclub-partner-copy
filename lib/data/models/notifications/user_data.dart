import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';

part 'user_data.g.dart';

@HiveType(typeId: 6)
class UserDataModel {
  @HiveField(0)
  final int? id;
  @HiveField(1)
  final String? name;
  @HiveField(2)
  final String? phoneNumber;
  @HiveField(3)
  final String? avatar;
  @HiveField(4)
  final String? status;
  @HiveField(5)
  final String? fcmToken;
  @HiveField(6)
  final String? notificationPreference;
  @HiveField(7)
  final bool? hasUpdatedName;
  @HiveField(8)
  final bool? hasUpdatedImage;
  @HiveField(9)
  final String? tag;
  @HiveField(10)
  final AccountType? role;
  UserDataModel({
    this.id,
    this.name,
    this.phoneNumber,
    this.avatar,
    this.status,
    this.fcmToken,
    this.notificationPreference,
    this.hasUpdatedName,
    this.hasUpdatedImage,
    this.tag,
    this.role,
  });

  UserDataModel.fromJson(Map<String, dynamic> json)
    : id = json['id'] as int?,
      name = json['name'] as String?,
      phoneNumber = json['phone_number'] as String?,
      avatar = json['avatar'] as String?,
      status = json['status'] as String?,
      notificationPreference = json['preference'] as String?,
      fcmToken = json['fcm_token'] as String?,
      hasUpdatedName = json['has_updated_name'] as bool?,
      hasUpdatedImage = json['has_updated_image'] as bool?,
      tag = json['tag'] as String?,
      role = (json['role'] as String? ?? "").toAccountType();

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'phone_number': phoneNumber,
    'avatar': avatar,
    'status': status,
    'preference': notificationPreference,
    'fcm_token': fcmToken,
    'has_updated_name': hasUpdatedName,
    'has_updated_image': hasUpdatedImage,
    'tag': tag,
    'role': role?.name,
  };

  String get encodedJson => jsonEncode(toJson());

  bool get hasCompletedAccountCreation =>
      hasUpdatedName == true && hasUpdatedImage == true;

  Widget get tagWidget {
    if (role == AccountType.SUPPLY) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 4),
        child: Icon(Icons.verified, color: Colors.blue, size: 14),
      );
    }

    final trimmedTag = tag?.trim().toUpperCase() ?? '';
    Color textColor;
    LinearGradient gradient;
    List<BoxShadow>? shadows;

    switch (trimmedTag) {
      case 'NEW':
        return const SizedBox(width: 5);
      case 'SILVER':
        textColor = const Color(0xFF2C2C2C);
        gradient = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE8E8E8), Color(0xFFFFFFFF), Color(0xFFE8E8E8)],
        );
        shadows = [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.5),
            blurRadius: 1,
            offset: const Offset(0, 0),
          ),
        ];
        break;
      case 'GOLD':
        textColor = const Color(0xFF8B6B0E);
        gradient = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFD700), Color(0xFFFFF8DC), Color(0xFFFFD700)],
        );
        shadows = [
          BoxShadow(
            color: Colors.amber.withValues(alpha: 0.5),
            blurRadius: 1,
            offset: const Offset(0, 0),
          ),
        ];
        break;
      case 'PREMIUM':
        textColor = Colors.white;
        gradient = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF00695C), // Dark teal
            Color(0xFF00897B), // Medium teal
            Color(0xFF00695C), // Dark teal
          ],
        );
        shadows = [
          BoxShadow(
            color: const Color(0xFF00695C).withValues(alpha: 0.5),
            blurRadius: 2,
            offset: const Offset(0, 0),
          ),
        ];
        break;
      case 'VIP':
        textColor = Colors.white;
        gradient = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF9B30FF), Color(0xFF7B68EE), Color(0xFF9B30FF)],
        );
        shadows = [
          BoxShadow(
            color: const Color(0xFF9B30FF).withValues(alpha: 0.5),
            blurRadius: 2,
            offset: const Offset(0, 0),
          ),
        ];
        break;
      case 'VVIP':
        textColor = Colors.white;
        gradient = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF000000),
            Color(0xFF4A4A4A), // Brighter middle tone for shine
            Color(0xFF000000),
          ],
        );
        shadows = [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 2,
            offset: const Offset(0, 0),
          ),
        ];
        break;
      default:
        return const SizedBox(width: 5);
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(4),
        boxShadow: shadows,
      ),
      child: Text(
        trimmedTag,
        style: TextStyle(
          color: textColor,
          fontSize: 7.0,
          fontWeight: Weight.bold,
          letterSpacing: 0.5,
          shadows: [
            Shadow(
              color: Colors.black.withValues(alpha: 0.1),
              offset: const Offset(0, 0),
              blurRadius: 2,
            ),
          ],
        ),
      ),
    );
  }
}
