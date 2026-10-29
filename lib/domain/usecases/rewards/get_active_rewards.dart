import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/data/models/rewards/get_active_rewards_response_model.dart';
import 'package:voiceclub_partner/domain/repository/rewards_repository.dart';

class GetActiveRewardsUseCase
    implements UseCase<DataState<GetActiveRewardsResponseModel>, NoParams> {
  final RewardsRepository _rewardsRepository;

  GetActiveRewardsUseCase(this._rewardsRepository);

  @override
  Future<DataState<GetActiveRewardsResponseModel>> call(NoParams params) {
    return _rewardsRepository.getActiveRewards();
  }
}
