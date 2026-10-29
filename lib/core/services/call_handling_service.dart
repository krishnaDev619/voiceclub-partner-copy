import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/injection_container.dart';
import 'package:voiceclub_partner/core/services/alert_service.dart';
import 'package:voiceclub_partner/core/services/analytics_service.dart';
import 'package:voiceclub_partner/core/services/logger.dart';
import 'package:voiceclub_partner/core/services/notification_service.dart';
import 'package:voiceclub_partner/core/services/showcase_service.dart';
import 'package:voiceclub_partner/data/models/calling/call_model.dart';
import 'package:voiceclub_partner/data/models/calling/call_state_model.dart';
import 'package:voiceclub_partner/domain/usecases/calling/fetch_call_state_stream.dart';
import 'package:voiceclub_partner/domain/usecases/calling/get_current_call.dart'
    as call;
import 'package:voiceclub_partner/modules/bindings/incoming_call_binding.dart';
import 'package:voiceclub_partner/modules/controller/call_controller.dart';
import 'package:voiceclub_partner/modules/controller/probation_controller.dart';
import 'package:voiceclub_partner/modules/controller/user_controller.dart';
import 'package:voiceclub_partner/view/calling/incoming_call_screen.dart';
import 'package:voiceclub_partner/view/profile/troubleshooting_screen.dart';
import 'package:voiceclub_partner/view/social/controllers/explore_controller.dart';

class CallHandlingService {
  Worker? callListener;
  final callController = sl<CallController>();
  void executeCallBuilder() {
    Logger.logMessage('🔨 CallHandlingService: Setting up call builder...');
    // Check if there is call payload received from the terminated state
    if (callController.incomingCallPayload.isNotEmpty) {
      final channelId = callController.incomingCallPayload.value;
      Logger.logMessage(
        '📥 CallHandlingService: Processing call payload from terminated state: $channelId',
      );
      _initIncomingCall(channelId: channelId, setRing: false);
    }

    // Add a listener to the call payload to receive future calls while the app is running
    callListener = ever(callController.incomingCallPayload, (payload) {
      if (payload.isNotEmpty) {
        try {
          if (Get.isBottomSheetOpen ?? false) {
            Get.back();
          }
          ShowcaseService.dismissShowCase();
        } catch (e, stackTrace) {
          Logger.logSoftError(
            'Error while dismissing showcase for incoming call',
            stackTrace,
          );
        }
        final channelId = callController.incomingCallPayload.value;
        Logger.logMessage(
          '📞 CallHandlingService: Processing new incoming call: $channelId',
        );
        _initIncomingCall(channelId: channelId, setRing: true);
      }
    });
  }

  Future<void> _initIncomingCall({
    required String channelId,
    required bool setRing,
  }) async {
    Logger.logMessage('CallHandlingService: Initializing incoming call...');
    if (await Permission.microphone.isGranted) {
      Logger.logMessage(
        'CallHandlingService: Microphone permission already granted',
      );
      _buildIncomingCallScreen(channelId: channelId, setRing: setRing);
    } else {
      Logger.logMessage(
        'CallHandlingService: Requesting microphone permission...',
      );
      Permission.microphone.request().then((status) {
        if (status == PermissionStatus.granted) {
          Logger.logMessage(
            'CallHandlingService: Microphone permission granted',
          );
          _buildIncomingCallScreen(channelId: channelId, setRing: setRing);
        } else {
          Logger.logMessage(
            'CallHandlingService: Microphone permission denied: ${status.name}',
          );
          AlertService.showSnackBar(
            snackBarType: SnackBarType.Error,
            title: 'Permission Denied',
            subtitle:
                'Please${status == PermissionStatus.permanentlyDenied ? ' open settings and' : ''} give microphone access to accept calls!',
          );
        }
      });
    }
  }

  Future<void> _buildIncomingCallScreen({
    required String channelId,
    required bool setRing,
  }) async {
    try {
      Logger.logMessage(
        'CallHandlingService: Building incoming call screen...',
      );
      // Request Bluetooth permission if needed
      Permission.bluetoothConnect.request();

      // Fetch the current call data
      final getCurrentCallResponse = await sl<call.GetCurrentCallUsecase>()
          .call(call.Params(channelId: channelId));

      final data = getCurrentCallResponse.data;

      if (data != null) {
        Logger.logMessage(
          'CallHandlingService: Successfully fetched call data',
        );
        _handleCallStateStream(data, channelId, setRing);
      } else {
        Logger.logMessage('CallHandlingService: Failed to fetch call data');
        _showErrorSnackbar(errorCode: "GCC_NULL", channelId: channelId);
      }
    } catch (e, stackTrace) {
      Logger.logSoftError(
        'CallHandlingService: Error building call screen: $e',
        stackTrace,
      );
      _showErrorSnackbar(errorCode: e.toString(), channelId: channelId);
    }
  }

