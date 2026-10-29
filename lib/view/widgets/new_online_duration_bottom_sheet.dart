import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';
import 'package:intl/intl.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/core/injection_container.dart';
import 'package:voiceclub_partner/core/services/analytics_service.dart';
import 'package:voiceclub_partner/modules/controller/tier_controller.dart';
import 'package:voiceclub_partner/modules/controller/user_controller.dart';
import 'dart:math' as math;

class NewOnlineDurationBottomSheet extends StatefulWidget {
  const NewOnlineDurationBottomSheet({super.key});

  @override
  State<NewOnlineDurationBottomSheet> createState() =>
      _NewOnlineDurationBottomSheetState();
}

class _NewOnlineDurationBottomSheetState
    extends State<NewOnlineDurationBottomSheet> {
  bool isExpanded = false;

  double calculateProgressValue({
    required num onlineDurationInHours,
    required num maxDurationInHours,
  }) {
    final progress = (onlineDurationInHours) / (maxDurationInHours);
    if (progress > 1.0) {
      return 1.0;
    } else if (progress < 0.0) {
      return 0.0;
    } else {
      return progress;
    }
  }

  String formatTimeToHoursMinutes(num seconds) {
    final hours = (seconds ~/ 3600);
    final minutes = ((seconds % 3600) ~/ 60);

    final formattedHours = hours.toString().padLeft(2, '0');
    final formattedMinutes = minutes.toString().padLeft(2, '0');

    return '${formattedHours}h ${formattedMinutes}m';
  }

  Color getCurrentSlabColor({
    required List<CutoffSlabs> list,
    required int seconds,
  }) {
    final int hours = Duration(seconds: seconds).inHours;
    Color color =
        list.firstWhereOrNull((element) => hours >= element.cutoff)?.color ??
        Get.theme.primaryColor;
    return color;
  }

  String getPriceStringFromTime({
    required int seconds,
    required num veryHigh,
    required num high,
    required num low,
    required num penaltyAmount,
    required num rewardAmount,
    required num highRewardAmount,
  }) {
    final int hours = Duration(seconds: seconds).inHours;

    if (hours >= veryHigh) {
      return "+ ₹${highRewardAmount.toStringAsFixed(0)}"; // Formats the bonus amount without decimal points
    } else if (hours >= high) {
      return "+ ₹${rewardAmount.toStringAsFixed(0)}"; // Formats the reward amount without decimal points
    } else if (hours >= low) {
      return "₹0";
    } else {
      return "- ₹${penaltyAmount.toStringAsFixed(0)}"; // Formats the penalty amount without decimal points
    }
  }

  List<int> divideIntoIntervals({required int maxDuration}) {
    List<int> intervals = [];
    int step =
        maxDuration ~/
        5; // Integer division to split into 5 equal parts between 0 and number.

    for (int i = 0; i <= 5; i++) {
      intervals.add(i * step);
    }

    // Ensure the last element is exactly the input number
    if (intervals.last != maxDuration) {
      intervals.last = maxDuration;
    }

    return intervals;
  }

  String getSlabTitle(RewardsType rewardsType, num rewardCutoff) {
    switch (rewardsType) {
      case RewardsType.Reward:
        return LocaleKeys.liveAboveHours.trParams({'hours': '$rewardCutoff'});
      case RewardsType.Penalty:
        return LocaleKeys.liveBelowHours.trParams({'hours': '$rewardCutoff'});
      case RewardsType.Pending:
        return LocaleKeys.liveAboveHours.trParams({'hours': '$rewardCutoff'});
    }
  }

  String getSlabSubtitle(RewardsType rewardsType, num reward) {
    switch (rewardsType) {
      case RewardsType.Reward:
        return "+ ₹$reward";
      case RewardsType.Penalty:
        return "- ₹$reward";
      case RewardsType.Pending:
        return "₹0";
    }
  }

  Color getSlabColors(RewardsType rewardsType, int index) {
    List<Color> predefinedColors = [
      const Color(0xFF4AA611),
      const Color(0xFF112FA6),
      Colors.deepOrange,
      Colors.deepPurple,
      Colors.greenAccent,
    ];
    switch (rewardsType) {
      case RewardsType.Reward:
        if (index < predefinedColors.length) {
          return predefinedColors[index];
        } else {
          return Color(
            (math.Random().nextDouble() * 0xFFFFFF).toInt(),
          ).withValues(
            alpha: 1.0,
          ); // Random color if predefined colors are exhausted
        }
      case RewardsType.Penalty:
        return ApplicationColors.primaryRed;
      case RewardsType.Pending:
        return ApplicationColors.yellow;
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TierController>();
    final userController = Get.find<UserController>();
    return SafeArea(
      child: Obx(() {
        final width = Get.width;
        // final tierDetails = controller.myTierDetails.value;
        final currentOnlineDurationDetails =
            userController.currentOnlineDuration.value;
        final currentDurationInHours =
            (currentOnlineDurationDetails.duration ?? 0);
        final currentDurationInSeconds = currentDurationInHours * 3600;
        final maxDuration =
            currentOnlineDurationDetails.maxDuration?.round() ?? 10;
        final resultMap = userController.getCutoffList;
        final priceColor = userController.getCurrentSlabColor;

        sl<AnalyticsService>().trackEvent(
          "partnerBottomSheetOpen",
          eventProperties: {
            "bottomSheetType": "NewOnlineDurationBottomSheet",
            "durationInHours": currentDurationInHours,
            "averageWeeklyDurationInHours":
                double.tryParse(
                  controller
                      .weeklyOnlineDuration
                      .value
                      .getThisWeekOnlineAverage,
                ) ??
                0.0,
            "type": "DAILY",
          },
        );
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16.0),
              topRight: Radius.circular(16.0),
            ),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                blurRadius: 5,
                spreadRadius: 1,
                color: Colors.black.withValues(alpha: 0.1),
              ),
            ],
          ),
          child:
              controller.isLoading.value
                  ? SizedBox(
                    height: 20.0,
                    width: 20.0,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.8,
                      color: Get.theme.primaryColor,
                    ),
                  )
                  : Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 10.0),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Today's Online Duration",
                                style: TextStyle(
                                  fontSize: FontSize.xL,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        width: width - 8.0,
                        height: 16.0,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: width - 8.0,
                              height: 6.0,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  LinearProgressIndicator(
                                    value: calculateProgressValue(
                                      onlineDurationInHours:
                                          currentDurationInHours,
                                      maxDurationInHours: maxDuration,
                                    ),
                                    backgroundColor: const Color(0xFFE4E4E4),
                                    color: priceColor,
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      for (int i = 0; i < 4; i++)
                                        Container(
                                          height: 6.0,
                                          width: 1.5,
                                          color: Colors.white,
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Align(
                              alignment:
                                  Alignment.lerp(
                                    Alignment.centerLeft,
                                    Alignment.centerRight,
                                    calculateProgressValue(
                                      onlineDurationInHours:
                                          currentDurationInHours,
                                      maxDurationInHours: maxDuration,
                                    ),
                                  ) ??
                                  Alignment.center,
                              child: Tooltip(
                                triggerMode: TooltipTriggerMode.tap,
                                message: formatTimeToHoursMinutes(
                                  currentDurationInSeconds,
                                ),
                                showDuration: const Duration(seconds: 3),
                                child: Container(
                                  padding: const EdgeInsets.all(1.0),
                                  decoration: BoxDecoration(
                                    color: priceColor,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Container(
                                    height: 16.0,
                                    width: 16.0,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: priceColor,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 1.0,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 5.0),
                      SizedBox(
                        width: width - 16.0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children:
                              divideIntoIntervals(maxDuration: maxDuration)
                                  .map(
                                    (hr) => SizedBox(
                                      height: 16.0,
                                      child: Text(
                                        '${hr}hr${hr < 10 ? " " : ""}',
                                        textAlign: TextAlign.center,
                                        maxLines: 1,
                                        style: TextStyle(
                                          fontSize: FontSize.xS,
                                          color: Get.theme.primaryColor,
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      SizedBox(
                        height: 50.0,
                        child: ListView.builder(
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(
                            vertical: 8.0,
                            horizontal: 8.0,
                          ),
                          itemCount: resultMap.length,
                          itemBuilder: (context, index) {
                            final e = resultMap[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6.0,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CircleAvatar(
                                    backgroundColor: e.color,
                                    maxRadius: 6,
                                    child: const SizedBox(),
                                  ),
                                  const SizedBox(width: 5),
                                  Flexible(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        FittedBox(
                                          child: Text(
                                            getSlabTitle(
                                              e.rewardsType,
                                              e.cutoff,
                                            ),
                                            style: const TextStyle(
                                              fontSize: FontSize.S,
                                              fontWeight: Weight.heavy,
                                            ),
                                          ),
                                        ),
                                        FittedBox(
                                          child: Text(
                                            getSlabSubtitle(
                                              e.rewardsType,
                                              e.rewards,
                                            ),
                                            style: TextStyle(
                                              color: e.color,
                                              fontSize: FontSize.xS,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Today's Date: ${DateFormat("dd/MM/yy").format(DateTime.now())}",
                              style: const TextStyle(
                                color: Colors.black45,
                                fontSize: FontSize.S,
                              ),
                            ),
                            Text(
                              "Average: ${controller.weeklyOnlineDuration.value.getThisWeekOnlineAverage} hrs/day",
                              style: const TextStyle(
                                color: Colors.black45,
                                fontSize: FontSize.S,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12.0),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                isExpanded = !isExpanded;
                              });
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "Weekly Online Duration",
                                  style: TextStyle(
                                    color: Get.theme.primaryColor,
                                    decoration: TextDecoration.underline,
                                    decorationColor: Get.theme.primaryColor,
                                    fontSize: FontSize.xL,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 2.0),
                                  child: Icon(
                                    isExpanded
                                        ? Icons.keyboard_arrow_up_rounded
                                        : Icons.keyboard_arrow_down_rounded,
                                    color: Get.theme.primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(
                          top: 12.0,
                          bottom: 8.0,
                          left: 16.0,
                          right: 16.0,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.all(
                            Radius.circular(16.0),
                          ),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 5,
                              spreadRadius: 1,
                              color: Colors.black.withValues(alpha: 0.1),
                            ),
                          ],
                        ),
                        child: Visibility(
                          visible: isExpanded,
                          maintainState: true,
                          child: ListView.separated(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              final day =
                                  DayOfWeekExtensions.getPreviousWeekSorted()[index];
                              final durationInSeconds =
                                  (controller
                                          .weeklyOnlineDuration
                                          .value
                                          .onlineDuration?[day] ??
                                      0) *
                                  3600;
                              return ListTile(
                                title: Text(day.name),
                                visualDensity: VisualDensity.compact,
                                dense: true,
                                subtitle: Text(
                                  DateFormat(
                                    'dd/MM/yy',
                                  ).format(day.getCorrespondingDate()),
                                  style: const TextStyle(
                                    fontSize: FontSize.S,
                                    color: Colors.grey,
                                  ),
                                ),
                                trailing: Text(
                                  formatTimeToHoursMinutes(
                                    durationInSeconds.round(),
                                  ),
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            },
                            separatorBuilder:
                                (_, _) => const Divider(
                                  height: 0.0,
                                  endIndent: 16.0,
                                  indent: 16.0,
                                  thickness: 1.0,
                                ),
                            itemCount:
                                DayOfWeekExtensions.getPreviousWeekSorted()
                                    .length,
                          ),
                        ),
                      ),
                    ],
                  ),
        );
      }),
    );
  }
}

class CutoffSlabs {
  final num rewards;
  final num cutoff;
  final RewardsType rewardsType;
  final Color color;

  CutoffSlabs(this.rewards, this.cutoff, this.rewardsType, this.color);
}
