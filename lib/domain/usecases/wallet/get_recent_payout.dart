import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/data/models/wallet/result_wallet.dart';
import 'package:voiceclub_partner/domain/repository/wallet_repository.dart';

class GetRecentPayoutUseCase
    implements UseCase<DataState<ResultWalletModel>, NoParams> {
  final WalletRepository _walletRepository;

  GetRecentPayoutUseCase(this._walletRepository);

  @override
  Future<DataState<ResultWalletModel>> call(NoParams params) {
    return _walletRepository.getRecentPayout();
  }
}
