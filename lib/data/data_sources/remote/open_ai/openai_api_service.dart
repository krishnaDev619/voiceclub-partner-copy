import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:voiceclub_partner/core/constants/api_constants.dart';
import 'package:voiceclub_partner/data/models/open_ai/analyze_audio_response.dart';

part 'openai_api_service.g.dart';

@RestApi()
abstract class OpenAIApiService {
  factory OpenAIApiService(Dio dio) = _OpenAIApiService;

  @POST(APIConstants.analyzeAudioRoute)
  Future<HttpResponse<AnalyzeAudioResponseModel>> analyzeAudio({
    @Query('api-version') required String apiVersion,
    @Body() required Map<String, dynamic> body,
  });
}
