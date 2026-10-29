import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:voiceclub_partner/core/constants/asset_constants.dart';
import 'package:voiceclub_partner/core/injection_container.dart';
import 'package:voiceclub_partner/core/services/analytics_service.dart';
import 'package:voiceclub_partner/view/widgets/custom_button.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';

class EnableNotificationsScreen extends StatefulWidget {
  const EnableNotificationsScreen({super.key});

  @override
  State<EnableNotificationsScreen> createState() =>
      _EnableNotificationsScreenState();
}

class _EnableNotificationsScreenState extends State<EnableNotificationsScreen> {
  @override
  void initState() {
    sl<AnalyticsService>().trackEvent("partnerEnableNotificationsScreen");
    super.initState();
  }

  /// Request notification permission
  /// If permission is denied, show a snackbar to open app settings
  Future<void> requestNotifications() async {
    try {
      Permission.notification.request().then((value) {
        if (value == PermissionStatus.granted) {
          Get.back();
          sl<AnalyticsService>().updateNotificationsPermission();
        } else {
          _openAppSettings();
        }
      });
    } catch (_) {}
  }

  /// Navigate to the app settings
  Future<void> _openAppSettings() async {
    try {
      if (!(await openAppSettings())) {
        // Handle the error if unable to open settings
        Get.snackbar(
          LocaleKeys.homeNotifDenied.tr,
          LocaleKeys.homeNotifSettings.tr,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(days: 1),
          margin: const EdgeInsets.only(top: 12.0, left: 8.0, right: 8.0),
          overlayBlur: 2,
          mainButton: TextButton(
            onPressed: () {
              Get.back();
            },
            child: const Padding(
              padding: EdgeInsets.only(bottom: 8.0),
              child: Icon(Icons.close, color: Colors.white),
            ),
          ),
        );
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 64.0),
            Image.asset(
              AssetConstants.enableNotification,
              height: Get.height * 0.3,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 32.0),
            Center(
              child: Text(
                LocaleKeys.homeNotifRequired.tr,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16.0),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: Text(
                  LocaleKeys.homeTurnOnNotif.tr,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const Spacer(),
            CustomButton(
              text: LocaleKeys.homeTurnOn.tr,
              onTap: requestNotifications,
            ),
            TextButton(
              onPressed: () {
                Get.back();
              },
              child: Text(
                LocaleKeys.homeNotNow.tr,
                style: TextStyle(
                  color: Colors.black45,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
