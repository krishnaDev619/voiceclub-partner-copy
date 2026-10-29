import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:get/get.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:play_install_referrer/play_install_referrer.dart';
import 'package:shorebird_code_push/shorebird_code_push.dart';
import 'package:singular_flutter_sdk/singular.dart';
import 'package:singular_flutter_sdk/singular_config.dart';
import 'package:singular_flutter_sdk/singular_global_property.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/constants/string_constants.dart';
import 'package:voiceclub_partner/core/injection_container.dart';
import 'package:voiceclub_partner/core/services/app_info_service.dart';
import 'package:voiceclub_partner/core/services/events_service.dart';
import 'package:voiceclub_partner/core/services/growthbook_service.dart';
import 'package:voiceclub_partner/core/services/logger.dart';
import 'package:voiceclub_partner/core/services/purchase_event_service.dart';
import 'package:voiceclub_partner/features/onboarding/core/services/facebook_event_service.dart';
import 'package:voiceclub_partner/modules/controller/user_controller.dart';
import 'package:voiceclub_partner/features/onboarding/core/services/analytics_service.dart'
    as onboarding_analytics;

class AnalyticsService {
  final Mixpanel mixpanel;
  final FirebaseAnalytics firebaseAnalytics;

  AnalyticsService({required this.mixpanel, required this.firebaseAnalytics});

