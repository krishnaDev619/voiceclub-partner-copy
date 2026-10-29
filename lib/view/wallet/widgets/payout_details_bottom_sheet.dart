import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/core/injection_container.dart';
import 'package:voiceclub_partner/core/services/analytics_service.dart';
import 'package:voiceclub_partner/core/services/payout_service.dart';
import 'package:voiceclub_partner/data/models/wallet/get_payout_breakdown.dart';
import 'package:voiceclub_partner/data/models/wallet/payout_items.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';

class PayoutDetailsBottomsheet extends StatefulWidget {
  final GetPayoutBreakdownResponse payoutBreakdown;
  final String createdAt;
  final bool isDemo;

  const PayoutDetailsBottomsheet({
    super.key,
    required this.payoutBreakdown,
    required this.createdAt,
    this.isDemo = false,
  });

  @override
  State<PayoutDetailsBottomsheet> createState() =>
      _PayoutDetailsBottomsheetState();
}

class _PayoutDetailsBottomsheetState extends State<PayoutDetailsBottomsheet> {
  List<Items> rewardsItems = [];
  List<Items> deductionItems = [];

  @override
  void initState() {
    filterList();
    super.initState();
  }

  void filterList() {
    rewardsItems =
        widget.payoutBreakdown.items
            ?.where((element) => element.type == PayoutItemType.REWARD)
            .toList() ??
        [];

    deductionItems =
        widget.payoutBreakdown.items
            ?.where((element) => element.type == PayoutItemType.PENALTY)
            .toList() ??
        [];
  }

  String formatDate(String? dateString) {
    final date = DateTime.tryParse(dateString ?? "")?.toLocal();
    if (date != null) {
      final previousDate = date.subtract(const Duration(days: 10));

      String formattedDate = '';

      formattedDate =
          "${DateFormat('dd MMM').format(previousDate)} - ${DateFormat('dd MMM').format(date)}";

      return formattedDate;
    } else {
      return "";
    }
  }

  // Map<String, String> calculateTaxAmounts() {
  //   final taxItems = widget.payoutBreakdown.taxItems;
  //   final amount = widget.payoutBreakdown.totalAmount ?? 0;
  //   if (taxItems == null || taxItems.isEmpty) {
  //     return {};
  //   }
  //
  //   Map<String, String> result = {};
  //
  //   for (TaxItems taxItem in taxItems) {
  //     if (taxItem.name != null && taxItem.rate != null) {
  //       double taxAmount = ((taxItem.rate ?? 0) * amount).toDouble();
  //       result[taxItem.name!] = taxAmount.toStringAsFixed(2);
  //     }
  //   }
  //   return result;
  // }

  num get getTotalEarning {
    final total = widget.payoutBreakdown.total ?? 0;
    final platformFees = widget.payoutBreakdown.platformFee ?? 0;
    final taxAmount = widget.payoutBreakdown.tax?.amount ?? 0;

    final result = total - platformFees - taxAmount;
    return result;
  }

  num get getOtherEarnings {
    final total = widget.payoutBreakdown.total ?? 0;
    // final platformFees = widget.payoutBreakdown.platformFee ?? 0;
    // final taxAmount = widget.payoutBreakdown.tax?.amount ?? 0;

    double sumOfPLUS = 0.0;
    double sumOfMINUS = 0.0;

    // Iterate over items and calculate sums based on their signs
    for (final item in widget.payoutBreakdown.items ?? <Items>[]) {
      if (item.sign == PayoutItemSign.PLUS) {
        sumOfPLUS += item.amount ?? 0;
      } else if (item.sign == PayoutItemSign.MINUS) {
        sumOfMINUS += item.amount ?? 0;
      }
    }

    // Calculate other earnings
    double otherEarnings = total - (sumOfPLUS - sumOfMINUS);
    return otherEarnings;
  }

