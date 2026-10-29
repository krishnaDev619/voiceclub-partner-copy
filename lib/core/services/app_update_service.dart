import 'dart:io';

import 'package:get/get.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:shorebird_code_push/shorebird_code_push.dart';
import 'package:voiceclub_partner/core/injection_container.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/core/services/auth_service.dart';
import 'package:voiceclub_partner/domain/usecases/config/get_app_config_status.dart';
import 'package:voiceclub_partner/view/auth/dynamic_screen.dart';

class AppUpdateService {
  static void fetchConfigStatus({required bool isSplash}) async {
    try {
      sl<GetAppConfigStatusUsecase>().call(NoParams()).then((response) {
        if (response.data == null) return;
        final configData = response.data;
        if (configData?.isAppUnderMaintenance ?? false) {
          Get.offAll(
            () => DynamicScreen(
              title: configData?.title,
              subtitle: configData?.message,
            ),
          );
        } else {
          _checkForUpdate(
            isForceUpdate: configData?.forceUpdate ?? false,
            isSplash: isSplash,
          );
        }
      });
    } catch (_) {}
  }

  static Future<void> _checkForUpdate({
    required bool isForceUpdate,
    required bool isSplash,
  }) async {
    bool updateAvailable = false;
    try {
      InAppUpdate.checkForUpdate()
          .then((updateInfo) async {
            if (updateInfo.updateAvailability ==
                UpdateAvailability.updateAvailable) {
              updateAvailable = true;
              if (isForceUpdate) {
                if (updateInfo.immediateUpdateAllowed) {
                  // Perform immediate update
                  InAppUpdate.performImmediateUpdate()
                      .then((appUpdateResult) {
                        if (appUpdateResult ==
                            AppUpdateResult.userDeniedUpdate) {
                          _checkForUpdate(
                            isForceUpdate: isForceUpdate,
                            isSplash: isSplash,
                          );
                        } else if (appUpdateResult == AppUpdateResult.success) {
                          //App Update successful
                          exit(0);
                        }
                      })
                      .catchError((_) {});
                } else if (updateInfo.flexibleUpdateAllowed) {
                  //Perform flexible update
                  InAppUpdate.startFlexibleUpdate()
                      .then((appUpdateResult) {
                        if (appUpdateResult == AppUpdateResult.success) {
                          //App Update successful
                          InAppUpdate.completeFlexibleUpdate();
                        } else if (appUpdateResult ==
                            AppUpdateResult.userDeniedUpdate) {
                          _checkForUpdate(
                            isForceUpdate: isForceUpdate,
                            isSplash: isSplash,
                          );
                        }
                      })
                      .catchError((_) {});
                }
              }
            }
          })
          .catchError((_) {});
    } catch (_) {
    } finally {
      await _checkForPatchUpdate();
      if (!updateAvailable && isSplash) {
        sl<AuthService>().checkUser();
      }
    }
  }

  static Future<void> _checkForPatchUpdate() async {
    try {
      final status = await ShorebirdUpdater().checkForUpdate();

      if (status == UpdateStatus.outdated) {
        // Download the new patch if it's available.
        await ShorebirdUpdater().update();
      }
    } catch (_) {}
  }
}
