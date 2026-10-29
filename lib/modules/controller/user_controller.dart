import 'dart:async';
import 'dart:math' as math;

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/constants/string_constants.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/core/injection_container.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/core/services/alert_service.dart';
import 'package:voiceclub_partner/core/services/analytics_service.dart';
import 'package:voiceclub_partner/core/services/app_lock_service.dart';
import 'package:voiceclub_partner/core/services/growthbook_service.dart';
import 'package:voiceclub_partner/core/services/intro_audio_policy_service.dart';
import 'package:voiceclub_partner/core/services/logger.dart';
import 'package:voiceclub_partner/data/models/account/audio_status.dart';
import 'package:voiceclub_partner/data/models/account/get_current_online_duration_response.dart';
import 'package:voiceclub_partner/data/models/account/get_kyc_response.dart';
import 'package:voiceclub_partner/data/models/account/get_meeting_schedule_response.dart';
import 'package:voiceclub_partner/data/models/account/meeting.dart';
import 'package:voiceclub_partner/data/models/account/onboarding_details.dart';
import 'package:voiceclub_partner/data/models/data.dart';
import 'package:voiceclub_partner/data/models/metrics/get_probation_details_response.dart';
import 'package:voiceclub_partner/data/models/query/start_session_response_model.dart';
import 'package:voiceclub_partner/domain/usecases/account/get_audio_status.dart';
import 'package:voiceclub_partner/domain/usecases/account/get_current_online_duration.dart';
import 'package:voiceclub_partner/domain/usecases/account/get_kyc.dart';
import 'package:voiceclub_partner/domain/usecases/account/get_meeting_schedule.dart';
import 'package:voiceclub_partner/domain/usecases/account/get_onboarding_details.dart';
import 'package:voiceclub_partner/domain/usecases/account/get_profile.dart';
import 'package:voiceclub_partner/domain/usecases/account/update_notification_preference.dart'
    as notifications;
import 'package:voiceclub_partner/domain/usecases/account/update_onboarding_stage.dart';
import 'package:voiceclub_partner/domain/usecases/account/update_status.dart';
import 'package:voiceclub_partner/domain/usecases/agreement/get_file_url.dart';

import 'package:voiceclub_partner/domain/usecases/query/start_query_session.dart';
import 'package:voiceclub_partner/modules/controller/call_controller.dart';
import 'package:voiceclub_partner/modules/controller/probation_controller.dart';
import 'package:voiceclub_partner/view/home/enable_notification_screen.dart';
import 'package:voiceclub_partner/view/landing/landing_controller.dart';
import 'package:voiceclub_partner/view/tutorial/demo/widgets/core/next_stage_bottom_sheet.dart';
import 'package:voiceclub_partner/view/widgets/new_online_duration_bottom_sheet.dart';
import 'package:voiceclub_partner/view/widgets/reverse_call_adoption_bottom_sheet.dart';
import 'package:voiceclub_partner/view/widgets/status_switch_bottom_sheet.dart';
import 'package:voiceclub_partner/view/widgets/unread_bottom_sheet.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';

class UserController extends GetxController {
  final DataModel initUserDataModel;
  final PartnerCurrentStatus initPartnerStatus;
  final GetProbationDetailsResponseModel initProbationData;

  UserController({
    required this.initUserDataModel,
    required this.initPartnerStatus,
    required this.initProbationData,
  });

  final userDetails = DataModel().obs;
  final audioStatusList = <AudioStatus>[].obs;
  final currentOnlineDuration = GetCurrentOnlineDurationResponseModel().obs;
  final kycDetails = GetKYCResponseModel().obs;
  final partnerStatus = PartnerCurrentStatus.NULL.obs;

  Timer? idleStateTimer;
  final meetingSchedule = Rxn<GetMeetingScheduleResponseModel>();
  final isAppLockEnabled = false.obs;
  final managerContactNumber = "".obs;
  final growthBookService = sl<GrowthBookService>();
  bool _isUpdatingActivityStatus = false;

