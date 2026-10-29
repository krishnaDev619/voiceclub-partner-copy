import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/data/models/tutorial/tutorial_lesson.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';
import 'package:voiceclub_partner/view/tutorial/lessons/controllers/tutorial_lesson_controller.dart';
import 'package:voiceclub_partner/view/widgets/custom_button.dart';

class StepperControlsButton extends StatelessWidget {
  final TutorialLesson lesson;
  final int stageId;
  final int lessonIndex;

  const StepperControlsButton({
    super.key,
    required this.lesson,
    required this.stageId,
    required this.lessonIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: Get.width / 3, top: 16.0),
      child: CustomButton(
        onTap: () {
          Get.find<TutorialLessonController>().fetchAndPlayVideo(
            lesson: lesson,
            stageId: stageId,
            isCompleted: false,
            lessonIndex: lessonIndex,
          );
        },
        text: LocaleKeys.watchNow.tr,
        padding: const EdgeInsets.symmetric(vertical: 8.0),
      ),
    );
  }
}
