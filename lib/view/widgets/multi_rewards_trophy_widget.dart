import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/core/constants/asset_constants.dart';
import 'package:voiceclub_partner/modules/controller/multi_reward_controller.dart';
import 'package:voiceclub_partner/view/rewards/multi_reward/multi_rewards_list_screen.dart';

class MultiRewardsTrophyWidget extends StatelessWidget {
  const MultiRewardsTrophyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Visibility(
        visible: Get.find<MultiRewardController>().isRewardActive,
        child: GestureDetector(
          onTap: () {
            Get.find<MultiRewardController>().getActiveRewards();
            Get.to(() => const MultiRewardsListScreen());
          },
          child: Container(
            height: 80.0,
            width: 80.0,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFEE6464), Color(0xFFEE8564)],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  offset: const Offset(0.0, 4.0),
                  spreadRadius: 2,
                  blurRadius: 4,
                ),
              ],
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(AssetConstants.rewardsTrophy, fit: BoxFit.cover),
          ),
        ),
      );
    });
  }
}
