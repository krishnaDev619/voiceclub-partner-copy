import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:voiceclub_partner/features/onboarding/core/constants/asset_constants.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/features/onboarding/core/injection_container.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';
import 'package:voiceclub_partner/features/onboarding/core/services/analytics_service.dart';
import 'package:voiceclub_partner/features/onboarding/views/video_screen/agreement_video_screen.dart';
import 'package:voiceclub_partner/view/widgets/custom_button.dart';

class InterviewResultScreen extends StatelessWidget {
  final bool isPassed;
  final Map<String, dynamic> eventProperties;

  const InterviewResultScreen({
    super.key,
    required this.isPassed,
    required this.eventProperties,
  });

  @override
  Widget build(BuildContext context) {
    sl<AnalyticsService>().trackEvent(
      'interviewResultScreen',
      eventProperties: eventProperties,
    );
    return Scaffold(
      appBar: AppBar(
        title: Text(LocaleKeys.yourResult.tr),
        centerTitle: true,
        elevation: 0.0,
        backgroundColor: Colors.white,
        systemOverlayStyle: systemOverlayStyle,
      ),
      body: SafeArea(
        child: SizedBox(
          width: Get.width,
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Spacer(flex: 2),
                Lottie.asset(
                  isPassed
                      ? AssetConstants.passedAnimation
                      : AssetConstants.failedAnimation,
                  width: 250,
                  height: 250,
                ),
                const SizedBox(height: 24.0),
                Text(
                  isPassed
                      ? LocaleKeys.interviewPassedMessage.tr
                      : LocaleKeys.interviewNotSelected.tr,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color:
                        isPassed
                            ? const Color(0xFF4AA611)
                            : const Color(0xFFFF2222),
                  ),
                ),
                Spacer(flex: 3),
                Visibility(
                  visible: isPassed,
                  child: CustomButton(
                    text: LocaleKeys.continueLabel.tr,
                    onTap: () {
                      Get.off(() => const AgreementVideoScreen());
                    },
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
