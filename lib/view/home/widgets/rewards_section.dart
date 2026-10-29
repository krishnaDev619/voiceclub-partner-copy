import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/modules/controller/multi_reward_controller.dart';
import 'package:voiceclub_partner/modules/controller/user_controller.dart';
import 'package:voiceclub_partner/view/home/widgets/daily_rewards_section.dart';
import 'package:voiceclub_partner/view/home/widgets/metrics_section.dart';
import 'package:voiceclub_partner/view/home/widgets/multi_reward_section.dart';
import 'package:voiceclub_partner/view/tutorial/demo/widgets/core/disabled_widget.dart';

class RewardsSection extends StatelessWidget {
  const RewardsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final userController = Get.find<UserController>();
    final multiRewardController = Get.find<MultiRewardController>();

    return multiRewardController.isRewardActive
        ? Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(width: 16.0),
                const SizedBox(width: 170, child: MultiRewardSection()),
                const SizedBox(width: 10.0),
                SizedBox(
                  width: 170,
                  child: Disabled(
                    disabled: userController.currentStage.isLessThan(
                      TutorialStage.S3,
                    ),
                    child: const DailyRewardsSection(),
                  ),
                ),
                const SizedBox(width: 10.0),
                const SizedBox(width: 170, child: MetricsSection()),
                const SizedBox(width: 16.0),
              ],
            ),
          ),
        )
        : Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0),
          child: Row(
            children: [
              Expanded(
                child: Disabled(
                  disabled: userController.currentStage.isLessThan(
                    TutorialStage.S3,
                  ),
                  child: const DailyRewardsSection(),
                ),
              ),
              const SizedBox(width: 8.0),
              const Expanded(child: MetricsSection()),
            ],
          ),
        );
  }
}
