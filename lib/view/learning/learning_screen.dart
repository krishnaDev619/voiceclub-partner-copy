import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/core/injection_container.dart';
import 'package:voiceclub_partner/core/services/analytics_service.dart';
import 'package:voiceclub_partner/core/services/tutorials_video_service.dart';
import 'package:voiceclub_partner/view/tutorial/lessons/bindings/tutorial_lesson_binding.dart';
import 'package:voiceclub_partner/view/tutorial/lessons/screens/tutorial_lesson_screen.dart';
import 'package:voiceclub_partner/view/widgets/custom_button.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';

class LearningScreen extends StatefulWidget {
  const LearningScreen({super.key});

  @override
  State<LearningScreen> createState() => _LearningScreenState();
}

class _LearningScreenState extends State<LearningScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SizedBox(
          height: 46.0,
          width: 160.0,
          child: CustomButton(
            text: LocaleKeys.liveGoBackToCourses.tr,
            onTap: () async {
              sl<AnalyticsService>().trackEvent("goToCourseFromLearning");
              final initCompletedLessonId =
                  await TutorialLessonService.getCompletedLessonID() ?? -1;
              Get.to(
                () => const TutorialLessonScreen(isFromNormalApp: true),
                binding: TutorialLessonBinding(
                  initCompletedLessonId: initCompletedLessonId,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
