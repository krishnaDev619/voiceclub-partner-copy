import 'dart:async';

import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:another_stepper/another_stepper.dart';
import 'package:app_settings/app_settings.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:lottie/lottie.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:restart_app/restart_app.dart';
import 'package:shorebird_code_push/shorebird_code_push.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:voiceclub_partner/core/constants/asset_constants.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/core/constants/url_constants.dart';
import 'package:voiceclub_partner/core/injection_container.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/core/services/alert_service.dart';
import 'package:voiceclub_partner/core/services/analytics_service.dart';
import 'package:voiceclub_partner/core/services/notification_service.dart';
import 'package:voiceclub_partner/domain/usecases/calling/end_hung_call.dart'
    as end_hung_call;
import 'package:voiceclub_partner/domain/usecases/calling/get_hung_call.dart';
import 'package:voiceclub_partner/view/profile/warning_screen.dart';
import 'package:voiceclub_partner/view/widgets/custom_app_bar.dart';
import 'package:voiceclub_partner/view/widgets/custom_button.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';

class TroubleshootingScreen extends StatefulWidget {
  final VoidCallback? demoAction;
  final bool autoStart;
  const TroubleshootingScreen({
    super.key,
    this.demoAction,
    this.autoStart = false,
  });

  @override
  State<TroubleshootingScreen> createState() => _TroubleshootingScreenState();
}

class _TroubleshootingScreenState extends State<TroubleshootingScreen> {
  int _currentIndex = -1;
  bool started = false;
  final stepperData = <StateModel>[];

