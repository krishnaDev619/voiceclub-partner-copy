import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/core/injection_container.dart';
import 'package:voiceclub_partner/core/services/analytics_service.dart';
import 'package:voiceclub_partner/view/widgets/custom_button.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';

class WarningScreen extends StatefulWidget {
  final String title;
  final String warning;
  final String suggestion;
  final VoidCallback action;
  final bool autostart;

  const WarningScreen({
    super.key,
    required this.title,
    required this.warning,
    required this.suggestion,
    required this.action,
    required this.autostart,
  });

  @override
  State<WarningScreen> createState() => _WarningScreenState();
}

class _WarningScreenState extends State<WarningScreen> {
  @override
  void initState() {
    super.initState();
    sl<AnalyticsService>().trackEvent(
      "partnerTroubleshootingFailed",
      eventProperties: {
        "title": widget.title,
        "warning": widget.warning,
        "suggestion": widget.suggestion,
        "autostart": widget.autostart,
      },
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 500), () {
        widget.action();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(height: 40.0),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.warning_rounded,
                        size: 120.0,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        widget.warning,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: Weight.heavy,
                          fontSize: FontSize.xXL,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Text(widget.suggestion, textAlign: TextAlign.center),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          onTap: widget.action,
                          text: LocaleKeys.liveFix.tr,
                          filled: false,
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(width: 12.0),
                      Expanded(
                        child: CustomButton(
                          onTap: () {
                            Get.back(result: true);
                          },
                          color: Colors.red,
                          text: LocaleKeys.liveRetry.tr,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
