import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/features/onboarding/core/constants/asset_constants.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/features/onboarding/core/injection_container.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';
import 'package:voiceclub_partner/features/onboarding/core/services/analytics_service.dart';
import 'package:voiceclub_partner/features/onboarding/core/services/local_data_service.dart';
import 'package:voiceclub_partner/view/widgets/custom_button.dart';
import 'package:voiceclub_partner/view/auth/login_screen.dart';

class BelowEighteenScreen extends StatelessWidget {
  const BelowEighteenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    sl<AnalyticsService>().trackEvent("below18Screen");
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: const Icon(Icons.arrow_back_ios, size: 14.0),
        ),
        title: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            LocaleKeys.ageVerification.tr,
            style: const TextStyle(
              fontWeight: Weight.heavy,
              color: Colors.black,
            ),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0.0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            width: Get.width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 130.0),
                SizedBox(
                  height: Get.height * 0.2,
                  child: Image.asset(
                    AssetConstants.belowEighteen,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 20.0),
                Text(
                  LocaleKeys.notEligible.tr,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: FontSize.xXXL,
                    fontWeight: Weight.heavy,
                  ),
                ),
                const SizedBox(height: 20.0),
                Text.rich(
                  TextSpan(
                    text: LocaleKeys.unfortunately.tr,
                    children: [
                      TextSpan(
                        text: LocaleKeys.mustBe18.tr,
                        style: const TextStyle(
                          color: Color(0xFFC3673A),
                          fontWeight: Weight.heavy,
                        ),
                      ),
                      TextSpan(text: LocaleKeys.toJoinYet.tr),
                    ],
                  ),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: FontSize.xL,
                    color: Color(0xFF858585),
                  ),
                ),
                const Spacer(),
                CustomButton(
                  text: LocaleKeys.okay.tr,
                  onTap: () async {
                    await sl<LocalDataService>().logout();
                    Get.offAll(() => const LoginScreen());
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
