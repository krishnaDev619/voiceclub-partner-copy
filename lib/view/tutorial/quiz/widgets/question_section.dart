import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/view/tutorial/quiz/controller/quiz_controller.dart';
import 'package:voiceclub_partner/view/tutorial/quiz/widgets/custom_radio_widget.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';

class QuestionSection extends StatelessWidget {
  QuestionSection({super.key});

  final _quizController = Get.find<QuizController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      var question = _quizController.getCurrentQuestion();
      var selectedAnswerIndex = _quizController.selectedAnswerIndex.value;
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0),
          color: Colors.white,
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10.0)],
        ),
        padding: const EdgeInsets.only(
          left: 14.0,
          right: 14.0,
          bottom: 30.0,
          top: 40.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              LocaleKeys.quizQuestionProgress.trParams({
                'current': '${_quizController.questionIndex.value}',
                'total': '${_quizController.questionsMap.keys.length}',
              }),
              style: const TextStyle(color: Colors.grey),
              textAlign: TextAlign.start,
            ),
            const SizedBox(height: 10.0),
            Text(
              question.question ?? "",
              style: const TextStyle(
                fontWeight: Weight.heavy,
                fontSize: FontSize.xXL,
              ),
            ),
            const SizedBox(height: 24.0),
            ListView.builder(
              itemCount: question.answers?.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(
                      color:
                          selectedAnswerIndex == index
                              ? _quizController.answerState != null
                                  ? _quizController.answerState ==
                                          AnswerState.Correct
                                      ? const Color(0xFF89B94C)
                                      : const Color(0xFFE21616)
                                  : const Color(0xFFEEEFF2)
                              : const Color(0xFFEEEFF2),
                      width: selectedAnswerIndex == index ? 1.5 : 2.0,
                    ),
                    color:
                        selectedAnswerIndex == index
                            ? _quizController.answerState != null
                                ? _quizController.answerState ==
                                        AnswerState.Correct
                                    ? const Color(
                                      0xFF89B94C,
                                    ).withValues(alpha: 0.2)
                                    : const Color(
                                      0xFFE21616,
                                    ).withValues(alpha: 0.2)
                                : const Color(0xFFEEF4FE)
                            : Colors.white,
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 6.0),
                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                  child: InkWell(
                    onTap: () {
                      if (!_quizController.isSubmitted.value) {
                        if (selectedAnswerIndex != index) {
                          _quizController.onOptionChanged(
                            answerId: question.answers?[index].id ?? 0,
                            index: index,
                          );
                        }
                      }
                    },
                    child: Row(
                      children: [
                        CustomRadioWidget(
                          isSelected: index == selectedAnswerIndex,
                          answerState: _quizController.answerState,
                        ),
                        const SizedBox(width: 5.0),
                        Flexible(
                          child: Text(
                            question.answers?[index].value ?? "",
                            style: const TextStyle(fontSize: FontSize.xL),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      );
    });
  }
}
