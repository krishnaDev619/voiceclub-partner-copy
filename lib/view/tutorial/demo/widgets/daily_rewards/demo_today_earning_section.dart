import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/core/constants/asset_constants.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/data/models/account/rewards_stats.dart';
import 'package:voiceclub_partner/view/rewards/daily_rewards/widgets/reward_card_widget.dart';
import 'package:voiceclub_partner/view/tutorial/demo/controllers/demo_landing_controller.dart';
import 'package:voiceclub_partner/view/tutorial/demo/widgets/daily_rewards/demo_chat_rewards.dart';
import 'package:voiceclub_partner/view/tutorial/demo/widgets/daily_rewards/demo_incentive_listing.dart';
import 'package:voiceclub_partner/view/tutorial/demo/widgets/daily_rewards/demo_reverse_call_listing.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';

class DemoTodayEarningSection extends StatelessWidget {
  const DemoTodayEarningSection({super.key});

  Color getRewardsColor({required bool allPassed}) {
    if (allPassed) {
      return const Color(0xFF4AA611); // Green color for passed state
    } else {
      return ApplicationColors.primaryRed; // Red color for failed state
    }
  }

  String formatTimeToHoursMinutes(num seconds) {
    final hours = (seconds ~/ 3600);
    final minutes = ((seconds % 3600) ~/ 60);

    final formattedHours = hours.toString().padLeft(2, '0');
    final formattedMinutes = minutes.toString().padLeft(2, '0');

    return '${formattedHours}h ${formattedMinutes}m';
  }

  @override
  Widget build(BuildContext context) {
    final demoController = Get.find<DemoLandingController>();
    final rewardStats = demoController.rewardStats;
    final reverseCallsData = rewardStats.reverseCalls;
    final incentiveCallsData = rewardStats.incentiveCalls;
    final chatReceivedData = rewardStats.chatReceived;
    final onlineDurationData = rewardStats.onlineDuration;

    final currentDurationInHours = onlineDurationData?.currentHours ?? 0.0;
    final currentDurationInSeconds = currentDurationInHours * 3600;

    final onlineDurationCutoff = onlineDurationData?.rewardThreshold ?? 7;
    final num reverseCallCutoff = reverseCallsData?.thresholds?.last.count ?? 0;
    final num reverseCallCount = reverseCallsData?.currentCount ?? 0;
    final num incentiveCutoff = incentiveCallsData?.thresholds?.last.count ?? 0;
    final num incentiveCount = incentiveCallsData?.currentCount ?? 0;
    final num chatRewardsCutoff = chatReceivedData?.thresholds?.last.count ?? 0;
    final num chatRewardsCount = chatReceivedData?.currentCount ?? 0;

    final bool reversePassed = reverseCallCount >= reverseCallCutoff;
    final bool incentivePassed = incentiveCount >= incentiveCutoff;
    final bool chatPassed = chatRewardsCount >= chatRewardsCutoff;
    final bool onlineDurationPassed =
        currentDurationInHours >= onlineDurationCutoff;
    final remainingOnlineDurationInSeconds =
        (onlineDurationCutoff - currentDurationInHours) * 3600;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.only(right: 12.0, left: 12.0, top: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RewardCardWidget(
                title: LocaleKeys.demoReverseCalls.tr,
                isCompleted: reversePassed,
                progress: "$reverseCallCount / $reverseCallCutoff",
                remaining: LocaleKeys.demoRemaining.trParams({
                  'count': '${reverseCallCutoff - reverseCallCount}',
                }),
                imagePath: AssetConstants.reverseCalls,
                onTap:
                    () => Get.to(
                      () => DemoReverseCallListing(
                        reverseCalls: reverseCallsData ?? IncentiveCalls(),
                      ),
                    ),
              ),
              const SizedBox(height: 20.0),
              RewardCardWidget(
                title: LocaleKeys.demo30MinCallReward.tr,
                isCompleted: incentivePassed,
                progress: "$incentiveCount / $incentiveCutoff",
                remaining: LocaleKeys.demoRemaining.trParams({
                  'count': '${incentiveCutoff - incentiveCount}',
                }),
                imagePath: AssetConstants.mins30,
                onTap:
                    () => Get.to(
                      () => DemoIncentiveListing(
                        incentiveCalls: incentiveCallsData ?? IncentiveCalls(),
                      ),
                    ),
              ),
              const SizedBox(height: 20.0),
              RewardCardWidget(
                title: LocaleKeys.demoChatRewards.tr,
                isCompleted: chatPassed,
                progress: "$chatRewardsCount / $chatRewardsCutoff",
                remaining: LocaleKeys.demoRemaining.trParams({
                  'count': '${chatRewardsCutoff - chatRewardsCount}',
                }),
                imagePath: AssetConstants.chatReward,
                onTap:
                    () => Get.to(
                      () => DemoChatRewards(
                        chatReceived: chatReceivedData ?? IncentiveCalls(),
                      ),
                    ),
              ),
              const SizedBox(height: 20.0),
              RewardCardWidget(
                title: LocaleKeys.demoOnlineDuration.tr,
                isCompleted: onlineDurationPassed,
                progress: formatTimeToHoursMinutes(currentDurationInSeconds),
                remaining: LocaleKeys.demoTimeRemaining.trParams({
                  'time': formatTimeToHoursMinutes(
                    remainingOnlineDurationInSeconds,
                  ),
                }),
                imagePath: AssetConstants.onlineDuration,
              ),
              const SizedBox(height: 20.0),
            ],
          ),
        ),
      ],
    );
  }
}

class PassedIcon extends StatelessWidget {
  final bool passed;

  const PassedIcon({super.key, required this.passed});

  @override
  Widget build(BuildContext context) {
    return Visibility(
      child: CircleAvatar(
        radius: 12.0,
        backgroundColor: passed ? Colors.green : Colors.red,
        child: Icon(passed ? Icons.done : Icons.close),
      ),
    );
  }
}
