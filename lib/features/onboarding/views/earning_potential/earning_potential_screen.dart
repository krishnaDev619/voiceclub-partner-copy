import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/features/onboarding/core/constants/asset_constants.dart';
import 'package:voiceclub_partner/features/onboarding/core/constants/enums.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/features/onboarding/core/injection_container.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';
import 'package:voiceclub_partner/features/onboarding/core/services/analytics_service.dart';
import 'package:voiceclub_partner/features/onboarding/core/services/local_data_service.dart';
import 'package:voiceclub_partner/features/onboarding/modules/controllers/data_controller.dart';
import 'package:voiceclub_partner/features/onboarding/views/earning_potential/widgets/hours_selection_chip.dart';
import 'package:voiceclub_partner/features/onboarding/views/onboarding/onboarding_screen.dart';
import 'package:voiceclub_partner/view/widgets/custom_button.dart';

class EarningPotentialScreen extends StatefulWidget {
  const EarningPotentialScreen({super.key});

  @override
  State<EarningPotentialScreen> createState() => _EarningPotentialScreenState();
}

class _EarningPotentialScreenState extends State<EarningPotentialScreen> {
  EarningPotential selectedEarningPotential = EarningPotential.Eight;

  String calculateAndGetEarnings() {
    var result = "";
    switch (selectedEarningPotential) {
      case EarningPotential.Six:
        result = "₹20,000";
      case EarningPotential.Eight:
        result = "₹30,000";
      case EarningPotential.Ten:
        result = "₹50,000";
    }
    sl<AnalyticsService>().trackEvent(
      "estimatedEarningScreen",
      eventProperties: {
        "estEarning": result,
        "estHours": selectedEarningPotential.name,
      },
    );
    return result;
  }

  String getPerDay() {
    switch (selectedEarningPotential) {
      case EarningPotential.Six:
        return "₹600";
      case EarningPotential.Eight:
        return "₹1,000";
      case EarningPotential.Ten:
        return "₹1,600";
    }
  }

  void goToOnBoardingScreen() {
    Get.to(() => const OnboardingScreen());
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              Container(
                height: 1000,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.center,
                    colors: [Color(0xFFF4C464), Colors.white, Colors.white],
                  ),
                ),
              ),
              Image.asset(AssetConstants.coinsBg),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 200),
                  Image.asset(
                    AssetConstants.vcPartnerLogo,
                    width: Get.width * .6,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    LocaleKeys.youCanEarn.tr,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: FontSize.xXXXL,
                      fontWeight: Weight.heavy,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    calculateAndGetEarnings(),
                    style: const TextStyle(
                      fontSize: 64,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text.rich(
                      textAlign: TextAlign.center,
                      TextSpan(
                        text: "${LocaleKeys.perMonthIfYou.tr} ",
                        children: [
                          TextSpan(
                            text:
                                "${selectedEarningPotential.getEarningHoursInDigit()} ${LocaleKeys.hours.tr}",
                            style: TextStyle(
                              fontWeight: Weight.heavy,
                              color: Get.theme.primaryColor,
                            ),
                          ),
                          TextSpan(text: " ${LocaleKeys.workDoing.tr}..."),
                        ],
                        style: const TextStyle(
                          fontSize: FontSize.L,
                          color: ApplicationColors.grey,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children:
                        EarningPotential.values
                            .map(
                              (e) => HoursSelectionChip(
                                hours: e.getEarningHoursInDigit(),
                                selected: e == selectedEarningPotential,
                                onTap: () {
                                  setState(() {
                                    selectedEarningPotential = e;
                                  });
                                },
                              ),
                            )
                            .toList(),
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: CustomButton(
                      text: LocaleKeys.continueLabel.tr,
                      onTap: () {
                        Get.find<DataController>().earningPotential.value =
                            calculateAndGetEarnings();
                        sl<LocalDataService>().setEarningPotential(
                          calculateAndGetEarnings(),
                        );
                        goToOnBoardingScreen();
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
