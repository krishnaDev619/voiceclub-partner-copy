import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/view/widgets/play_video_screen.dart';

class MetricsMeterTile extends StatelessWidget {
  final String iconUrl;
  final String metricTitle;
  final num value;
  final num score;
  final num maxScore;
  final MetricsCutoffTag tag;
  final double firstIntervalValue;
  final double secondIntervalValue;
  final double firstInterval;
  final double secondInterval;
  final String suffix;
  final String? infoVideoUrl;

  const MetricsMeterTile({
    super.key,
    required this.iconUrl,
    required this.metricTitle,
    required this.value,
    required this.score,
    required this.maxScore,
    required this.tag,
    required this.firstIntervalValue,
    required this.secondIntervalValue,
    required this.firstInterval,
    required this.secondInterval,
    required this.suffix,
    this.infoVideoUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(
        right: 8.0,
        left: 8.0,
        bottom: 10.0,
        top: 14.0,
      ),
      margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: const [
          BoxShadow(color: Colors.black12, spreadRadius: 1.0, blurRadius: 6.0),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              SvgPicture.network(
                iconUrl,
                width: 16.0,
                height: 16.0,
                fit: BoxFit.contain,
                colorFilter: const ColorFilter.mode(
                  ApplicationColors.black,
                  BlendMode.srcIn,
                ),
                placeholderBuilder:
                    (context) => const CircularProgressIndicator(),
                errorBuilder:
                    (context, url, error) => const Icon(
                      Icons.error,
                      size: 16.0,
                      color: ApplicationColors.errorColor,
                    ),
              ),
              const SizedBox(width: 8.0),
              Expanded(
                child: Text(
                  metricTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (infoVideoUrl != null && infoVideoUrl!.isNotEmpty)
                GestureDetector(
                  onTap: () {
                    Get.to(
                      () => PlayVideoScreen(
                        videoUrl: infoVideoUrl!,
                        isMetricFlow: true,
                      ),
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.zero,
                    child: Icon(
                      Icons.help_outline_rounded,
                      color: ApplicationColors.gossip,
                      size: 16.0,
                    ),
                  ),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 4.0, right: 4.0, top: 16.0),
            child: Row(
              children: [
                const Text(
                  "Your Score",
                  style: TextStyle(fontSize: FontSize.M),
                ),
                const Spacer(),
                CircleAvatar(radius: 6.0, backgroundColor: tag.getColorFromTag),
                const SizedBox(width: 4.0),
                Text(
                  "${value.toStringAsFixed(2)} $suffix",
                  style: const TextStyle(
                    fontSize: FontSize.M,
                    fontWeight: Weight.heavy,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8.0),
          SfLinearGauge(
            showTicks: false,
            useRangeColorForAxis: true,
            animateRange: true,
            interval: 100 / 3,
            animationDuration: 3000,
            animateAxis: false,
            orientation: LinearGaugeOrientation.horizontal,
            axisTrackStyle: const LinearAxisTrackStyle(thickness: 0.0),
            labelOffset: 12.0,
            minimum: 0,
            maximum: 100,
            onGenerateLabels: () {
              return [
                LinearAxisLabel(
                  text: firstInterval.toStringAsFixed(1),
                  value: firstIntervalValue,
                ),
                LinearAxisLabel(
                  text: secondInterval.toStringAsFixed(1),
                  value: secondIntervalValue,
                ),
              ];
            },
            markerPointers: [
              LinearShapePointer(
                height: 10.0,
                width: 10.0,
                value: score.toDouble(),
                shapeType: LinearShapePointerType.invertedTriangle,
                color: tag.getColorFromTag,
              ),
            ],
            ranges: <LinearGaugeRange>[
              LinearGaugeRange(
                startValue: 0,
                endValue: firstIntervalValue,
                position: LinearElementPosition.inside,
                color: MetricsUIConstants.redColor,
                midWidth: 10,
                startWidth: 10,
                endWidth: 10,
                edgeStyle: LinearEdgeStyle.startCurve,
              ),
              LinearGaugeRange(
                startValue: firstIntervalValue,
                endValue: secondIntervalValue,
                position: LinearElementPosition.inside,
                color: MetricsUIConstants.yellowColor,
                midWidth: 10,
                startWidth: 10,
                endWidth: 10,
              ),
              LinearGaugeRange(
                startValue: secondIntervalValue,
                endValue: 100,
                position: LinearElementPosition.inside,
                color: MetricsUIConstants.greenColor,
                midWidth: 10,
                startWidth: 10,
                endWidth: 10,
                edgeStyle: LinearEdgeStyle.endCurve,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
