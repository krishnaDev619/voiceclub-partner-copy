import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:voiceclub_partner/features/onboarding/core/constants/api_constants.dart';
import 'package:voiceclub_partner/features/onboarding/data/models/auth/profile_response.dart';
import 'package:voiceclub_partner/features/onboarding/data/models/auth/verify_otp_response.dart';

part 'auth_api_service.g.dart';

@RestApi()
abstract class AuthApiService {
  factory AuthApiService(Dio dio) = _AuthApiService;

  @POST(APIConstants.registerRoute)
  Future<HttpResponse> register({
    @Field('phone_number') required String phoneNumber,
    @Field('gaid') String? gaid,
  });

  @PUT(APIConstants.verifyOTPRoute)
  Future<HttpResponse<VerifyOtpResponseModel>> verifyOTP({
    @Field('phone_number') required String phoneNumber,
    @Field('otp') required String otp,
  });

  @GET(APIConstants.profileRoute)
  Future<HttpResponse<ProfileResponseModel>> getProfile();
}
