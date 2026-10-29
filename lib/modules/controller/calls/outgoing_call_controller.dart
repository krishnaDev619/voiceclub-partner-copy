import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:byteplus_rtc/byteplus_rtc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
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
import 'package:voiceclub_partner/core/services/reverse_call_service.dart';
import 'package:voiceclub_partner/core/services/rtc_app_kill_manager.dart';
import 'package:voiceclub_partner/data/models/calling/call_model.dart';
import 'package:voiceclub_partner/data/models/calling/call_state_model.dart';
import 'package:voiceclub_partner/data/models/chat/chat_theme.dart';
import 'package:voiceclub_partner/domain/usecases/calling/end_call.dart';
import 'package:voiceclub_partner/domain/usecases/calling/fetch_call_state_stream.dart';
import 'package:voiceclub_partner/domain/usecases/calling/get_current_call.dart'
    as current;
import 'package:voiceclub_partner/domain/usecases/calling/ping_call.dart'
    as ping;
import 'package:voiceclub_partner/modules/controller/call_controller.dart';
import 'package:voiceclub_partner/modules/controller/chat_messages_controller.dart';
import 'package:voiceclub_partner/modules/controller/probation_controller.dart';
import 'package:voiceclub_partner/modules/controller/user_controller.dart';
import 'package:voiceclub_partner/modules/controller/wallet_controller.dart';
import 'package:voiceclub_partner/view/notes/notes_bottom_sheet.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';

class OutgoingCallController extends GetxController {
  final String? avatar;
  final String screenName;
  final String token;
  final String name;
  final int demandUid;
  final String phoneNo;
  final String channelId;
  final int demandAccountId;
  final int? chatGroupId;

  OutgoingCallController({
    required this.avatar,
    required this.screenName,
    required this.token,
    required this.name,
    required this.phoneNo,
    required this.channelId,
    required this.demandAccountId,
    required this.demandUid,
    this.chatGroupId,
  });

  RTCEngine? _rtcEngine;
  RTCRoom? _rtcRoom;
  final _roomHandler = IRTCRoomEventHandler();
  final _rtcEngineEventHandler = IRTCEngineEventHandler();
  StreamSubscription<int>? _streamSubscription;
  final _userController = Get.find<UserController>();
  static const _foregroundService = MethodChannel('foregroundChannel');
  final Stopwatch callDurationTime = Stopwatch();

  int notificationId = 0;
  Timer? _countdownTimer;
  Timer? _ringTimer;
  Timer? _pingCallTimer;
  StreamSubscription<CallStateModel?>? _callStateStreamSubscription;
  bool _isCaptureVolumeBoosted = false;
  bool _isCaptureVolumeReduced = false;
  bool hasDemandLeft = true;
  int lastProximityEvent = 0;

  // Dynamic variables
  final callStateModel = Rxn<CallStateModel>();
  final callModel = Rxn<CallModel>();
  final countDownSeconds = 0.obs;
  final callOnlySeconds = 0.obs;
  final remoteUserMute = false.obs;
  final isMuted = false.obs;
  final isSpeaker = false.obs;
  final isAccepted = false.obs;
  final left = false.obs;
  final remoteUser = Rxn<UserInfo>();

  @override
  void onInit() {
    WakelockPlus.enable();
    sl<CallController>().startOutgoingCall();
    FlutterRingtonePlayer().play(
      fromAsset: AssetConstants.callConnecting,
      looping: true,
    );
    _checkSetting();
    getCallData(isInit: true);
    _fetchCallStateStream();
    _initRoomEventHandler();
    super.onInit();
  }

  @override
  Future<void> dispose() async {
    WakelockPlus.disable();
    await _cleanup();
    super.dispose();
  }

  void getCallData({bool isInit = false}) async {
    final response = await sl<current.GetCurrentCallUsecase>().call(
      current.Params(channelId: channelId),
    );
    if (response.data != null && response.error == null) {
      callModel.value = response.data;
      if (!isInit) {
        if (response.data?.callOnlySeconds != null) {
          _updateCallOnlySeconds(response.data?.callOnlySeconds ?? 0);
        }
      }
    } else {
      leave();
    }
  }