  // Helper getter for meetings list
  List<Meeting> get meetings => meetingSchedule.value?.meetings ?? [];

  @override
  void onInit() {
    super.onInit();
    userDetails.value = initUserDataModel;
    partnerStatus.value = initPartnerStatus;
    startIdleTimer();
    _fetchLockStatus();
  }

  @override
  void onReady() {
    super.onReady();
    sl<AnalyticsService>().setUserProperties(AccountType.SUPPLY);
  }

  int get accountId => userDetails.value.accountId ?? 0;

  bool get isOnLeave => currentOnlineDuration.value.isLeave ?? false;

  bool get isOnline => userDetails.value.status == "ONLINE";

  bool get isOnlineOrBusy => isOnline || isBusy;

  bool get isBusy => userDetails.value.status == "BUSY";

  TutorialStage get currentStage =>
      userDetails.value.onboardingStage ?? TutorialStage.DONE;

  bool get isNotificationsEnabled =>
      userDetails.value.user?.notificationPreference == "ON";

  String get avatarUrl => userDetails.value.user?.avatar ?? "";

  String get primaryLanguage => userDetails.value.primaryLanguage ?? '';
  String get secondaryLanguage => userDetails.value.secondaryLanguage ?? '';

  bool get isAgencyPartner => userDetails.value.isAgencyPartner ?? false;

  bool get enablePayoutWithdraw =>
      !isAgencyPartner &&
      ((growthBookService
              .fetchPenaltyWithdrawalExperiment()
              ?.isWithdrawalAllowed ??
          false));

  bool get showManagersFeedback {
    final isOnboardingStageGreaterThanS2 =
        userDetails.value.onboardingStage != null &&
        userDetails.value.onboardingStage!.isGreaterThan(TutorialStage.S2);

    final isCurrentStageLive =
        userDetails.value.currentStage == PartnerCurrentStatus.LIVE;
    final wasNotFired =
        userDetails.value.previousStage != PartnerCurrentStatus.FIRED;

    if (isOnboardingStageGreaterThanS2 && !isCurrentStageLive) {
      return true;
    }

    if (isOnboardingStageGreaterThanS2 && isCurrentStageLive && wasNotFired) {
      final dateStr = userDetails.value.stageChangeDate;
      if (dateStr == null) return false;

      try {
        final date = DateTime.parse(dateStr).toLocal();
        final onlyStageChangeDate =
            DateTime(date.year, date.month, date.day).toLocal();
        final now = DateTime.now().toLocal();
        final onlyNowDate = DateTime(now.year, now.month, now.day);
        final difference = onlyNowDate.difference(onlyStageChangeDate).inDays;
        return difference <= 7;
      } catch (e) {
        return false;
      }
    } else {
      return false;
    }
  }

  String get getCurrentEligibleReward {
    String reward = "₹0";
    var currentOnlineDurationInHours =
        currentOnlineDuration.value.duration ?? 0;
    for (var slab in getCutoffList) {
      if (slab.rewardsType == RewardsType.Penalty) {
        if (slab.cutoff > currentOnlineDurationInHours) {
          reward = "- ₹${slab.rewards}";
          break;
        }
      } else if (slab.rewardsType == RewardsType.Reward) {
        if (slab.cutoff < currentOnlineDurationInHours) {
          reward = "+ ₹${slab.rewards}";
        }
      }
    }
    return reward;
  }

  Color get getCurrentSlabColor {
    Color color = ApplicationColors.yellow;
    var currentOnlineDurationInHours =
        currentOnlineDuration.value.duration ?? 0;
    for (var slab in getCutoffList) {
      if (slab.rewardsType == RewardsType.Penalty) {
        if (slab.cutoff > currentOnlineDurationInHours) {
          color = slab.color;
          break;
        }
      } else if (slab.rewardsType == RewardsType.Reward) {
        if (slab.cutoff < currentOnlineDurationInHours) {
          color = slab.color;
        }
      }
    }
    return color;
  }

