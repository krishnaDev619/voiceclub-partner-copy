import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:restart_app/restart_app.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/view/widgets/custom_button.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';

class NextOnboardingStageBottomSheet extends StatelessWidget {
  final TutorialStage nextStage;
  final VoidCallback? onNextPressed;

  const NextOnboardingStageBottomSheet({
    super.key,
    required this.nextStage,
    this.onNextPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: PopScope(
        canPop: false,
        child: Container(
          height: Get.height * 0.5,
          padding: const EdgeInsets.all(16.0),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.0),
              topRight: Radius.circular(20.0),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox.shrink(),
              Column(
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    color: Colors.green,
                    size: 120.0,
                  ),
                  const SizedBox(height: 24.0),
                  Text(
                    LocaleKeys.demoCongratulations.tr,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: FontSize.xXL,
                    ),
                  ),
                  Text(
                    nextStage == TutorialStage.DONE
                        ? LocaleKeys.demoOnboardingComplete.tr
                        : LocaleKeys.demoUnlockedStage.trParams({
                          'stage': '${nextStage.index + 1}',
                        }),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: FontSize.L,
                      color: Colors.green,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              CustomButton(
                text: LocaleKeys.demoNext.tr,
                color: Colors.green,
                onTap:
                    onNextPressed ??
                    () {
                      HapticFeedback.vibrate();
                      Restart.restartApp();
                    },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
