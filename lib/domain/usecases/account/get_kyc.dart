import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/data/models/account/get_kyc_response.dart';
import 'package:voiceclub_partner/domain/repository/account_repository.dart';

class GetKYCUsecase
    implements UseCase<DataState<GetKYCResponseModel>, NoParams> {
  final AccountRepository _accountRepository;

  GetKYCUsecase(this._accountRepository);

  @override
  Future<DataState<GetKYCResponseModel>> call(_) {
    return _accountRepository.getKYC();
  }
}
