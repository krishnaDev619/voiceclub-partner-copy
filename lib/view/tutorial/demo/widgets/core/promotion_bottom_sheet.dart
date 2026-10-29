import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:voiceclub_partner/core/constants/asset_constants.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/view/widgets/custom_button.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';

class PromotionBottomSheet extends StatelessWidget {
  final TutorialStage currentStage;
  const PromotionBottomSheet({super.key, required this.currentStage});

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
            Lottie.asset(
              AssetConstants.celebrationAnimation,
              width: double.infinity,
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 10.0),
                Text(
                  LocaleKeys.demoCongratulationsBang.tr,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: FontSize.xXXL,
                  ),
                ),
                const SizedBox(height: 16.0),
                Text.rich(
                  TextSpan(
                    text: LocaleKeys.demoAmongThe.tr,
                    children: [
                      TextSpan(
                        text:
                            currentStage == TutorialStage.S5
                                ? LocaleKeys.demoTop20.tr
                                : LocaleKeys.demoTop10.tr,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: FontSize.xXL,
                        ),
                      ),
                      TextSpan(
                        text: LocaleKeys.demoMovedTo.tr,
                        style: TextStyle(fontSize: FontSize.xXL),
                      ),
                    ],
                    style: const TextStyle(fontSize: FontSize.xXL),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6.0),
                Text(
                  currentStage == TutorialStage.S3
                      ? LocaleKeys.demoNewLive.tr
                      : LocaleKeys.demoLive.tr,
                  style: const TextStyle(
                    fontSize: FontSize.xXXL,
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Expanded(
                  child: Image.asset(
                    AssetConstants.clapAnimation,
                    width: 130.0,
                    height: 130.0,
                  ),
                ),
                CustomButton(
                  text: LocaleKeys.continueLabel.tr,
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
