import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:voiceclub_partner/core/constants/asset_constants.dart';
import 'package:voiceclub_partner/core/injection_container.dart';
import 'package:voiceclub_partner/core/services/analytics_service.dart';
import 'package:voiceclub_partner/core/services/app_update_service.dart';
import 'package:voiceclub_partner/core/services/notification_service.dart';
import 'package:voiceclub_partner/view/landing/retry_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      checkConnectivity();
    });
    super.initState();
  }

  void checkConnectivity() async {
    try {
      final result = await InternetConnection().hasInternetAccess;
      if (result) {
        getInit();
        AppUpdateService.fetchConfigStatus(isSplash: true);
      } else {
        Get.offAll(() => const RetryScreen(errorReason: "404"));
      }
    } catch (_) {}
  }

  Future<void> getInit() async {
    sl<AnalyticsService>().trackEvent("splashScreen");
    NotificationService.requestNotificationPermissions();
    await [
      Permission.notification,
      Permission.microphone,
      Permission.storage,
      Permission.bluetooth,
      Permission.bluetoothAdvertise,
      Permission.bluetoothConnect,
    ].request();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(20.0),
            height: 100.0,
            width: 100.0,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(AssetConstants.logo),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