  List<CutoffSlabs> get getCutoffList {
    try {
      final penalties = currentOnlineDuration.value.penalties ?? [];
      final penaltiesCutoffs = currentOnlineDuration.value.penaltyCutoffs ?? [];
      final rewards = currentOnlineDuration.value.rewards ?? [];
      final rewardsCutoffs = currentOnlineDuration.value.rewardCutoffs ?? [];

      final resultMap = <CutoffSlabs>[];

      // First Add penalties
      if (penalties.isNotEmpty) {
        for (int i = 0; i < penalties.length; i++) {
          resultMap.add(
            CutoffSlabs(
              penalties[i],
              penaltiesCutoffs[i],
              RewardsType.Penalty,
              _getSlabColors(RewardsType.Penalty, i),
            ),
          );
          if (i == penalties.length - 1) {
            resultMap.add(
              CutoffSlabs(
                penalties[i],
                penaltiesCutoffs[i],
                RewardsType.Pending,
                _getSlabColors(RewardsType.Pending, i),
              ),
            );
          }
        }
      }

      // Add Rewards
      if (rewards.isNotEmpty) {
        for (int i = 0; i < rewards.length; i++) {
          resultMap.add(
            CutoffSlabs(
              rewards[i],
              rewardsCutoffs[i],
              RewardsType.Reward,
              _getSlabColors(RewardsType.Reward, i),
            ),
          );
        }
      }
      return resultMap;
    } catch (_) {
      return [];
    }
  }

  Color _getSlabColors(RewardsType rewardsType, int index) {
    List<Color> predefinedColors = [
      const Color(0xFF4AA611),
      const Color(0xFF112FA6),
      Colors.deepOrange,
      Colors.deepPurple,
      Colors.greenAccent,
    ];
    switch (rewardsType) {
      case RewardsType.Reward:
        if (index < predefinedColors.length) {
          return predefinedColors[index];
        } else {
          return Color(
            (math.Random().nextDouble() * 0xFFFFFF).toInt(),
          ).withValues(
            alpha: 1.0,
          ); // Random color if predefined colors are exhausted
        }
      case RewardsType.Penalty:
        return ApplicationColors.primaryRed;
      case RewardsType.Pending:
        return ApplicationColors.yellow;
    }
  }

  bool get hasStartedAudioUpload => audioStatusList.isNotEmpty;

  bool get hasUploadedAllAudios {
    // Create a set of all RecordingAudioType values
    final allTypes =
        (userDetails.value.secondaryLanguage?.isNotEmpty ?? false) &&
                (userDetails.value.secondaryLanguage !=
                    userDetails.value.primaryLanguage)
            ? RecordingAudioType.values.toSet()
            : {RecordingAudioType.Main};

    // Extract the types from the audioStatusList
    final typesInList =
        audioStatusList
            .where(
              (audioStatus) => audioStatus.type != null,
            ) // Filter out null types
            .map((audioStatus) => audioStatus.type)
            .toSet();

    // Check if the set of types in the list contains all enum values
    return typesInList.containsAll(allTypes);
  }

