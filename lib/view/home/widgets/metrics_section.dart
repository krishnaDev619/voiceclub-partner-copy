import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/modules/controller/probation_controller.dart';
import 'package:voiceclub_partner/view/chat/widgets/bottom_sheet/semi_circular_progress_indicator.dart';
import 'package:voiceclub_partner/view/home/widgets/right_arrow_button.dart';
import 'package:voiceclub_partner/view/metrics/metrics_screen.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';

class MetricsSection extends StatelessWidget {
  const MetricsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final probationController = Get.find<ProbationController>();
    return Obx(() {
      var stage = probationController.probationDetails.value.stage;
      final aggregate = probationController.metricsData.value.aggregate;

      final isMetricsEnabled =
          (stage == PartnerCurrentStatus.PROBATION ||
              stage == PartnerCurrentStatus.NEW_LIVE ||
              stage == PartnerCurrentStatus.LIVE);
      return Visibility(
        visible: isMetricsEnabled,
        child: GestureDetector(
          onTap: () async {
            await probationController.fetchProbationDetails(
              fetchMetrics: true,
              fireEvent: true,
              scoreOnly: false,
            );
            Get.to(() => const MetricsScreen());
          },
          child: Stack(
            children: [
              Container(
                height: 100.0,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.0),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade300,
                      blurRadius: 4.0,
                      spreadRadius: 0.4,
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(
                      flex:
                          stage == PartnerCurrentStatus.LIVE ||
                                  stage == PartnerCurrentStatus.NEW_LIVE
                              ? 1
                              : 3,
                      child: FittedBox(
                        alignment: Alignment.centerLeft,
                        fit: BoxFit.scaleDown,
                        child: Text(
                          LocaleKeys.homeYourScoreBreak.tr,
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
                            text: aggregate?.score?.toStringAsFixed(0) ?? "",
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Positioned(
                right: 8.0,
                top: 8.0,
                child: RightArrowButton(size: 20.0),
              ),
            ],
          ),
        ),
      );
    });
  }
}
