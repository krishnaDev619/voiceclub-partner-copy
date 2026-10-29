import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/data/models/config/get_app_config_status_response.dart';
import 'package:voiceclub_partner/domain/repository/config_repository.dart';

class GetAppConfigStatusUsecase
    implements UseCase<DataState<GetAppConfigStatusResponseModel>, NoParams> {
  final ConfigRepository _configRepository;
  GetAppConfigStatusUsecase(this._configRepository);

  @override
  Future<DataState<GetAppConfigStatusResponseModel>> call(NoParams params) {
    return _configRepository.getAppConfigStatus();
  }
}
