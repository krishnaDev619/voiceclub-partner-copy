import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';

class CancelAlertDialog extends StatelessWidget {
  const CancelAlertDialog({super.key, required this.title, this.subtitle});
  final String title;
  final String? subtitle;
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      title: Text(
        title,
        style: TextStyle(
          color: Get.theme.primaryColor,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: (subtitle?.isNotEmpty ?? false) ? Text(subtitle!) : null,
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Get.back(result: false); // No option
          },
          style: TextButton.styleFrom(
            foregroundColor: Colors.grey, // Set text color to red
          ),
          child: Text(LocaleKeys.liveNo.tr),
        ),
        TextButton(
          onPressed: () {
            Get.back(result: true); // Yes option
          },
          style: TextButton.styleFrom(
            foregroundColor: Get.theme.primaryColor, // Set text color to red
          ),
          child: Text(LocaleKeys.liveYes.tr),
        ),
      ],
    );
  }
}
