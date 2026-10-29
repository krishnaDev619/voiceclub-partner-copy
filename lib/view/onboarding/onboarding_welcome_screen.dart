import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:voiceclub_partner/core/constants/asset_constants.dart';
import 'package:voiceclub_partner/core/injection_container.dart';
import 'package:voiceclub_partner/core/services/analytics_service.dart';
import 'package:voiceclub_partner/core/services/logger.dart';
import 'package:voiceclub_partner/modules/controller/call_controller.dart';
import 'package:voiceclub_partner/view/onboarding/onboarding_status_router.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';

class OnboardingWelcomeScreen extends StatefulWidget {
  const OnboardingWelcomeScreen({super.key});

  @override
  State<OnboardingWelcomeScreen> createState() =>
      _OnboardingWelcomeScreenState();
}

class _OnboardingWelcomeScreenState extends State<OnboardingWelcomeScreen> {
  @override
  void initState() {
    checkCallPayload();
    super.initState();
  }

  Future<void> checkCallPayload() async {
    Future.delayed(
      Duration(
        seconds: sl<CallController>().incomingCallPayload.isNotEmpty ? 0 : 2,
      ),
    ).then((_) => checkOnboardingStatus());
  }

  void checkOnboardingStatus() async {
    try {
      Get.context?.loaderOverlay.show();
      await OnboardingStatusRouter.routeAfterWelcome();
    } catch (e) {
      Logger.logMessage("Error in checkOnboardingStatus ${e.toString()}");
    } finally {
      Get.context?.loaderOverlay.hide();
    }
  }

  @override
  Widget build(BuildContext context) {
    sl<AnalyticsService>().trackEvent('partnerWelcomeScreen');
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                AssetConstants.vcPartnerLogo,
                height: 70.0,
                width: double.infinity * 0.7,
                fit: BoxFit.fill,
              ),
              const SizedBox(height: 60.0),
              Text(
                LocaleKeys.welcomeToVoiceClub.tr,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 40.0),
              SizedBox(
                height: Get.height * 0.4,
                child: Image.asset(
                  AssetConstants.welcomeIllustration,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 50.0),
              SizedBox(
                width: 50.0,
                child: LinearProgressIndicator(
                  color: Get.theme.primaryColor,
                  backgroundColor: Colors.grey.shade300,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
