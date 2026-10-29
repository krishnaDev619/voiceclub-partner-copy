import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/modules/controller/probation_controller.dart';
import 'package:voiceclub_partner/view/chat/widgets/bottom_sheet/semi_circular_progress_indicator.dart';
import 'package:voiceclub_partner/view/tutorial/demo/controllers/demo_landing_controller.dart';
import 'package:voiceclub_partner/view/tutorial/demo/screens/demo_metrics_screen.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';

class DemoMetricsSection extends StatelessWidget {
  const DemoMetricsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DemoLandingController>();
    final aggregate = controller.metricsData.value.aggregate;

    return GestureDetector(
      onTap: () async {
        await Get.find<ProbationController>().fetchProbationDetails(
          scoreOnly: true,
        );
        Get.to(() => const DemoMetricsScreen());
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(12.0)),
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [Color(0xFFFF9B6D), Color(0xFFFF7777)],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 4.0,
              spreadRadius: 0.4,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 100.0,
              width: double.infinity,
              padding: const EdgeInsets.only(left: 12.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.0),
                color: Colors.white,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 1,
                    child: FittedBox(
                      alignment: Alignment.centerLeft,
                      fit: BoxFit.scaleDown,
                      child: Text(
                        LocaleKeys.demoYourScoreBreak.tr,
                        style: TextStyle(
                          fontWeight: Weight.bold,
                          fontSize: FontSize.xL,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: FittedBox(
                      alignment: Alignment.center,
                      child: Transform.translate(
                        offset: const Offset(0.0, 20.0),
                        child: SemiCircularProgressIndicator(
                          progress: ((aggregate?.score?.toDouble() ?? 0.0) /
                                  100.0)
                              .clamp(0.0, 1.0),
                          arcColor: aggregate?.tag?.getColorFromTag,
                          width: ((Get.width) / 2),
                          text:
                              aggregate?.score?.toDouble().toStringAsFixed(0) ??
                              "",
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    LocaleKeys.demoSeeAll.tr,
                    style: TextStyle(fontSize: FontSize.S, color: Colors.white),
                  ),
                  Icon(
                    Icons.arrow_circle_right_rounded,
                    size: 18.0,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