  RecordingAudioStatus get audioApprovalStatus {
    try {
      // Check if there is any rejected audio
      // if (audioStatusList
      //     .any((audio) => audio.status == RecordingAudioStatus.Rejected)) {
      //   return RecordingAudioStatus.Rejected;
      // }

      // Check if all audios are approved and we have an entry for each type
      final typesWithStatuses =
          audioStatusList
              .where(
                (audio) =>
                    (audio.status == RecordingAudioStatus.Approved ||
                        audio.status == RecordingAudioStatus.AiApproved),
              )
              .map((audio) => audio.type)
              .toSet();

      final allTypes =
          (userDetails.value.secondaryLanguage?.isNotEmpty ?? false) &&
                  (userDetails.value.secondaryLanguage !=
                      userDetails.value.primaryLanguage)
              ? RecordingAudioType.values.toSet()
              : {RecordingAudioType.Main};

      var comparableList = <AudioStatus>[];

      for (final e in allTypes) {
        final matchingAudio = audioStatusList.firstWhere(
          (p0) => p0.type == e,
          orElse:
              () => AudioStatus(
                type: e,
                status: RecordingAudioStatus.Pending,
              ), // Default value
        );
        comparableList.add(matchingAudio);
      }

      if (comparableList.any(
        (element) => element.status == RecordingAudioStatus.Rejected,
      )) {
        return RecordingAudioStatus.Rejected;
      }

      if (typesWithStatuses.containsAll(allTypes)) {
        return RecordingAudioStatus.Approved;
      }

      // In all other cases, return Pending
      return RecordingAudioStatus.Pending;
    } catch (_) {
      return RecordingAudioStatus.Pending;
    }
  }

  Future<void> fetchData({bool fetchOnlineDuration = false}) async {
    try {
      final response = await sl<GetProfileUsecase>().call(NoParams());
      if (response.data != null && response.error == null) {
        userDetails(response.data!);
        await getMeetingSchedule();
        if (!(response.data?.isLiveOnlyPartner ?? false)) {
          await fetchExtraUserData(fetchOnlineDuration);
        }
      }
    } catch (_) {
    } finally {
      update();
    }
  }

  Future<void> fetchExtraUserData(bool fetchOnlineDuration) async {
    await fetchAudioStatus();
    await fetchKYCDetails();
    if (fetchOnlineDuration) {
      await getOnlineDuration();
    }
  }

  Future<void> fetchAudioStatus() async {
    final response = await sl<GetAudioStatusUsecase>().call(NoParams());
    if (response.data != null && response.error == null) {
      audioStatusList(response.data?.audios ?? []);
    }
  }

  Future<void> getOnlineDuration() async {
    try {
      var response = await sl<GetCurrentOnlineDurationUseCase>().call(
        NoParams(),
      );
      if (response.data != null) {
        currentOnlineDuration.value =
            response.data ?? GetCurrentOnlineDurationResponseModel();
      }
    } catch (_) {}
  }

  Future<bool> didUpdateOnbardingTutorialStage() async {
    if (!isOnlineOrBusy) {
      if (currentStage != TutorialStage.DONE &&
          partnerStatus.value != PartnerCurrentStatus.LIVE) {
        final nextStage = TutorialStage.values[currentStage.index + 1];
        final previousDate = await _stageUpdateReferenceDate(
          nextStage: nextStage,
        );
        if (previousDate == null) {
          return false;
        }
        final now = DateTime.now();
        if (StringConstants.isDev
            ? now.difference(previousDate).inMinutes >= 3
            : now.difference(previousDate).inDays >= 1) {
          final response = await sl<UpdateOnboardingStageUseCase>().call(
            OnboardingStageUpdateParams(stage: nextStage),
          );
          if (response.error == null) {
            sl<AnalyticsService>().trackEvent(
              "onboardingStageUpdate",
              eventProperties: {
                "currentStage": currentStage.name,
                "updatedStage": nextStage.name,
                'journeyType': 'Forceful-Old-Journey',
              },
            );
            if (nextStage == TutorialStage.S5) {
              await sl<IntroAudioPolicyService>().clearNewLiveIntroCompletedAt(
                accountId,
              );
            }
            if (nextStage == TutorialStage.DONE) {
              await sl<AnalyticsService>().firePurchaseEvents();
            }
            Get.context?.loaderOverlay.hide();
            Get.bottomSheet(
              NextOnboardingStageBottomSheet(nextStage: nextStage),
              isDismissible: false,
              enableDrag: false,
            );
            return true;
          }
        }
      }
    }

    return false;
  }

