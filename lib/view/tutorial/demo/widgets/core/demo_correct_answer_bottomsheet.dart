import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:voiceclub_partner/core/constants/asset_constants.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/modules/controller/user_controller.dart';
import 'package:voiceclub_partner/view/widgets/custom_button.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';

class DemoCorrectAnswerBottomSheet extends StatelessWidget {
  final bool isLastQuestion;
  final bool isQuiz;
  const DemoCorrectAnswerBottomSheet({
    super.key,
    required this.isLastQuestion,
    this.isQuiz = false,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
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
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (isLastQuestion)
              Lottie.asset(
                AssetConstants.celebrationAnimation,
                width: double.infinity,
              ),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Spacer(),
                const Icon(
                  Icons.check_circle_rounded,
                  color: Colors.green,
                  size: 120.0,
                ),
                const SizedBox(height: 24.0),
                Text(
                  isLastQuestion
                      ? LocaleKeys.demoCongratulations.tr
                      : LocaleKeys.demoPerfect.tr,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: FontSize.xXL,
                  ),
                ),
                Expanded(
                  child: Text(
                    isLastQuestion
                        ? LocaleKeys.demoPassedStage.trParams({
                          'stage':
                              Get.find<UserController>().currentStage
                                  .toStageString(),
                        })
                        : LocaleKeys.demoAnsweredCorrectly.tr,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: FontSize.xL,
                      color: Colors.green,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const Spacer(),
                CustomButton(
                  text:
                      isLastQuestion
                          ? LocaleKeys.continueLabel.tr
                          : LocaleKeys.demoNext.tr,
                  color: Colors.green,
                  onTap: () {
                    HapticFeedback.vibrate();
                    Get.back();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
