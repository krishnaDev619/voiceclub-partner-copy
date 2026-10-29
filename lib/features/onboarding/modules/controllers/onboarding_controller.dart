import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/features/onboarding/core/constants/enums.dart';
import 'package:voiceclub_partner/features/onboarding/core/injection_container.dart';
import 'package:voiceclub_partner/features/onboarding/core/services/analytics_service.dart';

class OnboardingController extends GetxController {
  final pageController = PageController().obs;
  final completedStep = OnboardingStep.Pending.obs;
  var onboardingSteps = OnboardingStep.values;
  final progress = 0.0.obs; // Returns progress percentage (0 to 1)
  final completedSteps = 0.obs; // Get the index of the current step

  // Get the index of the current step
  int get completedStepIndex => onboardingSteps.indexOf(completedStep.value);

  // Total steps count
  int get totalSteps => onboardingSteps.length - 1;

  // Update Step
  void updateCompletedStep({required OnboardingStep step}) {
    completedStep(step);
    completedSteps.value = completedStepIndex;
    progress.value = (completedSteps) / totalSteps;
  }

  void jumpToNextPage() async {
    update();
    await pageController.value.nextPage(
      duration: const Duration(milliseconds: 500),
      curve: Curves.linear,
    );
  }

  void jumpToPreviousPage() async {
    update();
    await pageController.value.previousPage(
      duration: const Duration(milliseconds: 500),
      curve: Curves.linear,
    );
    sl<AnalyticsService>().trackEvent(
      "previousQuestionPressed",
      eventProperties: {"questionNumber": pageController.value.page},
    );
  }

  String formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
