import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:voiceclub_partner/core/constants/api_constants.dart';
import 'package:voiceclub_partner/data/models/calling/accept_call_response.dart';
import 'package:voiceclub_partner/data/models/calling/call_details_response.dart';
import 'package:voiceclub_partner/data/models/calling/call_model.dart';
import 'package:voiceclub_partner/data/models/calling/get_hung_call.dart';
import 'package:voiceclub_partner/data/models/calling/get_reverse_calling_stats_reponse.dart';
import 'package:voiceclub_partner/data/models/calling/place_call_response.dart';
import 'package:voiceclub_partner/data/models/get_logs_grouped_response.dart';

part 'calling_api_service.g.dart';

@RestApi()
abstract class CallingApiService {
  factory CallingApiService(Dio dio) = _CallingApiService;

  @POST(APIConstants.placeCallRoute)
  Future<HttpResponse<PlaceCallResponseModel>> placeCall({
    @Field('girl_uid') required int demandUid,
  });

  @GET(APIConstants.getCurrentCallRoute)
  Future<HttpResponse<CallModel>> getCurrentCall(
    @Path('channelId') String channelId,
  );

  @POST(APIConstants.endCallRoute)
  Future<HttpResponse> endCall(
    @Field('channel_id') String channelId,
    @Field('call_rejected') bool callRejected,
    @Field('ended_by') int uId,
    @Field('decline_reason') String declineReason,
  );

  @POST(APIConstants.acceptCallRoute)
  Future<HttpResponse<AcceptCallResponseModel>> acceptCall(
    @Path('channelId') String channelId,
  );

  @POST(APIConstants.setRingSupplyRoute)
  Future<HttpResponse> setRing({
    @Path('channelId') required String channelId,
    @Field('is_notification') required bool isNotification,
  });

  @GET(APIConstants.getLogsGroupedRoute)
  Future<HttpResponse<GetLogsGroupedResponseModel>> getLogsGrouped({
    @Path('type') required String type,
    @Path('period') required String period,
    @Query('page') required int page,
    @Query('page_size') required int pageSize,
  });

  @POST(APIConstants.pingCallRoute)
  Future<HttpResponse> pingCall({@Path('channelId') required String channelId});

  @GET(APIConstants.getCallDetailsRoute)
  Future<HttpResponse<GetCallDetailsResponseModel>> getCallDetails({
    @Path('channelId') required String channelId,
  });

  @GET(APIConstants.getReverseCallingStatsRoute)
  Future<HttpResponse<GetReverseCallingStatsResponseModel>>
  getReverseCallingStats({@Path('accountId') required int demandAccountId});

  @GET(APIConstants.getHungCallRoute)
  Future<HttpResponse<GetHungCallModel>> getHungCall();

  @PUT(APIConstants.endHungCallRoute)
  Future<HttpResponse> endHungCall({
    @Path('channelId') required String channelId,
  });
}
