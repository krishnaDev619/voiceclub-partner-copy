import 'dart:io';

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:voiceclub_partner/features/onboarding/core/constants/api_constants.dart';
import 'package:voiceclub_partner/features/onboarding/data/models/verify_gender/upload_file_response_model.dart';

part 'upload_file_api_service.g.dart';

@RestApi()
abstract class UploadFileApiService {
  factory UploadFileApiService(Dio dio) = _UploadFileApiService;

  @POST(APIConstants.uploadOnboardingFileRoute)
  @MultiPart()
  Future<HttpResponse<UploadFileResponseModel>> uploadOnboardingFile({
    @Part(name: 'attachment') required File file,
    @Path('extension') required String extension,
  });
}
