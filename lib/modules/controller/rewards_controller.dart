import 'package:get/get.dart';
import 'package:voiceclub_partner/core/injection_container.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/data/models/account/rewards_stats.dart';
import 'package:voiceclub_partner/domain/usecases/account/get_rewards_stats.dart';

class RewardsController extends GetxController {
  final rewardsStats = Rxn<RewardsStatsResponse>();

  @override
  void onInit() {
    fetchRewardsStats();
    super.onInit();
  }

  Future<void> fetchRewardsStats() async {
    try {
      var response = await sl<GetRewardsStatsUseCase>().call(NoParams());

      if (response.data != null && response.error == null) {
        rewardsStats.value = response.data;
      }
    } catch (_) {
      // Handle error silently as this is supplementary data
    } finally {}
  }
}
