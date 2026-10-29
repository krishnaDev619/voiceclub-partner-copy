import 'package:equatable/equatable.dart';
import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/data/models/rewards/get_rewards_leaderboard_response.dart';
import 'package:voiceclub_partner/domain/repository/rewards_repository.dart';

class GetRewardsLeaderboardUseCase
    implements UseCase<DataState<GetRewardsLeaderboardResponseModel>, Params> {
  final RewardsRepository _rewardsRepository;

  GetRewardsLeaderboardUseCase(this._rewardsRepository);

  @override
  Future<DataState<GetRewardsLeaderboardResponseModel>> call(Params params) {
    return _rewardsRepository.getRewardsLeaderboard(
      rewardId: params.rewardId,
      page: params.page,
      pageSize: params.pageSize,
    );
  }
}

class Params extends Equatable {
  final int rewardId;
  final int page;
  final int pageSize;

  const Params({
    required this.rewardId,
    required this.page,
    required this.pageSize,
  });

  @override
  List<Object> get props => [rewardId];
}
