import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:voiceclub_partner/core/constants/api_constants.dart';
import 'package:voiceclub_partner/data/models/events/get_event_data_response.dart';
import 'package:voiceclub_partner/data/models/events/get_pending_events_list_response.dart';

part 'events_api_service.g.dart';

@RestApi()
abstract class EventsApiService {
  factory EventsApiService(Dio dio) = _EventsApiService;

  @GET(APIConstants.getEventDataRoute)
  Future<HttpResponse<GetEventDataResponseModel>> getEventData({
    @Query('event') required String event,
    @Query('id') required String propertyId,
  });

  @GET(APIConstants.getPendingEventsListRoute)
  Future<HttpResponse<GetPendingEventsListResponseModel>> getPendingEventsList({
    @Query('page') required int page,
    @Query('page_size') required int pageSize,
  });

  @POST(APIConstants.markEventRoute)
  Future<HttpResponse> markEvent({@Path('id') required int eventId});
}
