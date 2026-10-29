import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:byteplus_rtc/byteplus_rtc.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:neo_beep/neo_beep.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:proximity_sensor/proximity_sensor.dart';
import 'package:screen_off/screen_off.dart';
import 'package:vibration/vibration.dart';
import 'package:voiceclub_partner/core/constants/asset_constants.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/constants/string_constants.dart';
import 'package:voiceclub_partner/core/injection_container.dart';
import 'package:voiceclub_partner/core/services/alert_service.dart';
import 'package:voiceclub_partner/core/services/analytics_service.dart';
import 'package:voiceclub_partner/core/services/auth_service.dart';
import 'package:voiceclub_partner/core/services/events_service.dart';
import 'package:voiceclub_partner/core/services/logger.dart';
import 'package:voiceclub_partner/core/services/notification_service.dart';
import 'package:voiceclub_partner/core/services/notify_demand_service.dart';
import 'package:voiceclub_partner/core/services/rtc_app_kill_manager.dart';
import 'package:voiceclub_partner/data/models/calling/call_model.dart';
import 'package:voiceclub_partner/data/models/calling/call_state_model.dart';
import 'package:voiceclub_partner/data/models/chat/chat_theme.dart';
import 'package:voiceclub_partner/domain/usecases/calling/accept_call.dart';
import 'package:voiceclub_partner/domain/usecases/calling/end_call.dart' as end;
import 'package:voiceclub_partner/domain/usecases/calling/ping_call.dart'
    as ping_call_use_case;
import 'package:voiceclub_partner/modules/controller/call_controller.dart';
import 'package:voiceclub_partner/modules/controller/probation_controller.dart';
import 'package:voiceclub_partner/modules/controller/user_controller.dart';
import 'package:voiceclub_partner/modules/controller/wallet_controller.dart';
import 'package:voiceclub_partner/view/notes/notes_bottom_sheet.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';

class IncomingCallController extends GetxController {
  final String channelId;
  final CallModel initCallData;
  final int callerUid;
  final String name;
  final String? avatar;
  final StreamSubscription<CallStateModel?> callStateStreamSubscription;
  final num lifeTimeCallDuration;

  IncomingCallController({
    required this.channelId,
    required this.initCallData,
    required this.callerUid,
    required this.name,
    required this.callStateStreamSubscription,
    required this.avatar,
    required this.lifeTimeCallDuration,
  });

  RTCEngine? _rtcEngine;
  RTCRoom? _rtcRoom;
  final _roomHandler = IRTCRoomEventHandler();
  final _rtcEngineEventHandler = IRTCEngineEventHandler();
  final _audioPlayer = AudioPlayer();
  final supplyUserDetails = Get.find<UserController>().userDetails.value;
  final _walletController = Get.find<WalletController>();
  final _notificationService = NotifyDemandService();
  static const _foregroundService = MethodChannel('foregroundChannel');

  StreamSubscription<int>? _streamSubscription;
  Timer? _callTimer;
  Timer? _ringingTimer;
  Timer? _muteTimer;
  Timer? _pingCallTimer;
  bool _left = false;
  bool _isCaptureVolumeBoosted = false;
  bool _isCaptureVolumeReduced = false;
  final Stopwatch _callDurationTime = Stopwatch();
  bool retryJoin = false;
  int lastProximityEvent = 0;

  // Dynamic variables
  final _rtcToken = Rxn<String>();
  final callDurationSeconds = 0.obs;
  int ringDurationSeconds = 0;
  final muteSeconds = 60.obs;
  final backgroundImage = AssetConstants.friendCallBackground;
  final isMuted = false.obs;
  final isSpeaker = false.obs;
  final isAccepted = false.obs;
  final isNew = false.obs;
  final remoteUserMute = false.obs;
  final callModel = Rxn<CallModel>();
  final remoteUser = Rxn<UserInfo>();
  final demandAccountId = Rxn<int>();

  bool isFromRandomCall = false;
  bool isFromFindFriend = false;

  @override
  void onInit() {
    WakelockPlus.enable();
    callModel.value = initCallData;
    if (callModel.value?.label?.toLowerCase().contains('new') ?? false) {
      isNew.value = true;
    }
    demandAccountId.value = callModel.value?.callerAccountId;
    trackCallEvent("callReceivedPartner");
    _updateCallStateStreamSubscription();
    _initAudioPlayer();
    super.onInit();
  }

