import 'package:dio/dio.dart';
import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/http_response_handler.dart';
import 'package:voiceclub_partner/data/data_sources/remote/events/events_api_service.dart';
import 'package:voiceclub_partner/data/models/events/get_event_data_response.dart';
import 'package:voiceclub_partner/data/models/events/get_pending_events_list_response.dart';
import 'package:voiceclub_partner/domain/repository/events_repository.dart';

class EventsRepositoryImpl implements EventsRepository {
  final EventsApiService _eventsApiService;

  EventsRepositoryImpl(this._eventsApiService);

  @override
  Future<DataState<GetEventDataResponseModel>> getEventData({
    required String event,
    required String propertyId,
  }) async {
    try {
      final response = await _eventsApiService.getEventData(
        event: event,
        propertyId: propertyId,
      );

      return toDataState(response);
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<GetPendingEventsListResponseModel>>
  getPendingEventsList() async {
    try {
      final response = await _eventsApiService.getPendingEventsList(
        page: 1,
        pageSize: 50,
      );

      return toDataState(response);
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState> markEvent({required int eventId}) async {
    try {
      final response = await _eventsApiService.markEvent(eventId: eventId);

      return toDataState(response);
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }
}