  void _fetchCallStateStream() async {
    final callStateStream = await sl<FetchCallStateStreamUsecase>().call(
      FetchCallStateStreamParams(channelId: channelId),
    );
    _callStateStreamSubscription = callStateStream?.listen(
      (data) {
        if (!left.value) {
          callStateModel.value = data;

          if (callStateModel.value?.callState == CallState.STARTED) {
            if (callStateModel.value?.ringState == RingState.RINGING) {
              FlutterRingtonePlayer().stop();
              NeoBeep.playSysSound(AndroidSoundIDs.TONE_SUP_RINGTONE);
            }
            _startRingTimer();
          } else if (callStateModel.value?.callState == CallState.ACCEPTED) {
            _callAccepted();
            _updateCallOnlySeconds(callStateModel.value?.callOnlySeconds ?? 0);
          } else if (callStateModel.value?.callState == CallState.ENDED) {
            if (!isAccepted.value) {
              if (hasDemandLeft) {
                hasDemandLeft = false;

                trackCallEvent(
                  "reverseCallFailed",
                  additionalProperties: {"reason": "Declined By User"},
                );
              }
            }
            leave();
          } else if (data?.callState == CallState.REJECTED) {
            if (!isAccepted.value) {
              if (hasDemandLeft) {
                hasDemandLeft = false;

                trackCallEvent(
                  "reverseCallFailed",
                  additionalProperties: {"reason": "Rejected By User"},
                );
              }
            }
            leave();
          }
        }
      },
      onError: (Object error, StackTrace stackTrace) {
        Logger.logMessage(
          "Error in call state stream : $error",
          name: "OutgoingCallController",
          isCritical: true,
        );
      },
    );
  }

  void _callAccepted() async {
    try {
      if (!isAccepted.value) {
        final joinRTCResult = await _initVideoAndJoinRoom();
        if (joinRTCResult == 0) {
          FlutterRingtonePlayer().stop();
          NeoBeep.beep(true);
          isAccepted.value = true;
          if (!callDurationTime.isRunning) {
            callDurationTime.start();
          }
          _startCallPinging();
          _ringTimer?.cancel();
          trackCallEvent("reverseCallConnected");
          Vibration.vibrate(duration: 100);
          NotificationService.showInternalNotification(
            notificationId: notificationId,
            title: name,
            body: 'Call Connected',
          );

          [Permission.notification].request().then(
            (value) async => {
              if (PermissionStatus.granted == value[Permission.notification])
                {
                  // Ensure Granted Notification Permission or else foreground service will failed
                  await _startForegroundService(),
                },
            },
          );
        } else {
          _showErrorSnackbar(errorCode: "INIT_RTC_FAILURE: $joinRTCResult");
        }
      }
    } catch (_) {}
  }

  void _showErrorSnackbar({required String errorCode}) {
    Get.context?.loaderOverlay.hide();
    if (!isAccepted.value) {
      leave();
    }
    Logger.logMessage(
      "Failed to accept reverse call. Error code: $errorCode",
      name: "OutgoingCallController",
      isCritical: true,
    );
    trackCallEvent(
      "reverseCallConnectedError",
      additionalProperties: {"errorCode": errorCode},
    );
  }

  Future _checkSetting() async {
    var random =
        Random(); // keep this somewhere in a static variable. Just make sure to initialize only once.
    notificationId = random.nextInt(pow(2, 31).toInt());
    await [Permission.microphone, Permission.bluetoothConnect].request();
    _streamSubscription = ProximitySensor.events.listen((int event) {
      _handleAndroidProximitySensorEvent(event);
    });
    NotificationService.showInternalNotification(
      notificationId: notificationId,
      title: name,
      body: 'Calling..',
    );
  }

