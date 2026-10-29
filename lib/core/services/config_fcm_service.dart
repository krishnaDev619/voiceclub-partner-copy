import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:voiceclub_partner/core/injection_container.dart';
import 'package:voiceclub_partner/core/services/app_info_service.dart';
import 'package:voiceclub_partner/domain/usecases/fcm_config/update_supply_fcm.dart';

class ConfigFCMService {
  static final _supplyFCM = sl<UpdateSupplyFCMUsecase>();

  static Future<void> updateFCM() async {
    final token = await getFirebaseMessagingToken();
    if (token?.isNotEmpty == true) {
      final config = await AppInfoService().getAppInfo();
      await _supplyFCM.call(
        Params(
          token: token ?? '',
          version: config.version,
          buildNumber: config.buildNumber,
        ),
      );
    }
  }

  static Future<void> removeFCM() async {
    await _supplyFCM.call(const Params(token: ""));
  }

  // Request FCM token to Firebase
  static Future<String?> getFirebaseMessagingToken() async {
    String? firebaseAppToken;
    try {
      firebaseAppToken = await FirebaseMessaging.instance.getToken();
    } catch (_) {
      // debugPrint('$exception');
    }
    return firebaseAppToken;
  }
}
