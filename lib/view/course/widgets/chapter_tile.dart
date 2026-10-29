import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/core/injection_container.dart';
import 'package:voiceclub_partner/core/services/analytics_service.dart';
import 'package:voiceclub_partner/modules/controller/probation_course_controller.dart';
import 'package:voiceclub_partner/view/course/widgets/probation_lesson_tile.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';

class ChapterTile extends StatelessWidget {
  final int index;

  const ChapterTile({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProbationCourseController>(
      builder: (controller) {
        final chapter = controller.chapters[index];
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8.0,
                  spreadRadius: 2.0,
                ),
              ],
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: ExpansionTile(
              key: UniqueKey(),
              initiallyExpanded: controller.ongoingChapterId == chapter.id,
              tilePadding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 2.0,
              ),
              title: const Text(
                "Probation Video",
                style: TextStyle(
                  fontSize: FontSize.xXL,
                  fontWeight: Weight.heavy,
                ),
              ),
              subtitle:
                  chapter.isCompleted
                      ? const SizedBox.shrink()
                      : Text.rich(
                        TextSpan(
                          text: LocaleKeys.liveWatchVideoToGo.tr,
                          children: [
                            TextSpan(
                              text: LocaleKeys.homeOnline.tr,
                              style: TextStyle(
                                color: Color(0xFF4AA611),
                                fontWeight: Weight.heavy,
                              ),
                            ),
                          ],
                          style: TextStyle(
                            fontSize: FontSize.M,
                            color: Colors.grey,
                          ),
                        ),
                      ),
              expandedCrossAxisAlignment: CrossAxisAlignment.start,
              textColor: Colors.black,
              collapsedIconColor: Colors.black,
              iconColor: Colors.black,
              childrenPadding: const EdgeInsets.all(0.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
                side: const BorderSide(color: Color(0xFFF1F1F1)),
              ),
              collapsedShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              onExpansionChanged: (value) {
                if (value) {
                  sl<AnalyticsService>().trackEvent(
                    "probationCourse",
                    eventProperties: {"chapterName": chapter.title},
                  );
                }
              },
              children: [
                for (var lesson in chapter.lessons)
                  ProbationLessonTile(
                    key: UniqueKey(),
                    lessonId: lesson.id,
                    chapterId: chapter.id,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
