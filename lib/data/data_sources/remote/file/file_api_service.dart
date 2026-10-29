import 'dart:io';

import 'package:dio/dio.dart' hide Headers;
import 'package:retrofit/retrofit.dart';
import 'package:voiceclub_partner/core/constants/api_constants.dart';
import 'package:voiceclub_partner/data/models/file/upload_file_response.dart';

part 'file_api_service.g.dart';

@RestApi()
abstract class FileApiService {
  factory FileApiService(Dio dio) = _FileApiService;

  @POST(APIConstants.uploadFileRoute)
  @Headers({'Content-Type': 'multipart/form-data'})
  @MultiPart()
  Future<HttpResponse<FileResponseModel>> uploadFile({
    @Part(name: 'recording') required File recordingFile,
  });

  @GET(APIConstants.getSignedFileUrlRoute)
  Future<HttpResponse<FileResponseModel>> getSignedFileUrl({
    @Path('fileName') required String fileName,
  });
}
