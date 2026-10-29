import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/injection_container.dart';
import 'package:voiceclub_partner/core/services/growthbook_service.dart';
import 'package:voiceclub_partner/core/services/intro_script_service.dart';
import 'package:voiceclub_partner/core/services/ui_localization_service.dart';
import 'package:voiceclub_partner/core/services/location_service.dart';
import 'package:voiceclub_partner/core/services/logger.dart';
import 'package:voiceclub_partner/modules/controller/user_controller.dart';
import 'package:voiceclub_partner/view/audios/intro_audio_bottom_sheet.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:voiceclub_partner/view/profile/widgets/upload_audio_bottom_sheet/upload_audio_bottom_sheet.dart';
import 'package:voiceclub_partner/domain/usecases/account/update_recording.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';

class VoiceController extends GetxController {
  final currentIndex = 0.obs;
  final submitBtnEnabled = false.obs;

  final totalSteps = ProfileAudioType.values.length.obs;
  final currentStep = Rxn<ProfileAudioType>();
  final hasSecondaryAudio = false.obs;

  final progressPercentage = 0.0.obs;
  final remainingSteps = 0.obs;

  final controller = Get.find<UserController>();

  @override
  void onInit() {
    checkAndUpdateCurrentStep();
    super.onInit();
  }

  void submitBtnClicked() {
    Get.back();
  }

  void _updateProgressPercentage() {
    if (controller.audioStatusList.isEmpty) {
      progressPercentage.value = 0;
      return;
    }
    if (!hasSecondaryAudio.value) {
      final mainAudio = controller.audioStatusList.firstWhereOrNull(
        (p0) => p0.type == RecordingAudioType.Main,
      );
      progressPercentage.value =
          (mainAudio != null &&
                  (mainAudio.status == RecordingAudioStatus.Pending ||
                      mainAudio.status == RecordingAudioStatus.Approved ||
                      mainAudio.status == RecordingAudioStatus.AiApproved))
              ? 100
              : 0;
      return;
    }
    final mainAudio = controller.audioStatusList.firstWhereOrNull(
      (p0) => p0.type == RecordingAudioType.Main,
    );
    final secondaryAudio = controller.audioStatusList.firstWhereOrNull(
      (p0) => p0.type == RecordingAudioType.Secondary,
    );
    final mainUploaded =
        mainAudio != null &&
        (mainAudio.status == RecordingAudioStatus.Pending ||
            mainAudio.status == RecordingAudioStatus.Approved ||
            mainAudio.status == RecordingAudioStatus.AiApproved);
    final secondaryUploaded =
        secondaryAudio != null &&
        (secondaryAudio.status == RecordingAudioStatus.Pending ||
            secondaryAudio.status == RecordingAudioStatus.Approved ||
            secondaryAudio.status == RecordingAudioStatus.AiApproved);
    if (mainUploaded && secondaryUploaded) {
      progressPercentage.value = 100;
    } else if (mainUploaded || secondaryUploaded) {
      progressPercentage.value = 50;
    } else {
      progressPercentage.value = 0;
    }
  }

  void _updateRemainingSteps() {
    if (controller.audioStatusList.isEmpty) {
      remainingSteps.value = 1;
      return;
    }
    if (!hasSecondaryAudio.value) {
      remainingSteps.value = 0;
      return;
    }
    final mainAudio = controller.audioStatusList.firstWhereOrNull(
      (p0) => p0.type == RecordingAudioType.Main,
    );
    final secondaryAudio = controller.audioStatusList.firstWhereOrNull(
      (p0) => p0.type == RecordingAudioType.Secondary,
    );
    if (mainAudio == null ||
        mainAudio.status == RecordingAudioStatus.Rejected) {
      remainingSteps.value = 1;
    } else if (secondaryAudio == null ||
        secondaryAudio.status == RecordingAudioStatus.Rejected) {
      remainingSteps.value = 1;
    } else {
      remainingSteps.value = 0;
    }
  }