  @override
  void initState() {
    super.initState();
    stepperData.addAll([
      StateModel(
        title: LocaleKeys.livePermissions.tr,
        subtitle: LocaleKeys.liveAreAllTheNecessaryPermissions.tr,
        iconPath: AssetConstants.permissions,
        status: Status.idle,
        checkFunction: checkPermissions,
      ),
      StateModel(
        title: LocaleKeys.liveLowPowerMode.tr,
        subtitle: LocaleKeys.liveCheckingBatteryOptimizations.tr,
        iconPath: AssetConstants.batteryOptimizationIc, // Dummy icon for now
        status: Status.idle,
        checkFunction: checkLowPowerMode,
      ),
      StateModel(
        title: LocaleKeys.liveNetworkConnectivity.tr,
        subtitle: LocaleKeys.liveIsDeviceConnectedToNetwork.tr,
        iconPath: AssetConstants.networkConnectivityIc,
        status: Status.idle,
        checkFunction: checkNetwork,
      ),
      // StateModel(
      //   title: "Notifications",
      //   subtitle:
      //       "Testing if push notifications are enabled and received properly.",
      //   iconPath: AssetConstants.notificationPermissionIc, // Dummy icon for now
      //   status: Status.idle,
      //   checkFunction: checkNotifications,
      // ),
      StateModel(
        title: LocaleKeys.liveCallLag.tr,
        subtitle: LocaleKeys.liveIsThereACallLag.tr,
        iconPath: AssetConstants.callLagIc,
        status: Status.idle,
        checkFunction: checkCallLag,
      ),
      StateModel(
        title: LocaleKeys.liveAppUpdate.tr,
        subtitle: LocaleKeys.liveIsTheAppUpdatedTo.tr,
        iconPath: AssetConstants.appUpdateIc,
        status: Status.idle,
        checkFunction: checkAppUpdate,
      ),
    ]);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.autoStart) handleChecking();
    });
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  void initStepperDate() {
    stepperData.clear();
  }

  /// **Checks if Notifications are enabled and FCM works**
  // Future<Warning> checkNotifications() async {
  //   // Step 1: Send a Test Notification to the device's FCM token
  //   try {
  //     final deviceFCMToken = await ConfigFCMService.getFirebaseMessagingToken();
  //     await Get.find<UserController>().fetchData();
  //     final registeredFCMToken =
  //         Get.find<UserController>().userDetails.value.user?.fcmToken;
  //     if (deviceFCMToken != null &&
  //         registeredFCMToken != null &&
  //         deviceFCMToken == registeredFCMToken) {
  //       sl<CallController>().clearTestPayload();
  //       bool notificationSent = await _sendTestNotification();
  //       if (!notificationSent) {
  //         return Warning(
  //           success: false,
  //           warning: "Call Notification Test Failed",
  //           suggestion:
  //               "Please check your internet connection and ensure notifications are enabled.",
  //         );
  //       }
  //     } else {
  //       return Warning(
  //         success: false,
  //         warning: "Call Notification Token Mismatch",
  //         suggestion: "Please sign out and sign in again.",
  //       );
  //     }

  //     // Step 2: Listen for the test notification (Only for 10 seconds)
  //     final Completer<Warning> completer = Completer<Warning>();
  //     Timer? timeoutTimer;
  //     Worker? worker;

  //     // Step 2.1: Listen for notification payload
  //     if (!sl<CallController>().testPayloadReceived.value) {
  //       worker = ever(sl<CallController>().testPayloadReceived,
  //           (testReceived) async {
  //         if (testReceived) {
  //           if (timeoutTimer != null) timeoutTimer.cancel();
  //           if (worker != null) worker.dispose();
  //           await Future.delayed(const Duration(seconds: 3));
  //           sl<CallController>().clearTestPayload();
  //           completer.complete(Warning(success: true));
  //         }
  //       });

  //       // Step 2.2: Set a timeout of 10 seconds
  //       timeoutTimer = Timer(const Duration(seconds: 10), () {
  //         worker?.dispose();
  //         if (!completer.isCompleted) {
  //           completer.complete(
  //             Warning(
  //               success: false,
  //               warning: "Call Notification Test Failed",
  //               suggestion:
  //                   "Please check your internet connection and try again.",
  //             ),
  //           );
  //         }
  //       });
  //     } else {
  //       completer.complete(Warning(success: true));
  //     }

  //     return completer.future;
  //   } catch (e) {
  //     return Warning(
  //       success: false,
  //       warning: "Call Notification Test Failed",
  //       suggestion: "$e",
  //     );
  //   }
  // }

  /// **Send Test Notification**
  // static Future<bool> _sendTestNotification() async {
  //   try {
  //     final response = await sl<TestNotificationUsecase>().call(NoParams());
  //     if (response.error == null) {
  //       return true;
  //     } else {
  //       return false;
  //     }
  //   } catch (_) {
  //     return false;
  //   }
  // }

  /// ✅ **Checks if Low Power Mode or Battery Optimizations are enabled**
  Future<Warning> checkLowPowerMode() async {
    try {
      await Future.delayed(const Duration(seconds: 2));

      Battery battery = Battery();
      bool isLowPowerMode = await battery.isInBatterySaveMode;

      if (!isLowPowerMode) {
        return Warning(success: true);
      } else {
        return Warning(
          success: false,
          warning: LocaleKeys.liveLowPowerModeDetected.tr,
          suggestion: LocaleKeys.liveDisableLowPowerMode.tr,
          action: openBatterySaverSettings,
        );
      }
    } catch (e) {
      return Warning(success: true);
    }
  }

  void openBatterySaverSettings() async {
    try {
      const intent = AndroidIntent(
        action: "android.settings.BATTERY_SAVER_SETTINGS",
        flags: [Flag.FLAG_ACTIVITY_NEW_TASK],
      );

      await intent.launch();
    } catch (_) {}
  }

  Future<Warning> checkNetwork() async {
    final stopwatch = Stopwatch()..start();
    try {
      final response = await Dio().get(
        URLConstants.speedCheckFileUrl,
        options: Options(responseType: ResponseType.bytes),
      );
      if (response.statusCode == 200) {
        final elapsed = stopwatch.elapsedMilliseconds;
        final responseData = response.data as List;
        final speedInKbps =
            ((responseData.length / 1024) / (elapsed / 1000)) * 8;
        if (speedInKbps > 200) {
          return Warning(success: true);
        }
      }
    } catch (_) {}
    return Warning(
      success: false,
      warning: LocaleKeys.liveNetworkConnectivityIssue.tr,
      suggestion: LocaleKeys.liveCheckInternetConnection.tr,
      action: () {
        AppSettings.openAppSettingsPanel(
          AppSettingsPanelType.internetConnectivity,
        );
      },
    );
  }

  Future<Warning> checkCallLag() async {
    await Future.delayed(const Duration(seconds: 2));
    try {
      var response = await sl<GetHungCallUseCase>().call(NoParams());
      if (response.data != null && response.error == null) {
        final data = response.data;
        if ((data?.channelId?.isNotEmpty ?? false) &&
            data?.status != HungCallType.BUSY) {
          var result = await endCallLag(data?.channelId ?? "");
          if (result) {
            return Warning(success: true);
          }
        } else {
          return Warning(success: true);
        }
      }
    } catch (_) {}
    return Warning(
      success: false,
      warning: LocaleKeys.liveCallLagDetected.tr,
      suggestion: LocaleKeys.livePleaseTryAgain.tr,
    );
  }

  Future<bool> endCallLag(String channelId) async {
    try {
      var response = await sl<end_hung_call.EndHungCallUseCase>().call(
        end_hung_call.Params(channelId: channelId),
      );
      if (response.data != null && response.error == null) {
        return true;
      } else {
        return false;
      }
    } catch (_) {
      return false;
    }
  }

  Future<Warning> checkPermissions() async {
    await Future.delayed(const Duration(seconds: 2));
    try {
      var microPhoneStatus = await Permission.microphone.status;
      var notificationStatus = await Permission.notification.status;
      var firebaseStatus =
          (await FirebaseMessaging.instance.getNotificationSettings())
              .authorizationStatus ==
          AuthorizationStatus.authorized;

      // Handle microphone permission status
      if (microPhoneStatus.isDenied || microPhoneStatus.isPermanentlyDenied) {
        var result = await Permission.microphone.request();
        if (result.isDenied || result.isPermanentlyDenied) {
          return Warning(
            success: false,
            warning: LocaleKeys.liveMicrophonePermissionDenied.tr,
            suggestion: LocaleKeys.liveAllowMicrophonePermission.tr,
            action: () {
              AppSettings.openAppSettings();
            },
          );
        }
      }

      // Handle notification permission status
      if (notificationStatus.isDenied ||
          notificationStatus.isPermanentlyDenied) {
        var result = await Permission.notification.request();
        if (result.isDenied || result.isPermanentlyDenied) {
          return Warning(
            success: false,
            warning: LocaleKeys.liveNotificationPermissionDenied.tr,
            suggestion: LocaleKeys.liveAllowNotificationPermission.tr,
            action: () {
              AppSettings.openAppSettings(type: AppSettingsType.notification);
            },
          );
        }
      }

      if (!firebaseStatus) {
        var result = await NotificationService.requestNotificationPermissions();
        if (!result) {
          return Warning(
            success: false,
            warning: LocaleKeys.liveFcmNotificationPermissionDenied.tr,
            suggestion: LocaleKeys.liveAllowFcmNotificationPermission.tr,
          );
        }
      }
      // If all the permissions are granted
      return Warning(success: true);
    } catch (e) {
      return Warning(
        success: false,
        warning: e.toString(),
        suggestion: LocaleKeys.liveAllowPermissionAndTryAgain.tr,
      );
    }
  }

  void _updateApp() async {
    try {
      final Uri url = Uri.parse(URLConstants.playStoreUrl);

      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        InAppUpdate.performImmediateUpdate();
      }
    } catch (_) {}
  }

  Future<Warning> checkAppUpdate() async {
    await Future.delayed(const Duration(seconds: 1));
    try {
      final updateDetails = await InAppUpdate.checkForUpdate();
      final isPlayStoreUpdateAvailable =
          updateDetails.updateAvailability ==
          UpdateAvailability.updateAvailable;
      if (isPlayStoreUpdateAvailable) {
        return Warning(
          success: false,
          warning: LocaleKeys.liveAppIsNotUpdated.tr,
          suggestion: LocaleKeys.liveUpdateAppFromPlayStore.tr,
          action: _updateApp,
        );
      } else {
        final status = await ShorebirdUpdater().checkForUpdate();
        final isPatchUpdateAvailable = status == UpdateStatus.outdated;

        if (isPatchUpdateAvailable) {
          // Download the new patch if it's available.
          await ShorebirdUpdater().update();
          return Warning(
            success: false,
            warning: LocaleKeys.liveNewPatchAvailable.tr,
            suggestion: LocaleKeys.liveKillTheAppTwice.tr,
            action: () {
              Future.delayed(const Duration(seconds: 1), () {
                Restart.restartApp();
              });
            },
          );
        } else {
          return Warning(success: true);
        }
      }
    } catch (_) {
      return Warning(
        success: false,
        warning: LocaleKeys.liveAppIsNotUpdated.tr,
        suggestion: LocaleKeys.liveDownloadLatestFromPlayStore.tr,
        action: _updateApp,
      );
    }
  }

  Future<void> handleChecking() async {
    if (!started) {
      HapticFeedback.vibrate();
      started = true;
      bool allStepsSuccessful = true;

      for (int i = 0; i < stepperData.length; i++) {
        setState(() {
          _currentIndex = i;
          stepperData[i].status = Status.checking;
        });

        Warning result = Warning(success: false);

        result = await stepperData[i].checkFunction();

        if (result.success) {
          HapticFeedback.vibrate();
          setState(() {
            stepperData[i].status = Status.passed;
          });
        } else {
          setState(() {
            stepperData[i].status = Status.failed;
          });
          HapticFeedback.vibrate();
          allStepsSuccessful = false;
          final retry = await Get.to<bool?>(
            () => WarningScreen(
              title: stepperData[i].title,
              warning: result.warning ?? LocaleKeys.liveCheckFailed.tr,
              suggestion: result.suggestion ?? LocaleKeys.livePleaseTryAgain.tr,
              action: result.action,
              autostart: widget.autoStart,
            ),
          );
          if (retry == true) {
            allStepsSuccessful = true;
            i--;
          } else {
            break;
          }
        }
      }

      if (allStepsSuccessful) {
        sl<AnalyticsService>().trackEvent(
          "partnerTroubleshootingSuccess",
          eventProperties: {"autostart": widget.autoStart},
        );
        if (widget.demoAction != null) {
          widget.demoAction!();
        } else {
          Get.back<bool>(result: true);
          HapticFeedback.vibrate();
          if (!widget.autoStart) {
            AlertService.showSnackBar(
              snackBarType: SnackBarType.Success,
              title: LocaleKeys.liveTroubleshootingSuccessful.tr,
              subtitle: LocaleKeys.liveYouAreGoodToGo.tr,
              duration: const Duration(seconds: 1),
            );
          }
        }
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: LocaleKeys.liveTroubleshooting.tr),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: AnotherStepper(
                    stepperList: [
                      for (int i = 0; i < stepperData.length; i++)
                        StepperData(
                          title: StepperText(
                            stepperData[i].title,
                            textStyle: TextStyle(
                              color:
                                  stepperData[i].status == Status.passed
                                      ? Colors.green
                                      : stepperData[i].status == Status.failed
                                      ? Colors.red
                                      : Colors.black,
                              fontSize: FontSize.L,
                            ),
                          ),
                          subtitle: StepperText(
                            stepperData[i].subtitle,
                            textStyle: const TextStyle(
                              color: Colors.black54,
                              fontSize: FontSize.M,
                            ),
                          ),
                          iconWidget: Center(
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                if (stepperData[i].status == Status.checking)
                                  Lottie.asset(
                                    AssetConstants.loader,
                                    height: 150.0,
                                    width: 150.0,
                                  ),
                                Container(
                                  padding: const EdgeInsets.all(8.0),
                                  child: SvgPicture.asset(
                                    stepperData[i].status == Status.passed
                                        ? AssetConstants.doneIc
                                        : stepperData[i].iconPath,
                                    colorFilter:
                                        stepperData[i].status == Status.passed
                                            ? const ColorFilter.mode(
                                              Colors.green,
                                              BlendMode.srcIn,
                                            )
                                            : stepperData[i].status ==
                                                Status.failed
                                            ? const ColorFilter.mode(
                                              Colors.red,
                                              BlendMode.srcIn,
                                            )
                                            : null,
                                    height:
                                        stepperData[i].status != Status.passed
                                            ? 15.0
                                            : 30.0,
                                    width:
                                        stepperData[i].status != Status.passed
                                            ? 15.0
                                            : 30.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                    stepperDirection: Axis.vertical,
                    activeIndex: _currentIndex,
                    iconHeight: 60.0,
                    iconWidth: 60.0,
                    verticalGap: 26.0,
                    activeBarColor: Colors.green,
                    barThickness: 1,
                  ),
                ),
              ),
              CustomButton(
                text: LocaleKeys.liveStart.tr,
                enabled: !started,
                onTap: handleChecking,
              ),
              const SizedBox(height: 8.0),
            ],
          ),
        ),
      ),
    );
  }
}

class StateModel {
  String title;
  String subtitle;
  String iconPath;
  Status status;
  Future<Warning> Function() checkFunction;

  StateModel({
    required this.title,
    required this.subtitle,
    required this.iconPath,
    required this.status,
    required this.checkFunction,
  });
}

class Warning {
  bool success;
  String? warning;
  String? suggestion;
  VoidCallback action;

  Warning({
    required this.success,
    this.warning,
    this.suggestion,
    this.action = openAppSettings,
  });
}

enum Status { idle, checking, passed, failed }
