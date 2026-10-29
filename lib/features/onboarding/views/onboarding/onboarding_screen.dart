import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';
import 'package:voiceclub_partner/features/onboarding/modules/controllers/onboarding_controller.dart';
import 'package:voiceclub_partner/features/onboarding/views/onboarding/widgets/questions_widget.dart';
import 'package:voiceclub_partner/features/onboarding/views/widgets/progress_bar.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: GetBuilder<OnboardingController>(
        builder: (controller) {
          return Scaffold(
            resizeToAvoidBottomInset: false,
            appBar: AppBar(
              title: Text(
                LocaleKeys.personalDetails.tr,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: FontSize.xXXL,
                  fontWeight: Weight.bold,
                ),
              ),
              backgroundColor: Colors.white,
              elevation: 0.0,
              centerTitle: true,
              leading: BackButton(
                onPressed: () {
                  controller.jumpToPreviousPage();
                },
              ),
            ),
            body: SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 10.0),
                  const ProgressBar(),
                  QuestionsWidget(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
