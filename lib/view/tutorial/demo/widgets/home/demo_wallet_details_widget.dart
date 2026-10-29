import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/view/home/bottom_sheet/payout_info_bottom_sheet.dart';
import 'package:voiceclub_partner/view/tutorial/demo/screens/demo_transaction_screen.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';

class DemoWalletDetailsWidget extends StatelessWidget {
  const DemoWalletDetailsWidget({super.key});

  String getNextPayoutDate() {
    DateTime today = DateTime.now();
    int currentDay = today.day;
    int daysInMonth = DateTime(today.year, today.month + 1, 0).day;
    String payoutDate = "";

    if (currentDay == 10 || currentDay == 20 || currentDay == daysInMonth) {
      payoutDate = LocaleKeys.demoToday.tr;
    } else if (currentDay < 10) {
      payoutDate = DateFormat('10 MMM yyyy').format(today);
    } else if (currentDay < 20) {
      payoutDate = DateFormat('20 MMM yyyy').format(today);
    } else if (currentDay < daysInMonth) {
      payoutDate = DateFormat('$daysInMonth MMM yyyy').format(today);
    }

    return payoutDate;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0),
          color: Colors.white,
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4.0,
              spreadRadius: 0.4,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 6.0),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            LocaleKeys.demoWalletBalance.tr,
                            style: TextStyle(
                              fontWeight: Weight.heavy,
                              fontSize: FontSize.xXL,
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            Get.bottomSheet(
                              const PayoutInfoBottomSheet(),
                              isScrollControlled: true,
                            );
                          },
                          child: FittedBox(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  LocaleKeys.demoPayoutDate.trParams({
                                    'date': getNextPayoutDate(),
                                  }),
                                  style: TextStyle(
                                    fontWeight: Weight.heavy,
                                    fontSize: FontSize.M,
                                    color: Colors.black.withValues(alpha: 0.5),
                                  ),
                                ),
                                Icon(
                                  Icons.info_outline,
                                  color: Get.theme.primaryColor,
                                  size: 14.0,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 6.0),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10.0),
                  const Expanded(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Text(
                        "₹1420.69",
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: FontSize.xXXXL,
                        ),
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(thickness: 1.0, height: 0.0),
            InkWell(
              onTap: () {
                Get.to(() => const DemoTransactionScreen());
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      LocaleKeys.demoSeeDetails.tr,
                      style: TextStyle(
                        fontWeight: Weight.heavy,
                        color: Get.theme.primaryColor,
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Get.theme.primaryColor.withValues(alpha: 0.12),
                      ),
                      child: Icon(
                        Icons.navigate_next,
                        color: Get.theme.primaryColor,
                        size: 18.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
