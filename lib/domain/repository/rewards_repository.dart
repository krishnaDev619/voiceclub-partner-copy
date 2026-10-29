import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/data/models/rewards/get_active_rewards_response_model.dart';
import 'package:voiceclub_partner/data/models/rewards/get_gifts.dart';
import 'package:voiceclub_partner/data/models/rewards/get_rewards_config.dart';
import 'package:voiceclub_partner/data/models/rewards/get_rewards_cutoff_response_model.dart';
import 'package:voiceclub_partner/data/models/rewards/get_rewards_leaderboard_response.dart';

abstract class RewardsRepository {
  Future<DataState<GetActiveRewardsResponseModel>> getActiveRewards();

  Future<DataState<GetRewardsLeaderboardResponseModel>> getRewardsLeaderboard({
    required int rewardId,
    required int page,
    required int pageSize,
  });

  Future<DataState<GetRewardsCutoffResponseModel>> getRewardsCutoff({
    required int rewardId,
  });

  Future<DataState<GetGiftsResponse>> getGifts();

  Future<DataState<GetRewardsConfig>> getRewardsConfig();

  Future<DataState<void>> claimGift({
    required int giftId,
    required String type,
    required String address,
  });
}
