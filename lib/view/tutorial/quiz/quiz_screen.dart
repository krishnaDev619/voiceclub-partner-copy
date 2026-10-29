import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';
import 'package:voiceclub_partner/view/tutorial/quiz/controller/quiz_controller.dart';
import 'package:voiceclub_partner/view/tutorial/quiz/widgets/question_section.dart';
import 'package:voiceclub_partner/view/widgets/custom_button.dart';

class QuizScreen extends StatelessWidget {
  const QuizScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final quizController = Get.find<QuizController>();
    return Scaffold(
      backgroundColor: const Color(0xFFfafafa),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Obx(() {
            var currentQuestionIndex = quizController.questionIndex.value;
            var totalQuestionsLength = quizController.questionsMap.keys.length;
            return Column(
              children: <Widget>[
                const SizedBox(height: 10.0),
                Text(
                  LocaleKeys.quizTitle.tr,
                  style: TextStyle(
                    fontSize: FontSize.xXXL,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 20.0),
                LinearProgressIndicator(
                  value: currentQuestionIndex / totalQuestionsLength,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Get.theme.primaryColor,
                  ),
                  backgroundColor: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(4.0),
                  minHeight: 10.0,
                ),
                const SizedBox(height: 40.0),
                QuestionSection(),
                const Spacer(),
                CustomButton(
                  text: LocaleKeys.continueLabel.tr,
                  enabled: quizController.selectedAnswerId.value != 0,
                  onTap: () {
                    quizController.submitBtnClicked();
                  },
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
