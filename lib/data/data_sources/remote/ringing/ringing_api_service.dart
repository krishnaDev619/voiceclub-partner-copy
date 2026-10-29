import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:voiceclub_partner/core/constants/api_constants.dart';

part 'ringing_api_service.g.dart';

@RestApi()
abstract class RingingApiService {
  factory RingingApiService(Dio dio) = _RingingApiService;

  @POST(APIConstants.setRingSupplyRoute)
  Future<HttpResponse> setRing({
    @Path('channelId') required String channelId,
    @Field('is_notification') required bool isNotification,
  });
}