  void trackEvent(String eventName, {Map<String, dynamic>? eventProperties}) {
    try {
      mixpanel.track(eventName, properties: eventProperties);
    } catch (error) {
      Logger.logMessage(
        'Mixpanel event failed: $eventName: $error',
        name: 'Analytics Service',
      );
    }
    try {
      Singular.eventWithArgs(eventName, eventProperties ?? {});
    } catch (error) {
      Logger.logMessage(
        'Singular event failed: $eventName: $error',
        name: 'Analytics Service',
      );
    }
    // final stringMap =
    //     eventProperties?.map((key, value) => MapEntry(key, value.toString()));
    // firebaseAnalytics.logEvent(name: eventName, parameters: stringMap);
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

  void setUserProperties(AccountType accountType) async {
    String? utmSource0 = await EventsService.retrieveUtmSource();
    String? utmMedium0 = await EventsService.retrieveUtmMedium();

    if ((utmSource0?.isEmpty ?? true) || (utmMedium0?.isEmpty ?? true)) {
      try {
        await PlayInstallReferrer.installReferrer.then((referrerDetails) {
          final utmParams = parseInstallReferrer(
            referrerDetails.installReferrer ?? '',
          );
          if (utmSource0?.isEmpty ?? true) {
            utmSource0 = utmParams['utm_source'] ?? '';
          }
          if (utmMedium0?.isEmpty ?? true) {
            utmMedium0 = utmParams['utm_medium'] ?? '';
          }
        });
      } catch (_) {}
    }
    if (accountType == AccountType.DEMAND) {
      return;
    } else {
      final userController = Get.find<UserController>();
      final userDetails = userController.userDetails.value;

      // Mixpanel
      mixpanel.identify((userDetails.user?.id).toString());
      mixpanel.getPeople().set('user_id', userDetails.user?.id.toString());
      mixpanel.getPeople().set('userName', userDetails.user?.name);
      mixpanel.getPeople().set('userNumber', userDetails.user?.phoneNumber);
      mixpanel.getPeople().set('isVerified', userDetails.kycCompleted ?? false);
      mixpanel.getPeople().set('kamName', userDetails.kamName ?? "");
      mixpanel.getPeople().set('kamPhoneNumber', userDetails.kamPhone ?? "");
      mixpanel.getPeople().set('age', userDetails.age ?? "");
      mixpanel.getPeople().set('education', userDetails.education ?? "");
      mixpanel.getPeople().set('appType', 'partnerApp');
      mixpanel.getPeople().set(
        'userPrimaryLanguage',
        userDetails.primaryLanguage ?? "",
      );
      mixpanel.getPeople().set(
        'userSecondaryLanguage',
        userDetails.secondaryLanguage ?? "",
      );
      mixpanel.getPeople().set(
        'maritalStatus',
        userDetails.maritalStatus ?? "",
      );
      mixpanel.getPeople().set('userType', accountType.name);
      mixpanel.getPeople().setOnce('utm_medium', utmMedium0);
      mixpanel.getPeople().setOnce('utm_source', utmSource0);
      mixpanel.getPeople().setOnce(
        'onboardingDate',
        DateTime.now().toUtc().toIso8601String(),
      );
      mixpanel.getPeople().set(
        'currentStage',
        userDetails.onboardingStage?.name,
      );

      setJourneyType();
      updateNotificationsPermission();
      updateProbationStatus(userController.partnerStatus.value);
      final appInfo = await AppInfoService().getAppInfo();
      final patchVersion = await ShorebirdUpdater().readCurrentPatch();

      mixpanel.registerSuperProperties({
        'user_id': (userDetails.user?.id).toString(),
        'account_id': (userDetails.accountId).toString(),
        'userName': userDetails.user?.name,
        'categoryName': userDetails.category?.name,
        'userNumber': userDetails.user?.phoneNumber,
        'userType': accountType.name,
        'isOnLeave': userController.isOnLeave,
        'appVersion': appInfo.version,
        'appType': 'partnerApp',
        if (patchVersion != null) 'patchVersionNumber': patchVersion.number,
      });

      // Firebase Analytics
      // firebaseAnalytics.setUserId(id: userDetails.user?.id.toString());
      // firebaseAnalytics.setUserProperty(
      //   name: 'user_id',
      //   value: userDetails.user?.id.toString(),
      // );
      // firebaseAnalytics.setUserProperty(
      //   name: 'account_id',
      //   value: userDetails.accountId.toString(),
      // );
      // firebaseAnalytics.setUserProperty(
      //   name: 'userName',
      //   value: userDetails.user?.name,
      // );
      // firebaseAnalytics.setUserProperty(
      //   name: 'userNumber',
      //   value: userDetails.user?.phoneNumber,
      // );
      // firebaseAnalytics.setUserProperty(
      //   name: 'userType',
      //   value: accountType.name,
      // );

      // Crashlytics
      FirebaseCrashlytics.instance.setUserIdentifier(
        (userDetails.user?.id).toString(),
      );

      // Singular
      final userId = userDetails.user?.id.toString() ?? '';
      if (userId.isNotEmpty) {
        Singular.setCustomUserId(userId);
        Singular.setGlobalProperty('user_id', userId, true);
      }
      Singular.setGlobalProperty(
        'account_id',
        userDetails.accountId?.toString() ?? '',
        true,
      );
      Singular.setGlobalProperty('app_type', 'partnerApp', true);

      // GrowthBook
      final featuresEnabled = sl<GrowthBookService>().getEnabledFeatures();
      mixpanel.getPeople().set('featuresEnabled', featuresEnabled);
    }
  }

  void setJourneyType() {
    final isRegistered = Get.isRegistered<UserController>();

    if (isRegistered) {
      final userController = Get.find<UserController>();
      if (userController.partnerStatus.value == PartnerCurrentStatus.NEW_LIVE ||
          userController.partnerStatus.value ==
              PartnerCurrentStatus.PROBATION) {
        mixpanel.getPeople().setOnce(
          'partnerJourneyType',
          'Forceful-Old-Journey',
        );
      }
    }
  }

  void updateDemoCompletedDate() {
    mixpanel.getPeople().set(
      'lastDemoCompletedDate',
      DateTime.now().toUtc().toIso8601String(),
    );
  }

  void updateOneScore(int oneScore) {
    mixpanel.getPeople().set('oneScore', oneScore);
  }

  void updateNotificationsPermission() async {
    try {
      final isEnabled = await Permission.notification.isGranted;
      mixpanel.getPeople().set('notificationsEnabled', isEnabled);
    } catch (_) {}
  }

  void updateProbationStatus(PartnerCurrentStatus currentStatus) async {
    try {
      if (currentStatus != PartnerCurrentStatus.NULL) {
        mixpanel.getPeople().set('currentStatus', currentStatus.name);
      }
    } catch (_) {}
  }

  void updateTier(String tier) {
    mixpanel.getPeople().set('currentTier', tier);
  }

  void updateProperty(String propertyName, double updateBy) {
    mixpanel.getPeople().increment(propertyName, updateBy);
  }

  void updateSupplyBalance(double balance) {
    final userDetails = Get.find<UserController>().userDetails.value;
    mixpanel.identify((userDetails.user?.id).toString());
    mixpanel.getPeople().set('balance_available', balance);
  }

  void trackEnabledGrowthBookFeatures() {
    try {
      final enabledFeatures =
          sl<GrowthBookService>().getEnabledFeaturesWithValues();
      trackEvent(
        "enabledGrowthBookFeaturesPartner",
        eventProperties: enabledFeatures,
      );
    } catch (_) {}
  }

  Future<void> initSingularSDK({
    required Future<void> Function(
      Uri link, {
      required bool isDeferred,
      String? passthrough,
    })
    onDeepLink,
  }) async {
    try {
      final config = SingularConfig(
        StringConstants.singularAppKey,
        StringConstants.singularAppSecret,
      );
      config.globalProperties = [
        SingularGlobalProperty(
          'is_dev',
          StringConstants.isDev.toString(),
          true,
        ),
        SingularGlobalProperty('app_type', 'partnerApp', true),
      ];
      config.singularLinksHandler = (params) {
        final rawDeepLink = params.deeplink?.trim();
        final isDeferred = params.isDeferred ?? false;

        final properties = <String, dynamic>{
          'source': 'singular',
          'isDeferred': isDeferred,
          if (rawDeepLink?.isNotEmpty ?? false) 'deeplink': rawDeepLink,
          if (params.passthrough?.isNotEmpty ?? false)
            'passthrough': params.passthrough,
        };
        trackEvent('singularDeeplinkResolved', eventProperties: properties);

        if (rawDeepLink == null || rawDeepLink.isEmpty) {
          trackEvent(
            'singularDeeplinkIgnored',
            eventProperties: {...properties, 'reason': 'missing_deeplink'},
          );
          return;
        }

        final link = Uri.tryParse(rawDeepLink);
        if (link == null || !link.hasScheme) {
          trackEvent(
            'singularDeeplinkIgnored',
            eventProperties: {...properties, 'reason': 'invalid_deeplink'},
          );
          return;
        }

        unawaited(
          onDeepLink(
            link,
            isDeferred: isDeferred,
            passthrough: params.passthrough,
          ),
        );
      };

      Singular.start(config);
    } catch (error) {
      Logger.logMessage(
        'Singular SDK initialization failed: $error',
        name: 'Analytics Service',
        isCritical: true,
      );
    }
  }

  Future<void> reset() async {
    try {
      await mixpanel.reset();
      await sl<onboarding_analytics.AnalyticsService>().mixpanel.reset();
      Singular.unsetCustomUserId();
      Logger.logMessage(
        "Mixpanel successfully reset",
        name: "Analytics Service",
      );
    } catch (e) {
      Logger.logMessage(
        "Error in analytics reset: ${e.toString()}",
        name: "Analytics Service",
      );
    }
  }

  Future<void> firePurchaseEvents() async {
    final hasFired = await PurchaseEventService.hasPurchaseEventFired();
    if (!hasFired) {
      await FacebookEventService.trackPurchase(value: 10);
      await mixpanel.track("partnerLiveTransition");
      await sl<AnalyticsService>().firebaseAnalytics.logPurchase(
        currency: "INR",
        value: 10,
      );
      await PurchaseEventService.markPurchaseEventFired();
    }
  }

  /// Tracks a StartTrial event
  Future<void> fireStartTrialEvents() async {
    final hasFired = await PurchaseEventService.hasStartTrialEventFired();
    if (!hasFired) {
      await FacebookEventService.trackStartTrial();
      await sl<AnalyticsService>().firebaseAnalytics.logEvent(
        name: "StartTrial",
        parameters: {"state": "golive"},
      );
      await PurchaseEventService.markStartTrialEventFired();
    }
  }
}
