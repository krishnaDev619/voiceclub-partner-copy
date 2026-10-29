import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';
import 'package:voiceclub_partner/view/widgets/custom_button.dart';

class OnboardingStepperButton extends StatelessWidget {
  final OnboardingStep currentStep;
  final VoidCallback? onTap;

  const OnboardingStepperButton({
    super.key,
    required this.currentStep,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    String text = LocaleKeys.continueLabel.tr;
    if (currentStep == OnboardingStep.PROFILE_AUDIO) {
      text = LocaleKeys.upload.tr;
    }

    return Padding(
      padding: EdgeInsets.only(right: Get.width / 3, top: 16.0),
      child: CustomButton(
        onTap: onTap,
        text: text,
        padding: const EdgeInsets.symmetric(vertical: 8.0),
      ),
    );
  }
}
