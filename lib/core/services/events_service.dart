import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/injection_container.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/core/services/analytics_service.dart';
import 'package:voiceclub_partner/core/services/app_preferences.dart';
import 'package:voiceclub_partner/core/services/logger.dart';
import 'package:voiceclub_partner/core/services/session_router.dart';
import 'package:voiceclub_partner/domain/usecases/events/get_event_data.dart';
import 'package:voiceclub_partner/domain/usecases/events/get_pending_events_list.dart';
import 'package:voiceclub_partner/domain/usecases/events/mark_event.dart'
    as mark;

class EventsService {
  static bool _isPendingEventsProcessing = false;

  static AppPreferences get _preferences => sl<AppPreferences>();

  static Future<void> logEventThroughAPI({
    required EventType eventType,
    required String propertyId,
    Map<String, dynamic> additionalProperties = const {},
  }) async {
    try {
      final eventDataResponse = await sl<GetEventDataUseCase>().call(
        Params(event: eventType.eventName, propertyId: propertyId),
      );
      if (eventDataResponse.data != null && eventDataResponse.error == null) {
        final eventData = eventDataResponse.data;
        if (eventData?.eventId != null) {
          final eventId = eventData?.eventId ?? 0;
          final response = await sl<mark.MarkEventUseCase>().call(
            mark.Params(eventId: eventId),
          );
          if (response.error == null) {
            sl<AnalyticsService>().trackEvent(
              eventType.eventName,
              eventProperties: {
                ...(eventData?.data ?? {}),
                ...additionalProperties,
                'firedFrom': 'frontend',
              },
            );
          }
        }
      }
    } catch (_) {}
  }

  static void getAndMarkPendingEvents() async {
    if (_isPendingEventsProcessing) {
      return; // If already processing, return immediately
    }

    _isPendingEventsProcessing = true; // Mark as processing
    try {
      final pendingEventsResponse = await sl<GetPendingEventsListUseCase>()
          .call(NoParams());
      if (pendingEventsResponse.data != null &&
          pendingEventsResponse.error == null) {
        final pendingEvents = pendingEventsResponse.data?.events ?? [];
        final totalItems = pendingEventsResponse.data?.totalItems ?? 0;
        if (totalItems > 0) {
          if (pendingEvents.isNotEmpty) {
            for (final event in pendingEvents) {
              if (event.type != null) {
                final propertyId =
                    event.type == EventType.CHAT
                        ? event.messageId
                        : event.channelId;
                if (propertyId != null) {
                  await logEventThroughAPI(
                    eventType: event.type!,
                    propertyId: propertyId,
                  );
                }
              }
            }
          }
        } else {
          return;
        }
      }
    } catch (_) {
    } finally {
      _isPendingEventsProcessing = false; // Reset processing status
    }
  }

  static Future<String?> _getString(String key) async {
    try {
      return await _preferences.getString(key);
    } catch (e, stack) {
      Logger.logMessage("Error retrieving data for $key: $e\n$stack");
      return null;
    }
  }

  static Future<void> saveUtmData(Uri deeplink) async {
    try {
      if (deeplink.queryParameters.isNotEmpty) {
        String? utmSource =
            deeplink.queryParameters['utmSource']?.isNotEmpty == true
                ? deeplink.queryParameters['utmSource']
                : deeplink.queryParameters['utm_source'];

        String? utmMedium =
            deeplink.queryParameters['utmMedium']?.isNotEmpty == true
                ? deeplink.queryParameters['utmMedium']
                : deeplink.queryParameters['utm_medium'];

        final existingSource = await _getString(AppPreferences.utmSourceKey);
        final existingMedium = await _getString(AppPreferences.utmMediumKey);

        if ((utmSource?.isNotEmpty ?? false) &&
            (existingSource?.isEmpty ?? true)) {
          await _preferences.setString(AppPreferences.utmSourceKey, utmSource!);
        }
        if ((utmMedium?.isNotEmpty ?? false) &&
            (existingMedium?.isEmpty ?? true)) {
          await _preferences.setString(AppPreferences.utmMediumKey, utmMedium!);
        }

        SessionRouter.ensureOnboardingControllers();
      }
      if (deeplink.toString().isNotEmpty) {
        sl<AnalyticsService>().trackEvent(
          'onboardingDeeplink',
          eventProperties: {'deeplink': deeplink.toString()},
        );
      }
    } catch (e, stack) {
      Logger.logMessage("Error saving UTM data: $e\n$stack");
    }
  }

  static Future<String?> retrieveUtmSource() =>
      _getString(AppPreferences.utmSourceKey);

  static Future<String?> retrieveUtmMedium() =>
      _getString(AppPreferences.utmMediumKey);
}