  Future<void> _initAudioPlayer() async {
    try {
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer.play(AssetSource(AssetConstants.rozanaRingtone));
    } catch (e) {
      Logger.logSoftError(
        'Error initializing audio player $channelId',
        StackTrace.current,
      );
    }
  }

  @override
  void dispose() async {
    try {
      WakelockPlus.disable();
      if (_rtcRoom != null) {
        await _rtcRoom?.leaveRoom();
        await _rtcRoom?.destroy();
      }
      if (_rtcEngine != null) {
        _rtcEngine?.destroy();
      }
      await _stopForegroundService();
      if (_callTimer?.isActive ?? false) _callTimer?.cancel();
      if (_pingCallTimer?.isActive ?? false) _pingCallTimer?.cancel();
      await _stopAudioPlayer();
      NeoBeep.beep(true);
      // NotificationUtils.stopForegroundServiceNotification(_notificationId);
    } catch (_) {
    } finally {
      if (Platform.isAndroid) {
        //Turn on the screen when the call ends
        await ScreenOff.turnScreenOn();
      }
      _ringingTimer?.cancel();
      _streamSubscription?.cancel();
      super.dispose();
    }
  }

  void startRingingTimer() {
    ringDurationSeconds = 0;
    _ringingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      ringDurationSeconds++;
    });
  }

  void stopRingingTimer() {
    _ringingTimer?.cancel();
  }

  Future<void> _updateCallStateStreamSubscription() async {
    try {
      Logger.logMessage(
        'Updating call state stream subscription $channelId',
        name: 'IncomingCallController',
      );

      // Listen to the Firebase call state stream
      callStateStreamSubscription.onData((callStateModel) {
        if (!_left && callStateModel != null) {
          // Handle different call states
          if (callStateModel.callState == CallState.ENDED ||
              callStateModel.callState == CallState.MISSED ||
              callStateModel.callState == CallState.REJECTED) {
            Logger.logMessage(
              'Call state indicates call end $channelId',
              name: 'IncomingCallController',
            );
            leave();
          } else {
            Logger.logMessage(
              'Received call state update $channelId',
              name: 'IncomingCallController',
            );
          }
        }
      });

      callStateStreamSubscription.onError((
        Object error,
        StackTrace stackTrace,
      ) {
        Logger.logSoftError('Call state stream error $channelId', stackTrace);
      });

      callStateStreamSubscription.onDone(() {
        Logger.logMessage(
          'Call state stream closed unexpectedly $channelId',
          name: 'IncomingCallController',
        );
      });
    } catch (e) {
      Logger.logSoftError(
        'Failed to initialize call state stream $channelId',
        StackTrace.current,
      );
    }
  }

  void _startCallPinging() {
    _pingCallTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      try {
        if (!_left) {
          await sl<ping_call_use_case.PingCallUseCase>().call(
            ping_call_use_case.Params(channelId: channelId),
          );
        }
      } catch (e) {
        Logger.logSoftError(
          'Failed to ping call $channelId',
          StackTrace.current,
        );
      }
    });
  }

  void _startMuteTimer() {
    if (muteSeconds.value > 0) {
      _muteTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (muteSeconds.value > 0) {
          muteSeconds.value--;
        } else {
          if (isMuted.value) {
            enableLocalAudio();
          }
          _muteTimer?.cancel();
        }
      });
    }
  }

  void _pauseMuteTimer() {
    _muteTimer?.cancel();
  }

  Future<void> _startForegroundService() async {
    try {
      await _foregroundService.invokeMethod('startService');
      final token = await sl<AuthService>().getAuthorizationToken();
      if (token != null) {
        await RTCAppKillManager.initCallConfigs(
          inCall: true,
          channelId: channelId,
          endedBy: supplyUserDetails.accountId ?? 0,
          jwtToken: token,
          callAlreadyEnded: false,
        );
      }
    } on PlatformException catch (e) {
      Logger.logSoftError(
        'Failed to start microphone foreground service $channelId :: ${e.toString()}',
        StackTrace.current,
      );
    }
  }

  Future<void> _stopForegroundService() async {
    try {
      await _foregroundService.invokeMethod('stopService');
      final token = await sl<AuthService>().getAuthorizationToken();
      if (token != null) {
        await RTCAppKillManager.initCallConfigs(
          inCall: false,
          channelId: channelId,
          endedBy: supplyUserDetails.accountId ?? 0,
          jwtToken: token,
          callAlreadyEnded: true,
        );
      }
    } on PlatformException catch (e) {
      Logger.logSoftError(
        'Failed to stop microphone foreground service $channelId ${e.toString()}',
        StackTrace.current,
      );
    }
  }

  void _startCallTimer() {
    _callTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      try {
        if (!_left) {
          callDurationSeconds.value++;
          if (callDurationSeconds.value == 180 && isNew.value) {
            if (!(Get.isBottomSheetOpen ?? false)) {
              openNotesBottomSheet();
            }
          } else if (remoteUser.value == null &&
              callDurationSeconds.value > 10) {
            await leave(isMe: true);
          }
        } else {
          _callTimer?.cancel();
        }
      } catch (e) {
        Logger.logMessage(
          'Error in call timer $channelId',
          name: 'IncomingCallController',
        );
      }
    });
  }

  Future<void> _stopAudioPlayer() async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.dispose();
    } catch (_) {}
  }

  void _acceptCall() async {
    try {
      if (!isAccepted.value && _rtcToken.value != null) {
        _initRoomEventHandler();
        await Future.delayed(const Duration(milliseconds: 500));
        Logger.logMessage(
          'Initializing RTC connection $channelId',
          name: 'IncomingCallController',
        );
        final joinRTCResult = await _initVideoAndJoinRoom(
          token: _rtcToken.value ?? '',
        );
        final joinRTCResultCode = joinRTCResult.$1;
        final joinRTCResultMessage = joinRTCResult.$2;
        if (joinRTCResultCode == 0) {
          await _stopAudioPlayer();
          _streamSubscription = ProximitySensor.events.listen((int event) {
            _handleAndroidProximitySensorEvent(event);
          });
          Vibration.vibrate(duration: 100);
          NotificationService.showInternalNotification(
            title: name,
            body: 'Call Connected',
          );
          [Permission.notification].request().then(
            (value) async => {
              if (PermissionStatus.granted == value[Permission.notification])
                {await _startForegroundService()},
            },
          );
          trackCallEvent("callAcceptedPartner");
          isAccepted.value = true;
          _callDurationTime.start();
          _startCallTimer();
        } else {
          _showErrorSnackbar(
            errorCode: "INIT_RTC_FAILURE: $joinRTCResultCode",
            errorMessage: joinRTCResultMessage ?? "",
          );
        }
        _startCallPinging();
        _notificationService.deleteNotificationInfo(
          demandUserId: callModel.value?.callerUid ?? 0,
        );
      }
    } catch (e) {
      _showErrorSnackbar(errorCode: e.toString());
    } finally {
      Get.context?.loaderOverlay.hide();
    }
  }

  void _handleAndroidProximitySensorEvent(int event) async {
    if (Platform.isAndroid && !isSpeaker.value && isAccepted.value) {
      if (lastProximityEvent != event) {
        lastProximityEvent = event;
        if (event == 1) {
          //Turn off the screen when the phone is close to the ear
          await ScreenOff.turnScreenOff();
        } else {
          //Turn on the screen when the phone is away from the ear
          await ScreenOff.turnScreenOn();
        }
      }
    }
  }

  void join() async {
    try {
      Logger.logMessage(
        'Accept button pressed $channelId',
        name: 'IncomingCallController',
      );
      Get.context?.loaderOverlay.show();
      final response = await sl<AcceptCallUsecase>().call(
        Params(channelId: channelId),
      );
      if (response.error != null) {
        _showErrorSnackbar(
          errorCode: "API_ERROR",
          errorMessage:
              "STATUS: ${response.error?.response?.statusCode} DATA: ${response.error?.response?.data.toString()}",
        );
        if (response.error?.response?.statusCode == 400) {
          leave(isMe: true);
        }
      } else {
        _rtcToken.value = response.data?.token;

        Logger.logMessage('Room Token: ${_rtcToken.value}');
        if (_rtcToken.isNotEmpty ?? false) {
          _acceptCall();
        } else {
          _showErrorSnackbar(errorCode: "TOKEN_EMPTY");
        }
      }
    } catch (e) {
      _showErrorSnackbar(errorCode: e.toString());
    }
  }

  void _showErrorSnackbar({
    required String errorCode,
    String errorMessage = "",
  }) {
    Get.context?.loaderOverlay.hide();
    if (isAccepted.value) {
      leave();
    }
    Logger.logSoftError('Failed to accept call $channelId', StackTrace.current);
    trackCallEvent(
      "callAcceptError",
      additionalProperties: {
        "errorCode": errorCode,
        "errorMessage": errorMessage,
      },
    );
    if (!Get.isSnackbarOpen) {
      AlertService.showSnackBar(
        snackBarType: SnackBarType.Error,
        title: LocaleKeys.liveFailedToAcceptCallPlease.tr,
        subtitle: LocaleKeys.liveTroubleshootDevice.trParams({
          'errorCode': errorCode,
        }),
      );
    }
  }

  Future<void> leave({bool isMe = false}) async {
    if (!_left) {
      Get.context?.loaderOverlay.show();
      _left = true;

      try {
        _callDurationTime.stop();
        stopRingingTimer();
        if (isMe) {
          if (!isAccepted.value) {
            trackCallEvent(
              "callDeclinedPartner",
              additionalProperties: {
                "ringDurationInSeconds": ringDurationSeconds,
              },
            );
          }
          await sl<end.EndCallUsecase>().call(
            end.Params(
              callRejected: isMe,
              declineReason: "Decline by Partner",
              channelId: channelId,
              endedByID: supplyUserDetails.accountId ?? 0,
            ),
          );

          if (Platform.isAndroid) {
            await RTCAppKillManager.markCallAlreadyEnded();
          }
        }
        callStateStreamSubscription.cancel();
        _streamSubscription?.cancel();
        _walletController.fetchData();
        _walletController.getWalletTransactionFetch(
          1,
          transactionCategory: TransactionCategory.ALL,
        );
      } catch (e) {
        Logger.logSoftError(
          'Error while leaving call $channelId',
          StackTrace.current,
        );
      } finally {
        if (isAccepted.value) {
          await Future.delayed(const Duration(seconds: 3));
          EventsService.logEventThroughAPI(
            eventType: EventType.CALL,
            propertyId: channelId,
            additionalProperties: {
              "partnerLanguage": callModel.value?.supplyLanguage ?? "",
              "demandLanguage": callModel.value?.demandLanguage ?? "",
              "isFromRandomCall": isFromRandomCall,
              "isFromFindFriend": isFromFindFriend,
            },
          );
        }
        Get.context?.loaderOverlay.hide();
        sl<CallController>().endCall(
          demandAccountId.value,
          name,
          (_callDurationTime.elapsedMilliseconds ~/ 1000).toInt(),
          CategoryCode.GOSSIP,
          isNew.value,
          closeNewUserMenu: isNewUser,
        );

        if (Platform.isAndroid) {
          await RTCAppKillManager.markCallAlreadyEnded();
        }
      }
    }
  }

  void _onMessage(int _, String user, String message) {
    try {
      if (message == "lowBalance") {
        Vibration.vibrate(
          pattern: [500, 1000, 500, 1000, 500, 1000, 500, 1000],
        );
        AlertService.showSnackBar(
          snackBarType: SnackBarType.Warning,
          title: LocaleKeys.liveLowBalance.tr,
          subtitle: LocaleKeys.liveTalkTime230.trParams({'name': name}),
          duration: const Duration(seconds: 3),
        );
      } else {
        final messageMap = jsonDecode(message);
        if (messageMap['type'] == "isFromRandomCall") {
          isFromRandomCall = messageMap['value'] ?? false;
        } else if (messageMap['type'] == "isFromFindFriend") {
          isFromFindFriend = messageMap['value'] ?? false;
        }
      }
    } catch (_) {}
  }

  void switchAudioRoute() {
    isSpeaker.value = !isSpeaker.value;

    /// Set the audio playback device as a speaker or earpiece, and use speakers by default.
    AudioRoute audioRoute =
        isSpeaker.value ? AudioRoute.speakerphone : AudioRoute.earpiece;
    _rtcEngine?.setDefaultAudioRoute(audioRoute);
  }

  /// Initializes the video engine and joins a room.
  ///
  /// Returns:
  /// - `0` if the operation is successful.
  /// - Any other error code returned by the joinRoom method. (`-1`, `-2`, `-3`)
  /// - `-4` if the RTC video engine creation fails.
  /// - `-5` if the room creation fails.
  /// - `-6` if joining the room fails.
  /// - `-7` if an exception occurs during the process.
  Future<(int, String?)> _initVideoAndJoinRoom({required String token}) async {
    try {
      /// Create engine objects.
      _rtcEngine = await RTCEngine.createRTCEngine(
        RTCVideoContext(appId: StringConstants.byteplusAppId),
      );

      if (_rtcEngine == null) {
        return (-4, null);
      } else {
        _rtcEngine?.setRTCEngineEventHandler(_rtcEngineEventHandler);
      }

      _rtcEngine?.setAudioScenario(AudioScenarioType.auto);

      /// Enables internal audio capture. The default is off.
      _rtcEngine?.startAudioCapture();

      /// Create a room.
      _rtcRoom = await _rtcEngine?.createRTCRoom(channelId);

      if (_rtcRoom == null) {
        return (-5, null);
      }

      /// Set room event callback handler
      _rtcRoom?.setRTCRoomEventHandler(_roomHandler);

      /// Join the room.
      UserInfo userInfo = UserInfo(
        userId: (supplyUserDetails.user?.id).toString(),
        extraInfo: "",
      );
      RoomConfig roomConfig = RoomConfig(
        profile: RoomProfile.chat_room,
        isPublishAudio: true,
        isPublishVideo: false,
        isAutoSubscribeAudio: true,
        isAutoSubscribeVideo: false,
      );

      final joinRoomResult =
          await _rtcRoom?.joinRoom(
            userVisibility: true,
            token: token,
            userInfo: userInfo,
            roomConfig: roomConfig,
          ) ??
          -6;

      // joinRoomResult is 0 if the operation is successful, otherwise it is an error code.
      if (joinRoomResult != 0) {
        return (joinRoomResult, null);
      }

      _rtcEngine?.setDefaultAudioRoute(
        isSpeaker.value ? AudioRoute.speakerphone : AudioRoute.earpiece,
      );

      // _rtcEngine?.enableAudioPropertiesReport(AudioPropertiesConfig());

      return (joinRoomResult, null);
    } catch (e) {
      Logger.logSoftError(
        'Error initializing video and joining room $channelId',
        StackTrace.current,
      );
      return (-7, e.toString());
    }
  }

  void _initRoomEventHandler() {
    try {
      /// Callback for remote visible user joining the room.
      _roomHandler.onUserJoined = (UserInfo userInfo) {
        remoteUser.value = userInfo;

        Logger.logMessage(
          'Remote user joined room $channelId',
          name: 'IncomingCallController',
        );
      };

      /// Callback for remote visible user leaving the room.
      _roomHandler.onUserLeave = (String uid, int reason) {
        Logger.logMessage(
          'Remote user left room $channelId reason: $reason',
          name: 'IncomingCallController',
        );
      };

      _roomHandler.onUserPublishStreamAudio = (_, _, isPublished) {
        if (isPublished) {
          remoteUserMute.value = false;
        } else {
          remoteUserMute.value = true;
        }
      };

      _roomHandler.onUserMessageReceived = _onMessage;

      // _rtcEngineEventHandler.onLocalAudioPropertiesReport = (
      //   audioPropertiesInfo,
      // ) {
      //   if (audioPropertiesInfo.isNotEmpty) {
      //     final linearVolume =
      //         audioPropertiesInfo.first.audioPropertiesInfo.linearVolume;

      //     if (linearVolume < 75 && !_isCaptureVolumeBoosted) {
      //       _rtcEngine?.setCaptureVolume(volume: 200);
      //       _isCaptureVolumeBoosted = true;
      //     } else if (linearVolume >= 75 && !_isCaptureVolumeReduced) {
      //       _rtcEngine?.setCaptureVolume(volume: 100);
      //       _isCaptureVolumeReduced = true;
      //     }
      //   }
      // };

      _rtcEngineEventHandler.onAudioDeviceWarning = (
        _,
        audioDeviceType,
        mediaDeviceWarning,
      ) {
        if (mediaDeviceWarning ==
                MediaDeviceWarning.MEDIA_DEVICE_WARNING_CAPTURE_SILENCE &&
            !_isCaptureVolumeBoosted) {
          _rtcEngine?.setCaptureVolume(volume: 200);
          _isCaptureVolumeBoosted = true;
        } else if (mediaDeviceWarning ==
                MediaDeviceWarning.MEDIA_DEVICE_WARNING_OK &&
            _isCaptureVolumeReduced) {
          _rtcEngine?.setCaptureVolume(volume: 100);
          _isCaptureVolumeReduced = true;
        }
      };
    } catch (e) {
      Logger.logSoftError(
        'Error initializing room event handler $channelId',
        StackTrace.current,
      );
    }
  }

  void sendUserMessage({required String encodedMessage}) {
    if (remoteUser.value != null) {
      _rtcRoom?.sendUserMessage(
        userId: remoteUser.value?.userId ?? '',
        messageStr: encodedMessage,
        config: MessageConfig.reliable_ordered,
      );
    }
  }

  void enableLocalAudio() {
    if (isMuted.value) {
      trackCallEvent(
        "callScreenPartner",
        additionalProperties: {"option": "UNMUTE"},
      );
    } else {
      trackCallEvent(
        "callScreenPartner",
        additionalProperties: {"option": "MUTE"},
      );
    }

    /// Controls the send status of the local audio stream: send/not send.
    isMuted.value = !isMuted.value;

    final publishAudio = !isMuted.value;

    if (publishAudio) {
      _pauseMuteTimer();
    } else {
      _startMuteTimer();
    }

    /// Controls the send status of the local audio stream: send/not send.
    _rtcRoom?.publishStreamAudio(publishAudio);
  }

  void openNotesBottomSheet() {
    if (!Get.find<UserController>().currentStage.isLessThan(TutorialStage.S5)) {
      HapticFeedback.vibrate();
      Get.bottomSheet(
        NotesBottomSheet(
          userName: name,
          accountId: demandAccountId.value ?? 0,
          userNumber: "",
          screenName: "CallScreen",
          theme: defaultTheme,
          existingNickname: callModel.value?.customName,
          nicknameChangeCallback: (newNickname) {
            callModel.update((val) {
              val?.customName = newNickname;
            });
          },
        ),
        isScrollControlled: true,
      );
    }
  }

  bool get isNewUser {
    return (initCallData.callStatLabel ?? '') != 'Old User';
  }

  num? get oneScore {
    try {
      return Get.find<ProbationController>().metricsData.value.aggregate?.score;
    } catch (_) {}
    return null;
  }

  String? get stage {
    try {
      return Get.find<UserController>().userDetails.value.onboardingStage?.name;
    } catch (_) {}
    return null;
  }

  void trackCallEvent(
    String eventName, {
    Map<String, dynamic>? additionalProperties,
  }) {
    try {
      sl<AnalyticsService>().trackEvent(
        eventName,
        eventProperties: {
          "demandName": name,
          "demandUid": callerUid,
          "currentBalance": _walletController.finalValue.toDouble(),
          "rtcToken": _rtcToken.value,
          "channelId": channelId,
          "category": CategoryCode.GOSSIP.name,
          "newUserCallLimitEnabled": supplyUserDetails.showCallCount,
          "partnerLanguage": callModel.value?.supplyLanguage ?? "",
          "demandLanguage": callModel.value?.demandLanguage ?? "",
          if (Get.find<UserController>().partnerStatus.value !=
              PartnerCurrentStatus.NULL)
            "partnerStatus":
                Get.find<UserController>().partnerStatus.value.name,
          if (oneScore != null) "oneScore": oneScore,
          if (stage != null) "stage": stage,
          "lifetimeCallDuration": lifeTimeCallDuration,
          ...?additionalProperties,
        },
      );
    } catch (e) {
      Logger.logSoftError(
        'Error tracking call event $channelId',
        StackTrace.current,
      );
    }
  }
}
