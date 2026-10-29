import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/core/injection_container.dart';
import 'package:voiceclub_partner/core/services/analytics_service.dart';
import 'package:voiceclub_partner/core/services/formatter.dart';
import 'package:voiceclub_partner/core/services/logger.dart';
import 'package:voiceclub_partner/data/models/account/rewards_stats.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';

enum RewardsProgressBarType { reverseCalls, incentive, chatRewards }

extension RewardsProgressBarTypeExtension on RewardsProgressBarType {
  String get labelText {
    switch (this) {
      case RewardsProgressBarType.reverseCalls:
        return LocaleKeys.liveCalls.tr;
      case RewardsProgressBarType.incentive:
        return LocaleKeys.liveCalls.tr;
      case RewardsProgressBarType.chatRewards:
        return LocaleKeys.liveChats.tr;
    }
  }
}

class RewardsProgressBar extends StatefulWidget {
  final IncentiveCalls rewards;
  final RewardsProgressBarType type;

  const RewardsProgressBar({
    super.key,
    required this.rewards,
    required this.type,
  });

  @override
  State<RewardsProgressBar> createState() => _RewardsProgressBarState();
}

class _RewardsProgressBarState extends State<RewardsProgressBar> {
  List<ProgressStepModel> stepList = <ProgressStepModel>[];

  @override
  void initState() {
    _insertIntoStepList();
    _fireAnalytics();
    super.initState();
  }

  void _fireAnalytics() {
    try {
      sl<AnalyticsService>().trackEvent(
        "${widget.type.name}ProgressBar",
        eventProperties: {
          "amount": widget.rewards.amount,
          "currentCount": widget.rewards.currentCount,
          "cutoffCount":
              widget.rewards.thresholds?.map((e) => e.count).toList(),
          "cutoffAmount":
              widget.rewards.thresholds?.map((e) => e.amount).toList(),
        },
      );
    } catch (e) {
      Logger.logMessage(
        "Error firing analytics for progress bar ${e.toString()}",
      );
    }
  }

  void _insertIntoStepList() {
    final thresholds = widget.rewards.thresholds ?? [];
    final currentCount = widget.rewards.currentCount ?? 0;

    for (var i = 0; i < thresholds.length; i++) {
      final threshold = thresholds[i];
      final thresholdCount = threshold.count ?? 0;
      final rewardAmount = threshold.amount ?? 0;

      stepList.add(
        ProgressStepModel(
          isCompleted: currentCount >= thresholdCount,
          targetCount: thresholdCount,
          rewardAmount: rewardAmount,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (stepList.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: Get.width,
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(color: Colors.grey.withValues(alpha: 0.5), blurRadius: 4.0),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 16.0),
          _buildRewardAmounts(),
          const SizedBox(height: 16.0),
          _buildProgressBar(),
          const SizedBox(height: 10.0),
          _buildThresholdLabels(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final currentCount = widget.rewards.currentCount ?? 0;

    return Text(
      LocaleKeys.liveCompletedProgress.trParams({
        'current': '$currentCount',
        'total': '${widget.rewards.thresholds?.last.count}',
        'label': widget.type.labelText,
      }),
      style: TextStyle(
        fontSize: FontSize.L,
        fontWeight: Weight.heavy,
        color: Colors.grey[600],
      ),
    );
  }

  Widget _buildRewardAmounts() {
    return SizedBox(
      width: double.infinity,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Spacer(),
          for (int i = 0; i < stepList.length; i++)
            _buildRewardAmountWidget(
              rewardAmount: stepList[i].rewardAmount,
              index: i + 1,
            ),
        ],
      ),
    );
  }

  Widget _buildRewardAmountWidget({
    required num rewardAmount,
    required int index,
  }) {
    return Expanded(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          "+₹${Formatter.formatNumValue(rewardAmount)}",
          style: const TextStyle(
            fontSize: FontSize.L,
            fontWeight: FontWeight.bold,
            color: Color(0xFFE74C3C), // Red color from screenshot
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    final currentCount = widget.rewards.currentCount ?? 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Tooltip(
        message: "$currentCount ${widget.type.labelText}",
        triggerMode: TooltipTriggerMode.tap,
        child: SizedBox(
          width: Get.width,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Default start step widget
              _buildStepWidget(isCompleted: true),

              // Add default progress bar to first threshold
              if (stepList.isNotEmpty)
                _buildProgressBarSegment(
                  start: 0,
                  end: stepList.first.targetCount,
                ),

              for (int i = 0; i < stepList.length; i++) ...[
                _buildStepWidget(isCompleted: stepList[i].isCompleted),
                // Add progress till next threshold
                if (i < stepList.length - 1)
                  _buildProgressBarSegment(
                    start: stepList[i].targetCount,
                    end: stepList[i + 1].targetCount,
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThresholdLabels() {
    return SizedBox(
      width: double.infinity,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Spacer(),
          for (int i = 0; i < stepList.length; i++)
            Expanded(
              child: _buildThresholdLabel(
                count: stepList[i].targetCount,
                isCompleted: stepList[i].isCompleted,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildThresholdLabel({required num count, required bool isCompleted}) {
    return Text(
      "${Formatter.formatNumValue(count)} ${widget.type.labelText}",
      style: TextStyle(
        fontSize: 10,
        fontWeight: Weight.heavy,
        color: isCompleted ? Colors.black : Colors.grey,
      ),
      textAlign: TextAlign.center,
    );
  }

  double _calculateProgressValue({required num start, required num end}) {
    final currentCount = widget.rewards.currentCount ?? 0;
    var progressResult = 0.0;

    if (currentCount < start) {
      progressResult = 0.0;
    } else if (currentCount > start && currentCount < end) {
      final startEndDifference = end - start;
      final comparableValue = currentCount - start;
      progressResult = comparableValue / startEndDifference;
    } else if (currentCount >= end) {
      progressResult = 1.0;
    }

    return progressResult;
  }

  Widget _buildProgressBarSegment({required num start, required num end}) {
    return Expanded(
      child: Container(
        decoration: const BoxDecoration(color: Color(0xFFECECEC)),
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: LinearProgressIndicator(
          value: _calculateProgressValue(start: start, end: end),
          valueColor: const AlwaysStoppedAnimation<Color>(
            Color(0xFFE74C3C), // Red color matching the screenshot
          ),
          backgroundColor: const Color(0xFFECECEC),
          minHeight: 8.0,
        ),
      ),
    );
  }

  Widget _buildStepWidget({required bool isCompleted}) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color:
            isCompleted
                ? const Color(0xFFE74C3C) // Red color for completed steps
                : const Color(0xFFECECEC), // Gray for incomplete steps
      ),
      padding: const EdgeInsets.all(10.0),
      child: Container(
        width: 8.0,
        height: 8.0,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
        ),
      ),
    );
  }
}

class ProgressStepModel {
  final bool isCompleted;
  final num targetCount;
  final num rewardAmount;

  ProgressStepModel({
    required this.isCompleted,
    required this.targetCount,
    required this.rewardAmount,
  });
}
