import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/features/onboarding/modules/controllers/onboarding_controller.dart';
import 'package:voiceclub_partner/features/onboarding/views/onboarding/widgets/choose_language_question.dart';
import 'package:voiceclub_partner/features/onboarding/views/onboarding/widgets/education_question.dart';
import 'package:voiceclub_partner/features/onboarding/views/onboarding/widgets/marital_status_question.dart';
import 'package:voiceclub_partner/features/onboarding/views/onboarding/widgets/name_question.dart';
import 'package:voiceclub_partner/features/onboarding/views/onboarding/widgets/religion_question.dart';

class QuestionsWidget extends StatelessWidget {
  const QuestionsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<OnboardingController>(
      builder: (controller) {
        return Expanded(
          child: Container(
            // height: 260,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10.0),
                topRight: Radius.circular(10.0),
              ),
            ),
            padding: const EdgeInsets.all(16.0),
            child: PageView(
              physics: const NeverScrollableScrollPhysics(),
              scrollDirection: Axis.horizontal,
              controller: controller.pageController.value,
              onPageChanged: (index) {},
              children: [
                // AgeGroupQuestion(replayController: replayController),
                NameQuestion(),
                ChooseLanguageQuestion(),
                MaritalStatusQuestion(),
                EducationQuestion(),
                ReligionQuestion(),
              ],
            ),
          ),
        );
      },
    );
  }
}
