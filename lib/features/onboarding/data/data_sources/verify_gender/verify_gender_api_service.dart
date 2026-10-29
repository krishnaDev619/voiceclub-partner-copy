import 'package:dio/dio.dart' hide Headers;
import 'package:retrofit/retrofit.dart';
import 'package:voiceclub_partner/features/onboarding/core/constants/api_constants.dart';
import 'package:voiceclub_partner/features/onboarding/data/models/verify_gender/verify_gender_response_model.dart';

part 'verify_gender_api_service.g.dart';

@RestApi()
abstract class VerifyGenderApiService {
  factory VerifyGenderApiService(Dio dio) = _VerifyGenderApiService;

  @POST(APIConstants.verifyGenderRoute)
  Future<HttpResponse<VerifyGenderResponseModel>> verifyGender({
    @Field('S3Object') required Map<String, dynamic> s3Object,
  });
}
