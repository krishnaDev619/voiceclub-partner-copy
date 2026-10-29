import 'package:dio/dio.dart';
import 'package:voiceclub_partner/core/services/app_preferences.dart';

/// Keeps auth token in [AppPreferences] and syncs Authorization on [Dio] clients.
class TokenService {
  final AppPreferences _preferences;

  TokenService(this._preferences);

  final Set<Dio> _dioClients = {};

  void registerDio(Dio dio) {
    _dioClients.add(dio);
  }

  Future<void> restoreSession() async {
    await _preferences.ensureReady();
    final token = await getToken();
    _applyTokenToClients(token);
  }

  Future<void> setToken(String token) async {
    await _preferences.setString(AppPreferences.authTokenKey, token);
    _applyTokenToClients(token);
  }

  Future<String?> getToken() async {
    return _preferences.getString(AppPreferences.authTokenKey);
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token?.isNotEmpty ?? false;
  }

  Future<void> clearToken() async {
    await _preferences.remove(AppPreferences.authTokenKey);
    _applyTokenToClients(null);
  }

  /// Reads the stored token without requiring [TokenService] from GetIt.
  static Future<String?> readStoredToken() => AppPreferences.readAuthToken();

  void _applyTokenToClients(String? token) {
    for (final dio in _dioClients) {
      if (token?.isNotEmpty ?? false) {
        dio.options.headers['Authorization'] = 'Bearer $token';
      } else {
        dio.options.headers.remove('Authorization');
      }
    }
  }
}
