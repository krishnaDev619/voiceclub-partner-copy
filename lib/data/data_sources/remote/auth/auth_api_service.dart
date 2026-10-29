import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:voiceclub_partner/core/constants/api_constants.dart';

part 'auth_api_service.g.dart';

@RestApi()
abstract class AuthApiService {
  factory AuthApiService(Dio dio) = _AuthApiService;

  @POST(APIConstants.logoutRoute)
  Future<HttpResponse<void>> logout();
}
