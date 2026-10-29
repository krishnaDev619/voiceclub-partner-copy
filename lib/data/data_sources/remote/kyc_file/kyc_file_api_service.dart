import 'dart:io';

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:voiceclub_partner/core/constants/api_constants.dart';
import 'package:voiceclub_partner/data/models/kyc_file/upload_kyc_file_response.dart';

part 'kyc_file_api_service.g.dart';

@RestApi()
abstract class KYCFileApiService {
  factory KYCFileApiService(Dio dio) = _KYCFileApiService;

  @POST(APIConstants.uploadKycFileRoute)
  @MultiPart()
  Future<HttpResponse<UploadKYCFileResponseModel>> uploadKYCFile({
    @Part(name: 'attachment') required File file,
    @Path('extension') required String extension,
  });
}
