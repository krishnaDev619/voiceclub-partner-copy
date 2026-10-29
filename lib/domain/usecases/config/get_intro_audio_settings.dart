import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/data/models/config/intro_audio_settings_response.dart';
import 'package:voiceclub_partner/domain/repository/config_repository.dart';

class GetIntroAudioSettingsUsecase
    implements UseCase<DataState<IntroAudioSettingsResponse>, NoParams> {
  final ConfigRepository _configRepository;

  GetIntroAudioSettingsUsecase(this._configRepository);

  @override
  Future<DataState<IntroAudioSettingsResponse>> call(NoParams params) {
    return _configRepository.getIntroAudioSettings();
  }
}
