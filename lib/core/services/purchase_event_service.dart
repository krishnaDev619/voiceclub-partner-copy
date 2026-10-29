import 'package:voiceclub_partner/core/services/app_preferences.dart';
import 'package:voiceclub_partner/core/injection_container.dart';

class PurchaseEventService {
  static AppPreferences get _preferences => sl<AppPreferences>();

  static Future<bool> hasPurchaseEventFired() async {
    return await _preferences.getBool(AppPreferences.purchaseEventFiredKey) ??
        false;
  }

  static Future<void> markPurchaseEventFired() async {
    await _preferences.setBool(AppPreferences.purchaseEventFiredKey, true);
  }

  static Future<bool> hasCheckoutEventFired() async {
    return await _preferences.getBool(AppPreferences.checkoutEventFiredKey) ??
        false;
  }

  static Future<void> markCheckoutEventFired() async {
    await _preferences.setBool(AppPreferences.checkoutEventFiredKey, true);
  }

  static Future<void> markStartTrialEventFired() async {
    await _preferences.setBool(AppPreferences.startTrialEventFiredKey, true);
  }

  static Future<bool> hasStartTrialEventFired() async {
    return await _preferences.getBool(AppPreferences.startTrialEventFiredKey) ??
        false;
  }
}
