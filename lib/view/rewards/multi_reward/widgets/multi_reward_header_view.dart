import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/data/models/rewards/rewards.dart';
import 'package:voiceclub_partner/modules/controller/multi_reward_controller.dart';
import 'package:voiceclub_partner/view/rewards/multi_reward/widgets/multi_rewards_audio_player.dart';

class MultiRewardHeaderView extends StatelessWidget {
  final Rewards ds;

  const MultiRewardHeaderView({super.key, required this.ds});

  String calculateNextUpdate(String lastUpdatedTime) {
    // Parse the last updated time
    DateTime? lastUpdated = DateTime.tryParse(lastUpdatedTime)?.toLocal();

    if (lastUpdated != null) {
      var result = "";

      // Get the current time
      DateTime currentTime = DateTime.now();

      // Calculate the next update time (1 hour after the last update)
      DateTime nextUpdate = lastUpdated.add(const Duration(hours: 1));

      // Calculate the difference between next update time and current time
      Duration remainingTime = nextUpdate.difference(currentTime);

      // If the remaining time is negative, calculate the time for the next cycle
      if (remainingTime.isNegative) {
        nextUpdate = lastUpdated.add(const Duration(hours: 1));
        remainingTime = nextUpdate.difference(currentTime);
      }

      // Format the duration as hh:mm:ss
      result = [
        // remainingTime.inHours.toString().padLeft(2, '0'), // Hours
        (remainingTime.inMinutes % 60).toString().padLeft(2, '0'), // Minutes
        // (remainingTime.inSeconds % 60).toString().padLeft(2, '0'), // Seconds
      ].join(':');

      return "Next Update in: $result mins";
    }

    return "";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(
        bottom: 16.0,
        right: 16.0,
        left: 16.0,
        top: 16.0,
      ),
      decoration: BoxDecoration(
        color: (ds.colorCode ?? "").toColor(),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(12.0),
          bottomRight: Radius.circular(12.0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 6.0,
            spreadRadius: 2.0,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  ds.description ?? "",
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w300,
                    fontSize: FontSize.xL,
                    overflow: TextOverflow.ellipsis,
                  ),
                  maxLines: 2,
                ),
                Obx(() {
                  final lastUpdatedTime =
                      Get.find<MultiRewardController>()
                          .rewardsLeaderboardResponse
                          .value
                          .lastUpdatedTime;
                  return Padding(
                    padding: const EdgeInsets.only(top: 12.0, bottom: 16.0),
                    child: Visibility(
                      visible:
                          ds.type == RewardType.LEADERBOARD &&
                          (lastUpdatedTime?.isNotEmpty ?? false),
                      replacement: const SizedBox(height: 12.0),
                      child: Text(
                        calculateNextUpdate(lastUpdatedTime ?? ""),
                        style: const TextStyle(
                          color: Color(0xFFE9573E),
                          fontSize: FontSize.L,
                        ),
                      ),
                    ),
                  );
                }),
                MultiRewardsAudioPlayer(reward: ds, width: double.infinity),
              ],
            ),
          ),
          const SizedBox(width: 8.0),
          SizedBox(
            width: 100.0,
            height: 100.0,
            child: SvgPicture.network(ds.imageUrl ?? "", fit: BoxFit.fill),
          ),
        ],
      ),
    );
  }
}
