import 'dart:io';

import 'package:dio/dio.dart' hide Headers;
import 'package:retrofit/retrofit.dart';
import 'package:voiceclub_partner/core/constants/api_constants.dart';
import 'package:voiceclub_partner/data/models/query/get_daily_query_raised_count_response.dart';
import 'package:voiceclub_partner/data/models/query/get_query_session_response.dart';
import 'package:voiceclub_partner/data/models/query/get_unseen_kam_query_chat_message_count_response.dart';
import 'package:voiceclub_partner/data/models/query/list_query_sessions_response.dart';
import 'package:voiceclub_partner/data/models/query/start_session_response_model.dart';

part 'query_api_service.g.dart';

@RestApi()
abstract class QueryApiService {
  factory QueryApiService(Dio dio) = _QueryApiService;

  @POST(APIConstants.startQueryBotSessionRoute)
  Future<HttpResponse<StartSessionResponseModel>> startQueryBotSession({
    @Field('source') required String source,
  });

  @POST(APIConstants.sendQueryBotMessageRoute)
  @Headers({'Content-Type': 'multipart/form-data'})
  @MultiPart()
  Future<HttpResponse<void>> sendQueryBotMessage({
    @Part(name: 'session_id') required String sessionId,
    @Part(name: 'message_type') required String messageType,
    @Part(name: 'content') String? content,
    @Part(name: 'attachment') File? attachment,
    @Part(name: 'option_type') String? actionOptionType,
    @Part(name: 'value') String? actionValue,
    @Part(name: 'external_id') String? externalId,
  });

  @POST(APIConstants.endQueryBotSessionRoute)
  Future<HttpResponse<void>> endQueryBotSession({
    @Field('session_id') required String sessionId,
  });

  @GET(APIConstants.listQuerySessionsRoute)
  Future<HttpResponse<ListQuerySessionsResponse>> listQuerySessions({
    @Query('page') required int page,
    @Query('page_size') required int pageSize,
  });

  @GET(APIConstants.getQuerySessionRoute)
  Future<HttpResponse<GetQuerySessionResponse>> getQuerySession({
    @Path('id') required String sessionId,
  });

  @GET(APIConstants.getUnseenKamQueryChatMessageCountRoute)
  Future<HttpResponse<GetUnseenKamQueryChatMessageCountResponse>>
  getUnseenKamQueryChatMessageCount();

  @GET(APIConstants.getDailyQueryRaisedCountRoute)
  Future<HttpResponse<GetDailyQueryRaisedCountResponse>>
  getDailyQueryRaisedCount();

  @PUT(APIConstants.updateAiCallCountRoute)
  Future<HttpResponse<void>> updateAiCallCount({
    @Field('session_id') required String sessionId,
  });
}
