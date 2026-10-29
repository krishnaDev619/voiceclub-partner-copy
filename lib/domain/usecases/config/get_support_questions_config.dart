import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/data/models/config/get_support_questions_config_response.dart';
import 'package:voiceclub_partner/domain/repository/config_repository.dart';

class GetSupportQuestionsConfigUsecase
    implements
        UseCase<DataState<GetSupportQuestionsConfigResponseModel>, NoParams> {
  final ConfigRepository _configRepository;

  GetSupportQuestionsConfigUsecase(this._configRepository);

  @override
  Future<DataState<GetSupportQuestionsConfigResponseModel>> call(
    NoParams params,
  ) {
    return _configRepository.getSupportQuestionsConfig();
  }
}