  void _updateSubmitBtnEnabled() {
    if (controller.audioStatusList.isEmpty) {
      submitBtnEnabled.value = false;
      return;
    }
    // If any audio is rejected, disable submit
    if (controller.audioStatusList.any(
      (element) => element.status == RecordingAudioStatus.Rejected,
    )) {
      submitBtnEnabled.value = false;
      return;
    }
    // If no secondary audio
    if (!hasSecondaryAudio.value) {
      final mainAudio = controller.audioStatusList.firstWhereOrNull(
        (p0) => p0.type == RecordingAudioType.Main,
      );
      submitBtnEnabled.value =
          mainAudio != null &&
          mainAudio.status != RecordingAudioStatus.Rejected;
      return;
    }
    // If secondary audio is present
    final mainAudio = controller.audioStatusList.firstWhereOrNull(
      (p0) => p0.type == RecordingAudioType.Main,
    );
    final secondaryAudio = controller.audioStatusList.firstWhereOrNull(
      (p0) => p0.type == RecordingAudioType.Secondary,
    );
    submitBtnEnabled.value =
        (mainAudio != null &&
            mainAudio.status != RecordingAudioStatus.Rejected) &&
        (secondaryAudio != null &&
            secondaryAudio.status != RecordingAudioStatus.Rejected);
  }

  Future<void> checkAndUpdateCurrentStep() async {
    await controller.fetchAudioStatus();
    hasSecondaryAudio.value =
        (controller.userDetails.value.secondaryLanguage?.isNotEmpty ?? false) &&
        (controller.userDetails.value.secondaryLanguage !=
            controller.userDetails.value.primaryLanguage);

    // Handle empty audioStatusList (first time upload)
    if (controller.audioStatusList.isEmpty) {
      currentStep.value = ProfileAudioType.Primary;
    } else {
      // Check for Main audio
      final mainAudio = controller.audioStatusList.firstWhereOrNull(
        (p0) => p0.type == RecordingAudioType.Main,
      );
      if (mainAudio == null ||
          mainAudio.status == RecordingAudioStatus.Rejected) {
        currentStep.value = ProfileAudioType.Primary;
      } else {
        // Check for Secondary audio if needed
        final secondaryAudio = controller.audioStatusList.firstWhereOrNull(
          (p0) => p0.type == RecordingAudioType.Secondary,
        );
        if (hasSecondaryAudio.value &&
            (secondaryAudio == null ||
                secondaryAudio.status == RecordingAudioStatus.Rejected)) {
          currentStep.value = ProfileAudioType.Secondary;
        } else {
          currentStep.value = null;
        }
      }
    }
    _updateProgressPercentage();
    _updateRemainingSteps();
    _updateSubmitBtnEnabled();
  }

