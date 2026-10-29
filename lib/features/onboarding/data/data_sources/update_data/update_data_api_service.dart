import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:voiceclub_partner/features/onboarding/core/constants/api_constants.dart';
import 'package:voiceclub_partner/features/onboarding/data/models/update_data/get_file_url_response.dart';

part 'update_data_api_service.g.dart';

@RestApi()
abstract class UpdateDataApiService {
  factory UpdateDataApiService(Dio dio) = _UpdateDataApiService;

  @PUT(APIConstants.updateDataRoute)
  Future<HttpResponse> updateData({
    @Field('name') required String name,
    @Field('marital_status') required String maritalStatus,
    @Field('phone') required String phone,
    @Field('image_path') required String imagePath,
    @Field('has_pan') required bool hasPan,
    @Field('has_aadhar') required bool hasAadhar,
    @Field('first_language') required String firstLanguage,
    @Field('second_language') required String secondLanguage,
    @Field('age') required String age,
    @Field('education') required String education,
    @Field('religion') required String religion,
    @Field('location') required String city,
    @Field('state') required String state,
    @Field('profile_status') String? profileStatus,
  });

  @PUT(APIConstants.updateDataRoute)
  Future<HttpResponse> updateProfileStatus({
    @Field('phone') required String phone,
    @Field('profile_status') required String profileStatus,
  });

  @PUT(APIConstants.updateSignDocumentRoute)
  Future<HttpResponse> updateSignDocument({
    @Field('document_path') required String documentPath,
    @Field('phone_number') required String phoneNumber,
  });

  @GET(APIConstants.getFileUrlRoute)
  Future<HttpResponse<GetFileUrlResponseModel>> getFileUrlRoute({
    @Path('filename') required String fileName,
  });

  @POST(APIConstants.completeOnboardingRoute)
  Future<HttpResponse> completeOnboarding({
    @Field('phone') required String phone,
    @Field('bypass_kyc') required bool bypassKyc,
  });
}
