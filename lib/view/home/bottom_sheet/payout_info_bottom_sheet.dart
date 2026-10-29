import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';
import 'package:get/get.dart';

class PayoutInfoBottomSheet extends StatefulWidget {
  const PayoutInfoBottomSheet({super.key});

  @override
  State<PayoutInfoBottomSheet> createState() => _PayoutInfoBottomSheetState();
}

class _PayoutInfoBottomSheetState extends State<PayoutInfoBottomSheet> {
  bool firstPayoutDone = false;

  bool secondPayoutDone = false;

  bool thirdPayoutDone = false;

  String getWeekday(DateTime date) {
    // Format the date to include weekday
    String formattedDate = DateFormat('EEEE').format(date);
    return formattedDate;
  }

  DateTime getToday() => DateTime.now();

  int daysInMonth() => DateTime(getToday().year, getToday().month + 1, 0).day;

  void markPayoutBasedOnTime() {
    DateTime today = DateTime.now();
    int currentDay = today.day;

    if (currentDay > 20) {
      firstPayoutDone = true;
      secondPayoutDone = true;
    } else if (currentDay > 10) {
      firstPayoutDone = true;
    }
    setState(() {});
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      markPayoutBasedOnTime();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF9F9F9),
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(16.0),
            topLeft: Radius.circular(16.0),
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              LocaleKeys.homePayout.tr,
              style: TextStyle(
                fontWeight: Weight.heavy,
                fontSize: FontSize.xXL,
              ),
            ),
            const SizedBox(height: 10.0),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const SizedBox(),
                    visualDensity: const VisualDensity(vertical: -3),
                    minLeadingWidth: 40,
                    title: Text(
                      LocaleKeys.homePayoutDate.tr,
                      style: TextStyle(
                        fontWeight: Weight.heavy,
                        fontSize: FontSize.xL,
                      ),
                    ),
                    trailing: SizedBox(
                      width: 90,
                      child: Text(
                        LocaleKeys.homePayDay.tr,
                        style: TextStyle(
                          fontWeight: Weight.heavy,
                          fontSize: FontSize.xL,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  ListTile(
                    leading: Checkbox(
                      value: firstPayoutDone,
                      shape: const CircleBorder(),
                      fillColor: WidgetStateProperty.resolveWith(
                        (_) =>
                            firstPayoutDone ? Colors.green : Colors.transparent,
                      ),
                      onChanged: (value) {},
                    ),
                    visualDensity: const VisualDensity(vertical: -3),
                    dense: true,
                    title: Row(
                      children: [
                        Text(
                          DateFormat('10 MMM yyyy').format(getToday()),
                          style:
                              firstPayoutDone
                                  ? const TextStyle(fontWeight: Weight.heavy)
                                  : null,
                        ),
                      ],
                    ),
                    trailing: SizedBox(
                      width: 90,
                      child: Text(
                        getWeekday(
                          DateTime(getToday().year, getToday().month, 10),
                        ),
                        style:
                            firstPayoutDone
                                ? const TextStyle(fontWeight: Weight.heavy)
                                : null,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.visible,
                      ),
                    ),
                  ),
                  ListTile(
                    leading: Checkbox(
                      value: secondPayoutDone,
                      shape: const CircleBorder(),
                      fillColor: WidgetStateProperty.resolveWith(
                        (_) =>
                            secondPayoutDone
                                ? Colors.green
                                : Colors.transparent,
                      ),
                      onChanged: (value) {},
                    ),
                    dense: true,
                    visualDensity: const VisualDensity(vertical: -3),
                    title: Text(
                      DateFormat('20 MMM yyyy').format(getToday()),
                      style:
                          secondPayoutDone
                              ? const TextStyle(fontWeight: Weight.heavy)
                              : null,
                    ),
                    trailing: SizedBox(
                      width: 90,
                      child: Text(
                        getWeekday(
                          DateTime(getToday().year, getToday().month, 20),
                        ),
                        style:
                            secondPayoutDone
                                ? const TextStyle(fontWeight: Weight.heavy)
                                : null,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.visible,
                      ),
                    ),
                  ),
                  ListTile(
                    leading: Checkbox(
                      value: thirdPayoutDone,
                      shape: const CircleBorder(),
                      fillColor: WidgetStateProperty.resolveWith(
                        (_) =>
                            thirdPayoutDone ? Colors.green : Colors.transparent,
                      ),
                      onChanged: (value) {},
                    ),
                    dense: true,
                    visualDensity: const VisualDensity(vertical: -3),
                    title: Text(
                      DateFormat(
                        '${daysInMonth()} MMM yyyy',
                      ).format(getToday()),
                      style:
                          thirdPayoutDone
                              ? const TextStyle(fontWeight: Weight.heavy)
                              : null,
                    ),
                    trailing: SizedBox(
                      width: 90,
                      child: Text(
                        getWeekday(
                          DateTime(
                            getToday().year,
                            getToday().month,
                            daysInMonth(),
                          ),
                        ),
                        style:
                            thirdPayoutDone
                                ? const TextStyle(fontWeight: Weight.heavy)
                                : null,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.visible,
                      ),
                    ),
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
