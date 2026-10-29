import 'package:flutter/material.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/data/models/rewards/rewards.dart';
import 'package:voiceclub_partner/view/rewards/multi_reward/widgets/multi_reward_header_view.dart';
import 'package:voiceclub_partner/view/rewards/multi_reward/widgets/multi_rewards_cutoff_view.dart';
import 'package:voiceclub_partner/view/rewards/multi_reward/widgets/multi_rewards_rank_view.dart';
import 'package:voiceclub_partner/view/rewards/multi_reward/widgets/rewards_config_info_view.dart';
import 'package:voiceclub_partner/view/widgets/custom_app_bar.dart';

class MultiRewardScreen extends StatelessWidget {
  final Rewards ds;

  const MultiRewardScreen({super.key, required this.ds});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: ds.name ?? "",
        backgroundColor: ds.colorCode?.toColor() ?? Colors.white,
      ),
      body: Column(
        children: [
          MultiRewardHeaderView(ds: ds),
          const SizedBox(height: 16.0),
          Visibility(
            visible: ds.type == RewardType.LEADERBOARD,
            replacement: MultiRewardsCutoffView(reward: ds),
            child: MultiRewardsRankView(reward: ds),
          ),
          if (shouldShowRewardsConfig(ds.rewardId))
            RewardsConfigInfoView(ds: ds),
          const SizedBox(height: 16.0),
        ],
      ),
    );
  }

  bool shouldShowRewardsConfig(int? rewardId) {
    return rewardId == 20 || rewardId == 21;
  }
}
