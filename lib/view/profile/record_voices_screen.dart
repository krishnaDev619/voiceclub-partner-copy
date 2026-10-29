import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/core/injection_container.dart';
import 'package:voiceclub_partner/core/services/analytics_service.dart';
import 'package:voiceclub_partner/core/services/intro_audio_policy_service.dart';
import 'package:voiceclub_partner/core/services/growthbook_service.dart';
import 'package:voiceclub_partner/domain/usecases/account/update_recording.dart';
import 'package:voiceclub_partner/modules/controller/user_controller.dart';
import 'package:voiceclub_partner/view/profile/widgets/record_voice_tile.dart';
import 'package:voiceclub_partner/view/profile/widgets/upload_audio_bottom_sheet/upload_audio_bottom_sheet.dart';
import 'package:voiceclub_partner/view/widgets/custom_app_bar.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';

class RecordVoicesScreen extends GetView<UserController> {
  const RecordVoicesScreen({super.key});

  Widget getSubtitleTitleWidget({
    required RecordingAudioStatus? status,
    required String? recordingUrl,
  }) {
    Color color = Colors.red;
    switch (status) {
      case RecordingAudioStatus.Pending:
        color = Colors.amber;
        break;
      case RecordingAudioStatus.Approved:
        color = Colors.green;
        break;
      case RecordingAudioStatus.Rejected:
        color = Colors.red;
        break;
      case RecordingAudioStatus.AiApproved:
        color = Colors.green;
        break;
      case RecordingAudioStatus.AiRejected:
        color = Colors.red;
        break;
      case null:
        color = Colors.red;
        break;
    }

    return FittedBox(
      alignment: Alignment.centerLeft,
      fit: BoxFit.scaleDown,
      child: Text(
        (status == null
            ? ((recordingUrl?.isEmpty ?? true)
                ? LocaleKeys.liveNotUploaded.tr
                : " ")
            : status.toLocalizedStatusLabel()),
        textAlign: TextAlign.left,
        maxLines: 1,
        style: TextStyle(fontSize: 11.0, color: color),
      ),
    );
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
        status: RecordingAudioStatus.Pending.name.toUpperCase(),
      ),
    );
    if (response.error == null) {
      return false;
    } else {
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    sl<AnalyticsService>().trackEvent(
      'partnerRecordVoice',
      eventProperties: sl<IntroAudioPolicyService>().analyticsProperties,
    );
    return Scaffold(
      appBar: CustomAppBar(title: LocaleKeys.liveRecordYourVoices.tr),
      body: Obx(() {
        final userDetails = controller.userDetails.value;
        return SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Primary Language
              Container(
                margin: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.0),
                  boxShadow: [
                    BoxShadow(
                      offset: const Offset(0.0, 0.0),
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 12.0,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
                      child: Text(
                        userDetails.primaryLanguage ?? "Hindi",
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: FontSize.xXL,
                        ),
                      ),
                    ),
                    RecordVoiceTile(
                      title: LocaleKeys.liveProfileIntro.tr,
                      subtitle: getSubtitleTitleWidget(
                        status:
                            controller.audioStatusList
                                .firstWhereOrNull(
                                  (audioStatus) =>
                                      audioStatus.type ==
                                      RecordingAudioType.Main,
                                )
                                ?.status,
                        recordingUrl:
                            controller.audioStatusList
                                .firstWhereOrNull(
                                  (audioStatus) =>
                                      audioStatus.type ==
                                      RecordingAudioType.Main,
                                )
                                ?.audioUrl,
                      ),
                      onTap: () {
                        Get.bottomSheet(
                          UploadAudioBottomSheet(
                            key: const Key("Profile Intro"),
                            title: LocaleKeys.liveProfileIntro.tr,
                            recordingUrl:
                                controller.audioStatusList
                                    .firstWhereOrNull(
                                      (audioStatus) =>
                                          audioStatus.type ==
                                          RecordingAudioType.Main,
                                    )
                                    ?.audioUrl,
                            sampleAudioUrl:
                                sl<GrowthBookService>().getSampleAudioUrl(),
                            languageType: "Primary",
                            language: userDetails.primaryLanguage,
                            status:
                                controller.audioStatusList
                                    .firstWhereOrNull(
                                      (audioStatus) =>
                                          audioStatus.type ==
                                          RecordingAudioType.Main,
                                    )
                                    ?.status,
                            subtitle:
                                LocaleKeys.liveRecordProfileIntroSubtitle.tr,
                            uploadFunction: (fileUrl) async {
                              return await uploadFunction(
                                fileUrl: fileUrl,
                                recordingType: RecordingAudioType.Main,
                                language:
                                    userDetails.primaryLanguage ?? "Hindi",
                              );
                            },
                            type: "profileIntro",
                            pendingAudioUrl:
                                controller.audioStatusList
                                    .firstWhereOrNull(
                                      (audioStatus) =>
                                          audioStatus.type ==
                                          RecordingAudioType.Main,
                                    )
                                    ?.audioUrl,
                            reason:
                                controller.audioStatusList
                                    .firstWhereOrNull(
                                      (audioStatus) =>
                                          audioStatus.type ==
                                          RecordingAudioType.Main,
                                    )
                                    ?.reason,
                          ),
                          isScrollControlled: true,
                          isDismissible: true,
                          backgroundColor: Colors.transparent,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(12.0),
                            ),
                          ),
                        );
                      },
                      icon: Icons.person,
                    ),
                  ],
                ).paddingOnly(top: 16.0, bottom: 12.0),
              ),
              // Secondary Language
              Visibility(
                visible:
                    (userDetails.secondaryLanguage?.isNotEmpty ?? false)
                        ? (userDetails.secondaryLanguage !=
                            userDetails.primaryLanguage)
                        : false,
                child: Container(
                  margin: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.0),
                    boxShadow: [
                      BoxShadow(
                        offset: const Offset(0.0, 0.0),
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 12.0,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
                        child: Text(
                          userDetails.secondaryLanguage ?? "",
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: FontSize.xXL,
                          ),
                        ),
                      ),
                      RecordVoiceTile(
                        title: LocaleKeys.liveProfileIntro.tr,
                        subtitle: getSubtitleTitleWidget(
                          status:
                              controller.audioStatusList
                                  .firstWhereOrNull(
                                    (audioStatus) =>
                                        audioStatus.type ==
                                        RecordingAudioType.Secondary,
                                  )
                                  ?.status,
                          recordingUrl:
                              controller.audioStatusList
                                  .firstWhereOrNull(
                                    (audioStatus) =>
                                        audioStatus.type ==
                                        RecordingAudioType.Secondary,
                                  )
                                  ?.audioUrl,
                        ),
                        onTap: () {
                          Get.bottomSheet(
                            UploadAudioBottomSheet(
                              key: const Key("Profile Intro"),
                              title: LocaleKeys.liveProfileIntro.tr,
                              recordingUrl:
                                  controller.audioStatusList
                                      .firstWhereOrNull(
                                        (audioStatus) =>
                                            audioStatus.type ==
                                            RecordingAudioType.Secondary,
                                      )
                                      ?.audioUrl,
                              languageType: "Secondary",
                              language: userDetails.secondaryLanguage,
                              status:
                                  controller.audioStatusList
                                      .firstWhereOrNull(
                                        (audioStatus) =>
                                            audioStatus.type ==
                                            RecordingAudioType.Secondary,
                                      )
                                      ?.status,
                              sampleAudioUrl:
                                  sl<GrowthBookService>().getSampleAudioUrl(),
                              subtitle:
                                  LocaleKeys.liveRecordProfileIntroSubtitle.tr,
                              uploadFunction: (fileUrl) async {
                                return await uploadFunction(
                                  fileUrl: fileUrl,
                                  recordingType: RecordingAudioType.Secondary,
                                  language: userDetails.secondaryLanguage ?? "",
                                );
                              },
                              type: "profileIntro",
                              pendingAudioUrl:
                                  controller.audioStatusList
                                      .firstWhereOrNull(
                                        (audioStatus) =>
                                            audioStatus.type ==
                                            RecordingAudioType.Secondary,
                                      )
                                      ?.audioUrl,
                              reason:
                                  controller.audioStatusList
                                      .firstWhereOrNull(
                                        (audioStatus) =>
                                            audioStatus.type ==
                                            RecordingAudioType.Secondary,
                                      )
                                      ?.reason,
                            ),
                            isScrollControlled: true,
                            isDismissible: true,
                            backgroundColor: Colors.transparent,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(12.0),
                              ),
                            ),
                          );
                        },
                        icon: Icons.person,
                      ),
                    ],
                  ).paddingOnly(top: 16.0, bottom: 12.0),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