  Future<DateTime?> _stageUpdateReferenceDate({
    required TutorialStage nextStage,
  }) async {
    if (nextStage == TutorialStage.S5) {
      final introCompletedAt = await sl<IntroAudioPolicyService>()
          .getNewLiveIntroCompletedAt(accountId);
      if (introCompletedAt != null) {
        return introCompletedAt;
      }
    }
    if (userDetails.value.onboardingStageChangeDate?.isEmpty ?? true) {
      return null;
    }
    return DateTime.tryParse(
          userDetails.value.onboardingStageChangeDate ?? '',
        ) ??
        DateTime.now();
  }

  Future<void> showUpdateStatusBottomSheet(bool value) async {
    if (_isUpdatingActivityStatus) {
      return;
    }
    _isUpdatingActivityStatus = true;

    try {
      if (value ? !isOnline : isOnlineOrBusy) {
        Get.context?.loaderOverlay.show();
        if (!value) {
          await getOnlineDuration();
        } else {
          final didUpdate = await didUpdateOnbardingTutorialStage();
          if (didUpdate) {
            return;
          }
          Get.context?.loaderOverlay.show();
          // Check notifications permission
          if (!(await Permission.notification.isGranted)) {
            Get.context?.loaderOverlay.hide();
            Get.to(() => const EnableNotificationsScreen());
            return;
          }
        }
        bool result = false;
        Get.context?.loaderOverlay.hide();

        final totalDuration =
            currentOnlineDuration.value.duration?.toDouble() ?? 0.0;
        int totalMinute = (totalDuration * 60).floor();
        int convertedHours = totalMinute ~/ 60;
        int remainingMinutes = totalMinute % 60;

        final totalHours = convertedHours.toString();
        final totalMinutes = remainingMinutes.toString();
        result =
            await Get.bottomSheet<bool>(
              StatusSwitchBottomSheet(
                online: value,
                durationHours: totalHours,
                durationMinutes: totalMinutes,
                requiredDurationInHours:
                    currentOnlineDuration.value.low?.round() ?? 7,
              ),
            ) ??
            false;
        if (result) {
          _updateStatus(value: value);
        }
      }
    } catch (_) {
    } finally {
      _isUpdatingActivityStatus = false;
    }
  }

  void _updateStatus({required bool value}) async {
    try {
      Get.context?.loaderOverlay.show();
      if ((userDetails.value.recordingUrl?.isEmpty ?? true) &&
          sl<IntroAudioPolicyService>().blocksGoOnlineWithoutRecording) {
        await sl<UpdateStatusUsecase>().call(const Params(isOnline: false));
        await Future.delayed(const Duration(seconds: 2));
        await fetchData(fetchOnlineDuration: true);
        AlertService.showSnackBar(
          snackBarType: SnackBarType.Warning,
          title: LocaleKeys.liveRequired.tr,
          subtitle: LocaleKeys.liveAudioRecordingIsNeededTo.tr,
        );
      } else {
        final response = await sl<UpdateStatusUsecase>().call(
          Params(isOnline: value),
        );
        if (response.error != null) {
          try {
            final message =
                (response.error?.response?.data
                        as Map<String, dynamic>)['message']
                    as String?;
            if (message?.toLowerCase().contains("unread") ?? false) {
              Get.bottomSheet(
                UnreadBottomSheet(
                  message: message ?? "Please read all your unread messages.",
                ),
              );
            } else {
              await fetchData(fetchOnlineDuration: true);
              AlertService.showSnackBar(
                snackBarType: SnackBarType.Error,
                title: LocaleKeys.liveCannotGoLive.tr,
                subtitle: message ?? "",
              );
            }
          } catch (_) {}
        } else {
          await Future.delayed(const Duration(milliseconds: 500));
          await fetchData(fetchOnlineDuration: true);
          if (value == isOnlineOrBusy) {
            if (!value) {
              sl<AnalyticsService>().trackEvent(
                "partnerActivity",
                eventProperties: {
                  "currentStatus": "OFFLINE",
                  "stage": partnerStatus.value.name,
                  "currentDuration": double.tryParse(
                    currentOnlineDuration.value.duration?.toStringAsFixed(2) ??
                        "0.0",
                  ),
                  "score": Get.find<ProbationController>().getCurrentScore,
                },
              );
              endIdleTimer();
            } else {
              sl<AnalyticsService>().trackEvent(
                "partnerActivity",
                eventProperties: {
                  "currentStatus": "ONLINE",
                  "stage": partnerStatus.value.name,
                  "score": Get.find<ProbationController>().getCurrentScore,
                },
              );
              endIdleTimer();
              startIdleTimer();
            }
          }
        }
      }
    } catch (_) {
    } finally {
      Get.context?.loaderOverlay.hide();
    }
  }

