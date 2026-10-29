import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:voiceclub_partner/core/constants/asset_constants.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/modules/controller/user_controller.dart';
import 'package:voiceclub_partner/view/widgets/custom_button.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';

class VerificationResultScreen extends StatelessWidget {
  final bool isVerified;
  final String? reason;

  const VerificationResultScreen({
    super.key,
    required this.isVerified,
    this.reason,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Stack(
              children: [
                if (isVerified)
                  Lottie.asset(
                    AssetConstants.celebrationAnimation,
                    repeat: true,
                  ),
                SizedBox(
                  width: Get.width,
                  height: Get.height,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 48.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              height: 36.0,
                              child: Image.asset(
                                AssetConstants.logo,
                                height: MediaQuery.of(context).size.height / 2,
                              ),
                            ),
                            const SizedBox(width: 8.0),
                            Text.rich(
                              TextSpan(
                                text: 'VoiceClub',
                                style: TextStyle(
                                  fontSize: FontSize.xXXL,
                                  fontWeight: FontWeight.bold,
                                  color: Get.theme.primaryColor,
                                ),
                                children: [
                                  TextSpan(
                                    text: LocaleKeys.livePartner.tr,
                                    style: TextStyle(
                                      fontSize: FontSize.xL,
                                      fontWeight: FontWeight.normal,
                                      color: Get.theme.primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            height: Get.height * 0.3,
                            width: Get.width * 0.5,
                            child: Image.asset(
                              isVerified
                                  ? AssetConstants.verified
                                  : AssetConstants.unVerified,
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(height: 20.0),
                          Text(
                            isVerified
                                ? "You're verified!"
                                : "Verification Failed",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: FontSize.xXXL,
                              fontWeight: Weight.heavy,
                            ),
                          ),
                          const SizedBox(height: 20.0),
                          if (isVerified)
                            Text.rich(
                              TextSpan(
                                text: LocaleKeys.yourProfileIsNow.tr,
                                children: [
                                  TextSpan(
                                    text: LocaleKeys.verified.tr,
                                    style: TextStyle(
                                      color: Get.theme.primaryColor,
                                      fontWeight: Weight.heavy,
                                    ),
                                  ),
                                  TextSpan(
                                    text: LocaleKeys.youCanNowStartEarning.tr,
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: FontSize.xL),
                            ),
                          if (!isVerified)
                            Text.rich(
                              TextSpan(
                                text: LocaleKeys.yourProfile.tr,
                                children: [
                                  TextSpan(
                                    text: LocaleKeys.liveFailed.tr,
                                    style: TextStyle(
                                      color: Get.theme.primaryColor,
                                      fontWeight: Weight.heavy,
                                    ),
                                  ),
                                  TextSpan(
                                    text: LocaleKeys.liveToVerifyTryAgain.tr,
                                  ),
                                  if (reason != null)
                                    TextSpan(
                                      text: LocaleKeys.liveVerifyReason
                                          .trParams({'reason': '$reason'}),
                                    ),
                                ],
                              ),
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: FontSize.xL),
                            ),
                        ],
                      ),
                      CustomButton(
                        text: isVerified ? 'Done' : 'Try Again',
                        onTap: () {
                          Get.find<UserController>().fetchData();
                          Get.back();
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
