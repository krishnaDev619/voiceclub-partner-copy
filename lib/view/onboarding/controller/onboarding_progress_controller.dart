import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/constants/url_constants.dart';
import 'package:voiceclub_partner/core/injection_container.dart';
import 'package:voiceclub_partner/core/services/analytics_service.dart';
import 'package:voiceclub_partner/core/services/logger.dart';
import 'package:voiceclub_partner/core/services/intro_audio_policy_service.dart';
import 'package:voiceclub_partner/modules/controller/user_controller.dart';
import 'package:voiceclub_partner/view/onboarding/onboarding_record_voices_screen.dart';
import 'package:voiceclub_partner/view/onboarding/onboarding_status_router.dart';
import 'package:voiceclub_partner/view/widgets/play_video_screen.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';

class OnboardingProgressController extends GetxController {
  final isLoading = false.obs;
  final currentStep = OnboardingStep.PROFILE_AUDIO.obs;

  // Flags for onboarding steps
  final hasStartedAudioUpload = false.obs;
  final hasUploadedAudios = false.obs;
  final audioApprovalStatus = RecordingAudioStatus.Pending.obs;
  final isAnyAudioPending = false.obs;
  final isCompletingOnboarding = false.obs;
  final title = LocaleKeys.yourAccountHasBeenCreated.tr.obs;

  final userController = Get.find<UserController>();
  bool _hasTriggeredCompletion = false;

  int getCurrentStepIndex() {
    return OnboardingStep.values.indexOf(currentStep.value);
  }

  // Check if any of the audios are in pending state
  void _checkAndUpdateAudioStatus() {
    isAnyAudioPending.value = userController.audioStatusList.any(
      (audio) => audio.status == RecordingAudioStatus.Pending,
    );
  }

  // Update the title based on the current step
  void _updateTitle() {
    if (isCompletingOnboarding.value || isOnboardingCompleted) {
      title.value = LocaleKeys.settingUpYourAccount.tr;
    } else if (!hasUploadedAudios.value) {
      title.value = LocaleKeys.uploadYourProfileAudio.tr;
    } else {
      title.value = LocaleKeys.yourAccountHasBeenCreated.tr;
    }
  }

  // Load onboarding status from API or local storage
  Future<void> fetchOnboardingStatus(bool isInit) async {
    try {
      isLoading.value = true;

      hasStartedAudioUpload.value = false;
      hasUploadedAudios.value = false;
      audioApprovalStatus.value = RecordingAudioStatus.Pending;

      if (!isInit) {
        Logger.logMessage("$isInit", name: 'fetchOnboardingStatus');
        // Load audio upload details
        await userController.fetchData();
      } else {
        await userController.fetchExtraUserData(false);
      }

      // Load audio upload status
      hasStartedAudioUpload.value = userController.hasStartedAudioUpload;
      hasUploadedAudios.value = userController.hasUploadedAllAudios;

      // Check if all audios are approved
      audioApprovalStatus.value = userController.audioApprovalStatus;

      // Set current step based on hasCompletedAccountCreation and hasUploadedAudios
      if (!hasUploadedAudios.value ||
          audioApprovalStatus.value != RecordingAudioStatus.Approved ||
          audioApprovalStatus.value != RecordingAudioStatus.AiApproved) {
        currentStep.value = OnboardingStep.PROFILE_AUDIO;
      }
    } catch (_) {
      // Handle error
    } finally {
      isLoading.value = false;
      _checkAndUpdateAudioStatus();
      _updateTitle();
      await tryCompleteOnboardingIfReady();
    }
  }

  Future<void> tryCompleteOnboardingIfReady() async {
    if (!isOnboardingCompleted ||
        _hasTriggeredCompletion ||
        isCompletingOnboarding.value) {
      return;
    }

    _hasTriggeredCompletion = true;
    isCompletingOnboarding.value = true;
    _updateTitle();

    final completed = await OnboardingStatusRouter.completeIntroIfReady(
      isFromAi: false,
    );

    if (!completed) {
      _hasTriggeredCompletion = false;
      isCompletingOnboarding.value = false;
      _updateTitle();
    }
  }

  bool get isOnboardingCompleted {
    if (sl<IntroAudioPolicyService>().requiresIntroAtNewLive) {
      return sl<IntroAudioPolicyService>().hasCompletedNewLiveIntroSubmission(
        hasUploadedAllAudios: hasUploadedAudios.value,
        audioApprovalStatus: audioApprovalStatus.value,
        accountId: userController.accountId,
      );
    }
    return sl<IntroAudioPolicyService>().hasApprovedRequiredIntros(
      hasUploadedAllAudios: hasUploadedAudios.value,
      audioApprovalStatus: audioApprovalStatus.value,
    );
  }

  double get progress {
    if (isOnboardingCompleted) {
      return 1.0;
    } else {
      if (!hasUploadedAudios.value) {
        return 0.90;
      } else {
        return 0.99;
      }
    }
  }

  void stepNavigation() async {
    if (currentStep.value == OnboardingStep.PROFILE_AUDIO) {
      trackOnboardingEvent('recordVoicesScreenTap');
      await _checkVideoAndShowRecordVoicesScreen();
    }
    fetchOnboardingStatus(false);
  }

  Future<void> _checkVideoAndShowRecordVoicesScreen() async {
    final isTelugu =
        userController.userDetails.value.primaryLanguage == "Telugu";

    final videoUrl = URLConstants.introAudioVideo;

    final isSeen = await _hasSeenVideo();
    if (!isSeen && !isTelugu && videoUrl.trim().isNotEmpty) {
      await Get.to(
        () => PlayVideoScreen(
          videoUrl: videoUrl,
          isFromOnboarding: true,
          videoKey: 'onboarding_intro_audio',
          isForce: true,
        ),
      );
      await _setVideoSeen();
    }

    await Get.to(() => const OnboardingRecordVoicesScreen());
  }

  Future<bool> _hasSeenVideo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('onboarding_intro_audio_video_seen') ?? false;
  }

  Future<void> _setVideoSeen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_intro_audio_video_seen', true);
  }

  void trackOnboardingEvent(
    String eventName, {
    Map<String, dynamic>? additionalProperties,
  }) {
    sl<AnalyticsService>().trackEvent(
      eventName,
      eventProperties: {
        ...additionalProperties ?? {},
        ...getCommonEventProperties,
      },
    );
  }

  //// -----------------------Getters---------------------------------///
  Map<String, dynamic> get getCommonEventProperties {
    return {
      'progress': progress,
      'currentStep': currentStep.value.name,
      'audioApprovalStatus': audioApprovalStatus.value.name,
      ...sl<IntroAudioPolicyService>().analyticsProperties,
    };
  }
}
