import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/injection_container.dart';
import 'package:voiceclub_partner/core/services/analytics_service.dart';
import 'package:voiceclub_partner/core/services/formatter.dart';
import 'package:voiceclub_partner/view/logs/logs_controller.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';

class EarningOverviewWidget extends StatelessWidget {
  final String earning;
  final int calls;
  final int missed;
  final OverviewFilter overviewFilter;
  final void Function(BottomBarTabType) changeTab;

  const EarningOverviewWidget({
    super.key,
    required this.earning,
    required this.calls,
    required this.missed,
    required this.overviewFilter,
    required this.changeTab,
  });

  void navigateToLogsScreen(LogType logType) async {
    Get.find<LogsController>().updateLogFilter(
      logType: logType,
      overviewFilter: overviewFilter,
    );
    sl<AnalyticsService>().trackEvent(
      "logTypeTap",
      eventProperties: {"logType": logType.name},
    );
    changeTab(BottomBarTabType.LOGS);
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 8.0),
        ListTile(
          dense: true,
          visualDensity: VisualDensity.compact,
          leading: Text(
            LocaleKeys.homeEarning.tr,
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          trailing: Text("₹${Formatter.formatStringToLargeNumber(earning)}"),
        ),
        // const Divider(),
        // ListTile(
        //   dense: true,
        //   visualDensity: VisualDensity.compact,
        //   leading: const Text(
        //     "Minutes",
        //     style: TextStyle(fontWeight: FontWeight.w500),
        //   ),
        //   trailing: Text(
        //     Formatter.formatStringToLargeNumber(
        //       Formatter.formattedTime(timeInSecond: minutes),
        //     ),
        //   ),
        // ),
        const Divider(),
        ListTile(
          dense: true,
          visualDensity: VisualDensity.compact,
          leading: Text(
            LocaleKeys.homeCalls.tr,
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          trailing: Text(Formatter.formatLargeNumber(calls)),
        ),
        const Divider(),
        ListTile(
          dense: true,
          visualDensity: VisualDensity.compact,
          leading: Text(
            LocaleKeys.homeMissed.tr,
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          trailing: Text(Formatter.formatLargeNumber(missed)),
          onTap: () => navigateToLogsScreen(LogType.Missed),
        ),
        // const Divider(),
        // ListTile(
        //   dense: true,
        //   visualDensity: VisualDensity.compact,
        //   leading: const Text(
        //     "Busy",
        //     style: TextStyle(fontWeight: FontWeight.w500),
        //   ),
        //   trailing: Text(Formatter.formatLargeNumber(busy)),
        //   onTap: () => navigateToLogsScreen(LogType.Busy),
        // ),
        // const Divider(),
        // ListTile(
        //   dense: true,
        //   visualDensity: VisualDensity.compact,
        //   leading: const Text(
        //     "Offline",
        //     style: TextStyle(fontWeight: FontWeight.w500),
        //   ),
        //   trailing: Text(Formatter.formatLargeNumber(offline)),
        //   onTap: () => navigateToLogsScreen(LogType.Offline),
        // ),
        // const Divider(),
        // ListTile(
        //   dense: true,
        //   visualDensity: VisualDensity.compact,
        //   leading: const Text(
        //     "Viewed",
        //     style: TextStyle(fontWeight: FontWeight.w500),
        //   ),
        //   trailing: Text(Formatter.formatLargeNumber(viewed)),
        //   onTap: () => navigateToLogsScreen(LogType.Viewed),
        // ),
      ],
    );
  }
}
