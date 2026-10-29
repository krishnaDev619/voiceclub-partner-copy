import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:voiceclub_partner/core/constants/api_constants.dart';
import 'package:voiceclub_partner/data/models/blocking/get_blocked_users_response.dart';

part 'blocking_api_service.g.dart';

@RestApi()
abstract class BlockingApiService {
  factory BlockingApiService(Dio dio) = _BlockingApiService;

  @POST(APIConstants.blockUserRoute)
  Future<HttpResponse> blockUser(
    @Field('blocked_account_id') int accountId,
    @Field('reason') String reason,
  );

  @POST(APIConstants.reportUserRoute)
  Future<HttpResponse> reportUser(
    @Field('reported_account_id') int accountId,
    @Field('reason') String reason,
  );

  @GET(APIConstants.getBlockedUsersRoute)
  Future<HttpResponse<GetBlockedUsersResponseModel>> getBlockedUsers(
    @Query('page') int page,
    @Query('page_size') int pageSize,
  );
}