  Future<void> updateNotificationPreference() async {
    if (userDetails.value.category?.categoryCode == CategoryCode.GOSSIP) {
      try {
        Get.context?.loaderOverlay.show();
        final newPreference = isNotificationsEnabled ? "OFF" : "ON";
        final response =
            await sl<notifications.UpdateNotificationPreferenceUseCase>().call(
              notifications.Params(notificationPreference: newPreference),
            );
        if (response.error != null) {
          final data = response.error?.response?.data;
          String message = data?['message'] ?? 'Something went wrong';
          AlertService.showSnackBar(
            snackBarType: SnackBarType.Error,
            title: LocaleKeys.liveNotificationSwitchError.tr,
            subtitle: message,
          );
        } else {
          await Future.delayed(const Duration(milliseconds: 500));
          await fetchData(fetchOnlineDuration: true);
        }
      } catch (_) {
      } finally {
        Get.context?.loaderOverlay.hide();
      }
    }
  }

  Future<StartSessionResponseModel?> fetchQuerySession({
    required String source,
  }) async {
    String? error;
    try {
      var response = await sl<StartQuerySessionUseCase>().call(
        StartQuerySessionParams(source: source),
      );
      if (response.data != null) {
        return response.data!;
      } else {
        final responseData =
            response.error?.response?.data as Map<String, dynamic>?;
        if (responseData?.containsKey("message") ?? false) {
          error = (responseData?['message']).toString();
        }
        AlertService.showSnackBar(
          snackBarType: SnackBarType.Error,
          title: LocaleKeys.somethingWentWrong.tr,
          subtitle: error ?? "Please try again later.",
        );
        return null;
      }
    } catch (e) {
      Logger.logMessage("Error fetching query session ${e.toString()}");
      error = e.toString();
      AlertService.showSnackBar(
        snackBarType: SnackBarType.Error,
        title: LocaleKeys.somethingWentWrong.tr,
        subtitle: error,
      );
      return null;
    }
  }

  Future<void> fetchKYCDetails() async {
    try {
      final response = await sl<GetKYCUsecase>().call(NoParams());
      if (response.data != null && response.error == null) {
        kycDetails.value = response.data ?? GetKYCResponseModel();
      }
    } catch (_) {
      AlertService.showSnackBar(
        snackBarType: SnackBarType.Warning,
        title: LocaleKeys.liveSomethingWentWrong.tr,
        subtitle: LocaleKeys.pleaseTryAgainLater.tr,
      );
    } finally {}
  }

  void startIdleTimer() {
    if (!(idleStateTimer?.isActive ?? false)) {
      idleStateTimer = Timer.periodic(const Duration(minutes: 5), (_) {
        if (isOnlineOrBusy &&
            !sl<CallController>().isOnCall &&
            Get.currentRoute == '/LandingScreen' &&
            Get.find<LandingController>().selectedTab.value ==
                BottomBarTabType.HOME &&
            !(Get.isBottomSheetOpen ?? false) &&
            !currentStage.isLessThan(TutorialStage.S3)) {
          Get.bottomSheet(const ReverseCallAdoptionBottomSheet());
        }
      });
    }
  }

  void endIdleTimer() {
    if (idleStateTimer?.isActive ?? false) idleStateTimer?.cancel();
  }