  void _handleCallStateStream(CallModel data, String channelId, bool setRing) {
    Logger.logMessage('CallHandlingService: Setting up call state stream...');
    sl<FetchCallStateStreamUsecase>()
        .call(FetchCallStateStreamParams(channelId: channelId))
        .then((callStateStream) {
          if (callStateStream == null) {
            Logger.logMessage('CallHandlingService: Call state stream is null');
            _showErrorSnackbar(errorCode: "CSS_NULL", channelId: channelId);
            return;
          }

          StreamSubscription<CallStateModel?>? streamSubscription;
          bool timedOut = false;

          // Set a timeout for 20 seconds
          Future.delayed(const Duration(seconds: 20)).then((_) {
            if (streamSubscription != null && !timedOut) {
              Logger.logMessage(
                'CallHandlingService: Call state stream timeout',
              );
              _showErrorSnackbar(
                errorCode: "CSS_TIMEOUT",
                channelId: channelId,
              );
              timedOut = true;
            }
          });

          streamSubscription = callStateStream.listen(
            (callStateModel) {
              if (streamSubscription != null &&
                  callStateModel?.callState == CallState.STARTED) {
                if (!timedOut) {
                  Logger.logMessage(
                    'CallHandlingService: Call started, navigating to call screen',
                  );
                  _navigateToCallScreen(
                    data,
                    channelId,
                    setRing,
                    streamSubscription,
                  );
                  timedOut = true;
                }
              } else {
                Logger.logMessage(
                  'CallHandlingService: Invalid call state received',
                );
                _handleInvalidCallState(data, channelId);
                timedOut = true;
              }
            },
            onError: (error, stackTrace) {
              Logger.logSoftError(
                'CallHandlingService: Error in call state stream: $error',
                stackTrace,
              );
              _showErrorSnackbar(
                errorCode: "CSS_ERROR: $error",
                channelId: channelId,
              );
            },
            cancelOnError: true,
          );
        });
  }

  void _navigateToCallScreen(
    CallModel data,
    String channelId,
    bool setRing,
    StreamSubscription<CallStateModel?> streamSubscription,
  ) {
    Get.find<ExploreController>().pauseAllPlayers();
    Get.to(
      () => IncomingCallScreen(setRing: setRing, channelId: channelId),
      binding: IncomingCallBinding(
        callerUid: data.callerUid ?? 0,
        channelId: channelId,
        initCallData: data,
        avatar: data.avatar,
        name: (data.name?.isNotEmpty ?? false) ? (data.name ?? 'V') : 'V',
        callStateStreamSubscription: streamSubscription,
        lifeTimeCallDuration: data.lifeTimeCallDuration ?? 0,
      ),
    );
  }

  void _handleInvalidCallState(CallModel data, String channelId) {
    if (sl<CallController>().incomingCallPayload.value == channelId) {
      sl<CallController>().setHandleInvalidCallState(true);
    }
    NotificationService.showInternalNotification(
      notificationId: Random().nextInt(pow(2, 31).toInt()),
      title:
          (data.name?.isNotEmpty ?? false)
              ? (data.name ?? 'VoiceClub')
              : 'VoiceClub',
      body: "Tried calling you",
    );
  }

  void _showErrorSnackbar({
    required String errorCode,
    required String channelId,
  }) {
    Logger.logSoftError(
      'CallHandlingService: Showing error snackbar: $errorCode',
      StackTrace.current,
    );
    sl<AnalyticsService>().trackEvent(
      "callReceivedError",
      eventProperties: {
        "errorCode": errorCode,
        "channelId": channelId,
        if (oneScore != null) "oneScore": oneScore,
        if (stage != null) "stage": stage,
      },
    );
    if (!Get.isSnackbarOpen) {
      AlertService.showSnackBar(
        snackBarType: SnackBarType.Error,
        title: "Failed to receive call",
        subtitle: "Tap here to troubleshoot your device. ($errorCode)",
        onTap: (_) {
          Get.closeAllSnackbars();
          Get.to(() => const TroubleshootingScreen());
        },
        mainButton: TextButton(
          onPressed: () {
            Get.closeAllSnackbars();
            Get.to(() => const TroubleshootingScreen());
          },
          child: const Padding(
            padding: EdgeInsets.only(bottom: 8.0),
            child: Icon(Icons.warning_rounded, color: Colors.white),
          ),
        ),
      );
    }
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

  void dispose() {
    if (callListener != null) callListener?.dispose();
  }
}
