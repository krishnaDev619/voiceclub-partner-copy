import 'package:facebook_app_events/facebook_app_events.dart';
import 'package:voiceclub_partner/core/services/logger.dart';

class FacebookEventService {
  static final FacebookAppEvents _facebookAppEvents = FacebookAppEvents();
  static const String _defaultCurrency = 'INR';

  /// Tracks a ViewContent event
  static Future<bool> trackViewContent({required double value}) async {
    try {
      _facebookAppEvents.logViewContent(
        currency: _defaultCurrency,
        price: value,
      );
      return true;
    } catch (e) {
      Logger.logError('Error tracking ViewContent: $e');
      return false;
    }
  }

  /// Tracks a CompleteRegistration event
  static Future<bool> trackCompleteRegistration() async {
    try {
      _facebookAppEvents.logCompletedRegistration();
      return true;
    } catch (e) {
      Logger.logError('Error tracking CompleteRegistration: $e');
      return false;
    }
  }

  /// Tracks a Purchase event
  static Future<bool> trackPurchase({required double value}) async {
    try {
      _facebookAppEvents.logPurchase(currency: _defaultCurrency, amount: value);
      return true;
    } catch (e) {
      Logger.logError('Error tracking Purchase: $e');
      return false;
    }
  }

  /// Tracks an InitiateCheckout event
  static Future<bool> trackInitiateCheckout({required double value}) async {
    try {
      _facebookAppEvents.logInitiatedCheckout(
        currency: _defaultCurrency,
        totalPrice: value,
      );
      return true;
    } catch (e) {
      Logger.logError('Error tracking InitiateCheckout: $e');
      return false;
    }
  }

  /// Tracks an startTrial event
  static Future<bool> trackStartTrial() async {
    try {
      _facebookAppEvents.logStartTrial(orderId: "1234567890", price: 10);
      return true;
    } catch (e) {
      Logger.logError('Error tracking StartTrial: $e');
      return false;
    }
  }

  /// Tracks a Lead event
  static Future<bool> trackLead({required double value}) async {
    try {
      _facebookAppEvents.logEvent(
        name: "Lead",
        parameters: {"currency": _defaultCurrency, "value": value},
      );
      return true;
    } catch (e) {
      Logger.logError('Error tracking Lead: $e');
      return false;
    }
  }

  /// Tracks a Custom event
  static Future<bool> trackEvent(
    String name, {
    Map<String, dynamic>? eventProperties,
  }) async {
    try {
      _facebookAppEvents.logEvent(name: name, parameters: eventProperties);
      return true;
    } catch (e) {
      Logger.logError('Error tracking Lead: $e');
      return false;
    }
  }
}
