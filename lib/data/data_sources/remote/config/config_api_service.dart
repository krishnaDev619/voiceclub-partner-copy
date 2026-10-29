import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:voiceclub_partner/core/constants/api_constants.dart';
import 'package:voiceclub_partner/data/models/config/get_app_config_status_response.dart';
import 'package:voiceclub_partner/data/models/config/get_support_questions_config_response.dart';
import 'package:voiceclub_partner/data/models/config/intro_audio_settings_response.dart';
import 'package:voiceclub_partner/data/models/config/languages_response.dart';

part 'config_api_service.g.dart';

@RestApi()
abstract class ConfigApiService {
  factory ConfigApiService(Dio dio) = _ConfigApiService;

  @GET(APIConstants.getAppConfigStatusRoute)
  Future<HttpResponse<GetAppConfigStatusResponseModel>> getAppConfigStatus();

  @GET(APIConstants.getLanguagesRoute)
  Future<HttpResponse<LanguagesResponseModel>> getLanguages();

  @GET(APIConstants.getSupportQuestionsConfigRoute)
  Future<HttpResponse<GetSupportQuestionsConfigResponseModel>>
  getSupportQuestionsConfig();

  @GET(APIConstants.getIntroAudioSettingsRoute)
  Future<HttpResponse<IntroAudioSettingsResponse>> getIntroAudioSettings();
}
