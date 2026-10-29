import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/features/onboarding/modules/controllers/onboarding_controller.dart';

class ProgressBar extends StatelessWidget {
  const ProgressBar({super.key});

  @override
  Widget build(BuildContext context) {
    final onboardingController = Get.find<OnboardingController>();
    return Obx(() {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LinearProgressIndicator(
              backgroundColor: Colors.grey.shade400,
              color: Colors.redAccent,
              borderRadius: BorderRadius.circular(12.0),
              value:
                  onboardingController.progress.value != 0.0
                      ? onboardingController.progress.value
                      : 0.05,
              minHeight: 20.0,
            ),
            const SizedBox(height: 6.0),
            Text(
              "${onboardingController.completedSteps}/${onboardingController.totalSteps} steps completed",
              style: TextStyle(
                color: Get.theme.primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: FontSize.xL,
                overflow: TextOverflow.ellipsis,
              ),
              maxLines: 1,
            ),
          ],
        ),
      );
    });
  }
}