  Future<void> _startForegroundService() async {
    try {
      await _foregroundService.invokeMethod('startService');
      final authToken = await sl<AuthService>().getAuthorizationToken();
      if (authToken != null) {
        await RTCAppKillManager.initCallConfigs(
          inCall: true,
          channelId: channelId,
          endedBy: _userController.userDetails.value.accountId ?? 0,
          jwtToken: authToken,
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
      final authToken = await sl<AuthService>().getAuthorizationToken();
      if (authToken != null) {
        await RTCAppKillManager.initCallConfigs(
          inCall: false,
          channelId: channelId,
          endedBy: _userController.userDetails.value.accountId ?? 0,
          jwtToken: authToken,
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

  void _startCallPinging() {
    try {
      _pingCallTimer = Timer.periodic(const Duration(seconds: 5), (
        timer,
      ) async {
        if (!left.value) {
          await sl<ping.PingCallUseCase>().call(
            ping.Params(channelId: channelId),
          );
        }
      });
    } catch (_) {
    } finally {}
  }

  void _startRingTimer() {
    if (_ringTimer != null) return;
    const ringDurationInSeconds = 45;
    _ringTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      try {
        if (timer.isActive) {
          if (timer.tick < ringDurationInSeconds) {
            if (isAccepted.value) {
              timer.cancel();
            }
          } else {
            if (!isAccepted.value) {
              leave(isMe: true, reason: 'Missed call');
            }
            timer.cancel();
          }
        }
      } catch (_) {}
    });
  }

  void _handleAndroidProximitySensorEvent(int event) async {
    if (Platform.isAndroid && !isSpeaker.value && isAccepted.value) {
      try {
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
      } catch (_) {}
    }
  }

  void _startCountdownTimer() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      try {
        if (countDownSeconds.value > 0) {
          countDownSeconds.value--;
        }
      } catch (_) {}
    });
  }

  void _updateCallOnlySeconds(int newSeconds) {
    if (callOnlySeconds.value != newSeconds) {
      final difference = newSeconds - callOnlySeconds.value;
      if (!(_countdownTimer?.isActive ?? false)) {
        countDownSeconds.value = newSeconds;
        _startCountdownTimer();
      } else {
        countDownSeconds.value += difference;
      }

      callOnlySeconds.value = newSeconds;
    }
  }

  void sendUserMessage({required String message}) {
    if (remoteUser.value != null) {
      _rtcRoom?.sendUserMessage(
        userId: remoteUser.value?.userId ?? '',
        messageStr: message,
        config: MessageConfig.reliable_ordered,
      );
    }
  }

  String formatTime(int seconds) {
    return '${(Duration(seconds: seconds))}'.split('.')[0].padLeft(8, '0');
  }

  Future<void> _cleanup() async {
    if (!isAccepted.value) {
      ReverseCallService.incrementFailedCall(demandAccountId);
    } else {
      ReverseCallService.resetFailedCalls(demandAccountId);
    }
    _rtcRoom?.leaveRoom();
    _rtcRoom?.destroy();
    _rtcEngine?.destroy();
    if (_ringTimer?.isActive ?? false) _ringTimer?.cancel();
    if (_countdownTimer?.isActive ?? false) _countdownTimer?.cancel();
    if (_pingCallTimer?.isActive ?? false) _pingCallTimer?.cancel();
    AwesomeNotifications().cancel(notificationId);
    _stopForegroundService();
    _callStateStreamSubscription?.cancel();
    NeoBeep.beep(true);
    if (Platform.isAndroid) {
      //Turn on the screen when the call ends
      await ScreenOff.turnScreenOn();
    }
    _streamSubscription?.cancel();
  }

  Future<void> leave({
    bool isMe = false,
    String reason = 'Declined by Partner',
  }) async {
    FlutterRingtonePlayer().stop();
    if (!left.value) {
      Get.context?.loaderOverlay.show();
      left.value = true;
      try {
        callDurationTime.stop();
        NeoBeep.beep(true);
        _streamSubscription?.cancel();
        if (isMe) {
          if (!isAccepted.value) {
            trackCallEvent("reverseCallDecline");
          }
          await sl<EndCallUsecase>().call(
            Params(
              channelId: channelId,
              callRejected: true,
              endedByID: _userController.userDetails.value.accountId ?? 0,
              declineReason: reason,
            ),
          );

          if (Platform.isAndroid) {
            await RTCAppKillManager.markCallAlreadyEnded();
          }
        }
        Vibration.vibrate(duration: 100);
      } finally {
        Get.context?.loaderOverlay.hide();
        if (Get.currentRoute != '/OutgoingCallScreen') {
          Get.until((route) => route.settings.name == '/OutgoingCallScreen');
        }
        Get.back(closeOverlays: true);
        sl<CallController>().endOutgoingCall();
        _afterCallEnded();
        await RTCAppKillManager.markCallAlreadyEnded();
      }
    }
  }

  /// Show any bottom sheets when call ends
  void _afterCallEnded() async {
    if (isAccepted.value) {
      Get.find<UserController>().fetchData(fetchOnlineDuration: true);
      Future.delayed(const Duration(seconds: 3), () {
        if (chatGroupId != null) {
          if (Get.isRegistered<ChatMessagesController>(
            tag: chatGroupId.toString(),
          )) {
            Get.find<ChatMessagesController>(
              tag: chatGroupId.toString(),
            ).getReverseStats(demandAccountId);
          }
        }
        EventsService.logEventThroughAPI(
          eventType: EventType.CALL,
          propertyId: channelId,
          additionalProperties: {
            "isReverseCall": true,
            "screenName": screenName,
          },
        );
      });
    }
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
  Future<int> _initVideoAndJoinRoom() async {
    try {
      /// Create engine objects.
      _rtcEngine = await RTCEngine.createRTCEngine(
        RTCVideoContext(appId: StringConstants.byteplusAppId),
      );

      if (_rtcEngine == null) {
        return -4;
      } else {
        _rtcEngine?.setRTCEngineEventHandler(_rtcEngineEventHandler);
      }

      _rtcEngine?.setAudioScenario(AudioScenarioType.auto);

      /// Enables internal audio capture. The default is off.
      _rtcEngine?.startAudioCapture();

      /// Create a room.
      _rtcRoom = await _rtcEngine?.createRTCRoom(channelId);

      if (_rtcRoom == null) {
        return -5;
      }

      /// Set room event callback handler
      _rtcRoom?.setRTCRoomEventHandler(_roomHandler);

      /// Join the room.
      UserInfo userInfo = UserInfo(
        userId: _userController.userDetails.value.user?.id.toString() ?? "0",
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
            token: token,
            userVisibility: true,
            userInfo: userInfo,
            roomConfig: roomConfig,
          ) ??
          -6;

      // joinRoomResult is 0 if the operation is successful, otherwise it is an error code.
      if (joinRoomResult != 0) {
        return joinRoomResult;
      }

      _rtcEngine?.setDefaultAudioRoute(
        isSpeaker.value ? AudioRoute.speakerphone : AudioRoute.earpiece,
      );

      // _rtcEngine?.enableAudioPropertiesReport(AudioPropertiesConfig());

      return joinRoomResult;
    } catch (e) {
      Logger.logMessage(
        "Error in initVideoAndJoinRoom ${e.toString()}",
        name: "IncomingCallController",
        isCritical: true,
      );
      return -7;
    }
  }

  void openNotesBottomSheet() {
    HapticFeedback.vibrate();
    Get.bottomSheet(
      NotesBottomSheet(
        userName: name,
        accountId: demandAccountId,
        userNumber: "",
        screenName: "ReverseCallScreen",
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

  void _initRoomEventHandler() {
    /// Callback for remote visible user joining the room.
    _roomHandler.onUserJoined = (UserInfo userInfo) {
      remoteUser.value = userInfo;
      debugPrint('onUserJoined: ${userInfo.userId}');
    };

    /// Callback for remote visible user leaving the room.
    _roomHandler.onUserLeave = (String uid, int reason) {
      // Supply has left.value the room
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
  }

  void _onMessage(int _, String user, String message) {
    if (message == "lowBalance") {
      Vibration.vibrate(
        pattern: [500, 1000, 500, 1000, 500, 1000, 500, 1000],
        // repeat: -3
      );
      AlertService.showSnackBar(
        snackBarType: SnackBarType.Warning,
        title: LocaleKeys.liveLowBalance.tr,
        subtitle: LocaleKeys.liveTalkTime3.trParams({'name': name}),
        duration: const Duration(seconds: 3),
      );
    }
  }

  void switchAudioRoute() {
    isSpeaker.value = !isSpeaker.value;

    /// Set the audio playback device as a speaker or earpiece, and use speakers by default.
    AudioRoute audioRoute =
        isSpeaker.value ? AudioRoute.speakerphone : AudioRoute.earpiece;
    _rtcEngine?.setDefaultAudioRoute(audioRoute);
  }

  void enableLocalAudio() {
    isMuted.value = !isMuted.value;
    final publishAudio = !isMuted.value;

    // Controls the send status of the local audio stream: send/not send.
    _rtcRoom?.publishStreamAudio(publishAudio);
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
    sl<AnalyticsService>().trackEvent(
      eventName,
      eventProperties: {
        "demandName": name,
        "demandUid": demandUid,
        "demandAccountId": demandAccountId,
        "demandNumber": phoneNo,
        "currentBalance": Get.find<WalletController>().finalValue.toDouble(),
        "screenName": screenName,
        "rtcToken": token,
        "channelId": channelId,
        "ringState": callStateModel.value?.ringState?.name,
        if (_ringTimer != null) "ringDurationInSeconds": _ringTimer?.tick,
        "newUserCallLimitEnabled":
            _userController.userDetails.value.showCallCount,
        if (_userController.partnerStatus.value != PartnerCurrentStatus.NULL)
          "partnerStatus": _userController.partnerStatus.value.name,
        if (oneScore != null) "oneScore": oneScore,
        if (stage != null) "stage": stage,
        ...?additionalProperties,
      },
    );
  }
}
