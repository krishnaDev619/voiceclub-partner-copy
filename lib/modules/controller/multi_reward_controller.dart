import 'package:get/get.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/injection_container.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/core/services/logger.dart';
import 'package:voiceclub_partner/data/models/rewards/get_rewards_config.dart';
import 'package:voiceclub_partner/data/models/rewards/get_rewards_cutoff_response_model.dart';
import 'package:voiceclub_partner/data/models/rewards/get_rewards_leaderboard_response.dart';
import 'package:voiceclub_partner/data/models/rewards/rewards.dart';
import 'package:voiceclub_partner/domain/usecases/rewards/get_active_rewards.dart';
import 'package:voiceclub_partner/domain/usecases/rewards/get_rewards_config_usecase.dart';
import 'package:voiceclub_partner/domain/usecases/rewards/get_rewards_cutoff.dart'
    as rewards_cutoff;
import 'package:voiceclub_partner/domain/usecases/rewards/get_rewards_leaderboard.dart'
    as rewards_leaderboard;
import 'package:voiceclub_partner/modules/controller/user_controller.dart';

class MultiRewardController extends GetxController {
  final activeRewardsList = <Rewards>[].obs;
  final rewardsLeaderboardResponse = GetRewardsLeaderboardResponseModel().obs;
  final rewardsCutoffResponse = GetRewardsCutoffResponseModel().obs;
  final rewardsConfig = Rxn<GetRewardsConfig>();
  final fetchingLeaderboard = false.obs;
  final fetchingCutoffRewards = false.obs;
  final fetchingRewardsConfig = false.obs;

  bool get isRewardActive {
    final partnerStatus = Get.find<UserController>().partnerStatus.value;
    return activeRewardsList.isNotEmpty &&
        (partnerStatus == PartnerCurrentStatus.LIVE ||
            partnerStatus == PartnerCurrentStatus.NEW_LIVE ||
            partnerStatus == PartnerCurrentStatus.PROBATION);
  }

  @override
  void onInit() {
    getActiveRewards();
    super.onInit();
  }

  Future<void> getActiveRewards() async {
    try {
      final response = await sl<GetActiveRewardsUseCase>().call(NoParams());
      if (response.data != null && response.error == null) {
        activeRewardsList.clear();
        activeRewardsList.addAll(response.data?.rewards ?? []);
      }
    } catch (e) {
      Logger.logMessage("Error getting multi rewards ${e.toString()}");
    } finally {}
  }

  Future<void> fetchRewardsLeaderBoard({required int id}) async {
    try {
      fetchingLeaderboard(true);
      final response =
          await sl<rewards_leaderboard.GetRewardsLeaderboardUseCase>().call(
            rewards_leaderboard.Params(rewardId: id, pageSize: 50, page: 1),
          );
      if (response.data != null && response.error == null) {
        rewardsLeaderboardResponse.value =
            response.data ?? GetRewardsLeaderboardResponseModel();
      }
    } catch (e) {
      Logger.logMessage("Error fetching rewards leaderboard ${e.toString()}");
    } finally {
      fetchingLeaderboard(false);
    }
  }

  Future<void> fetchCutoffRewards({required int id}) async {
    try {
      fetchingCutoffRewards(true);
      final response = await sl<rewards_cutoff.GetRewardsCutoffUseCase>().call(
        rewards_cutoff.Params(rewardId: id),
      );
      if (response.data != null && response.error == null) {
        rewardsCutoffResponse.value =
            response.data ?? GetRewardsCutoffResponseModel();
      }
    } catch (e) {
      Logger.logMessage("Error fetching rewards cutoff ${e.toString()}");
    } finally {
      fetchingCutoffRewards(false);
    }
  }

  Future<void> fetchRewardsConfig() async {
    try {
      fetchingRewardsConfig(true);
      final response = await sl<GetRewardsConfigUseCase>().call(NoParams());
      if (response.data != null && response.error == null) {
        rewardsConfig.value = response.data;
      }
    } catch (e) {
      Logger.logMessage("Error fetching rewards config ${e.toString()}");
    } finally {
      fetchingRewardsConfig(false);
    }
  }

  bool shouldShowRewardsConfig(int? rewardId) {
    return rewardId == 20 || rewardId == 21;
  }
}
