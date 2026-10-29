import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/data/models/events/get_event_data_response.dart';
import 'package:voiceclub_partner/data/models/events/get_pending_events_list_response.dart';

abstract class EventsRepository {
  // API methods
  Future<DataState<GetEventDataResponseModel>> getEventData({
    required String event,
    required String propertyId,
  });

  Future<DataState<GetPendingEventsListResponseModel>> getPendingEventsList();

  Future<DataState> markEvent({required int eventId});
}
