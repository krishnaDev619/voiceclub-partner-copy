import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/data/models/config/languages_response.dart';
import 'package:voiceclub_partner/domain/repository/config_repository.dart';

class GetLanguagesUseCase
    implements UseCase<DataState<LanguagesResponseModel>, NoParams> {
  final ConfigRepository _configRepository;

  GetLanguagesUseCase(this._configRepository);

  @override
  Future<DataState<LanguagesResponseModel>> call(NoParams params) {
    return _configRepository.getLanguages();
  }
}
