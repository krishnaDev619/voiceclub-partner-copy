import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/data/models/wallet/get_coin_wallet.dart';
import 'package:voiceclub_partner/domain/repository/wallet_repository.dart';

class GetCoinBalanceUseCase
    implements UseCase<DataState<GetCoinWalletResponse>, NoParams> {
  final WalletRepository _walletRepository;

  GetCoinBalanceUseCase(this._walletRepository);

  @override
  Future<DataState<GetCoinWalletResponse>> call(NoParams params) {
    return _walletRepository.getCoinBalance();
  }
}
