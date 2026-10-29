import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/core/constants/asset_constants.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';

class AlertService {
  static void showSnackBar({
    required SnackBarType snackBarType,
    required String title,
    required String subtitle,
    TextButton? mainButton,
    Function(GetSnackBar)? onTap,
    Duration? duration,
    bool vibrate = false,
  }) {
    if (snackBarType == SnackBarType.Error || vibrate) {
      HapticFeedback.vibrate();
    }
    Get.snackbar(
      title,
      subtitle,
      onTap: onTap,
      backgroundColor: _getBackgroundColorFromType(snackBarType),
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(10),
      borderRadius: 16.0,
      duration: duration ?? const Duration(days: 365),
      mainButton:
          mainButton ??
          TextButton(
            onPressed: () {
              Get.back();
            },
            child: const Padding(
              padding: EdgeInsets.only(bottom: 8.0),
              child: Icon(Icons.close, color: Colors.white),
            ),
          ),
      icon: Padding(
        padding: const EdgeInsets.only(left: 8.0, right: 8.0),
        child: SvgPicture.asset(_getSnackBarImageFromType(snackBarType)),
      ),
      overlayBlur: 0.5,
      overlayColor: Colors.black.withValues(alpha: 0.3),
    );
  }

  static String _getSnackBarImageFromType(SnackBarType snackBarType) {
    switch (snackBarType) {
      case SnackBarType.Success:
        return AssetConstants.snackBarSuccessIc;
      case SnackBarType.Warning:
        return AssetConstants.snackBarWarningIc;
      case SnackBarType.Error:
        return AssetConstants.snackBarErrorIc;
    }
  }

  static Color _getBackgroundColorFromType(SnackBarType snackBarType) {
    switch (snackBarType) {
      case SnackBarType.Success:
        return const Color(0xFF1FAA3E);
      case SnackBarType.Warning:
        return const Color(0xFFEF8D32);
      case SnackBarType.Error:
        return const Color(0xFFE9573E);
    }
  }
}
