import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/data/models/account/get_account_preference_response.dart';
import 'package:voiceclub_partner/domain/repository/account_repository.dart';

class GetAccountPreferenceUsecase
    implements UseCase<DataState<GetAccountPreferenceResponseModel>, NoParams> {
  final AccountRepository _accountRepository;

  GetAccountPreferenceUsecase(this._accountRepository);

  @override
  Future<DataState<GetAccountPreferenceResponseModel>> call(_) {
    return _accountRepository.getAccountPreference();
  }
}
