import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/injection_container.dart';
import 'package:voiceclub_partner/core/services/alert_service.dart';
import 'package:voiceclub_partner/core/services/analytics_service.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';

class DynamicScreen extends StatefulWidget {
  final String? title;
  final String? subtitle;

  const DynamicScreen({super.key, this.title, this.subtitle});

  @override
  State<DynamicScreen> createState() => _DynamicScreenState();
}

class _DynamicScreenState extends State<DynamicScreen> {
  @override
  void initState() {
    sl<AnalyticsService>().trackEvent("dynamicScreen");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(13.0),
        child: InkWell(
          onTap: () async {
            await Clipboard.setData(
              const ClipboardData(text: "help@voiceclub.app"),
            );

            AlertService.showSnackBar(
              snackBarType: SnackBarType.Success,
              title: LocaleKeys.liveCopied.tr,
              subtitle: "help@voiceclub.app",
            );
          },
          child: Container(
            height: 50,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: Get.theme.primaryColor.withValues(alpha: 1),
            ),
            child: Center(
              child: Text(
                "For any queries, please contact us".toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
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
          Center(
            child: Text(
              widget.title ?? 'App under mainteneance',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text(widget.subtitle ?? '', textAlign: TextAlign.center),
            ),
          ),
        ],
      ),
    );
  }
}
