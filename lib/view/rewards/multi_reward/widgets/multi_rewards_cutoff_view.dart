import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/core/injection_container.dart';
import 'package:voiceclub_partner/core/services/analytics_service.dart';
import 'package:voiceclub_partner/core/services/formatter.dart';
import 'package:voiceclub_partner/data/models/rewards/rewards.dart';
import 'package:voiceclub_partner/modules/controller/multi_reward_controller.dart';
import 'package:voiceclub_partner/view/rewards/multi_reward/widgets/reward_amount_status_view.dart';
import 'package:voiceclub_partner/view/rewards/multi_reward/widgets/stepper_widget.dart';

class MultiRewardsCutoffView extends StatefulWidget {
  final Rewards reward;

  const MultiRewardsCutoffView({super.key, required this.reward});

  @override
  State<MultiRewardsCutoffView> createState() => _MultiRewardsCutoffViewState();
}

class _MultiRewardsCutoffViewState extends State<MultiRewardsCutoffView> {
  final multiRewardController = Get.find<MultiRewardController>();
  bool isEventFired = false;

  @override
  void initState() {
    multiRewardController.fetchCutoffRewards(id: widget.reward.rewardId ?? 0);
    super.initState();
  }

  void fireLeaderboardEvent({required num value}) {
    sl<AnalyticsService>().trackEvent(
      "multiRewardsScreen",
      eventProperties: {
        "name": widget.reward.name,
        "rewardType": widget.reward.type?.name,
        "value": value,
      },
    );
    isEventFired = true;
  }

  void checkAndFireLeaderboardEvent({required num value}) {
    if (!isEventFired) {
      fireLeaderboardEvent(value: value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final cutoffResponse = multiRewardController.rewardsCutoffResponse.value;
      if (multiRewardController.fetchingCutoffRewards.value) {
        return const Expanded(
          child: Center(child: CircularProgressIndicator()),
        );
      }
      if (cutoffResponse.criteria?.isEmpty ?? false) {
        return const Expanded(
          child: Center(
            child: Text(
              "No rewards found.",
              style: TextStyle(fontSize: FontSize.xXL),
            ),
          ),
        );
      }
      checkAndFireLeaderboardEvent(value: cutoffResponse.value ?? 0);
      return Column(
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 6.0),
            decoration: BoxDecoration(
              color: (widget.reward.colorCode ?? "").toColor(),
              borderRadius: BorderRadius.circular(18.0),
              boxShadow: [
                BoxShadow(
                  offset: const Offset(4, 4),
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 6.0,
                ),
                BoxShadow(
                  offset: const Offset(-4, -4),
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 6.0,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.reward.name ?? "",
                        style: const TextStyle(
                          fontWeight: Weight.heavy,
                          fontSize: FontSize.xXXL,
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        "Completed : ${Formatter.formatNumValue(cutoffResponse.value)} ${widget.reward.unit.toString().capitalizeFirst}",
                        style: const TextStyle(
                          fontSize: FontSize.xL,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF757070),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8.0),
                StepperWidget(
                  reward: widget.reward,
                  criteria: cutoffResponse.criteria ?? [],
                  value: cutoffResponse.value ?? 0,
                  tag: cutoffResponse.tag,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20.0),
          RewardAmountStatusView(
            reward: widget.reward,
            criteria: cutoffResponse.criteria ?? [],
            value: cutoffResponse.value ?? 0,
            tag: cutoffResponse.tag ?? MetricsCutoffTag.RED,
          ),
        ],
      );
    });
  }
}
