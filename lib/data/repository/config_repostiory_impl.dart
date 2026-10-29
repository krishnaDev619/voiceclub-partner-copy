import 'package:dio/dio.dart';
import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/http_response_handler.dart';
import 'package:voiceclub_partner/data/data_sources/remote/config/config_api_service.dart';
import 'package:voiceclub_partner/data/models/config/get_app_config_status_response.dart';

import 'package:voiceclub_partner/data/models/config/get_support_questions_config_response.dart';
import 'package:voiceclub_partner/data/models/config/intro_audio_settings_response.dart';
import 'package:voiceclub_partner/data/models/config/languages_response.dart';
import 'package:voiceclub_partner/domain/repository/config_repository.dart';

class ConfigRepositoryImpl implements ConfigRepository {
  final ConfigApiService _configApiService;

  ConfigRepositoryImpl(this._configApiService);

  @override
  Future<DataState<GetAppConfigStatusResponseModel>>
  getAppConfigStatus() async {
    try {
      final response = await _configApiService.getAppConfigStatus();

      return toDataState(response);
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<LanguagesResponseModel>> getLanguages() async {
    try {
      final response = await _configApiService.getLanguages();
      return toDataState(response);
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<GetSupportQuestionsConfigResponseModel>>
  getSupportQuestionsConfig() async {
    try {
      final response = await _configApiService.getSupportQuestionsConfig();
      return toDataState(response);
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<IntroAudioSettingsResponse>> getIntroAudioSettings() async {
    try {
      final response = await _configApiService.getIntroAudioSettings();
      return toDataState(response);
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }
}
