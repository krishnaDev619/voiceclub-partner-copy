import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/data/models/config/get_app_config_status_response.dart';

import 'package:voiceclub_partner/data/models/config/get_support_questions_config_response.dart';
import 'package:voiceclub_partner/data/models/config/intro_audio_settings_response.dart';
import 'package:voiceclub_partner/data/models/config/languages_response.dart';

abstract class ConfigRepository {
  // API methods
  Future<DataState<GetAppConfigStatusResponseModel>> getAppConfigStatus();

  Future<DataState<LanguagesResponseModel>> getLanguages();

  Future<DataState<GetSupportQuestionsConfigResponseModel>>
  getSupportQuestionsConfig();

  Future<DataState<IntroAudioSettingsResponse>> getIntroAudioSettings();
}
