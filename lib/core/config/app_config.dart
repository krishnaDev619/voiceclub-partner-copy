import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Environment types for the application.
enum Environment {
  dev('.env.dev'),
  prod('.env.prod');

  final String fileName;
  const Environment(this.fileName);

  /// Get Environment from string name
  static Environment fromName(String? name) {
    if (name == 'dev') return Environment.dev;
    return Environment.prod;
  }
}

/// Application configuration that loads values from .env files.
///
/// This class must be initialized before accessing any configuration values.
/// The initialization loads the appropriate .env file based on the flavor.
///
/// Usage:
/// ```dart
/// // In main_dev.dart
/// void main() async {
///   await AppConfig.initialize(Environment.dev);
///   mainCommon();
/// }
///
/// // In main_prod.dart
/// void main() async {
///   await AppConfig.initialize(Environment.prod);
///   mainCommon();
/// }
/// ```
class AppConfig {
  AppConfig._();

  static const String _environmentKey = 'app_environment';
  static Environment? _environment;
  static bool _isInitialized = false;

  /// Check if AppConfig has been initialized
  static bool get isInitialized => _isInitialized;

  /// Initialize the app configuration by loading the appropriate .env file.
  /// This must be called before accessing any configuration values.
  static Future<void> initialize(Environment environment) async {
    _environment ??= environment;
    await dotenv.load(fileName: environment.fileName);
    _isInitialized = true;

    // Persist environment for background isolate usage
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_environmentKey, environment.name);
  }

  /// Initialize for background isolate usage.
  /// Reads the environment from SharedPreferences and loads the appropriate .env file.
  /// Must be called from background handlers before accessing any config values.
  static Future<void> initializeForBackground() async {
    if (_isInitialized) return;
    try {
      // Read environment from SharedPreferences (persisted during main app init)
      final prefs = await SharedPreferences.getInstance();
      await prefs.reload();
      final envName = prefs.getString(_environmentKey);
      _environment = Environment.fromName(envName);

      if (_environment != null) {
        await dotenv.load(fileName: _environment!.fileName);
        _isInitialized = true;
      }
    } catch (e) {
      // If loading fails, ensure we don't crash - values will return empty strings
      _isInitialized = false;
    }
  }

  /// Get the current environment
  static Environment get environment {
    return _environment ?? Environment.prod;
  }

  /// Whether the app is running in development mode
  static bool get isDev {
    return _environment == Environment.dev;
  }

  /// Whether the app is running in production mode
  static bool get isProd {
    return _environment == Environment.prod;
  }

  /// Base URL for API calls
  static String get baseUrl {
    return dotenv.env['BASE_URL'] ?? '';
  }

  /// FCM API Key
  static String get fcmApiKey {
    return dotenv.env['FCM_API_KEY'] ?? '';
  }

  /// Mixpanel Token
  static String get mixpanelToken {
    return dotenv.env['MIXPANEL_TOKEN'] ?? '';
  }

  /// Singular SDK key
  static String get singularAppKey {
    return dotenv.env['SINGULAR_APP_KEY'] ?? '';
  }

  /// Singular SDK secret
  static String get singularAppSecret {
    return dotenv.env['SINGULAR_APP_SECRET'] ?? '';
  }

  /// Unsplash Access Key
  static String get byteplusAppId {
    return dotenv.env['BYTEPLUS_APP_ID'] ?? '';
  }

  /// Unsplash Access Key
  static String get awesomeNotificationsLicenseKey {
    return dotenv.env['AWESOME_NOTIFICATIONS_LICENSE_KEY'] ?? '';
  }

  /// App Secret Key
  static String get appSecretKey {
    return dotenv.env['APP_SECRET_KEY'] ?? '';
  }

  /// GrowthBook Host URL
  static String get growthBookHostURL {
    return dotenv.env['GROWTHBOOK_HOST_URL'] ?? 'https://cdn.growthbook.io/';
  }

  /// GrowthBook API Key
  static String get growthBookAPIKey {
    return dotenv.env['GROWTHBOOK_API_KEY'] ?? '';
  }

  /// Hyperverge App ID
  static String get hypervergeAppId {
    return dotenv.env['HYPERVERGE_APP_ID'] ?? '';
  }

  /// Hyperverge App Key
  static String get hypervergeAppKey {
    return dotenv.env['HYPERVERGE_APP_KEY'] ?? '';
  }

  /// Hyperverge Workflow ID
  static String get hypervergeWorkflowId {
    return dotenv.env['HYPERVERGE_WORKFLOW_ID'] ?? '';
  }

  /// Hyperverge E-Sign Workflow ID
  static String get hypervergeESignWorkflowId {
    return dotenv.env['HYPERVERGE_ESIGN_WORKFLOW_ID'] ?? '';
  }
}
