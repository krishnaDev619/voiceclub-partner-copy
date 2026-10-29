import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:voiceclub_partner/features/onboarding/core/constants/asset_constants.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/features/onboarding/core/injection_container.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';
import 'package:voiceclub_partner/features/onboarding/core/services/local_data_service.dart';
import 'package:voiceclub_partner/view/widgets/custom_button.dart';
import 'package:voiceclub_partner/view/auth/login_screen.dart';

class VerifiedScreen extends StatelessWidget {
  final bool isVerified;

  const VerifiedScreen({super.key, required this.isVerified});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Stack(
            children: [
              if (isVerified)
                Lottie.asset(AssetConstants.celebrationAnimation, repeat: true),
              SingleChildScrollView(
                child: SizedBox(
                  width: Get.width,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 150.0),
                      SizedBox(
                        width: Get.width * 0.6,
                        child: Image.asset(
                          AssetConstants.logo,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 50.0),
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
                            ? LocaleKeys.youAreVerified.tr
                            : LocaleKeys.verificationFailed.tr,
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
                                text: LocaleKeys.failed.tr,
                                style: TextStyle(
                                  color: Get.theme.primaryColor,
                                  fontWeight: Weight.heavy,
                                ),
                              ),
                              TextSpan(text: LocaleKeys.toVerifyTryAgain.tr),
                            ],
                          ),
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: FontSize.xL),
                        ),
                      const SizedBox(height: 20.0),
                      CustomButton(
                        text: LocaleKeys.logout.tr,
                        onTap: () async {
                          await sl<LocalDataService>().logout();
                          Get.offAll(() => const LoginScreen());
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
