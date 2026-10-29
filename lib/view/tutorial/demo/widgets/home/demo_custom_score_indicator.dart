import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/view/tutorial/demo/controllers/demo_landing_controller.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';

class DemoCustomScoreIndicator extends StatefulWidget {
  final num score;
  final num maxScore;
  final num firstInterval;
  final num secondInterval;

  const DemoCustomScoreIndicator({
    super.key,
    required this.score,
    required this.maxScore,
    required this.firstInterval,
    required this.secondInterval,
  });

  @override
  State<DemoCustomScoreIndicator> createState() =>
      _DemoCustomScoreIndicatorState();
}

class _DemoCustomScoreIndicatorState extends State<DemoCustomScoreIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<num> _progressAnimation;
  final controller = Get.find<DemoLandingController>();

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
  Widget build(BuildContext context) {
    final height = Get.width * 0.6;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // The Gauge
        Stack(
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
                                endValue: controller.getIntervalPercentage(
                                  widget.firstInterval,
                                ),
                                color: MetricsUIConstants.redColor,
                                startWidth: 15,
                                endWidth: 15,
                              ),
                              GaugeRange(
                                startValue: controller.getIntervalPercentage(
                                  widget.firstInterval,
                                ),
                                endValue: controller.getIntervalPercentage(
                                  widget.secondInterval,
                                ),
                                color: MetricsUIConstants.yellowColor,
                                startWidth: 15,
                                endWidth: 15,
                              ),
                              GaugeRange(
                                startValue: controller.getIntervalPercentage(
                                  widget.secondInterval,
                                ),
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
                              // MarkerPointer(
                              //   value: widget.secondInterval - 2.0,
                              //   markerType: MarkerType.circle,
                              //   color: Colors.white,
                              //   markerWidth: 15,
                              //   markerHeight: 15,
                              // ),
                              // MarkerPointer(
                              //   value: widget.secondInterval + 2.0,
                              //   markerType: MarkerType.circle,
                              //   color: Colors.white,
                              //   markerWidth: 15,
                              //   markerHeight: 15,
                              // ),
                              MarkerPointer(
                                value: _progressAnimation.value.toDouble(),
                                markerType: MarkerType.circle,
                                color: getScoreColor(_progressAnimation.value),
                                borderColor: Colors.white,
                                overlayColor: getScoreColor(
                                  _progressAnimation.value,
                                ),
                                borderWidth: 2,
                                markerWidth: 24,
                                markerHeight: 24,
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
                      LocaleKeys.demoYourScore.tr,
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
                          (_progressAnimation.value).round().toStringAsFixed(0),
                          style: TextStyle(
                            fontSize: 28.0,
                            fontWeight: FontWeight.bold,
                            color: getScoreColor(_progressAnimation.value),
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

        // Min-Max Labels
        SizedBox(
          width: height,
          child: const Padding(
            padding: EdgeInsets.only(top: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "  0 ",
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
                Text(
                  "100",
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Function to determine color based on the score range
  Color getScoreColor(num score) {
    final controller = Get.find<DemoLandingController>();
    if (score < controller.getIntervalPercentage(widget.firstInterval)) {
      return MetricsUIConstants.redColor;
    }
    if (score < controller.getIntervalPercentage(widget.secondInterval)) {
      return MetricsUIConstants.yellowColor;
    }
    return MetricsUIConstants.greenColor;
  }
}
