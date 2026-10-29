import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/modules/controller/probation_controller.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';

class CustomScoreIndicator extends StatefulWidget {
  final num score;
  final num maxScore;
  final MetricsCutoffTag? tag;
  final num firstInterval;
  final num secondInterval;

  const CustomScoreIndicator({
    super.key,
    required this.score,
    required this.maxScore,
    required this.tag,
    required this.firstInterval,
    required this.secondInterval,
  });

  @override
  State<CustomScoreIndicator> createState() => _CustomScoreIndicatorState();
}

class _CustomScoreIndicatorState extends State<CustomScoreIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<num> _progressAnimation;
  final controller = Get.find<ProbationController>();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    _progressAnimation = Tween(
      begin: 0,
      end: (widget.score / widget.maxScore) * 100,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = Get.width * 0.6;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        const Spacer(),
        const Text(
          "0",
          style: TextStyle(fontSize: FontSize.M, color: Colors.grey),
        ),

        // The Gauge
        SizedBox(
          width: height,
          child: Stack(
            alignment: Alignment.center,
            children: [
              ClipRect(
                clipBehavior: Clip.none,
                child: Align(
                  alignment: Alignment.topCenter,
                  heightFactor: 0.5,
                  child: SizedBox(
                    height: height,
                    child: AnimatedBuilder(
                      animation: _progressAnimation,
                      builder: (_, _) {
                        return SfRadialGauge(
                          enableLoadingAnimation: false,
                          axes: <RadialAxis>[
                            RadialAxis(
                              minimum: 0,
                              maximum: 100,
                              startAngle: 180,
                              endAngle: 0,
                              showLabels: false,
                              showTicks: false,
                              axisLineStyle: const AxisLineStyle(
                                thickness: 15,
                                cornerStyle: CornerStyle.bothCurve,
                                color: Colors.white,
                              ),
                              ranges: <GaugeRange>[
                                GaugeRange(
                                  startValue: 2,
                                  endValue: widget.firstInterval.toDouble(),
                                  color: MetricsUIConstants.redColor,
                                  startWidth: 15,
                                  endWidth: 15,
                                ),
                                GaugeRange(
                                  startValue: widget.firstInterval.toDouble(),
                                  endValue: widget.secondInterval.toDouble(),
                                  color: MetricsUIConstants.yellowColor,
                                  startWidth: 15,
                                  endWidth: 15,
                                ),
                                GaugeRange(
                                  startValue: widget.secondInterval.toDouble(),
                                  endValue: 98,
                                  color: MetricsUIConstants.greenColor,
                                  startWidth: 15,
                                  endWidth: 15,
                                ),
                              ],
                              pointers: <GaugePointer>[
                                // START ROUND EDGE CIRCLES
                                const MarkerPointer(
                                  value: 2.0,
                                  markerType: MarkerType.circle,
                                  color: MetricsUIConstants.redColor,
                                  markerWidth: 15,
                                  markerHeight: 15,
                                ),
                                const MarkerPointer(
                                  value: 98,
                                  markerType: MarkerType.circle,
                                  color: MetricsUIConstants.greenColor,
                                  markerWidth: 15,
                                  markerHeight: 15,
                                ),
                                MarkerPointer(
                                  value: _progressAnimation.value.toDouble(),
                                  markerType: MarkerType.circle,
                                  color: widget.tag?.getColorFromTag,
                                  borderColor: Colors.white,
                                  overlayColor: widget.tag?.getColorFromTag,
                                  borderWidth: 2,
                                  markerWidth: 24,
                                  markerHeight: 24,
                                ),

                                // Interval Markers - Text Labels
                                MarkerPointer(
                                  value: widget.firstInterval.toDouble(),
                                  markerType: MarkerType.text,
                                  text: widget.firstInterval.toInt().toString(),
                                  textStyle: const GaugeTextStyle(
                                    fontSize: FontSize.M,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey,
                                  ),
                                  animationType: AnimationType.ease,
                                  markerOffset: -18,
                                ),
                                MarkerPointer(
                                  value: widget.secondInterval.toDouble(),
                                  markerType: MarkerType.text,
                                  text:
                                      widget.secondInterval.toInt().toString(),
                                  textStyle: const GaugeTextStyle(
                                    fontSize: FontSize.M,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey,
                                  ),
                                  animationType: AnimationType.ease,
                                  markerOffset: -18,
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
              // Score Label
              Align(
                alignment: Alignment.bottomCenter,
                child: SizedBox(
                  height: height * 0.5,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        LocaleKeys.homeYourScore.tr,
                        style: TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      // Score Value with Dynamic Color
                      AnimatedBuilder(
                        animation: _progressAnimation,
                        builder: (_, _) {
                          return Text(
                            (_progressAnimation.value).toInt().toStringAsFixed(
                              0,
                            ),
                            style: TextStyle(
                              fontSize: 28.0,
                              fontWeight: FontWeight.bold,
                              color: widget.tag?.getColorFromTag,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // Min-Max Labels
        const Text(
          "100",
          style: TextStyle(fontSize: FontSize.M, color: Colors.grey),
        ),
        const Spacer(),
      ],
    );
  }
}
