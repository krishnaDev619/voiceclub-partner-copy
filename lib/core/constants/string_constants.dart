import 'package:voiceclub_partner/core/config/app_config.dart';

/// String constants for the application.
///
/// Environment-specific values are loaded from [AppConfig] which is
/// initialized at app startup based on the build flavor.
///
/// To switch environments, run with the appropriate flavor and entry point:
/// ```bash
/// # Development
/// flutter run --flavor dev -t lib/main_dev.dart
///
/// # Production
/// flutter run --flavor prod -t lib/main_prod.dart
/// ```

class StringConstants {
  StringConstants._();

  // ==============================================================
  // Environment Configuration (from EnvConfig)
  // ==============================================================

  static bool get isDev => AppConfig.isDev;

  // BaseURL
  static String get baseProdURL => AppConfig.baseUrl;

  // FCM
  static String get fcmApiKey => AppConfig.fcmApiKey;

  // Mixpanel
  static String get mixpanelToken => AppConfig.mixpanelToken;

  // Singular
  static String get singularAppKey => AppConfig.singularAppKey;
  static String get singularAppSecret => AppConfig.singularAppSecret;

  // BytePlus RTC
  static String get byteplusAppId => AppConfig.byteplusAppId;

  // Awesome Notifications License Key
  static String get awesomeNotificationsLicenseKey =>
      AppConfig.awesomeNotificationsLicenseKey;

  // App Secret Key
  static String get appSecretKey => AppConfig.appSecretKey;

  // GrowthBook Host URL
  static String get growthBookHostURL => AppConfig.growthBookHostURL;

  // GrowthBook API Key
  static String get growthBookAPIKey => AppConfig.growthBookAPIKey;

  // HyperVerge App ID
  static String get hypervergeAppId => AppConfig.hypervergeAppId;

  // HyperVerge App Key
  static String get hypervergeAppKey => AppConfig.hypervergeAppKey;

  // HyperVerge Workflow ID
  static String get hypervergeWorkflowId => AppConfig.hypervergeWorkflowId;

  // HyperVerge E-Sign Workflow ID
  static String get hypervergeESignWorkflowId =>
      AppConfig.hypervergeESignWorkflowId;

  // ==============================================================
  // Static Constants (Non-Environment Specific)
  // ==============================================================

  // Hive name of the chat groups
  static const String chatGroupsBoxName = 'chat_groups';

  // Hive name of the message count
  static const String messageCountBoxName = 'message_count';

  // Hive name of the fetched message count
  static const String fetchedMessageCountBoxName = 'fetched_message_count';

  // Hive name of the scroll position
  static const String scrollPostionBoxName = 'scroll_position';

  // Hive name of the last seen message
  static const String lastSeenMessageBoxName = 'last_seen_message';
}
