import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/data/models/base_response.dart';
import 'package:voiceclub_partner/domain/repository/wallet_repository.dart';

class WithdrawPayoutUseCase
    implements UseCase<DataState<BaseResponseModel>, NoParams> {
  final WalletRepository _walletRepository;
  WithdrawPayoutUseCase(this._walletRepository);

  @override
  Future<DataState<BaseResponseModel>> call(NoParams params) {
    return _walletRepository.withdrawPayout();
  }
}
