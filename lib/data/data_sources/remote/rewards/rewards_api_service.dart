import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:voiceclub_partner/core/constants/api_constants.dart';
import 'package:voiceclub_partner/data/models/rewards/get_active_rewards_response_model.dart';
import 'package:voiceclub_partner/data/models/rewards/get_gifts.dart';
import 'package:voiceclub_partner/data/models/rewards/get_rewards_config.dart';
import 'package:voiceclub_partner/data/models/rewards/get_rewards_cutoff_response_model.dart';
import 'package:voiceclub_partner/data/models/rewards/get_rewards_leaderboard_response.dart';

part 'rewards_api_service.g.dart';

@RestApi()
abstract class RewardsApiService {
  factory RewardsApiService(Dio dio) = _RewardsApiService;

  @GET(APIConstants.activeRewardsRoute)
  Future<HttpResponse<GetActiveRewardsResponseModel>> getActiveRewards();

  @GET(APIConstants.rewardsLeaderboardRoute)
  Future<HttpResponse<GetRewardsLeaderboardResponseModel>>
  getRewardsLeaderboard({
    @Path('rewardId') required int rewardId,
    @Query('page') required int page,
    @Query('page_size') required int pageSize,
  });

  @GET(APIConstants.rewardsCutoffRoute)
  Future<HttpResponse<GetRewardsCutoffResponseModel>> getRewardsCutoff({
    @Path('rewardId') required int rewardId,
  });

  @GET(APIConstants.getGiftsRoute)
  Future<HttpResponse<GetGiftsResponse>> getGifts();

  @GET(APIConstants.rewardsConfigRoute)
  Future<HttpResponse<GetRewardsConfig>> getRewardsConfig();

  @POST(APIConstants.claimGiftRoute)
  Future<HttpResponse> claimGift({
    @Field('gift_id') required int giftId,
    @Field('type') required String type,
    @Field('address') required String address,
  });
}
