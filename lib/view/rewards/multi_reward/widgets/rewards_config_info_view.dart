import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/data/models/rewards/rewards.dart';
import 'package:voiceclub_partner/modules/controller/multi_reward_controller.dart';

class RewardsConfigInfoView extends StatefulWidget {
  final Rewards ds;

  const RewardsConfigInfoView({super.key, required this.ds});

  @override
  State<RewardsConfigInfoView> createState() => _RewardsConfigInfoViewState();
}

class _RewardsConfigInfoViewState extends State<RewardsConfigInfoView> {
  final controller = Get.find<MultiRewardController>();

  @override
  void initState() {
    super.initState();
    controller.fetchRewardsConfig();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.fetchingRewardsConfig.value) {
        return const SizedBox.shrink();
      }
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 30.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: (widget.ds.colorCode ?? "").toColor(),
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: (widget.ds.colorCode ?? "").toColor(),
            width: 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.grey, size: 20.0),
                SizedBox(width: 8.0),
                Text(
                  'Reward Info',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12.0),
            if (widget.ds.rewardId == 20 &&
                controller.rewardsConfig.value?.peakHourRewardStartTime !=
                    null &&
                controller.rewardsConfig.value?.peakHourRewardEndTime != null)
              _buildInfoRow(
                'Peak Hours',
                '${DateFormat("hh:mm a").format(controller.rewardsConfig.value?.peakHourRewardStartTime?.toDateTime()?.toLocal() ?? DateTime.now())} - ${DateFormat("hh:mm a").format(controller.rewardsConfig.value?.peakHourRewardEndTime?.toDateTime()?.toLocal() ?? DateTime.now())}',
              ),
            if (widget.ds.rewardId == 21 &&
                controller.rewardsConfig.value?.callDurationThreshold != null)
              _buildInfoRow(
                'Call Duration',
                '${(controller.rewardsConfig.value?.callDurationThreshold ?? 0) / 60} minutes',
              ),
          ],
        ),
      );
    });
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          const SizedBox(width: 4.0),
          const Text(":"),
          const SizedBox(width: 4.0),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
