import 'package:shared_preferences/shared_preferences.dart';

/// Service to store whether the user can lock the app or not using SharedPreferences
class AppLockService {
  static const String _lockKey = 'app_lock';

  /// Store the lock status
  /// [isLocked] true if the app is locked, false otherwise
  /// Returns true if the value was stored successfully, false otherwise
  static Future<bool> setLockStatus(bool isLocked) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setBool(_lockKey, isLocked);
    } catch (_) {
      return false;
    }
  }

  /// Get the lock status
  /// Returns true if the app is locked, false otherwise
  static Future<bool> getLockStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_lockKey) ?? false;
    } catch (_) {
      return false;
    }
  }
}
