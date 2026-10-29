import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/core/injection_container.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/core/services/analytics_service.dart';
import 'package:voiceclub_partner/data/models/account/rewards_stats.dart';
import 'package:voiceclub_partner/domain/usecases/account/get_rewards_stats.dart';
import 'package:voiceclub_partner/modules/controller/tier_controller.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';

class TwoCutoffOnlineDurationBottomSheet extends StatefulWidget {
  const TwoCutoffOnlineDurationBottomSheet({super.key});

  @override
  State<TwoCutoffOnlineDurationBottomSheet> createState() =>
      _TwoCutoffOnlineDurationBottomSheetState();
}

class _TwoCutoffOnlineDurationBottomSheetState
    extends State<TwoCutoffOnlineDurationBottomSheet> {
  bool isExpanded = false;
  bool isLoading = true;
  OnlineDuration? onlineDurationData;
  String? errorMessage;
  final controller = Get.find<TierController>();

  @override
  void initState() {
    super.initState();
    _fetchRewardsStats();
  }

  Future<void> _fetchRewardsStats() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final response = await sl<GetRewardsStatsUseCase>().call(NoParams());

      if (response.data != null) {
        setState(() {
          onlineDurationData = response.data!.onlineDuration;
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = LocaleKeys.liveFailedToLoadData.tr;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = LocaleKeys.liveErrorDetail.trParams({
          'detail': e.toString(),
        });
        isLoading = false;
      });
    }
  }

  double calculateProgressValue({
    required num currentHours,
    required num maxHours,
  }) {
    final progress = currentHours / maxHours;
    if (progress > 1.0) {
      return 1.0;
    } else if (progress < 0.0) {
      return 0.0;
    } else {
      return progress;
    }
  }

  String formatHours(num hours) {
    return '${hours}h';
  }

  Color getCurrentSlabColor({
    required num currentHours,
    required num penaltyThreshold,
    required num rewardThreshold,
  }) {
    if (currentHours >= rewardThreshold) {
      return const Color(0xFF4AA611); // Green for reward
    } else if (currentHours >= penaltyThreshold) {
      return const Color(0xFFFFA500); // Orange for neutral
    } else {
      return const Color(0xFFFF6B6B); // Red for penalty
    }
  }

  List<DurationSlab> _buildDurationSlabs() {
    if (onlineDurationData == null) return [];

    final penaltyThreshold = onlineDurationData!.penaltyThreshold ?? 4;
    final rewardThreshold = onlineDurationData!.rewardThreshold ?? 8;
    final penaltyAmount = onlineDurationData!.penaltyAmount ?? 50;
    final rewardAmount = onlineDurationData!.rewardAmount ?? 30;

    return [
      DurationSlab(
        title: LocaleKeys.liveBelowHours.trParams({
          'hours': '$penaltyThreshold',
        }),
        amount: '- ₹$penaltyAmount',
        color: const Color(0xFFFF6B6B),
        type: SlabType.penalty,
      ),
      DurationSlab(
        title: LocaleKeys.liveHourRange.trParams({
          'low': '$penaltyThreshold',
          'high': '$rewardThreshold',
        }),
        amount: '₹0',
        color: const Color(0xFFFFA500),
        type: SlabType.neutral,
      ),
      DurationSlab(
        title: LocaleKeys.liveAboveHoursPlus.trParams({
          'hours': '$rewardThreshold',
        }),
        amount: '+ ₹$rewardAmount',
        color: const Color(0xFF4AA611),
        type: SlabType.reward,
      ),
    ];
  }

  List<num> _generateProgressMarkers() {
    if (onlineDurationData == null) return [0, 4, 8];

    final penaltyThreshold = onlineDurationData!.penaltyThreshold ?? 4;
    final rewardThreshold = onlineDurationData!.rewardThreshold ?? 8;
    final maxDuration =
        rewardThreshold + 2; // Show a bit beyond reward threshold

    return [0, penaltyThreshold, rewardThreshold, maxDuration];
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
    final width = Get.width;

    // Track analytics
    if (onlineDurationData != null) {
      sl<AnalyticsService>().trackEvent(
        "partnerBottomSheetOpen",
        eventProperties: {
          "bottomSheetType": "SimplifiedOnlineDurationBottomSheet",
          "currentHours": onlineDurationData!.currentHours ?? 0,
          "status": onlineDurationData!.status ?? '',
          "amount": onlineDurationData!.amount ?? 0,
        },
      );
    }

    return SafeArea(
      child: Container(
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
            isLoading
                ? const SizedBox(
                  height: 200,
                  child: Center(child: CircularProgressIndicator()),
                )
                : errorMessage != null
                ? SizedBox(
                  height: 200,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _fetchRewardsStats,
                          child: Text(LocaleKeys.liveRetry.tr),
                        ),
                      ],
                    ),
                  ),
                )
                : _buildContent(width),
      ),
    );
  }

  Widget _buildContent(double width) {
    final currentHours = onlineDurationData?.currentHours ?? 0;
    final penaltyThreshold = onlineDurationData?.penaltyThreshold ?? 4;
    final rewardThreshold = onlineDurationData?.rewardThreshold ?? 8;
    final maxDuration = rewardThreshold + 2;
    final progressMarkers = _generateProgressMarkers();
    final durationSlabs = _buildDurationSlabs();

    final currentColor = getCurrentSlabColor(
      currentHours: currentHours,
      penaltyThreshold: penaltyThreshold,
      rewardThreshold: rewardThreshold,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 10.0),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Online Duration Today",
              style: TextStyle(
                fontSize: FontSize.xL,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20.0),

        // Progress bar section
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
                        currentHours: currentHours,
                        maxHours: maxDuration,
                      ),
                      backgroundColor: const Color(0xFFE4E4E4),
                      color: currentColor,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    // Progress markers
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        for (int i = 0; i < 2; i++)
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
              // Current position indicator
              Align(
                alignment:
                    Alignment.lerp(
                      Alignment.centerLeft,
                      Alignment.centerRight,
                      calculateProgressValue(
                        currentHours: currentHours,
                        maxHours: maxDuration,
                      ),
                    ) ??
                    Alignment.center,
                child: Tooltip(
                  triggerMode: TooltipTriggerMode.tap,
                  message: formatHours(currentHours),
                  showDuration: const Duration(seconds: 3),
                  child: Container(
                    padding: const EdgeInsets.all(1.0),
                    decoration: BoxDecoration(
                      color: currentColor,
                      shape: BoxShape.circle,
                    ),
                    child: Container(
                      height: 16.0,
                      width: 16.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: currentColor,
                        border: Border.all(color: Colors.white, width: 1.0),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 5.0),

        // Hour markers
        SizedBox(
          width: width - 16.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children:
                progressMarkers
                    .map(
                      (hr) => SizedBox(
                        height: 16.0,
                        child: Text(
                          '-${hr}hr',
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          style: TextStyle(
                            fontSize: FontSize.S,
                            color: Get.theme.primaryColor,
                          ),
                        ),
                      ),
                    )
                    .toList(),
          ),
        ),

        const SizedBox(height: 20.0),

        // Duration slabs
        SizedBox(
          height: 50.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children:
                durationSlabs.map<Widget>((slab) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          backgroundColor: slab.color,
                          maxRadius: 6,
                          child: const SizedBox(),
                        ),
                        const SizedBox(width: 5),
                        Flexible(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              FittedBox(
                                child: Text(
                                  slab.title,
                                  style: const TextStyle(
                                    fontSize: FontSize.S,
                                    fontWeight: Weight.heavy,
                                  ),
                                ),
                              ),
                              FittedBox(
                                child: Text(
                                  slab.amount,
                                  style: TextStyle(
                                    color: slab.color,
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
                }).toList(),
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
            borderRadius: const BorderRadius.all(Radius.circular(16.0)),
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
                final day = DayOfWeekExtensions.getPreviousWeekSorted()[index];
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
                    DateFormat('dd/MM/yy').format(day.getCorrespondingDate()),
                    style: const TextStyle(
                      fontSize: FontSize.S,
                      color: Colors.grey,
                    ),
                  ),
                  trailing: Text(
                    formatTimeToHoursMinutes(durationInSeconds.round()),
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
              itemCount: DayOfWeekExtensions.getPreviousWeekSorted().length,
            ),
          ),
        ),
      ],
    );
  }
}

class DurationSlab {
  final String title;
  final String amount;
  final Color color;
  final SlabType type;

  DurationSlab({
    required this.title,
    required this.amount,
    required this.color,
    required this.type,
  });
}

enum SlabType { penalty, neutral, reward }
