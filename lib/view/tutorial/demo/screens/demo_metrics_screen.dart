import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/modules/controller/probation_controller.dart';
import 'package:voiceclub_partner/view/tutorial/demo/controllers/demo_landing_controller.dart';
import 'package:voiceclub_partner/view/tutorial/demo/screens/demo_metrics_meter_widget.dart';
import 'package:voiceclub_partner/view/widgets/custom_app_bar.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';

class DemoMetricsScreen extends StatefulWidget {
  const DemoMetricsScreen({super.key});

  @override
  State<DemoMetricsScreen> createState() => _DemoMetricsScreenState();
}

class _DemoMetricsScreenState extends State<DemoMetricsScreen> {
  final probationController = Get.find<ProbationController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<DemoLandingController>().validateAction(
        TutorialDemoFeature.METRICS,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: LocaleKeys.demoMetrics.tr),
      body: DemoMetricsMeterWidget(),
    );
  }
}
