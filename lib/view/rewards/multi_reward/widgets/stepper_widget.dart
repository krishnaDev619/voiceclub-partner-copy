import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:voiceclub_partner/core/constants/asset_constants.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/core/services/formatter.dart';
import 'package:voiceclub_partner/data/models/rewards/criteria.dart';
import 'package:voiceclub_partner/data/models/rewards/rewards.dart';

class StepperWidget extends StatefulWidget {
  final Rewards reward;
  final List<Criteria> criteria;
  final MetricsCutoffTag? tag;
  final num value;

  const StepperWidget({
    super.key,
    required this.reward,
    required this.criteria,
    required this.value,
    this.tag,
  });

  @override
  State<StepperWidget> createState() => _StepperWidgetState();
}

class _StepperWidgetState extends State<StepperWidget> {
  List<StepModel> stepList = <StepModel>[];
  var progressValue = 0.0;
  final _scrollController = ScrollController();

  @override
  void initState() {
    _insertIntoStepList();
    super.initState();
  }

  void _insertIntoStepList() {
    for (var e in widget.criteria) {
      num cutoffValue = 0;
      switch (widget.tag) {
        case MetricsCutoffTag.RED:
          cutoffValue = e.cutoffValueRed ?? 0;
          break;
        case MetricsCutoffTag.YELLOW:
          cutoffValue = e.cutoffValueYellow ?? 0;
          break;
        case MetricsCutoffTag.GREEN:
          cutoffValue = e.cutoffValueGreen ?? 0;
          break;
        default:
          cutoffValue = e.cutoffValueRed ?? 0;
      }

      stepList.add(
        StepModel(
          isCompleted: widget.value >= cutoffValue,
          rewardCutoff: cutoffValue,
          rewardAmount: e.rewardAmount ?? 0,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SingleChildScrollView(
          controller: _scrollController,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Spacer(),
              for (int i = 0; i < stepList.length; i++)
                rewardAmountWidget(
                  rewardAmount:
                      i == 0
                          ? stepList[i].rewardAmount
                          : stepList[i].rewardAmount -
                              stepList[i - 1].rewardAmount,
                  index: i + 1,
                ),
            ],
          ),
        ),
        const SizedBox(height: 16.0),
        SingleChildScrollView(
          controller: _scrollController,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Tooltip(
              message:
                  "${Formatter.formatNumValue(widget.value)} ${widget.reward.unit}",
              triggerMode: TooltipTriggerMode.tap,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Default step widget
                  stepWidget(isCompleted: true),

                  // Add default progress bar end
                  progressBar(start: 0, end: stepList.first.rewardCutoff),

                  for (int i = 0; i < stepList.length; i++) ...[
                    stepWidget(isCompleted: stepList[i].isCompleted),
                    // Add progress till end
                    if (i < stepList.length - 1)
                      progressBar(
                        start: stepList[i].rewardCutoff,
                        end: stepList[i + 1].rewardCutoff,
                      ),
                  ],
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 10.0),
        SingleChildScrollView(
          controller: _scrollController,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Spacer(),
              for (int i = 0; i < stepList.length; i++)
                Expanded(
                  child: rewardCutoffWidget(
                    isCompleted: stepList[i].isCompleted,
                    rewardCutoff: stepList[i].rewardCutoff,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 20.0),
      ],
    );
  }

  Widget rewardAmountWidget({
    required num rewardAmount,
    required int index,
    bool isDefault = false,
  }) {
    return Expanded(
      child: SizedBox(
        width: 130.0,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Visibility(
                visible: !isDefault,
                replacement: const SizedBox(height: 0.0, width: 40.0),
                child: SvgPicture.asset(
                  AssetConstants.coinIc,
                  height: 20.0,
                  width: 20.0,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 4.0),
              Text(
                "+${Formatter.formatNumValue(rewardAmount)}",
                style: const TextStyle(
                  fontSize: FontSize.L,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4.0),
            ],
          ),
        ),
      ),
    );
  }

  Widget rewardCutoffWidget({
    required num rewardCutoff,
    required bool isCompleted,
    bool isDefault = false,
  }) {
    return Text(
      "${Formatter.formatNumValue(rewardCutoff)} ${widget.reward.unit}",
      style: TextStyle(
        fontSize: 10,
        fontWeight: Weight.heavy,
        color: isCompleted ? Colors.black : Colors.grey,
      ),
      textAlign: TextAlign.center,
    );
  }

  double calculateProgressValue({required num start, required num end}) {
    final actualValue = widget.value;
    var progressResult = 0.0;

    if (actualValue < start) {
      progressResult = 0.0;
    } else if (actualValue > start && actualValue < end) {
      final startEndDifference = end - start;
      final comparableValue = actualValue - start;
      progressResult = comparableValue / startEndDifference;
    } else if (actualValue >= end) {
      progressResult = 1.0;
    }

    return progressResult;
  }

  Widget progressBar({required num start, required num end}) {
    return Expanded(
      child: Container(
        decoration: const BoxDecoration(color: Color(0xFFECECEC)),
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: LinearProgressIndicator(
          value: calculateProgressValue(start: start, end: end),
          valueColor: AlwaysStoppedAnimation<Color>(
            (widget.reward.colorCodeDark ?? "").toColor(),
          ),
          backgroundColor: const Color(0xFFECECEC),
          minHeight: 8.0,
        ),
      ),
    );
  }

  Widget stepWidget({required bool isCompleted}) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color:
            isCompleted
                ? (widget.reward.colorCodeDark ?? "").toColor()
                : const Color(0xFFECECEC),
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

class StepModel {
  final bool isCompleted;
  final num rewardCutoff;
  final num rewardAmount;
  final bool isFirst;

  StepModel({
    required this.isCompleted,
    required this.rewardCutoff,
    required this.rewardAmount,
    this.isFirst = false,
  });
}
