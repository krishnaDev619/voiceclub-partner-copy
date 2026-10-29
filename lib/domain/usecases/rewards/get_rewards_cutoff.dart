import 'package:equatable/equatable.dart';
import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/data/models/rewards/get_rewards_cutoff_response_model.dart';
import 'package:voiceclub_partner/domain/repository/rewards_repository.dart';

class GetRewardsCutoffUseCase
    implements UseCase<DataState<GetRewardsCutoffResponseModel>, Params> {
  final RewardsRepository _rewardsRepository;

  GetRewardsCutoffUseCase(this._rewardsRepository);

  @override
  Future<DataState<GetRewardsCutoffResponseModel>> call(Params params) {
    return _rewardsRepository.getRewardsCutoff(rewardId: params.rewardId);
  }
}

class Params extends Equatable {
  final int rewardId;

  const Params({required this.rewardId});

  @override
  List<Object> get props => [rewardId];
}
