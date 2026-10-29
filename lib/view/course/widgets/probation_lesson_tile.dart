import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/core/constants/asset_constants.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/core/injection_container.dart';
import 'package:voiceclub_partner/core/services/probation_course_service.dart';
import 'package:voiceclub_partner/modules/controller/probation_course_controller.dart';

class ProbationLessonTile extends StatelessWidget {
  final int lessonId;
  final int chapterId;

  const ProbationLessonTile({
    super.key,
    required this.lessonId,
    required this.chapterId,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProbationCourseController>(
      builder: (controller) {
        final chapter = controller.chapters.firstWhereOrNull(
          (element) => element.id == chapterId,
        );
        final lesson = chapter?.lessons.firstWhereOrNull(
          (element) => element.id == lessonId,
        );
        if (lesson != null) {
          return ListTile(
            key: UniqueKey(),
            onTap: () {
              // sl<AnalyticsService>()
              //     .trackEvent("courseVideo", eventProperties: {
              //   "completed": lesson.isCompleted,
              //   "minutesRemaining": lesson.getFormattedDuration,
              //   "isLocked": lesson.isLocked,
              //   "courseTitle": lesson.title,
              // });
              if (!lesson.isLocked) {
                sl<ProbationCourseService>().fetchAndPlayVideo(
                  lesson: lesson,
                  chapterId: chapterId,
                );
              } else {
                HapticFeedback.vibrate();
              }
            },
            titleAlignment: ListTileTitleAlignment.center,
            tileColor: Colors.white,
            // isThreeLine: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12.0,
              vertical: 8.0,
            ),
            leading: Container(
              height: 54.0,
              width: 54.0,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6.0),
                image: DecorationImage(
                  image: const AssetImage(AssetConstants.courseThumbnail),
                  colorFilter: ColorFilter.mode(
                    Colors.black.withValues(alpha: 0.3),
                    BlendMode.darken,
                  ),
                  fit: BoxFit.cover,
                ),
              ),
              child: const Icon(Icons.play_arrow_rounded, color: Colors.white),
            ),
            title: Text(
              lesson.title,
              style:
                  lesson.isLocked
                      ? const TextStyle(
                        color: Colors.grey,
                        fontSize: FontSize.L,
                      )
                      : const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: FontSize.L,
                      ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  lesson.getFormattedDuration,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: FontSize.M,
                  ),
                ),
              ],
            ),
            trailing:
                lesson.isLocked
                    ? const Icon(Icons.lock, color: Colors.grey)
                    : (lesson.isCompleted
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : const Icon(
                          Icons.circle_outlined,
                          color: Colors.grey,
                        )),
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }
}
