import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:voiceclub_partner/core/constants/api_constants.dart';
import 'package:voiceclub_partner/data/models/call_logs/fetch_call_logs_for_pair_response.dart';
import 'package:voiceclub_partner/data/models/file/upload_file_response.dart';

part 'call_logs_api_service.g.dart';

@RestApi()
abstract class CallLogsApiService {
  factory CallLogsApiService(Dio dio) = _CallLogsApiService;

  @GET(APIConstants.fetchCallLogsForPairRoute)
  Future<HttpResponse<FetchCallLogsForPairResponseModel>> fetchCallLogsForPair({
    @Path('userId') required int userId,
    @Query('page') required int page,
    @Query('page_size') required int pageSize,
  });

  @GET(APIConstants.fetchLogRecordingUrlRoute)
  Future<HttpResponse<FileResponseModel>> fetchLogRecordingUrl({
    @Path('filename') required String filename,
  });
}
