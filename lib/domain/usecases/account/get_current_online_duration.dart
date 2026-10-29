import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/data/models/account/get_current_online_duration_response.dart';
import 'package:voiceclub_partner/domain/repository/account_repository.dart';

class GetCurrentOnlineDurationUseCase
    implements
        UseCase<DataState<GetCurrentOnlineDurationResponseModel>, NoParams> {
  final AccountRepository _accountRepository;
  GetCurrentOnlineDurationUseCase(this._accountRepository);

  @override
  Future<DataState<GetCurrentOnlineDurationResponseModel>> call(
    NoParams params,
  ) {
    return _accountRepository.getCurrentOnlineDuration();
  }
}
