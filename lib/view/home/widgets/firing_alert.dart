import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:voiceclub_partner/core/constants/asset_constants.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/modules/controller/probation_controller.dart';
import 'package:voiceclub_partner/modules/controller/user_controller.dart';
import 'package:voiceclub_partner/view/metrics/metrics_screen.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';

class FiringAlert extends StatelessWidget {
  const FiringAlert({super.key});

  @override
  Widget build(BuildContext context) {
    final probationController = Get.find<ProbationController>();
    final userController = Get.find<UserController>();
    return Obx(() {
      final stage = probationController.probationDetails.value.stage;
      final score =
          probationController.metricsData.value.aggregate?.score ?? 0.0;
      final cutoffScore = probationController.getFireCutoffWholeValue();

      return Visibility(
        visible:
            (stage == PartnerCurrentStatus.PROBATION ||
                stage == PartnerCurrentStatus.NEW_LIVE) &&
            score < cutoffScore,
        child: GestureDetector(
          onTap: () {
            Get.to(() => const MetricsScreen());
          },
          child: Container(
            margin: const EdgeInsets.only(left: 16.0, right: 16.0, top: 6.0),
            padding: const EdgeInsets.symmetric(
              horizontal: 12.0,
              vertical: 8.0,
            ),
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                Lottie.asset(
                  height: 30.0,
                  width: 30.0,
                  AssetConstants.firingAlertAnimation,
                  fit: BoxFit.cover,
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      (userController.currentStage == TutorialStage.S1)
                          ? LocaleKeys.homeFiredStayOnline.tr
                          : LocaleKeys.homeFiredScore.trParams({
                            'score': cutoffScore.toStringAsFixed(0),
                          }),
                      style: const TextStyle(
                        fontSize: 13.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
