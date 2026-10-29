import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get/get.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:video_player/video_player.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/injection_container.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/core/services/analytics_service.dart';
import 'package:voiceclub_partner/core/services/ui_localization_service.dart';
import 'package:voiceclub_partner/core/services/logger.dart';
import 'package:voiceclub_partner/core/services/tutorials_video_service.dart';
import 'package:voiceclub_partner/data/models/tutorial/tutorial_lesson.dart';
import 'package:voiceclub_partner/data/models/tutorial/tutorial_stage_model.dart';
import 'package:voiceclub_partner/domain/usecases/account/mark_onboarding_stage_course_completed.dart';
import 'package:voiceclub_partner/modules/controller/user_controller.dart';
import 'package:voiceclub_partner/view/onboarding/onboarding_status_router.dart';
import 'package:voiceclub_partner/view/tutorial/demo/bindings/demo_landing_binding.dart';
import 'package:voiceclub_partner/view/tutorial/demo/screens/demo_landing_screen.dart';
import 'package:voiceclub_partner/view/tutorial/lessons/widgets/tutorial_video_player_screen.dart';
import 'package:voiceclub_partner/view/tutorial/quiz/bindings/quiz_binding.dart';
import 'package:voiceclub_partner/view/tutorial/quiz/quiz_screen.dart';

class TutorialLessonController extends GetxController {
  final int initCompletedLessonId;

  TutorialLessonController({required this.initCompletedLessonId});

  final stages = <TutorialStageModel>[].obs;
  final completedLessonIndex = (-1).obs;
  final currentVisiblePageIndex = 0.obs;
  final showContinueButton = false.obs;

  TutorialStageModel get currentStage => stages.singleWhere(
    (element) => element.stage == Get.find<UserController>().currentStage,
    orElse: () => TutorialStageModel(stage: TutorialStage.DONE),
  );

  int get currentLessonIndex {
    return completedLessonIndex.value + 1;
  }

  int get currentStageIndex {
    final c = stages.indexWhere(
      (element) => element.stage == currentStage.stage,
    );
    return c == -1 ? 0 : c;
  }

  TutorialStageModel get currentVisibleStage =>
      stages[currentVisiblePageIndex.value];

  double get progressPercentage {
    if (currentVisibleStage.stage?.isLessThan(
          currentStage.stage ?? TutorialStage.S1,
        ) ??
        false) {
      return 1.0;
    } else if (currentVisibleStage.stage?.isEqualTo(
          currentStage.stage ?? TutorialStage.S1,
        ) ??
        false) {
      final lessons = currentStage.lessons ?? [];
      if (lessons.isEmpty) {
        return 1.0;
      } else {
        if (completedLessonIndex.value >= lessons.length) {
          return 1.0;
        } else {
          return ((completedLessonIndex.value + 1) / lessons.length);
        }
      }
    } else {
      return 0.0;
    }
  }

  double get _currentStageProgressPercentage {
    final lessons = currentStage.lessons ?? [];
    if (lessons.isEmpty) {
      return 1.0;
    } else {
      if (completedLessonIndex.value >= lessons.length) {
        return 1.0;
      } else {
        return ((completedLessonIndex.value + 1) / lessons.length);
      }
    }
  }

  @override
  void onInit() {
    fetchStageData(isInit: true);
    super.onInit();
  }

  void fetchStageData({required bool isInit}) async {
    stages.value = sl<UiLocalizationService>().journey?.stages ?? [];
    if (isInit) {
      if (currentStage.lessons?.any(
            (element) => element.id == initCompletedLessonId,
          ) ??
          false) {
        completedLessonIndex.value = currentStage.lessons!.indexWhere(
          (element) => element.id == initCompletedLessonId,
        );
      }
      currentVisiblePageIndex.value = currentStageIndex;
      enableContinueButton();
      cacheVideos();
    }
  }

  Future<void> cacheVideos() async {
    for (final stage in stages) {
      for (final lesson in stage.lessons ?? <TutorialLesson>[]) {
        if (lesson.lessonUrl?.isNotEmpty ?? false) {
          try {
            await DefaultCacheManager().downloadFile(lesson.lessonUrl!);
          } catch (_) {}
        }
      }
    }
  }

