import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:voiceclub_partner/core/constants/asset_constants.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/modules/controller/coins_transaction_controller.dart';
import 'package:voiceclub_partner/modules/controller/user_controller.dart';
import 'package:voiceclub_partner/modules/controller/wallet_controller.dart';
import 'package:voiceclub_partner/view/home/bottom_sheet/payout_info_bottom_sheet.dart';
import 'package:voiceclub_partner/view/wallet/coins_transaction_screen.dart';
import 'package:voiceclub_partner/view/wallet/transaction_screen.dart';
import 'package:voiceclub_partner/view/widgets/custom_button.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';

class WalletDetailsWidget extends StatefulWidget {
  const WalletDetailsWidget({super.key});

  @override
  State<WalletDetailsWidget> createState() => _WalletDetailsWidgetState();
}

class _WalletDetailsWidgetState extends State<WalletDetailsWidget> {
  String getNextPayoutDate() {
    DateTime today = DateTime.now();
    int currentDay = today.day;
    int daysInMonth = DateTime(today.year, today.month + 1, 0).day;
    String payoutDate = "";

    if (currentDay == 10 || currentDay == 20 || currentDay == daysInMonth) {
      payoutDate = LocaleKeys.homeToday.tr;
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
    final walletController = Get.find<WalletController>();
    final userController = Get.find<UserController>();

    return Obx(() {
      return Container(
        margin: const EdgeInsets.only(left: 16.0, right: 16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
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
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 16.0),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 6.0),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    LocaleKeys.homeWalletBalance.tr,
                                    style: TextStyle(
                                      fontWeight: Weight.heavy,
                                      fontSize: FontSize.xXL,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            userController.enablePayoutWithdraw
                                ? InkWell(
                                  onTap: () {
                                    Get.bottomSheet(
                                      const PayoutInfoBottomSheet(),
                                      isScrollControlled: true,
                                    );
                                  },
                                  child: FittedBox(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          LocaleKeys.homePayoutDateLine
                                              .trParams({
                                                'date': getNextPayoutDate(),
                                              }),
                                          style: TextStyle(
                                            fontWeight: Weight.heavy,
                                            fontSize: FontSize.M,
                                            color: Colors.black.withValues(
                                              alpha: 0.5,
                                            ),
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
                                )
                                : const SizedBox.shrink(),
                            const SizedBox(height: 6.0),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10.0),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Get.to(() => const TransactionScreen());
                          },
                          child: Row(
                            children: [
                              Expanded(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    "₹${walletController.finalValue.value.toStringAsFixed(2)}",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: FontSize.xXXXL,
                                    ),
                                    textAlign: TextAlign.end,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10.0),
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Get.theme.primaryColor.withValues(
                                    alpha: 0.12,
                                  ),
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
                  if (userController.enablePayoutWithdraw) ...[
                    Text(
                      LocaleKeys.homeWithdrawMin.tr,
                      style: TextStyle(
                        fontWeight: Weight.heavy,
                        fontSize: FontSize.S,
                        color: Colors.black.withValues(alpha: 0.5),
                      ),
                    ),
                    SizedBox(height: 8.0),
                    CustomButton(
                      text: LocaleKeys.homeWithdrawMoney.tr,
                      enabled: walletController.finalValue.value > 50,
                      onTap: () {
                        walletController.withdrawPayout();
                      },
                    ),
                  ],
                  SizedBox(height: 16.0),
                ],
              ),
            ),
            const Divider(thickness: 1.0, height: 0.0),
            InkWell(
              onTap: () {
                Get.to(
                  () => const CoinsTransactionScreen(),
                  binding: BindingsBuilder(() {
                    Get.put(CoinsTransactionController());
                  }),
                );
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 12.0,
                  horizontal: 12.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      LocaleKeys.homeCoinBalance.tr,
                      style: TextStyle(
                        fontWeight: Weight.heavy,
                        fontSize: FontSize.xXL,
                      ),
                    ),
                    const Spacer(),
                    SvgPicture.asset(
                      AssetConstants.coinIc,
                      width: 20.0,
                      height: 20.0,
                    ),
                    const SizedBox(width: 6.0),
                    Text(
                      walletController.coinBalance.value.toStringAsFixed(2),
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: FontSize.xXXL,
                      ),
                    ),
                    const SizedBox(width: 6.0),
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
      );
    });
  }
}
