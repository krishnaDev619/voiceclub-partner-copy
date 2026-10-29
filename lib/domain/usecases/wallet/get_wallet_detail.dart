import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/data/models/wallet/wallet_detail.dart';
import 'package:voiceclub_partner/domain/repository/wallet_repository.dart';

class GetWalletDetailUsecase
    implements UseCase<DataState<WalletDetail>, NoParams> {
  final WalletRepository _walletRepository;
  GetWalletDetailUsecase(this._walletRepository);

  @override
  Future<DataState<WalletDetail>> call(NoParams params) {
    return _walletRepository.getWalletDetail();
  }
}
