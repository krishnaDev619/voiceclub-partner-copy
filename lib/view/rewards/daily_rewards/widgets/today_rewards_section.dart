import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/core/constants/asset_constants.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/core/injection_container.dart';
import 'package:voiceclub_partner/core/services/analytics_service.dart';
import 'package:voiceclub_partner/modules/bindings/reverse_call_list_binding.dart';
import 'package:voiceclub_partner/modules/controller/rewards_controller.dart';
import 'package:voiceclub_partner/modules/controller/user_controller.dart';
import 'package:voiceclub_partner/view/activity_new/incentive_screen.dart';
import 'package:voiceclub_partner/view/rewards/daily_rewards/widgets/chat_rewards.dart';
import 'package:voiceclub_partner/view/rewards/daily_rewards/widgets/reverse_call_listing.dart';
import 'package:voiceclub_partner/view/rewards/daily_rewards/widgets/reward_card_widget.dart';
import 'package:voiceclub_partner/view/widgets/two_cutoff_online_duration_bottom_sheet.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';

class TodayRewardsSection extends StatelessWidget {
  const TodayRewardsSection({super.key});

  Color getRewardsColor({required bool allPassed}) {
    if (allPassed) {
      return const Color(0xFF4AA611); // Green color for passed state
    } else {
      return ApplicationColors.primaryRed; // Red color for failed state
    }
  }

  String formatTimeToHoursMinutes(num seconds) {
    final int hours = seconds ~/ 3600;
    final int minutes = (seconds % 3600) ~/ 60;

    if (hours > 0 && minutes > 0) {
      return "$hours hrs $minutes m";
    } else if (hours > 0) {
      return "$hours hrs";
    } else {
      return "$minutes m";
    }
  }

