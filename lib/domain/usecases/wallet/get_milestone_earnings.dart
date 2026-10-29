import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/data/models/wallet/get_milestone_earnings_response.dart';
import 'package:voiceclub_partner/domain/repository/wallet_repository.dart';

class GetMilestoneEarningsUsecase
    implements UseCase<DataState<GetMilestoneEarningsResponseModel>, NoParams> {
  final WalletRepository _walletRepository;
  GetMilestoneEarningsUsecase(this._walletRepository);

  @override
  Future<DataState<GetMilestoneEarningsResponseModel>> call(NoParams params) {
    return _walletRepository.getMilestoneEarnings();
  }
}
