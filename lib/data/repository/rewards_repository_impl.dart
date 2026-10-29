import 'package:dio/dio.dart';
import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/http_response_handler.dart';
import 'package:voiceclub_partner/data/data_sources/remote/rewards/rewards_api_service.dart';
import 'package:voiceclub_partner/data/models/rewards/get_active_rewards_response_model.dart';
import 'package:voiceclub_partner/data/models/rewards/get_gifts.dart';
import 'package:voiceclub_partner/data/models/rewards/get_rewards_config.dart';
import 'package:voiceclub_partner/data/models/rewards/get_rewards_cutoff_response_model.dart';
import 'package:voiceclub_partner/data/models/rewards/get_rewards_leaderboard_response.dart';
import 'package:voiceclub_partner/domain/repository/rewards_repository.dart';

class RewardsRepositoryImpl implements RewardsRepository {
  final RewardsApiService _rewardsApiService;

  RewardsRepositoryImpl(this._rewardsApiService);

  @override
  Future<DataState<GetActiveRewardsResponseModel>> getActiveRewards() async {
    try {
      final response = await _rewardsApiService.getActiveRewards();

      return toDataState(response);
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<GetRewardsCutoffResponseModel>> getRewardsCutoff({
    required int rewardId,
  }) async {
    try {
      final response = await _rewardsApiService.getRewardsCutoff(
        rewardId: rewardId,
      );

      return toDataState(response);
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<GetRewardsLeaderboardResponseModel>> getRewardsLeaderboard({
    required int rewardId,
    required int page,
    required int pageSize,
  }) async {
    try {
      final response = await _rewardsApiService.getRewardsLeaderboard(
        rewardId: rewardId,
        page: page,
        pageSize: pageSize,
      );

      return toDataState(response);
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<GetGiftsResponse>> getGifts() async {
    try {
      final response = await _rewardsApiService.getGifts();

      return toDataState(response);
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<GetRewardsConfig>> getRewardsConfig() async {
    try {
      final response = await _rewardsApiService.getRewardsConfig();

      return toDataState(response);
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<void>> claimGift({
    required int giftId,
    required String type,
    required String address,
  }) async {
    try {
      final response = await _rewardsApiService.claimGift(
        giftId: giftId,
        type: type,
        address: address,
      );

      if (response.response.statusCode == 200) {
        return const DataSuccess(null);
      } else {
        return DataFailed(
          DioException(
            error: response.response.statusCode,
            message: response.response.statusMessage,
            response: response.response,
            requestOptions: response.response.requestOptions,
          ),
        );
      }
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }
}
