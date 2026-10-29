import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:voiceclub_partner/core/constants/asset_constants.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/core/services/formatter.dart';
import 'package:voiceclub_partner/data/models/rewards/criteria.dart';
import 'package:voiceclub_partner/data/models/rewards/rewards.dart';

class RewardAmountStatusView extends StatefulWidget {
  final Rewards reward;
  final List<Criteria> criteria;
  final num value;
  final MetricsCutoffTag tag;

  const RewardAmountStatusView({
    super.key,
    required this.reward,
    required this.criteria,
    required this.value,
    required this.tag,
  });

  @override
  State<RewardAmountStatusView> createState() => _RewardAmountStatusViewState();
}

class _RewardAmountStatusViewState extends State<RewardAmountStatusView> {
  bool isRewardEnabled = false;

  @override
  void initState() {
    _checkRewardAvailable();
    super.initState();
  }

  void _checkRewardAvailable() {
    isRewardEnabled = widget.criteria.any((element) {
      num cutoffValue = 0;
      switch (widget.tag) {
        case MetricsCutoffTag.RED:
          cutoffValue = element.cutoffValueRed ?? 0;
          break;
        case MetricsCutoffTag.YELLOW:
          cutoffValue = element.cutoffValueYellow ?? 0;
          break;
        case MetricsCutoffTag.GREEN:
          cutoffValue = element.cutoffValueGreen ?? 0;
          break;
      }
      return cutoffValue <= widget.value;
    });
  }

  num getRewardAmount() {
    final value = widget.value;
    num result = 0.0;

    num getCutoffValue(Criteria element) {
      switch (widget.tag) {
        case MetricsCutoffTag.RED:
          return element.cutoffValueRed ?? 0;
        case MetricsCutoffTag.YELLOW:
          return element.cutoffValueYellow ?? 0;
        case MetricsCutoffTag.GREEN:
          return element.cutoffValueGreen ?? 0;
      }
    }

    if (value < getCutoffValue(widget.criteria.first)) {
      result = widget.criteria.first.rewardAmount ?? 0.0;
    } else {
      result =
          widget.criteria
              .lastWhere((element) => value >= getCutoffValue(element))
              .rewardAmount ??
          0.0;
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 6.0),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      decoration: BoxDecoration(
        color:
            isRewardEnabled
                ? (widget.reward.colorCode ?? "").toColor()
                : const Color(0xFFE9E9E9),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    SvgPicture.asset(
                      AssetConstants.coinIc,
                      height: 20.0,
                      width: 20.0,
                    ),
                    const SizedBox(width: 4.0),
                    Text(
                      Formatter.formatNumValue(getRewardAmount()),
                      style: TextStyle(
                        textBaseline: TextBaseline.alphabetic,
                        fontWeight: FontWeight.w900,
                        fontSize: 36.0,
                        color:
                            isRewardEnabled
                                ? const Color(0xFF4AA611)
                                : const Color(0xFF8B8B8B),
                      ),
                    ),
                    Visibility(
                      visible: !isRewardEnabled,
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Text(
                          " Pending",
                          style: TextStyle(
                            textBaseline: TextBaseline.alphabetic,
                            fontWeight: FontWeight.w900,
                            fontSize: FontSize.xXXL,
                            color:
                                isRewardEnabled
                                    ? const Color(0xFF4AA611)
                                    : const Color(0xFF8B8B8B),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6.0),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    "${Formatter.formatNumValue(getRewardAmount())} will be added to your account",
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color:
                          isRewardEnabled
                              ? const Color(0xFF4AA611)
                              : const Color(0xFF8B8B8B),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8.0),
          SvgPicture.asset(
            isRewardEnabled
                ? AssetConstants.walletIcon
                : AssetConstants.walletGreyIcon,
          ),
        ],
      ),
    );
  }
}
