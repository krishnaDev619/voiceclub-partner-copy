import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/data/models/metrics/score_model.dart';
import 'package:voiceclub_partner/view/metrics/widgets/metrics_info_section.dart';
import 'package:voiceclub_partner/view/metrics/widgets/metrics_meter_tile.dart';
import 'package:voiceclub_partner/view/tutorial/demo/controllers/demo_landing_controller.dart';
import 'package:voiceclub_partner/view/tutorial/demo/widgets/home/demo_custom_score_indicator.dart';

class DemoMetricsMeterWidget extends StatefulWidget {
  const DemoMetricsMeterWidget({super.key});

  @override
  State<DemoMetricsMeterWidget> createState() => _DemoMetricsMeterWidgetState();
}

class _DemoMetricsMeterWidgetState extends State<DemoMetricsMeterWidget> {
  final demoController = Get.find<DemoLandingController>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final aggregate = demoController.metricsData.value.aggregate;
      final maxScore = aggregate?.maxValue ?? 0.0;
      final yellow =
          aggregate?.cutoffs
              ?.where((e) => e.tag == MetricsCutoffTag.YELLOW)
              .firstOrNull;
      final green =
          aggregate?.cutoffs
              ?.where((e) => e.tag == MetricsCutoffTag.GREEN)
              .firstOrNull;

      final List<ScoreModel> scoreList =
          demoController.metricsData.value.metrics ?? [];

      final firstCutoffValue = ((yellow?.percentage ?? 0.0) / 100) * maxScore;
      final secondCutoffValue = ((green?.percentage ?? 0.0) / 100) * maxScore;

      return SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 16.0),
              DemoCustomScoreIndicator(
                score: aggregate?.score ?? 0,
                maxScore: maxScore,
                firstInterval: firstCutoffValue,
                secondInterval: secondCutoffValue,
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
              const MetricsInfoSection(),
            ],
          ),
        ),
      );
    });
  }
}
