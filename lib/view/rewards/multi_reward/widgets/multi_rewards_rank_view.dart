import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/injection_container.dart';
import 'package:voiceclub_partner/core/services/analytics_service.dart';
import 'package:voiceclub_partner/data/models/rewards/rewards.dart';
import 'package:voiceclub_partner/modules/controller/multi_reward_controller.dart';
import 'package:voiceclub_partner/view/rewards/multi_reward/widgets/multi_rewards_table.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';

class MultiRewardsRankView extends StatefulWidget {
  final Rewards reward;

  const MultiRewardsRankView({super.key, required this.reward});

  @override
  State<MultiRewardsRankView> createState() => _MultiRewardsRankViewState();
}

class _MultiRewardsRankViewState extends State<MultiRewardsRankView> {
  final multiRewardController = Get.find<MultiRewardController>();
  bool isEventFired = false;

  @override
  void initState() {
    multiRewardController.fetchRewardsLeaderBoard(
      id: widget.reward.rewardId ?? 0,
    );
    super.initState();
  }

  void fireLeaderboardEvent({required int myRank, required int myAmount}) {
    sl<AnalyticsService>().trackEvent(
      "multiRewardsScreen",
      eventProperties: {
        "name": widget.reward.name,
        "rewardType": widget.reward.type?.name,
        "myRank": myRank,
        "myAmount": myAmount,
      },
    );
    isEventFired = true;
  }

  void checkAndFireLeaderboardEvent({
    required int myRank,
    required int myAmount,
  }) {
    if (!isEventFired) {
      fireLeaderboardEvent(myAmount: myAmount, myRank: myRank);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Obx(() {
        final leaderboardResponse =
            multiRewardController.rewardsLeaderboardResponse.value;
        final rankings = leaderboardResponse.ranks;
        final myRank = leaderboardResponse.myRank;
        if (multiRewardController.fetchingLeaderboard.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (rankings?.isEmpty ?? false) {
          return Center(child: Text(LocaleKeys.liveNoDataFound.tr));
        }
        checkAndFireLeaderboardEvent(
          myRank: myRank?.rank?.toInt() ?? 0,
          myAmount: myRank?.rewardAmount?.toInt() ?? 0,
        );
        return Container(
          width: double.infinity,
          height: double.infinity - 30.0,
          margin: const EdgeInsets.symmetric(horizontal: 6.0),
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: (widget.reward.colorCode ?? "").toColor(),
            borderRadius: BorderRadius.circular(12.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 6.0,
                spreadRadius: 2.0,
              ),
            ],
          ),
          child: MultiRewardsTable(
            rankings: rankings ?? [],
            headerString: widget.reward.unit,
            myRank: myRank,
            reward: widget.reward,
          ),
        );
      }),
    );
  }
}
