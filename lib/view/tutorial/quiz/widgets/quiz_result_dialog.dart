import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/core/injection_container.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/core/services/analytics_service.dart';
import 'package:voiceclub_partner/data/models/tutorial/tutorial_quiz_model.dart';
import 'package:voiceclub_partner/domain/usecases/account/mark_onboarding_stage_course_completed.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';
import 'package:voiceclub_partner/view/onboarding/onboarding_status_router.dart';
import 'package:voiceclub_partner/view/tutorial/demo/widgets/core/demo_correct_answer_bottomsheet.dart';
import 'package:voiceclub_partner/view/tutorial/demo/widgets/core/promotion_bottom_sheet.dart';
import 'package:voiceclub_partner/view/tutorial/lessons/controllers/tutorial_lesson_controller.dart';
import 'package:voiceclub_partner/view/widgets/custom_button.dart';

class QuizResultDialog extends StatelessWidget {
  final bool isPassed;
  final int score;
  final int totalQuestions;
  final TutorialStage currentStage;
  final TutorialQuizModel quizModel;
  final Map<String, int> wrongQuestionMap;

  const QuizResultDialog({
    super.key,
    required this.isPassed,
    required this.score,
    required this.totalQuestions,
    required this.quizModel,
    required this.currentStage,
    required this.wrongQuestionMap,
  });

  @override
  Widget build(BuildContext context) {
    Get.find<TutorialLessonController>().trackLessonEvent(
      "quizResult",
      additionalProperties: {
        "isPassed": isPassed,
        "score": score,
        "totalQuestions": totalQuestions,
        "wrongQuestions": wrongQuestionMap,
      },
    );
    return SafeArea(
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(20.0),
            topLeft: Radius.circular(20.0),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 16.0,
                  backgroundColor:
                      isPassed
                          ? const Color(0xFF5DA040)
                          : const Color(0xFFEE6464),
                  child: Icon(isPassed ? Icons.done : Icons.close),
                ),
                const SizedBox(width: 10.0),
                Text(
                  isPassed
                      ? LocaleKeys.stageComplete.tr
                      : LocaleKeys.stageNotComplete.tr,
                  style: TextStyle(
                    color:
                        isPassed
                            ? const Color(0xFF5DA040)
                            : const Color(0xFFEE6464),
                    fontWeight: Weight.heavy,
                    fontSize: FontSize.xL,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10.0),
            Text(
              "$score/$totalQuestions",
              style: const TextStyle(fontSize: 90, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 10.0),
            Visibility(
              visible: !isPassed,
              child: FittedBox(
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      size: 22,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 10.0),
                    Text(
                      LocaleKeys.pleaseWatchCourseAgain.tr,
                      style: const TextStyle(
                        fontSize: FontSize.xL,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10.0),
            CustomButton(
              text:
                  isPassed
                      ? LocaleKeys.continueLabel.tr
                      : LocaleKeys.rewatchCourses.tr,
              onTap: () async {
                Get.back();
                if (isPassed) {
                  await sl<MarkOnboardingStageCourseCompletedUseCase>().call(
                    NoParams(),
                  );
                  // Fire quiz completed event
                  sl<AnalyticsService>().trackEvent(
                    'quizCompleted',
                    eventProperties: {
                      'stage': currentStage.name,
                      'score': score,
                      'totalQuestions': totalQuestions,
                    },
                  );
                  await Get.bottomSheet(
                    const DemoCorrectAnswerBottomSheet(
                      isLastQuestion: true,
                      isQuiz: true,
                    ),
                  );
                  if (currentStage == TutorialStage.S3 ||
                      currentStage == TutorialStage.S7) {
                    await Get.bottomSheet(
                      PromotionBottomSheet(currentStage: currentStage),
                    );
                  }
                  await OnboardingStatusRouter.continueAfterStageCourse(
                    completedStage: currentStage,
                  );
                } else {
                  Get.back();
                }
              },
            ),
            const SizedBox(height: 10.0),
            Visibility(
              visible: !isPassed,
              replacement: const SizedBox.shrink(),
              child: CustomButton(
                text: LocaleKeys.retryQuiz.tr,
                filled: false,
                onTap: () {
                  Get.back();
                  Get.back();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
