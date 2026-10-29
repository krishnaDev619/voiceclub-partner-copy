import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/data/models/account/rewards_stats.dart';
import 'package:voiceclub_partner/domain/repository/account_repository.dart';

class GetRewardsStatsUseCase
    implements UseCase<DataState<RewardsStatsResponse>, NoParams> {
  final AccountRepository _accountRepository;

  GetRewardsStatsUseCase(this._accountRepository);

  @override
  Future<DataState<RewardsStatsResponse>> call(NoParams params) {
    return _accountRepository.getRewardsStats();
  }
}
