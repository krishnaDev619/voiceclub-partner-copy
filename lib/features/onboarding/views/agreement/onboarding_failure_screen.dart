import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/features/onboarding/core/injection_container.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';
import 'package:voiceclub_partner/features/onboarding/core/services/analytics_service.dart';
import 'package:voiceclub_partner/features/onboarding/modules/controllers/auth_controller.dart';
import 'package:voiceclub_partner/view/widgets/custom_button.dart';

class OnboardingFailureScreen extends StatelessWidget {
  final String documentPath;

  const OnboardingFailureScreen({super.key, required this.documentPath});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    sl<AnalyticsService>().trackEvent("onboardingFailureScreen");

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // Error Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline,
                  size: 60,
                  color: Colors.red.shade400,
                ),
              ),
              const SizedBox(height: 32),

              // Title
              Text(
                LocaleKeys.technicalIssue.tr,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Subtitle
              Text(
                LocaleKeys.technicalIssueBody.tr,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              // Retry Button
              CustomButton(
                text: LocaleKeys.completeOnboarding.tr,
                onTap: () {
                  authController.retryCompleteOnboarding(documentPath);
                },
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
