import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/core/injection_container.dart';
import 'package:voiceclub_partner/core/services/analytics_service.dart';
import 'package:voiceclub_partner/modules/controller/tier_controller.dart';

class OnlineDurationBottomSheet extends StatelessWidget {
  const OnlineDurationBottomSheet({super.key});

  double calculateProgressValue({
    required int onlineSeconds,
    required int maxDuration,
  }) {
    final progress = (onlineSeconds / 3600) / maxDuration;
    if (progress > 1.0) {
      return 1.0;
    } else if (progress < 0.0) {
      return 0.0;
    } else {
      return progress;
    }
  }

  String formatTimeToHoursMinutes(int seconds) {
    final hours = (seconds ~/ 3600);
    final minutes = ((seconds % 3600) ~/ 60);

    final formattedHours = hours.toString().padLeft(2, '0');
    final formattedMinutes = minutes.toString().padLeft(2, '0');

    return '${formattedHours}h ${formattedMinutes}m';
  }

  Color getColorFromTime({
    required int seconds,
    required num high,
    required num low,
  }) {
    final int hours = Duration(seconds: seconds).inHours;

    if (hours >= high) {
      return const Color(0xFF4AA611); // Green color for high duration
    } else if (hours >= low) {
      return ApplicationColors.yellow; // Yellow color for medium duration
    } else {
      return ApplicationColors.primaryRed; // Red color for low duration
    }
  }

  String getPriceStringFromTime({
    required int seconds,
    required num high,
    required num low,
    required num penaltyAmount,
    required num rewardAmount,
  }) {
    final int hours = Duration(seconds: seconds).inHours;

    if (hours >= high) {
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

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TierController>(
      builder: (controller) {
        final width = Get.width;
        final tierDetails = controller.weeklyOnlineDuration.value;
        final high = tierDetails.high ?? 50;
        final low = tierDetails.low ?? 40;
        final reward = tierDetails.rewardAmount ?? 500;
        final penalty = tierDetails.penaltyAmount ?? 500;
        final maxDuration = tierDetails.maxDuration?.round() ?? 50;
        final priceColor = getColorFromTime(
          seconds: tierDetails.getThisWeekOnlineDuration,
          high: high,
          low: low,
        );
        sl<AnalyticsService>().trackEvent(
          "partnerBottomSheetOpen",
          eventProperties: {
            "bottomSheetType": "OnlineDurationBottomSheet",
            "durationInHours": (tierDetails.getThisWeekOnlineDuration / 3600),
            "averageWeeklyDurationInHours":
                double.tryParse(
                  controller
                      .weeklyOnlineDuration
                      .value
                      .getThisWeekOnlineAverage,
                ) ??
                0.0,
            "type": "WEEKLY",
          },
        );
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(color: Colors.black12),
            color: Colors.white,
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
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Online Duration This Week',
                                style: TextStyle(
                                  fontSize: FontSize.xL,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5.0),
                                color: priceColor.withValues(alpha: 0.1),
                                border: BorderDirectional(
                                  top: BorderSide(color: priceColor),
                                  bottom: BorderSide(color: priceColor),
                                  start: BorderSide(color: priceColor),
                                  end: BorderSide(color: priceColor),
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              child: Text(
                                getPriceStringFromTime(
                                  seconds:
                                      tierDetails.getThisWeekOnlineDuration,
                                  penaltyAmount: penalty,
                                  rewardAmount: reward,
                                  high: high,
                                  low: low,
                                ),
                                style: TextStyle(
                                  fontSize: FontSize.S,
                                  color: priceColor,
                                  fontWeight: Weight.heavy,
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
                                      onlineSeconds:
                                          tierDetails.getThisWeekOnlineDuration,
                                      maxDuration: maxDuration,
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
                                      onlineSeconds:
                                          tierDetails.getThisWeekOnlineDuration,
                                      maxDuration: maxDuration,
                                    ),
                                  ) ??
                                  Alignment.center,
                              child: Tooltip(
                                triggerMode: TooltipTriggerMode.tap,
                                message: formatTimeToHoursMinutes(
                                  tierDetails.getThisWeekOnlineDuration,
                                ),
                                enableTapToDismiss: false,
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
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8.0,
                          horizontal: 18.0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const CircleAvatar(
                                  backgroundColor: ApplicationColors.primaryRed,
                                  maxRadius: 6,
                                  child: SizedBox(),
                                ),
                                const SizedBox(width: 5),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    FittedBox(
                                      child: Text(
                                        'Below ${low}hr',
                                        style: const TextStyle(
                                          fontSize: FontSize.S,
                                          fontWeight: Weight.heavy,
                                        ),
                                      ),
                                    ),
                                    FittedBox(
                                      child: Text(
                                        '- ₹${penalty.toStringAsFixed(0)}',
                                        style: const TextStyle(
                                          color: ApplicationColors.primaryRed,
                                          fontSize: FontSize.xS,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const CircleAvatar(
                                  backgroundColor: ApplicationColors.yellow,
                                  maxRadius: 6,
                                  child: SizedBox(),
                                ),
                                const SizedBox(width: 5),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    FittedBox(
                                      child: Text(
                                        'Above ${low.toStringAsFixed(0)}hr',
                                        style: const TextStyle(
                                          fontSize: FontSize.S,
                                          fontWeight: Weight.heavy,
                                        ),
                                      ),
                                    ),
                                    const FittedBox(
                                      child: Text(
                                        '₹0',
                                        style: TextStyle(
                                          color: ApplicationColors.yellow,
                                          fontSize: FontSize.xS,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const CircleAvatar(
                                  backgroundColor: Color(0xFF4AA611),
                                  maxRadius: 6,
                                  child: SizedBox(),
                                ),
                                const SizedBox(width: 5),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    FittedBox(
                                      child: Text(
                                        'Above ${high.toStringAsFixed(0)}hr+',
                                        style: const TextStyle(
                                          fontSize: FontSize.S,
                                          fontWeight: Weight.heavy,
                                        ),
                                      ),
                                    ),
                                    FittedBox(
                                      child: Text(
                                        '+ ₹${reward.toStringAsFixed(0)}',
                                        style: const TextStyle(
                                          color: Color(0xFF4AA611),
                                          fontSize: FontSize.xS,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
        );
      },
    );
  }
}