  Future<void> getMeetingSchedule() async {
    final response = await sl<GetMeetingScheduleUseCase>().call(NoParams());
    if (response.data != null && response.error == null) {
      meetingSchedule.value = response.data;
    }
  }

  /// Update the lock status of the app
  void updateLockStatus() async {
    try {
      final value = !isAppLockEnabled.value;
      await AppLockService.setLockStatus(value);
      isAppLockEnabled.value = value;
      sl<AnalyticsService>().trackEvent(
        "appLockStatusChangedPartner",
        eventProperties: {"isAppLockEnabled": value},
      );
    } catch (_) {}
  }

  void _fetchLockStatus() async {
    try {
      final enabled = await AppLockService.getLockStatus();
      isAppLockEnabled.value = enabled;
    } catch (_) {}
  }

  // Meeting reminder management methods
  Future<bool> isReminderScheduled(int meetingId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool('meeting_reminder_$meetingId') ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<void> scheduleReminder(Meeting meeting) async {
    try {
      final reminderTime = meeting.startDateTime.subtract(
        const Duration(minutes: 10),
      );

      // Only schedule if reminder time is in the future
      if (reminderTime.isAfter(DateTime.now())) {
        await AwesomeNotifications().createNotification(
          content: NotificationContent(
            id: meeting.id ?? 0,
            channelKey: 'basic_channel',
            title: LocaleKeys.liveMeetingReminder.tr,
            body:
                'Your meeting "${meeting.title ?? 'Partner Meeting'}" starts in 10 minutes',
            notificationLayout: NotificationLayout.Default,
          ),
          schedule: NotificationCalendar(
            hour: reminderTime.hour,
            minute: reminderTime.minute,
            second: 0,
            day: reminderTime.day,
            month: reminderTime.month,
            year: reminderTime.year,
          ),
        );

        // Save reminder status
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('meeting_reminder_${meeting.id}', true);

        sl<AnalyticsService>().trackEvent(
          "meetingReminderScheduled",
          eventProperties: {
            'meetingId': meeting.id,
            'meetingTitle': meeting.title,
            'reminderTime': reminderTime.toIso8601String(),
          },
        );
      }
    } catch (e) {
      Logger.logMessage("Error scheduling reminder: ${e.toString()}");
    }
  }

  Future<void> cancelReminder(int meetingId) async {
    try {
      await AwesomeNotifications().cancel(meetingId);

      // Remove reminder status
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('meeting_reminder_$meetingId');

      sl<AnalyticsService>().trackEvent(
        "meetingReminderCancelled",
        eventProperties: {'meetingId': meetingId},
      );
    } catch (e) {
      Logger.logMessage("Error cancelling reminder: ${e.toString()}");
    }
  }

  bool shouldShowRemindButton(Meeting meeting) {
    final now = DateTime.now();
    final tenMinutesBefore = meeting.startDateTime.subtract(
      const Duration(minutes: 10),
    );
    return now.isBefore(tenMinutesBefore);
  }

  Future<String?> getFileUrlByName({required String fileName}) async {
    try {
      final response = await sl<GetFileUrlUseCase>().call(
        GetFileUrlParams(fileName: fileName),
      );
      if (response.data != null && response.error == null) {
        return response.data?.url;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<OnboardingDetailsResponseModel?> getOnboardingDetails() async {
    try {
      final response = await sl<GetOnboardingDetailsUseCase>().call(NoParams());
      if (response.data != null && response.error == null) {
        return response.data;
      } else {
        AlertService.showSnackBar(
          snackBarType: SnackBarType.Warning,
          title: LocaleKeys.liveSomethingWentWrong2.tr,
          subtitle: LocaleKeys.pleaseTryAgainLater.tr,
        );
        return null;
      }
    } catch (e) {
      Logger.logMessage("Error getting onboarding details: ${e.toString()}");
      return null;
    }
  }
}