  @override
  Widget build(BuildContext context) {
    final userController = Get.find<UserController>();
    final rewardsController = Get.find<RewardsController>();

    return Obx(() {
      final reverseCallsData =
          rewardsController.rewardsStats.value?.reverseCalls;
      final incentiveCallsData =
          rewardsController.rewardsStats.value?.incentiveCalls;
      final chatRewardsData =
          rewardsController.rewardsStats.value?.chatReceived;

      final twoCutoffonlineDurationData =
          rewardsController.rewardsStats.value?.onlineDuration;

      final isLeave = userController.isOnLeave;
      final currentDurationInHours =
          twoCutoffonlineDurationData?.currentHours ?? 0.0;

      final currentDurationInSeconds = currentDurationInHours * 3600;

      final onlineDurationCutoff =
          twoCutoffonlineDurationData?.rewardThreshold ?? 7;

      final num reverseCallCutoff =
          reverseCallsData?.thresholds?.last.count ?? 0;

      final num reverseCallCount = reverseCallsData?.currentCount ?? 0;

      final num incentiveCutoff =
          incentiveCallsData?.thresholds?.last.count ?? 0;

      final num incentiveCount = incentiveCallsData?.currentCount ?? 0;

      final num chatRewardsCutoff =
          chatRewardsData?.thresholds?.last.count ?? 0;

      final num chatRewardsCount = chatRewardsData?.currentCount ?? 0;

      final bool reversePassed = reverseCallCount >= reverseCallCutoff;
      final bool incentivePassed = incentiveCount >= incentiveCutoff;
      final bool chatPassed = chatRewardsCount >= chatRewardsCutoff;

      final bool onlineDurationPassed =
          currentDurationInHours >= onlineDurationCutoff;

      final remainingOnlineDurationInSeconds =
          (onlineDurationCutoff - currentDurationInHours) * 3600;

      final bool allPassed =
          reversePassed &&
          incentivePassed &&
          onlineDurationPassed &&
          chatPassed;

      final getCurrentEligibleReward = userController.getCurrentEligibleReward;

      sl<AnalyticsService>().trackEvent(
        "dailyRewardsData",
        eventProperties: {
          "reverseStagePassed": reversePassed,
          "incentiveStagePassed": incentivePassed,
          "onlineDurationStagePassed": onlineDurationPassed,
          "chatPassed": chatPassed,
          "reverseCallCount": reverseCallCount,
          "incentiveCount": incentiveCount,
          "chatRewardsCount": chatRewardsCount,
          "currentDurationInHours": currentDurationInHours,
          "reverseStageCutoff": reverseCallCutoff,
          "incentiveStageCutoff": incentiveCutoff,
          "onlineDurationStage": onlineDurationCutoff,
          "chatRewardsCutoff": chatRewardsCutoff,
          "allPassed": allPassed,
          "isLeave": isLeave,
          "currentEligibleReward": getCurrentEligibleReward,
        },
      );
      if (isLeave) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Transform.translate(
              offset: const Offset(20, 0),
              child: SvgPicture.asset(AssetConstants.leave, height: 100.0),
            ),
            const SizedBox(height: 16.0),
            Text(
              LocaleKeys.liveOnLeaveToday.tr,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 6.0),
            Text(
              LocaleKeys.liveNoRewardsOnLeave.tr,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14.0, color: Colors.red),
            ),
            const SizedBox(height: 100.0),
          ],
        );
      }

      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(
                right: 12.0,
                left: 12.0,
                top: 16.0,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RewardCardWidget(
                    title: LocaleKeys.liveReverseCalls.tr,
                    isCompleted: reversePassed,
                    progress: "$reverseCallCount / $reverseCallCutoff",
                    remaining: LocaleKeys.liveCountRemaining.trParams({
                      'count': '${reverseCallCutoff - reverseCallCount}',
                    }),
                    imagePath: AssetConstants.reverseCalls,
                    onTap:
                        () => Get.to(
                          () => const ReverseCallListing(),
                          binding: ReverseCallListBinding(),
                        ),
                  ),
                  const SizedBox(height: 20.0),
                  RewardCardWidget(
                    title: LocaleKeys.live30MinCallReward.tr,
                    isCompleted: incentivePassed,
                    progress: "$incentiveCount / $incentiveCutoff",
                    remaining: LocaleKeys.liveCountRemaining.trParams({
                      'count': '${incentiveCutoff - incentiveCount}',
                    }),
                    imagePath: AssetConstants.mins30,
                    onTap: () => Get.to(() => const IncentiveListing()),
                  ),
                  const SizedBox(height: 20.0),
                  RewardCardWidget(
                    title: LocaleKeys.liveChatRewards.tr,
                    isCompleted: chatPassed,
                    progress: "$chatRewardsCount / $chatRewardsCutoff",
                    remaining: LocaleKeys.liveCountRemaining.trParams({
                      'count': '${chatRewardsCutoff - chatRewardsCount}',
                    }),
                    imagePath: AssetConstants.chatReward,
                    onTap: () => Get.to(() => const ChatRewards()),
                  ),
                  const SizedBox(height: 20.0),
                  RewardCardWidget(
                    title: LocaleKeys.liveOnlineDuration.tr,
                    isCompleted: onlineDurationPassed,
                    progress: formatTimeToHoursMinutes(
                      currentDurationInSeconds,
                    ),
                    remaining: LocaleKeys.liveCountRemaining.trParams({
                      'count': formatTimeToHoursMinutes(
                        remainingOnlineDurationInSeconds,
                      ),
                    }),
                    imagePath: AssetConstants.onlineDuration,
                    onTap: () {
                      Get.bottomSheet(
                        TwoCutoffOnlineDurationBottomSheet(),
                        isScrollControlled: true,
                      );
                    },
                  ),
                  const SizedBox(height: 20.0),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}

class PassedIcon extends StatelessWidget {
  final bool passed;

  const PassedIcon({super.key, required this.passed});

  @override
  Widget build(BuildContext context) {
    return Visibility(
      child: CircleAvatar(
        radius: 15.0,
        backgroundColor: passed ? Colors.green : Colors.red,
        child: Icon(passed ? Icons.done : Icons.close),
      ),
    );
  }
}
