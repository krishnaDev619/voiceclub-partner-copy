import 'package:advertising_id/advertising_id.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';
import 'package:voiceclub_partner/features/onboarding/core/constants/enums.dart';
import 'package:voiceclub_partner/features/onboarding/core/injection_container.dart';
import 'package:voiceclub_partner/core/services/events_service.dart';
import 'package:voiceclub_partner/features/onboarding/core/services/facebook_event_service.dart';
import 'package:voiceclub_partner/features/onboarding/core/services/growthbook_service.dart';
import 'package:voiceclub_partner/core/services/logger.dart';
import 'package:voiceclub_partner/core/services/purchase_event_service.dart';

class AnalyticsService {
  final Mixpanel mixpanel;
  final FirebaseAnalytics firebaseAnalytics;

  AnalyticsService({required this.mixpanel, required this.firebaseAnalytics});

  void trackEvent(String eventName, {Map<String, dynamic>? eventProperties}) {
    mixpanel.track(
      eventName,
      properties: {
        ...eventProperties ?? {},
        'appType': UserType.PartnerOnboarding.name,
        'platform': "MOBILE",
      },
    );
    final stringMap = eventProperties?.map(
      (key, value) => MapEntry(key, value.toString()),
    );
    firebaseAnalytics.logEvent(name: eventName, parameters: stringMap);
  }

  Map<String, String> parseInstallReferrer(String referrer) {
    List<String> paramPairs = referrer.split("&");
    Map<String, String> params = {};

    for (String pair in paramPairs) {
      List<String> keyValue = pair.split("=");
      if (keyValue.length == 2) {
        String key = keyValue[0];
        String value = keyValue[1];
        params[key] = value;
      }
    }
    return params;
  }

  void setUserProperties({
    required String phoneNumber,
    required String name,
    required String appLanguage,
    String? city,
    String? state,
  }) async {
    final uid = phoneNumber.trim();
    if (uid.isEmpty) return;
    String? utmSource0 = await EventsService.retrieveUtmSource();
    String? utmMedium0 = await EventsService.retrieveUtmMedium();

    // Mixpanel
    mixpanel.identify(uid);
    mixpanel.getPeople().setOnce('userNumber', uid);
    mixpanel.getPeople().setOnce('userType', UserType.PartnerOnboarding.name);
    mixpanel.getPeople().setOnce('appType', UserType.PartnerOnboarding.name);
    if (utmSource0 != null) {
      mixpanel.getPeople().setOnce('utmSource', utmSource0);
    }
    if (utmMedium0 != null) {
      mixpanel.getPeople().setOnce('utmMedium', utmMedium0);
    }
    Map<String, dynamic> superProperties = {};
    superProperties = {
      'userNumber': uid,
      'userType': UserType.PartnerOnboarding.name,
    };
    if (name.isNotEmpty) {
      superProperties['userName'] = name;
      mixpanel.getPeople().setOnce('userName', name);
    }

    mixpanel.getPeople().setOnce(
      'onboardingDate',
      DateTime.now().toUtc().toIso8601String(),
    );
    mixpanel.registerSuperProperties(superProperties);

    if (appLanguage.isNotEmpty) {
      mixpanel.getPeople().set('appLanguage', appLanguage);
    }
    if (city?.isNotEmpty ?? false) mixpanel.getPeople().set('city', city);
    if (state?.isNotEmpty ?? false) mixpanel.getPeople().set('state', state);

    // Firebase Analytics
    firebaseAnalytics.setUserId(id: phoneNumber.toString());
    if (name.isNotEmpty) {
      firebaseAnalytics.setUserProperty(name: 'userName', value: name);
    }

    firebaseAnalytics.setUserProperty(name: 'userNumber', value: phoneNumber);
    firebaseAnalytics.setUserProperty(
      name: 'appType',
      value: UserType.PartnerOnboarding.name,
    );
    firebaseAnalytics.setUserProperty(
      name: 'userType',
      value: UserType.PartnerOnboarding.name,
    );
  }

  void updateProperty(String propertyName, double updateBy) {
    mixpanel.getPeople().increment(propertyName, updateBy);
  }

  void updateBalance(double balance) {
    // final userDetails = Get
    //     .find<UserController>()
    //     .userDetails;
    // mixpanel.identify(userDetails.uid.toString());
    mixpanel.getPeople().set('balance_available', balance);
  }

  void updateRetargetCount() {
    mixpanel.getPeople().increment('fbRetargetCount', 1);
  }

  void updateRechargeCount(int rechargeCount) {
    mixpanel.getPeople().set('rechargeCount', rechargeCount);
  }

  void trackEnabledGrowthBookFeatures() {
    try {
      final enabledFeatures =
          sl<GrowthBookService>().getEnabledFeaturesWithValues();
      trackEvent("enabledGrowthBookFeatures", eventProperties: enabledFeatures);
    } catch (_) {}
  }

  Future<void> fireCheckoutEvents() async {
    final hasFired = await PurchaseEventService.hasCheckoutEventFired();
    if (!hasFired) {
      await FacebookEventService.trackInitiateCheckout(value: 10);
      await sl<AnalyticsService>().firebaseAnalytics.logBeginCheckout();
      await PurchaseEventService.markCheckoutEventFired();
    }
  }

  /// Get the GAID (Google Advertising ID) id from the device
  Future<String> getGAID() async {
    try {
      final advertisingId = await AdvertisingId.id(true);
      return advertisingId ?? "";
    } catch (_) {
      Logger.logMessage("Error getting GAID");
    }
    return "";
  }

  void reset() {
    mixpanel.reset();
    firebaseAnalytics.resetAnalyticsData();
  }
}
