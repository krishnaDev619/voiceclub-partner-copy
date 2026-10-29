import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/data/models/wallet/payout_count.dart';
import 'package:voiceclub_partner/domain/repository/wallet_repository.dart';

class GetPayoutCountUseCase
    implements UseCase<DataState<PayoutCountResponse>, NoParams> {
  final WalletRepository _walletRepository;

  GetPayoutCountUseCase(this._walletRepository);

  @override
  Future<DataState<PayoutCountResponse>> call(NoParams params) {
    return _walletRepository.getPayoutCount();
  }
}
