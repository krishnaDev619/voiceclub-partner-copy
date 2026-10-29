import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:voiceclub_partner/core/constants/api_constants.dart';
import 'package:voiceclub_partner/data/models/file/upload_file_response.dart';

part 'file_url_api_service.g.dart';

@RestApi()
abstract class FileUrlApiService {
  factory FileUrlApiService(Dio dio) = _FileUrlApiService;

  @GET(APIConstants.getChatAttachmentUrlRoute)
  Future<HttpResponse<FileResponseModel>> getChatAttachmentUrl({
    @Query('filename') required String filename,
  });
}
