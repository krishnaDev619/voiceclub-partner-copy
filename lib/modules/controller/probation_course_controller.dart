import 'package:get/get.dart';
import 'package:voiceclub_partner/core/injection_container.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/core/services/probation_course_service.dart';
import 'package:voiceclub_partner/data/models/course/probation_chapter.dart';
import 'package:voiceclub_partner/data/models/course/probation_lesson.dart';
import 'package:voiceclub_partner/domain/usecases/metrics/mark_probation_course_completed.dart';
import 'package:voiceclub_partner/modules/controller/probation_controller.dart';

class ProbationCourseController extends GetxController {
  final chapters = <ProbationChapter>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchCourseData(true);
  }

  Future<void> fetchCourseData(bool isInit) async {
    try {
      chapters.clear();
      chapters.addAll(
        await sl<ProbationCourseService>().getCourseData(isInit: isInit),
      );
      if (isInit) {
        for (final chapter in chapters) {
          await sl<ProbationCourseService>().cacheVideos(
            chapter.lessons.map((e) => e.videoUrl).toList(),
          );
        }
      }
    } catch (e) {
      // Logger.logError('Error fetching course data: $e');
    } finally {
      update();
    }
  }

  Future<void> updateLessonWatchDuration({
    required int chapterId,
    required int lessonId,
    required Duration watchedDuration,
    required Duration totalDuration,
  }) async {
    ProbationLesson? nextLesson;
    int? nextChapterId;
    try {
      if ((watchedDuration + const Duration(seconds: 5)) >= totalDuration) {
        final result = await _markLessonAsCompleted(
          chapterId: chapterId,
          lessonId: lessonId,
          totalDuration: totalDuration,
        );
        nextLesson = result.$1;
        nextChapterId = result.$2;
      } else {
        for (final chapter in chapters) {
          if (chapter.id == chapterId) {
            for (final lesson in chapter.lessons) {
              if (lesson.id == lessonId) {
                lesson.updateWatchedDuration(watchedDuration.inSeconds);
                break;
              }
            }
            break;
          }
        }
      }
    } catch (e) {
      // Logger.logError('Error updating lesson watch duration: $e');
    } finally {
      await sl<ProbationCourseService>().saveCourseData(chapters);
      await Future.delayed(const Duration(milliseconds: 500));
      await fetchCourseData(false);
      if (watchedDuration >= totalDuration &&
          nextLesson != null &&
          nextChapterId != null) {
        await sl<ProbationCourseService>().fetchAndPlayVideo(
          lesson: nextLesson,
          chapterId: nextChapterId,
        );
      }
    }
  }

  Future<(ProbationLesson? nextLesson, int? nextChapterId)>
  _markLessonAsCompleted({
    required int chapterId,
    required int lessonId,
    required Duration totalDuration,
  }) async {
    ProbationLesson? nextLesson;
    int? nextChapterId;

    try {
      for (final chapter in chapters) {
        if (chapter.id == chapterId) {
          for (final lesson in chapter.lessons) {
            if (lesson.id == lessonId) {
              lesson.markAsCompleted();

              final allLessonsCompleted = chapter.lessons.every(
                (lesson) => lesson.isCompleted,
              );
              if (allLessonsCompleted) {
                chapter.markAsCompleted();
                final nextChapterIndex = chapters.indexOf(chapter) + 1;
                if (nextChapterIndex < chapters.length) {
                  chapters[nextChapterIndex].lessons.first.unlockLesson();
                  nextLesson = chapters[nextChapterIndex].lessons.first;
                  nextChapterId = chapters[nextChapterIndex].id;
                } else {
                  await sl<MarkProbationCourseCompletedUsecase>().call(
                    NoParams(),
                  );
                  await Get.find<ProbationController>().fetchProbationDetails(
                    scoreOnly: true,
                  );
                  // await authController.getProfile(
                  //   authController.phoneNoValue.value,
                  //   shouldNavigate: false,
                  // );
                }
                break;
              } else {
                // Unlock next lesson in the same chapter
                for (int i = 0; i < chapter.lessons.length - 1; i++) {
                  if (chapter.lessons[i].id == lessonId) {
                    nextLesson = chapter.lessons[i + 1];
                    nextLesson.unlockLesson();
                    nextChapterId = chapter.id;
                    break;
                  }
                }
              }
            }
          }
          break;
        }
      }
    } catch (e) {
      // Logger.logError('Error marking lesson as completed: $e');
    }
    return (nextLesson, nextChapterId);
  }

  int get ongoingChapterId {
    final ongoingChapter = chapters.firstWhereOrNull(
      (chapter) => !chapter.isCompleted,
    );
    return ongoingChapter?.id ?? 0;
  }

  String getCourseProgress() {
    try {
      final totalLessons = chapters.fold<int>(
        0,
        (previousValue, chapter) => previousValue + chapter.lessons.length,
      );
      final completedLessons = chapters.fold<int>(
        0,
        (previousValue, chapter) =>
            previousValue +
            chapter.lessons.where((lesson) => lesson.isCompleted).length,
      );

      return "$completedLessons/$totalLessons";
    } catch (_) {
      return "0/0";
    }
  }
}
