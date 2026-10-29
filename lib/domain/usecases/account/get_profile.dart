import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/data/models/data.dart';
import 'package:voiceclub_partner/domain/repository/account_repository.dart';

class GetProfileUsecase implements UseCase<DataState<DataModel>, NoParams> {
  final AccountRepository _accountRepository;
  GetProfileUsecase(this._accountRepository);

  @override
  Future<DataState<DataModel>> call(NoParams params) {
    return _accountRepository.getSupplyProfile();
  }
}
