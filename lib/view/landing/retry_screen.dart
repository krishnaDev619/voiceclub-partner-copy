import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:restart_app/restart_app.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/core/injection_container.dart';
import 'package:voiceclub_partner/core/services/analytics_service.dart';

class RetryScreen extends StatefulWidget {
  final String errorReason;
  const RetryScreen({super.key, required this.errorReason});

  @override
  State<RetryScreen> createState() => _RetryScreenState();
}

class _RetryScreenState extends State<RetryScreen> {
  StreamSubscription<InternetStatus>? listener;
  @override
  void initState() {
    sl<AnalyticsService>().trackEvent(
      "retryScreenPartner",
      eventProperties: {"errorReason": widget.errorReason},
    );
    super.initState();
  }

  void listenConnectivity() {
    listener = InternetConnection().onStatusChange.listen((status) {
      if (status == InternetStatus.connected) {
        Restart.restartApp();
      }
    });
  }

  @override
  void dispose() {
    if (listener != null) listener!.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(13.0),
          child: InkWell(
            onTap: Restart.restartApp,
            child: Container(
              height: 50,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: Get.theme.primaryColor.withValues(alpha: 1),
              ),
              child: const Center(
                child: Text(
                  "Retry",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(
            Icons.wifi_off_rounded,
            size: 144.0,
            color: ApplicationColors.gossip,
          ),
          const SizedBox(height: 16.0),
          const Center(
            child: Text(
              "Something went wrong.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text(
                "Please check your internet connection.\n(${widget.errorReason})",
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
