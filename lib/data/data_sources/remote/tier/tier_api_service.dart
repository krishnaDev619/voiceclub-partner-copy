import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:voiceclub_partner/core/constants/api_constants.dart';
import 'package:voiceclub_partner/data/models/tier/get_weekly_online_duration_response.dart';

part 'tier_api_service.g.dart';

@RestApi()
abstract class TierApiService {
  factory TierApiService(Dio dio) = _TierApiService;

  @GET(APIConstants.getWeeklyOnlineDurationRoute)
  Future<HttpResponse<GetWeeklyOnlineDurationResponseModel>>
  getWeeklyOnlineDuration();
}
