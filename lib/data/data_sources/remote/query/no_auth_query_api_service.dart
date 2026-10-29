import 'package:dio/dio.dart' hide Headers;
import 'package:retrofit/retrofit.dart';
import 'package:voiceclub_partner/core/constants/api_constants.dart';
import 'package:voiceclub_partner/data/models/query/start_session_response_model.dart';

part 'no_auth_query_api_service.g.dart';

@RestApi()
abstract class NoAuthQueryApiService {
  factory NoAuthQueryApiService(Dio dio) = _NoAuthQueryApiService;

  @POST(APIConstants.startNoAuthQueryBotSessionRoute)
  Future<HttpResponse<StartSessionResponseModel>> startSession({
    @Field('source') required String source,
    @Field('account_id') required int accountId,
  });

  @POST(APIConstants.sendNoAuthQueryBotMessageRoute)
  @Headers({'Content-Type': 'multipart/form-data'})
  @MultiPart()
  Future<HttpResponse<void>> sendMessage({
    @Part(name: 'session_id') required String sessionId,
    @Part(name: 'message_type') required String messageType,
    @Part(name: 'content') required String content,
    @Part(name: 'account_id') required int accountId,
  });

  @POST(APIConstants.endNoAuthQueryBotSessionRoute)
  Future<HttpResponse<void>> endSession({
    @Field('session_id') required String sessionId,
    @Field('account_id') required int accountId,
  });
}
