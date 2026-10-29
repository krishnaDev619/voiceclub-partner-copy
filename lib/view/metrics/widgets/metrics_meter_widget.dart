import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/data/models/metrics/score_model.dart';
import 'package:voiceclub_partner/modules/controller/probation_controller.dart';
import 'package:voiceclub_partner/view/home/widgets/custom_score_indicator.dart';
import 'package:voiceclub_partner/view/metrics/widgets/metrics_info_section.dart';
import 'package:voiceclub_partner/view/metrics/widgets/metrics_meter_tile.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';

class MetricsMeterWidget extends StatelessWidget {
  const MetricsMeterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProbationController>();
    return SafeArea(
      child: Obx(() {
        final aggregate = controller.metricsData.value.aggregate;
        final maxScore = controller.metricsData.value.aggregate?.maxValue;
        final List<ScoreModel> scoreList =
            controller.metricsData.value.metrics ?? [];

        if (scoreList.isEmpty && (aggregate == null || maxScore == null)) {
          return Center(child: Text(LocaleKeys.liveNoMetricsAvailable.tr));
        }

        double aggregateYellowCutoff =
            aggregate!.cutoffs
                ?.where((c) => c.tag == MetricsCutoffTag.YELLOW)
                .firstOrNull
                ?.percentage
                ?.toDouble() ??
            0.0;
        double aggregateGreenCutoff =
            aggregate.cutoffs
                ?.where((c) => c.tag == MetricsCutoffTag.GREEN)
                .firstOrNull
                ?.percentage
                ?.toDouble() ??
            0.0;

        return SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 16.0),
              CustomScoreIndicator(
                score: aggregate.score ?? 0.0,
                maxScore: aggregate.maxValue ?? 0.0,
                firstInterval: aggregateYellowCutoff,
                secondInterval: aggregateGreenCutoff,
                tag: aggregate.tag,
              ),
              const SizedBox(height: 60.0),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: scoreList.length,
                itemBuilder: (context, index) {
                  final item = scoreList[index];
                  final yellowCutoff =
                      item.cutoffs
                          ?.where((c) => c.tag == MetricsCutoffTag.YELLOW)
                          .firstOrNull
                          ?.percentage
                          ?.toDouble() ??
                      0.0;
                  final maxValue = item.maxValue ?? 0.0;
                  final firstCutoffValue = (yellowCutoff / 100) * maxValue;

                  final greenCutoff =
                      item.cutoffs
                          ?.where((c) => c.tag == MetricsCutoffTag.GREEN)
                          .firstOrNull
                          ?.percentage
                          ?.toDouble() ??
                      0.0;
                  final secondCutoffValue = (greenCutoff / 100) * maxValue;

                  return MetricsMeterTile(
                    value: item.value ?? 0.0,
                    score: item.score ?? 0.0,
                    maxScore: item.maxValue ?? 0.0,
                    firstIntervalValue: yellowCutoff,
                    secondIntervalValue: greenCutoff,
                    firstInterval: firstCutoffValue,
                    secondInterval: secondCutoffValue,
                    tag: item.tag ?? MetricsCutoffTag.GREEN,
                    iconUrl: item.iconUrl ?? "",
                    metricTitle: item.label ?? "",
                    suffix: item.units ?? "",
                    infoVideoUrl: item.videoUrl,
                  );
                },
              ),
              const SizedBox(height: 16.0),
              MetricsInfoSection(
                lastUpdatedTime: controller.metricsData.value.updatedAt,
              ),
            ],
          ),
        );
      }),
    );
  }
}
