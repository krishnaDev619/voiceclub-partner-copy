import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';
import 'package:voiceclub_partner/view/queries/controller/queries_controller.dart';

class QueryCountIndicatorWidget extends StatelessWidget {
  const QueryCountIndicatorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<QueriesController>(
      init: Get.find<QueriesController>(),
      builder: (controller) {
        return (!controller.showQueryCountIndicator)
            ? const SizedBox.shrink()
            : Container(
              width: double.maxFinite,
              padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
              decoration: BoxDecoration(
                color:
                    getQueryCountIndicatorColor(
                      controller.usedQueries,
                      controller.totalQueries,
                    ).$2,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(15.0),
                  bottomRight: Radius.circular(15.0),
                ),
              ),
              child: Text(
                (controller.usedQueries == 2)
                    ? LocaleKeys.liveOneQueryRemainingToday.tr
                    : LocaleKeys.liveQueriesRaisedToday.trParams({
                      'used': '${controller.usedQueries}',
                      'total': '${controller.totalQueries}',
                    }),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: FontSize.L,
                  fontWeight: FontWeight.bold,
                  color:
                      getQueryCountIndicatorColor(
                        controller.usedQueries,
                        controller.totalQueries,
                      ).$1,
                ),
              ),
            );
      },
    );
  }

  (Color, Color) getQueryCountIndicatorColor(
    int usedQueries,
    int totalQueries,
  ) {
    if (usedQueries == 0) {
      return (const Color(0xFF16A34A), const Color(0xFFF0FDF4));
    }

    if (usedQueries == 1) {
      return (const Color(0xFFF59E0B), const Color(0xFFFFFBEB));
    }

    if (usedQueries == 2) {
      return (const Color(0xFFDC2626), const Color(0xFFFEF2F2));
    }

    // Disabled / Default
    return (const Color(0xFF6B7280), const Color(0xFFF3F4F6));
  }
}
