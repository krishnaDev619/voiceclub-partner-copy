import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/data/models/rewards/get_rewards_config.dart';
import 'package:voiceclub_partner/domain/repository/rewards_repository.dart';

class GetRewardsConfigUseCase
    implements UseCase<DataState<GetRewardsConfig>, NoParams> {
  final RewardsRepository _rewardsRepository;

  GetRewardsConfigUseCase(this._rewardsRepository);

  @override
  Future<DataState<GetRewardsConfig>> call(NoParams params) async {
    return _rewardsRepository.getRewardsConfig();
  }
}
