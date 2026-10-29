import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:voiceclub_partner/core/constants/api_constants.dart';

part 'fcm_config_api_service.g.dart';

@RestApi()
abstract class FCMConfigApiService {
  factory FCMConfigApiService(Dio dio) = _FCMConfigApiService;

  @PUT(APIConstants.updateFCMRoute)
  Future<HttpResponse> updateSupplyFCM({
    @Field('token') required String token,
    @Field('version') String? version,
    @Field('build_number') int? buildNumber,
  });
}