  void recordNowBtnClicked(ProfileAudioType profileAudioType) async {
    try {
      final userDetails = controller.userDetails.value;
      var language = userDetails.primaryLanguage ?? "Hindi";
      RecordingAudioStatus? recordingStatus;
      var recordingType = RecordingAudioType.Main;
      var title = LocaleKeys.liveProfileIntro.tr;
      var subtitle = LocaleKeys.liveRecordProfileIntroSubtitle.tr;
      var recordingUrl = "";
      var sampleAudioUrl = "";
      var type = "";
      var languageType = ProfileAudioType.Primary;

      switch (profileAudioType) {
        case ProfileAudioType.Primary:
          title = LocaleKeys.liveProfileIntro.tr;
          subtitle = LocaleKeys.liveRecordProfileIntroSubtitle.tr;
          recordingUrl = controller.userDetails.value.recordingUrl ?? "";
          sampleAudioUrl = sl<GrowthBookService>().getSampleAudioUrl();
          recordingStatus =
              controller.audioStatusList
                  .firstWhereOrNull(
                    (element) => element.type == RecordingAudioType.Main,
                  )
                  ?.status;
          recordingType = RecordingAudioType.Main;
          type = "profileIntro";
          languageType = ProfileAudioType.Primary;
          language = userDetails.primaryLanguage ?? "Hindi";
          break;

        case ProfileAudioType.Secondary:
          title = LocaleKeys.liveProfileIntro.tr;
          subtitle = LocaleKeys.liveRecordProfileIntroSubtitle.tr;
          recordingUrl =
              controller.userDetails.value.secondaryRecordingUrl ?? "";
          sampleAudioUrl = sl<GrowthBookService>().getSampleAudioUrl();
          recordingStatus =
              controller.audioStatusList
                  .firstWhereOrNull(
                    (element) => element.type == RecordingAudioType.Secondary,
                  )
                  ?.status;
          recordingType = RecordingAudioType.Secondary;
          type = "profileIntro";
          languageType = ProfileAudioType.Secondary;
          language = userDetails.secondaryLanguage ?? "Hindi";
          break;
      }

      if (sl<UiLocalizationService>().introAudio != null) {
        Get.context?.loaderOverlay.show();
        String cityName = "Delhi";
        (String, String, String)? introAudio;
        try {
          final useNewIntroUi =
              await sl<IntroScriptService>()
                  .allRequiredLanguagesHaveIntroVariants();
          if (useNewIntroUi) {
            cityName = await sl<LocationService>().fetchCity();
            introAudio = await sl<IntroScriptService>().generateIntroAudioText(
              audioLanguage: language,
              cityName: cityName,
            );
          }
        } finally {
          Get.context?.loaderOverlay.hide();
        }
        if (introAudio != null) {
          final primaryText = introAudio.$1;
          final secondaryText = introAudio.$2;
          final audioUrl = introAudio.$3;

          Get.bottomSheet(
            IntroAudioBottomSheet(
              cityName: cityName,
              primaryText: primaryText,
              secondaryText: secondaryText,
              language: language,
              status: recordingStatus,
              audioType: recordingType,
              audioUrl: audioUrl,
            ),
            isScrollControlled: true,
            enableDrag: false,
            isDismissible: false,
          );
        } else {
          Get.bottomSheet(
            UploadAudioBottomSheet(
              key: UniqueKey(),
              title: title,
              recordingUrl: recordingUrl,
              languageType: languageType.name,
              language: language,
              status: recordingStatus,
              sampleAudioUrl: sampleAudioUrl,
              subtitle: subtitle,
              uploadFunction: (fileUrl) async {
                return await uploadFunction(
                  fileUrl: fileUrl,
                  recordingType: recordingType,
                  language: language,
                );
              },
              type: type,
            ),
            isScrollControlled: true,
            isDismissible: true,
            backgroundColor: Colors.transparent,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12.0)),
            ),
          );
        }
      } else {
        Get.bottomSheet(
          UploadAudioBottomSheet(
            key: UniqueKey(),
            title: title,
            recordingUrl: recordingUrl,
            languageType: languageType.name,
            language: language,
            status: recordingStatus,
            sampleAudioUrl: sampleAudioUrl,
            subtitle: subtitle,
            uploadFunction: (fileUrl) async {
              return await uploadFunction(
                fileUrl: fileUrl,
                recordingType: recordingType,
                language: language,
              );
            },
            type: type,
          ),
          isScrollControlled: true,
          isDismissible: true,
          backgroundColor: Colors.transparent,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12.0)),
          ),
        );
      }
    } catch (e) {
      Get.context?.loaderOverlay.hide();
      Logger.logMessage(
        e.toString(),
        name: "VoiceController",
        isCritical: true,
      );
    }
  }

  Future<bool> uploadFunction({
    required String fileUrl,
    required RecordingAudioType recordingType,
    required String language,
  }) async {
    final response = await sl<UpdateRecordingUsecase>().call(
      Params(
        url: fileUrl,
        recordingAudioType: recordingType,
        language: language,
        status: RecordingAudioStatus.Pending.name,
      ),
    );
    if (response.error == null) {
      return false;
    } else {
      return true;
    }
  }
}