  Widget rewardsSection() {
    return Visibility(
      visible: rewardsItems.isNotEmpty,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(Icons.arrow_right),
              Text(
                LocaleKeys.liveRewards.tr,
                style: TextStyle(fontWeight: Weight.heavy),
              ),
            ],
          ),
          const SizedBox(height: 4.0),
          for (final e in rewardsItems)
            Padding(
              padding: const EdgeInsets.only(
                left: 24.0,
                right: 6.0,
                bottom: 6.0,
                top: 6.0,
              ),
              child: Row(
                children: [
                  Container(
                    height: 6.0,
                    width: 6.0,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Flexible(child: Text("${e.title}")),
                  const Spacer(),
                  Text("+₹${e.amount?.toStringAsFixed(2)}"),
                ],
              ),
            ),
          const SizedBox(height: 10.0),
        ],
      ),
    );
  }

  Widget deductionSection() {
    return Visibility(
      visible: deductionItems.isNotEmpty,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(Icons.arrow_right),
              Text(
                "Deductions",
                style: TextStyle(
                  fontWeight: Weight.heavy,
                  color: Color(0xFFEE6464),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4.0),
          for (final e in deductionItems)
            Padding(
              padding: const EdgeInsets.only(
                left: 24.0,
                right: 6.0,
                bottom: 6.0,
                top: 6.0,
              ),
              child: Row(
                children: [
                  Container(
                    height: 6.0,
                    width: 6.0,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Flexible(child: Text("${e.title}")),
                  const Spacer(),
                  Text("-₹${e.amount?.toStringAsFixed(2)}"),
                ],
              ),
            ),
          const Divider(),
        ],
      ),
    );
  }

  Widget otherEarningSection() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(Icons.arrow_right),
            Text(
              LocaleKeys.liveOtherEarnings.tr,
              style: TextStyle(fontWeight: Weight.heavy),
            ),
          ],
        ),
        const SizedBox(height: 4.0),
        Padding(
          padding: const EdgeInsets.only(
            left: 24.0,
            right: 6.0,
            bottom: 6.0,
            top: 6.0,
          ),
          child: Row(
            children: [
              Container(
                height: 6.0,
                width: 6.0,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black,
                ),
              ),
              const SizedBox(width: 8.0),
              Flexible(child: Text(LocaleKeys.liveCallsChatsAndGifts.tr)),
              const Spacer(),
              Text("+₹${getOtherEarnings.toStringAsFixed(2)}"),
            ],
          ),
        ),
        const SizedBox(height: 10.0),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isDemo) {
      sl<AnalyticsService>().trackEvent(
        "partnerBottomSheetOpen",
        eventProperties: {
          "bottomSheetType": "PayoutInfoBottomSheet",
          "amount": widget.payoutBreakdown.total?.toStringAsFixed(2),
          "netPayout": getTotalEarning.toStringAsFixed(2),
          "payoutBreakdown": widget.payoutBreakdown.toJson(),
          // ...calculateTaxAmounts(),
        },
      );
    }
    return Container(
      constraints: BoxConstraints(maxHeight: Get.height * 0.85),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 8.0),
            child: Text(
              "Payout",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: FontSize.xL,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(LocaleKeys.homePayoutDate.tr),
                Text(formatDate(widget.createdAt)),
              ],
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10.0,
                vertical: 16.0,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.0),
                color: Colors.white,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Other Earnings
                    otherEarningSection(),
                    // Rewards Section
                    rewardsSection(),
                    // Deduction Section
                    deductionSection(),
                    // Total Earning Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Total Earning",
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "₹${widget.payoutBreakdown.total?.toStringAsFixed(2)}",
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20.0),
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.0),
              color: Colors.white,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Payout",
                      style: TextStyle(fontSize: FontSize.M),
                    ),
                    Text(
                      "₹${widget.payoutBreakdown.total?.toStringAsFixed(2)}",
                      style: const TextStyle(fontSize: FontSize.M),
                    ),
                  ],
                ),
                const SizedBox(height: 4.0),
                Visibility(
                  visible:
                      widget.payoutBreakdown.tax?.type?.isNotEmpty ?? false,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${widget.payoutBreakdown.tax?.type ?? " "} (${widget.payoutBreakdown.tax?.percentage}%)",
                        style: const TextStyle(fontSize: FontSize.M),
                      ),
                      Text(
                        "₹${widget.payoutBreakdown.tax?.amount?.toStringAsFixed(2)}",
                        style: const TextStyle(fontSize: FontSize.M),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Platform Fee (incl. GST)",
                      style: TextStyle(fontSize: FontSize.M),
                    ),
                    Text(
                      "₹${widget.payoutBreakdown.platformFee?.toStringAsFixed(2)}",
                      style: const TextStyle(fontSize: FontSize.M),
                    ),
                  ],
                ),
                const Divider(height: 20.0),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Net Payout",
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "₹${getTotalEarning.toStringAsFixed(2)}",
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      "(Total Payout - ${widget.payoutBreakdown.tax?.type} - Platform Fee (incl. GST))",
                      style: const TextStyle(
                        color: ApplicationColors.grey,
                        fontSize: FontSize.xS,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 10.0),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFFFF6F63),
              padding: const EdgeInsets.symmetric(vertical: 14.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
                side: const BorderSide(color: Color(0xFFFF6F63), width: 1.0),
              ),
            ),
            onPressed: () {
              sl<PayoutService>().sharePayout(
                amount: getTotalEarning,
                context: context,
              );
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.share, size: 18),
                SizedBox(width: 8),
                Text(LocaleKeys.liveShare.tr),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
