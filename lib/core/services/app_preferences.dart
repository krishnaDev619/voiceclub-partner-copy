import 'package:hive_ce/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:voiceclub_partner/core/services/logger.dart';

/// Single source of truth for app session and onboarding local data.
///
/// All auth tokens, onboarding fields, locale, video flags, and related
/// preferences are stored in [SharedPreferences] only.
class AppPreferences {
  AppPreferences();

  static const authTokenKey = 'auth_token';
  static const phoneKey = 'phone';
  static const earningPotentialKey = 'earningPotential';
  static const appLocaleKey = 'appLocale';
  static const deeplinkLanguageKey = 'deeplinkAppLanguage';
  static const accountTypeKey = 'accountType';

  static const meetingOneVideoKey = 'meetingOneVideoKey';
  static const testimonialVideoKey = 'testimonialVideoKey';
  static const agreementVideoKey = 'agreementVideoKey';

  static const purchaseEventFiredKey = 'purchaseEventFired';
  static const checkoutEventFiredKey = 'checkoutEventFired';
  static const startTrialEventFiredKey = 'startTrialEventFired';

  static const utmSourceKey = 'utmSource';
  static const utmMediumKey = 'utmMedium';

  static const _legacyAuthHiveStore = 'vc_auth_store';
  static const _legacyOnboardingHiveStore = 'vc_onboarding_store';
  static const _legacyLanguageHiveStore = 'app_language_store';
  static const _legacyVideoHiveStore = 'video_store';
  static const _legacyPurchaseHiveStore = 'purchase_event_store';
  static const _legacyEventsHiveStore = 'events_store';

  SharedPreferences? _prefs;
  bool _migrationDone = false;

  Future<SharedPreferences> _instance() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  Future<void> ensureReady() async {
    await _instance();
    if (!_migrationDone) {
      await migrateLegacyStorageIfNeeded();
    }
  }

  Future<String?> getString(String key) async {
    await ensureReady();
    return _prefs!.getString(key);
  }

  Future<void> setString(String key, String value) async {
    await ensureReady();
    await _prefs!.setString(key, value);
  }

  Future<void> remove(String key) async {
    await ensureReady();
    await _prefs!.remove(key);
  }

  Future<bool> containsKey(String key) async {
    await ensureReady();
    return _prefs!.containsKey(key);
  }

  Future<bool?> getBool(String key) async {
    await ensureReady();
    return _prefs!.getBool(key);
  }

  Future<void> setBool(String key, bool value) async {
    await ensureReady();
    await _prefs!.setBool(key, value);
  }

  Future<void> clearOnboardingSessionData() async {
    await ensureReady();
    await _prefs!.remove(phoneKey);
    await _prefs!.remove(earningPotentialKey);
  }

  /// One-time migration from legacy Hive boxes and duplicate prefs keys.
  Future<void> migrateLegacyStorageIfNeeded() async {
    if (_migrationDone) return;
    await _instance();

    await _migrateStringIfMissing(
      authTokenKey,
      sources: [
        () => _readHiveString(_legacyAuthHiveStore, authTokenKey),
        () => _readHiveString(_legacyOnboardingHiveStore, authTokenKey),
      ],
    );

    await _migrateStringIfMissing(
      phoneKey,
      sources: [() => _readHiveString(_legacyOnboardingHiveStore, phoneKey)],
    );

    await _migrateStringIfMissing(
      earningPotentialKey,
      sources: [
        () => _readHiveString(_legacyOnboardingHiveStore, earningPotentialKey),
      ],
    );

    await _migrateStringIfMissing(
      appLocaleKey,
      sources: [() => _readHiveString(_legacyLanguageHiveStore, appLocaleKey)],
    );

    await _migrateBoolIfMissing(
      meetingOneVideoKey,
      sources: [() => _readHiveBool(_legacyVideoHiveStore, meetingOneVideoKey)],
    );
    await _migrateBoolIfMissing(
      testimonialVideoKey,
      sources: [
        () => _readHiveBool(_legacyVideoHiveStore, testimonialVideoKey),
      ],
    );
    await _migrateBoolIfMissing(
      agreementVideoKey,
      sources: [() => _readHiveBool(_legacyVideoHiveStore, agreementVideoKey)],
    );

    await _migrateBoolIfMissing(
      purchaseEventFiredKey,
      sources: [
        () => _readHiveBool(_legacyPurchaseHiveStore, purchaseEventFiredKey),
      ],
    );
    await _migrateBoolIfMissing(
      checkoutEventFiredKey,
      sources: [
        () => _readHiveBool(_legacyPurchaseHiveStore, checkoutEventFiredKey),
      ],
    );

    await _migrateStringIfMissing(
      utmSourceKey,
      sources: [() => _readHiveString(_legacyEventsHiveStore, utmSourceKey)],
    );
    await _migrateStringIfMissing(
      utmMediumKey,
      sources: [() => _readHiveString(_legacyEventsHiveStore, utmMediumKey)],
    );

    _migrationDone = true;
  }

  Future<void> _migrateStringIfMissing(
    String key, {
    required List<Future<String?> Function()> sources,
  }) async {
    final existing = _prefs!.getString(key);
    if (existing?.isNotEmpty ?? false) return;

    for (final read in sources) {
      final value = await read();
      if (value?.isNotEmpty ?? false) {
        await _prefs!.setString(key, value!);
        return;
      }
    }
  }

  Future<void> _migrateBoolIfMissing(
    String key, {
    required List<Future<bool?> Function()> sources,
  }) async {
    if (_prefs!.containsKey(key)) return;

    for (final read in sources) {
      final value = await read();
      if (value != null) {
        await _prefs!.setBool(key, value);
        return;
      }
    }
  }

  Future<String?> _readHiveString(String boxName, String key) async {
    try {
      final box = await Hive.openBox(boxName);
      final value = box.get(key);
      return value?.toString();
    } catch (e, stack) {
      Logger.logMessage(
        'AppPreferences: failed reading Hive string $boxName/$key: $e\n$stack',
        isCritical: true,
      );
      return null;
    }
  }

  Future<bool?> _readHiveBool(String boxName, String key) async {
    try {
      final box = await Hive.openBox(boxName);
      final value = box.get(key);
      if (value is bool) return value;
      if (value == true) return true;
      return null;
    } catch (e, stack) {
      Logger.logMessage(
        'AppPreferences: failed reading Hive bool $boxName/$key: $e\n$stack',
        isCritical: true,
      );
      return null;
    }
  }

  /// Reads auth token without GetIt. Used by background isolates.
  static Future<String?> readAuthToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(authTokenKey);
      if (token?.isNotEmpty ?? false) return token;
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }
}
