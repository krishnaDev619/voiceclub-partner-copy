import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/core/services/formatter.dart';
import 'package:voiceclub_partner/modules/controller/probation_controller.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';

class MetricsHistoryBottomSheet extends StatelessWidget {
  const MetricsHistoryBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProbationController>();
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12.0),
          topRight: Radius.circular(12.0),
        ),
      ),
      padding: const EdgeInsets.all(12.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            LocaleKeys.liveYourPreviousMetrics.tr,
            style: const TextStyle(
              fontWeight: Weight.heavy,
              fontSize: FontSize.xXL,
            ),
          ),
          const SizedBox(height: 6.0),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 2.0,
                  spreadRadius: 2.0,
                ),
              ],
              borderRadius: BorderRadius.circular(12.0),
            ),
            margin: const EdgeInsets.symmetric(vertical: 12.0),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_month, size: 18.0),
                      SizedBox(width: 6.0),
                      Text(
                        LocaleKeys.liveDate.tr,
                        style: TextStyle(fontWeight: Weight.heavy),
                      ),
                      Spacer(),
                      Icon(Icons.emoji_events, size: 18.0),
                      SizedBox(width: 6.0),
                      Text(
                        LocaleKeys.liveScore.tr,
                        style: TextStyle(fontWeight: Weight.heavy),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 5.0),
                ListView.separated(
                  shrinkWrap: true,
                  itemCount: controller.metricsData.value.history?.length ?? 0,
                  separatorBuilder: (context, index) {
                    return const Divider(height: 5.0);
                  },
                  itemBuilder: (context, index) {
                    final score = controller.metricsData.value.history?[index];
                    return Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          Text(Formatter.getFormattedDate(score?.date ?? "")),
                          const Spacer(),
                          Text(
                            score?.scoreAggregate?.toDouble().toStringAsFixed(
                                  0,
                                ) ??
                                "",
                            style: TextStyle(
                              fontWeight: Weight.heavy,
                              color: score?.tag?.getColorFromTag,
                              fontSize: 24.0,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
