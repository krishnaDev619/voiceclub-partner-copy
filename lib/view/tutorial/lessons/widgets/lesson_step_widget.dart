import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/data/models/tutorial/tutorial_lesson.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';
import 'package:voiceclub_partner/view/tutorial/lessons/controllers/tutorial_lesson_controller.dart';

class LessonStepWidget {
  final String title;
  final bool isCompleted;
  final int currentStep;
  final int stepIndex;
  final TutorialLesson lesson;
  final int stageId;

  const LessonStepWidget({
    required this.title,
    required this.isCompleted,
    required this.currentStep,
    required this.stepIndex,
    required this.lesson,
    required this.stageId,
  });

  Step buildStep() {
    return Step(
      title: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: FontSize.L,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(width: 4.0),
          if (isCompleted)
            GestureDetector(
              onTap: () {
                Get.find<TutorialLessonController>().fetchAndPlayVideo(
                  lesson: lesson,
                  stageId: stageId,
                  isCompleted: true,
                  lessonIndex: stepIndex,
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(color: Get.theme.primaryColor),
                ),
                padding: const EdgeInsets.all(6.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.replay,
                      size: 16.0,
                      color: Get.theme.primaryColor,
                    ),
                    const SizedBox(width: 4.0),
                    Text(
                      LocaleKeys.rewatch.tr,
                      style: TextStyle(
                        fontSize: FontSize.M,
                        color: Get.theme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      content: const SizedBox.shrink(),
      isActive: currentStep == stepIndex || isCompleted,
      state: StepState.indexed,
    );
  }
}