  // Method to fetch and play a single video
  Future<void> fetchAndPlayVideo({
    required TutorialLesson lesson,
    required int stageId,
    required bool isCompleted,
    required int lessonIndex,
  }) async {
    try {
      Get.context?.loaderOverlay.show();
      if (lesson.lessonUrl?.isNotEmpty ?? false) {
        final file = await DefaultCacheManager().getSingleFile(
          lesson.lessonUrl!,
        );
        final path = file.path;
        late VideoPlayerController videoPlayerController;
        if (path.isNotEmpty) {
          videoPlayerController = VideoPlayerController.file(File(path));
        } else {
          videoPlayerController = VideoPlayerController.networkUrl(
            Uri.parse(lesson.lessonUrl ?? ""),
          );
        }
        Get.context?.loaderOverlay.hide();
        await videoPlayerController.initialize();
        await Get.to(
          () => TutorialVideoPlayerScreen(
            key: UniqueKey(),
            videoPlayerController: videoPlayerController,
            lesson: lesson,
            stageId: stageId,
            isCompleted: isCompleted,
            lessonIndex: lessonIndex,
          ),
        );
        trackPartnerTutorialScreenEvent(screenName: "TutorialLesson");
      }
    } catch (e) {
      Logger.logMessage(
        "Error while playing lesson in lesson controller ${e.toString()}",
        isCritical: true,
      );
    } finally {
      Get.context?.loaderOverlay.hide();
    }
  }

  Future<void> updateLessonWatchDuration({
    required int stageId,
    required int lessonId,
    required Duration watchedDuration,
    required Duration totalDuration,
  }) async {
    try {
      Logger.logMessage(
        "updateLessonWatchDuration called with stageId: $stageId:::currentStageId: ${currentStage.id}, lessonId: $lessonId, watchedDuration: $watchedDuration, totalDuration: $totalDuration",
        name: 'Tutorial',
      );
      if (stageId == currentStage.id &&
          lessonId == currentStage.lessons?[currentLessonIndex].id) {
        if ((watchedDuration + const Duration(seconds: 3)) >= totalDuration) {
          if (currentLessonIndex < (currentStage.lessons?.length ?? 0)) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              completedLessonIndex.value++;
              Logger.logMessage(
                "Updated completedLessonIndex to ${completedLessonIndex.value}",
                name: 'Tutorial',
              );
              enableContinueButton();
              TutorialLessonService.saveCompletedLessonID(lessonId);
            });
          }
        }
      }
    } catch (e) {
      Logger.logMessage(
        'Error updating lesson watch duration: $e',
        name: "Tutorial",
      );
    }
  }

  void enableContinueButton() {
    Logger.logMessage("enableContinueButton() called", name: 'Tutorial');
    if (completedLessonIndex.value == (currentStage.lessons?.length ?? 1) - 1) {
      showContinueButton.value = true;
    }
  }

  void onContinueButtonPressed() async {
    if (currentStage.quiz?.type == TutorialQuizType.DEMO) {
      await Get.to(
        () => const DemoLandingScreen(),
        binding: DemoLandingBinding(
          currentStage: currentStage.stage ?? TutorialStage.S1,
          demoQuestions: currentStage.quiz?.demoQuestions ?? [],
        ),
      );
      trackPartnerTutorialScreenEvent(screenName: "Demo");
    } else if (currentStage.quiz?.type == TutorialQuizType.MCQ) {
      await Get.to(
        () => const QuizScreen(),
        binding: QuizBinding(
          currentStage: currentStage.stage!,
          quizModel: currentStage.quiz!,
        ),
      );
      trackPartnerTutorialScreenEvent(screenName: "Quiz");
    } else {
      final completedStage = currentStage.stage ?? TutorialStage.S1;
      await sl<MarkOnboardingStageCourseCompletedUseCase>().call(NoParams());
      await OnboardingStatusRouter.continueAfterStageCourse(
        completedStage: completedStage,
      );
    }
  }

  void trackPartnerTutorialScreenEvent({required String screenName}) {
    trackLessonEvent(
      "partnerTutorialScreen",
      additionalProperties: {"screenName": screenName},
    );
  }

  void trackLessonEvent(
    String eventName, {
    Map<String, dynamic>? additionalProperties,
  }) {
    try {
      int lessonIndex = 0;
      String lessonTitle = "";
      if (currentStage.lessons?.isNotEmpty ?? false) {
        lessonIndex =
            currentLessonIndex < currentStage.lessons!.length
                ? currentLessonIndex
                : currentStage.lessons!.length - 1;
        lessonTitle =
            currentStage.lessons?.isNotEmpty ?? false
                ? currentStage.lessons![lessonIndex].title ?? ""
                : "";
      }
      sl<AnalyticsService>().trackEvent(
        eventName,
        eventProperties: {
          "currentStage": currentStage.stage?.name,
          "currentLessonIndex": lessonIndex,
          "currentLessonTitle": lessonTitle,
          "totalLessons": currentStage.lessons?.length ?? 0,
          "completionRate": _currentStageProgressPercentage,
          ...?additionalProperties,
        },
      );
    } catch (e) {
      Logger.logMessage(
        "Error in trackLessonEvent ${e.toString()}",
        name: "Tutorial Lesson Controller",
        isCritical: true,
      );
    }
  }
}
