import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:voiceclub_partner/core/constants/asset_constants.dart';

class ChatTheme extends Equatable {
  final int? purchaseId;
  final String? appBarBackground;
  final String? appBarContent;
  final String? primary;
  final String? secondaryBubble;
  final String? id;
  final String? displayName;
  final String? assetPath;
  final String? statusBarIconBrightnessString;
  final String? type;
  final int? price;
  final bool? hasPurchased;

  const ChatTheme({
    this.purchaseId,
    this.appBarBackground,
    this.appBarContent,
    this.primary,
    this.secondaryBubble,
    this.id,
    this.displayName,
    this.assetPath,
    this.statusBarIconBrightnessString,
    this.type,
    this.price,
    this.hasPurchased,
  });

  ChatTheme.fromJson(Map<String, dynamic> json)
    : purchaseId = json['themeId'] as int?,
      appBarBackground = json['appBarBackground'] as String?,
      appBarContent = json['appBarContent'] as String?,
      primary = json['primary'] as String?,
      secondaryBubble = json['secondaryBubble'] as String?,
      id = json['id'] as String?,
      displayName = json['displayName'] as String?,
      assetPath = json['assetPath'] as String?,
      statusBarIconBrightnessString =
          json['statusBarIconBrightness'] as String?,
      type = json['type'] as String?,
      price = json['price'] as int?,
      hasPurchased = json['hasPurchased'] as bool?;

  Map<String, dynamic> toJson() => {
    'themeId': purchaseId,
    'appBarBackground': appBarBackground,
    'appBarContent': appBarContent,
    'primary': primary,
    'secondaryBubble': secondaryBubble,
    'id': id,
    'displayName': displayName,
    'assetPath': assetPath,
    'statusBarIconBrightness': statusBarIconBrightnessString,
    'type': type,
    'price': price,
    'hasPurchased': hasPurchased,
  };

  // Create production grade getters with error handling

  // Convert hex color to Color object
  Color get appBarBackgroundColor {
    try {
      return _hexToColor(appBarBackground ?? "");
    } catch (e) {
      return const Color(0xFFEE6464);
    }
  }

  Color get appBarContentColor {
    try {
      return _hexToColor(appBarContent ?? "");
    } catch (e) {
      return const Color(0xFFFFFFFF);
    }
  }

  Color get primaryColor {
    try {
      return _hexToColor(primary ?? "");
    } catch (e) {
      return const Color(0xFFEE6464);
    }
  }

  Color get secondaryBubbleColor {
    try {
      return _hexToColor(secondaryBubble ?? "");
    } catch (e) {
      return const Color(0xFFFFFFFF);
    }
  }

  Brightness get statusBarIconBrightness {
    // dart/light
    try {
      if (statusBarIconBrightnessString?.trim().toLowerCase() == 'dark') {
        return Brightness.dark;
      } else {
        return Brightness.light;
      }
    } catch (e) {
      return Brightness.light;
    }
  }

  // type (FREE/PAID)
  bool get isFree {
    return type?.trim().toUpperCase() == 'FREE';
  }

  bool get isLocked {
    return !isFree && hasPurchased != true;
  }

  Color _hexToColor(String hexString) {
    hexString = hexString.toUpperCase().replaceAll("#", "");
    if (hexString.length == 6) {
      hexString = "FF$hexString";
    }
    return Color(int.parse(hexString, radix: 16));
  }

  @override
  List<Object?> get props => [id];
}

const defaultTheme = ChatTheme(
  id: "defaultTheme",
  displayName: "Default",
  assetPath: AssetConstants.chatBackground,
  statusBarIconBrightnessString: "light",
  type: "FREE",
  appBarBackground: "#EE6464",
  appBarContent: "#FFFFFF",
  primary: "#EE6464",
  secondaryBubble: "#FFFFFF",
);

const defaultThemeId = "defaultTheme";
