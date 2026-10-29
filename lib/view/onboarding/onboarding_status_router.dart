import 'package:get/get.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/injection_container.dart';
import 'package:voiceclub_partner/core/services/analytics_service.dart';
import 'package:voiceclub_partner/core/services/intro_audio_policy_service.dart';
import 'package:voiceclub_partner/core/services/logger.dart';
import 'package:voiceclub_partner/core/services/partner_onboarding_completion_service.dart';
import 'package:voiceclub_partner/core/services/tutorials_video_service.dart';
import 'package:voiceclub_partner/data/models/data.dart';
import 'package:voiceclub_partner/data/models/metrics/get_probation_details_response.dart';
import 'package:voiceclub_partner/domain/usecases/account/update_onboarding_stage.dart';
import 'package:voiceclub_partner/modules/bindings/landing_binding.dart';
import 'package:voiceclub_partner/modules/controller/user_controller.dart';
import 'package:voiceclub_partner/view/journey/journey_eligibility_controller.dart';
import 'package:voiceclub_partner/view/landing/landing_screen.dart';
import 'package:voiceclub_partner/view/onboarding/onboarding_progress_screen.dart';
import 'package:voiceclub_partner/view/tutorial/lessons/bindings/tutorial_lesson_binding.dart';
import 'package:voiceclub_partner/view/tutorial/lessons/screens/tutorial_lesson_screen.dart';

class OnboardingStatusRouter {
  OnboardingStatusRouter._();

  static IntroAudioPolicyService get _policy => sl<IntroAudioPolicyService>();

  static Future<void> routeAfterWelcome() async {
    final userController = Get.find<UserController>();
    final partnerStatus = userController.partnerStatus.value;

    if (partnerStatus == PartnerCurrentStatus.ONBOARDED) {
      if (_policy.requiresIntroAtOnboarded) {
        await goToIntroProgress();
        return;
      }
      await PartnerOnboardingCompletionService.completeSilently(
        isFromAi: false,
      );
      return;
    }

    await goToJourneyOrLanding();
  }

  static Future<void> goToIntroProgress() async {
    Get.offAll(() => const OnboardingProgressScreen());
  }

  static Future<void> goToJourneyOrLanding() async {
    if (await _shouldCollectNewLiveIntro()) {
      await goToIntroProgress();
      return;
    }

    final userController = Get.find<UserController>();
    final journeyEligibilityController =
        Get.isRegistered<JourneyEligibilityController>()
            ? Get.find<JourneyEligibilityController>()
            : Get.put(JourneyEligibilityController(), permanent: true);

    if (journeyEligibilityController.shouldShowLegacyTutorial) {
      await goToTutorial();
    } else {
      goToLandingScreen(
        userController.initUserDataModel,
        userController.initProbationData,
      );
    }
  }

  /// After S4 lessons/quiz/demo, collect NEW_LIVE intro before landing or S5.
  static Future<void> continueAfterStageCourse({
    required TutorialStage completedStage,
  }) async {
    final finishedS4 =
        completedStage == TutorialStage.S4 ||
        completedStage == TutorialStage.DONE ||
        completedStage.isGreaterThan(TutorialStage.S4);
    if (finishedS4 &&
        _policy.requiresIntroAtNewLive &&
        await _needsNewLiveIntroRecording()) {
      Logger.logMessage(
        'S4 journey complete, collecting NEW_LIVE intro audio',
        name: 'OnboardingStatusRouter',
      );
      await goToIntroProgress();
      return;
    }
    Get.offAll(() => const LandingScreen());
  }

  static Future<void> goToTutorial() async {
    final userController = Get.find<UserController>();
    final userDataResponse = userController.userDetails.value;
    if (userDataResponse.onboardingStageTutorialCompleted ?? false) {
      if (await _shouldCollectNewLiveIntro()) {
        await goToIntroProgress();
        return;
      }
      Get.offAll(() => const LandingScreen());
      return;
    }

    if (userDataResponse.onboardingStageChangeDate?.isEmpty ?? true) {
      await sl<UpdateOnboardingStageUseCase>().call(
        OnboardingStageUpdateParams(stage: userController.currentStage),
      );
    }
    final initCompletedLessonId =
        await TutorialLessonService.getCompletedLessonID() ?? -1;
    Get.offAll(
      () => const TutorialLessonScreen(),
      binding: TutorialLessonBinding(
        initCompletedLessonId: initCompletedLessonId,
      ),
    );
  }

  static void goToLandingScreen(
    DataModel userDataModel,
    GetProbationDetailsResponseModel initProbationData,
  ) {
    Get.offAll(
      () => const LandingScreen(),
      binding: LandingBinding(
        userDataModel: userDataModel,
        initProbationData: initProbationData,
      ),
    );
  }

  static Future<bool> completeIntroIfReady({
    required bool isFromAi,
    bool closeBottomSheetBeforeContinue = false,
  }) async {
    if (_policy.requiresIntroAtNewLive) {
      Logger.logMessage(
        'NEW_LIVE intro approved after S4, continuing to S5 journey',
        name: 'OnboardingStatusRouter',
      );
      if (closeBottomSheetBeforeContinue && (Get.isBottomSheetOpen ?? false)) {
        Get.back();
      }
      sl<AnalyticsService>().trackEvent(
        'introAudioNewLiveCompleted',
        eventProperties: {..._policy.analyticsProperties, 'isFromAi': isFromAi},
      );
      final accountId = Get.find<UserController>().accountId;
      await _policy.markNewLiveIntroPassed(accountId);
      await _policy.saveNewLiveIntroCompletedAt(accountId);
      Get.offAll(() => const LandingScreen());
      return true;
    }

    return PartnerOnboardingCompletionService.completeSilently(
      isFromAi: isFromAi,
      closeBottomSheetBeforeApi: closeBottomSheetBeforeContinue,
    );
  }

  static Future<bool> _shouldCollectNewLiveIntro() async {
    final userController = Get.find<UserController>();
    if (!_policy.shouldCollectIntroAfterS4(
      stage: userController.currentStage,
      stageCourseCompleted:
          userController.userDetails.value.onboardingStageTutorialCompleted ??
          false,
    )) {
      return false;
    }
    return _needsNewLiveIntroRecording();
  }

  static Future<bool> _needsNewLiveIntroRecording() async {
    if (!_policy.requiresIntroAtNewLive) {
      return false;
    }
    final userController = Get.find<UserController>();
    if (userController.partnerStatus.value == PartnerCurrentStatus.LIVE ||
        userController.partnerStatus.value == PartnerCurrentStatus.FIRED) {
      return false;
    }
    if (await _policy.hasPassedNewLiveIntro(userController.accountId)) {
      return false;
    }
    await userController.fetchAudioStatus();
    final passed = _policy.hasApprovedRequiredIntros(
      hasUploadedAllAudios: userController.hasUploadedAllAudios,
      audioApprovalStatus: userController.audioApprovalStatus,
    );
    if (passed) {
      await _policy.markNewLiveIntroPassed(userController.accountId);
    }
    return !passed;
  }
}
