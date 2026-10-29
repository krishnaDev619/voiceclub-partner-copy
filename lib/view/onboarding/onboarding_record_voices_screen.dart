import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/core/constants/url_constants.dart';
import 'package:voiceclub_partner/modules/controller/user_controller.dart';
import 'package:voiceclub_partner/modules/controller/voice_controller.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';
import 'package:voiceclub_partner/view/chat/widgets/bottom_sheet/semi_circular_progress_indicator.dart';
import 'package:voiceclub_partner/view/widgets/custom_button.dart';
import 'package:voiceclub_partner/view/widgets/play_video_screen.dart';

class OnboardingRecordVoicesScreen extends StatefulWidget {
  const OnboardingRecordVoicesScreen({super.key});

  @override
  State<OnboardingRecordVoicesScreen> createState() =>
      _OnboardingRecordVoicesScreenState();
}

class _OnboardingRecordVoicesScreenState
    extends State<OnboardingRecordVoicesScreen> {
  final userDetails = Get.find<UserController>().userDetails.value;
  final voiceController = Get.put(VoiceController());

  Widget _recordNowBtn(ProfileAudioType profileAudioType) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(top: 16.0),
        child: SizedBox(
          width: 120.0,
          child: CustomButton(
            text: LocaleKeys.recordNow.tr,
            onTap: () {
              Get.find<VoiceController>().recordNowBtnClicked(profileAudioType);
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          LocaleKeys.liveRecordYourVoices.tr,
          style: const TextStyle(
            fontWeight: Weight.heavy,
            fontSize: FontSize.xXXL,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.1,
        actions: [
          InkWell(
            onTap: () {
              final videoUrl = URLConstants.introAudioVideo;
              if (videoUrl.trim().isEmpty) return;

              Get.to(
                () => PlayVideoScreen(
                  videoUrl: videoUrl,
                  isFromOnboarding: false,
                  videoKey: 'intro_audio_watch_video',
                  isForce: false,
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Get.theme.primaryColor, width: 1.5),
                borderRadius: BorderRadius.circular(12.0),
              ),
              padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
              margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
              child: Row(
                children: [
                  Icon(
                    Icons.replay,
                    color: Get.theme.primaryColor,
                    size: 16.0,
                    weight: 1.5,
                  ),
                  SizedBox(width: 4.0),
                  Text(
                    LocaleKeys.rewatch.tr,
                    style: TextStyle(
                      color: Get.theme.primaryColor,
                      fontWeight: Weight.heavy,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Obx(() {
        return SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 40.0),
              Align(
                alignment: Alignment.center,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SemiCircularProgressIndicator(
                      width: 250.0,
                      progress: voiceController.progressPercentage.value / 100,
                      backgroundColor: const Color(0xFFCBC5C5),
                      arcColor: const Color(0xFFFF9292),
                      text:
                          "${voiceController.progressPercentage.value.toInt()}%",
                    ),
                    Positioned(
                      bottom: 18.0,
                      child: Text(
                        LocaleKeys.audiosLeftToRecord.trParams({
                          'count': '${voiceController.remainingSteps.value}',
                        }),
                        style: const TextStyle(fontSize: FontSize.L),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6.0),
                  color: const Color(0xFFFFF7F7),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 2.0,
                      spreadRadius: 1.0,
                    ),
                  ],
                ),
                margin: const EdgeInsets.all(16.0),
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0, left: 24.0),
                      child: Row(
                        children: [
                          Text(
                            userDetails.primaryLanguage ?? 'Hindi',
                            style: const TextStyle(
                              fontWeight: Weight.heavy,
                              fontSize: FontSize.xL,
                            ),
                          ),
                          const SizedBox(width: 4.0),
                          Text(
                            LocaleKeys.firstLanguageLabel.tr,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: FontSize.M,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Get.theme.primaryColor,
                        child: const Icon(Icons.mic),
                      ),
                      title: Text(LocaleKeys.liveProfileIntro.tr),
                      subtitle: Visibility(
                        visible:
                            voiceController.currentStep.value ==
                            ProfileAudioType.Primary,
                        child: _recordNowBtn(ProfileAudioType.Primary),
                      ),
                      trailing: Obx(() {
                        final mainAudio = voiceController
                            .controller
                            .audioStatusList
                            .firstWhereOrNull(
                              (p0) => p0.type == RecordingAudioType.Main,
                            );
                        if (mainAudio != null && mainAudio.status != null) {
                          return mainAudio.status!.getStatusChip();
                        }
                        return const SizedBox.shrink();
                      }),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10.0),
              Visibility(
                visible: voiceController.hasSecondaryAudio.value,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6.0),
                    color: const Color(0xFFFFF7F7),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 2.0,
                        spreadRadius: 1.0,
                      ),
                    ],
                  ),
                  margin: const EdgeInsets.all(16.0),
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0, left: 24.0),
                        child: Row(
                          children: [
                            Text(
                              userDetails.secondaryLanguage ?? 'Tamil',
                              style: const TextStyle(
                                fontWeight: Weight.heavy,
                                fontSize: FontSize.xL,
                              ),
                            ),
                            const SizedBox(width: 4.0),
                            Text(
                              LocaleKeys.secondLanguageLabel.tr,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: FontSize.M,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Get.theme.primaryColor,
                          child: const Icon(Icons.mic),
                        ),
                        title: Text(LocaleKeys.liveProfileIntro.tr),
                        subtitle: Visibility(
                          visible:
                              voiceController.currentStep.value ==
                              ProfileAudioType.Secondary,
                          child: _recordNowBtn(ProfileAudioType.Secondary),
                        ),
                        trailing: Obx(() {
                          final secondaryAudio = voiceController
                              .controller
                              .audioStatusList
                              .firstWhereOrNull(
                                (p0) => p0.type == RecordingAudioType.Secondary,
                              );
                          if (secondaryAudio != null &&
                              secondaryAudio.status != null) {
                            return secondaryAudio.status!.getStatusChip();
                          }
                          return const SizedBox.shrink();
                        }),
                      ),
                    ],
                  ),
                ),
              ),
              Visibility(
                visible: voiceController.submitBtnEnabled.value,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10.0,
                    horizontal: 12.0,
                  ),
                  child: CustomButton(
                    text: LocaleKeys.liveSubmit.tr,
                    onTap: () {
                      voiceController.submitBtnClicked();
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
