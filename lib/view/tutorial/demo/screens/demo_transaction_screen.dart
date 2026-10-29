import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/data/models/wallet/get_payout_breakdown.dart';
import 'package:voiceclub_partner/data/models/wallet/payout_items.dart';
import 'package:voiceclub_partner/data/models/wallet/tax.dart';
import 'package:voiceclub_partner/data/models/wallet/transaction_details.dart';
import 'package:voiceclub_partner/view/chat/widgets/custom_tab.dart';
import 'package:voiceclub_partner/view/tutorial/demo/bottom_sheets/demo_transaction_details_bottom_sheet.dart';
import 'package:voiceclub_partner/view/tutorial/demo/controllers/demo_landing_controller.dart';
import 'package:voiceclub_partner/view/tutorial/demo/widgets/core/demo_question_widget.dart';
import 'package:voiceclub_partner/view/wallet/widgets/payout_details_bottom_sheet.dart';
import 'package:voiceclub_partner/view/widgets/custom_app_bar.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';
import 'package:voiceclub_partner/view/tutorial/demo/demo_labels.dart';

class DemoTransactionScreen extends StatefulWidget {
  const DemoTransactionScreen({super.key});

  @override
  State<DemoTransactionScreen> createState() => _DemoTransactionScreenState();
}

class _DemoTransactionScreenState extends State<DemoTransactionScreen> {
  final controller = Get.find<DemoLandingController>();

  @override
  void initState() {
    super.initState();
    controller.selectedTransactionTab.value = TransactionCategory.ALL;
  }

  void _showDurationEarningsBottomSheet() async {
    final transactionDetails = TransactionDetailsModel.fromJson({
      "ID": 71799916,
      "price": "₹9/min",
      "title": LocaleKeys.demoEarningWith.trParams({'name': 'miss u varsha'}),
      "channel_id": "703-1737021994",
      "subtitle": "00:00:09 16/01/2025, 03:36:45 PM",
      "amount": 10.0,
      "action": "PLUS",
      "reason": LocaleKeys.demoDeclinedByUser.tr,
      "type": "CALL",
      "status": 0,
      "hold_status": "PAID",
      "call_duration": 100,
      "call_start_time": "2025-01-16T10:06:36.743043Z",
      "call_end_time": "2025-01-16T10:06:45.92181Z",
      "call_revenue_ratio": 60,
      "created_at": "2025-01-16T10:06:45.925932Z",
      "updated_at": "2025-01-16T10:06:45.925932Z",
      "user": {
        "id": 3646653,
        "name": "Rahul",
        "phone_number": "5858858558",
        "avatar": "",
        "status": "ACTIVE",
        "fcm_token":
            "f5x8wBHWQcewmfjDBETUqv:APA91bG3v88Llc-rncJy3Ug04AqFsMnsu7lam3lHzGbev2gLyPRqDN8dGVZyQJx7-jaOXs1VDeHAGj6CAyghCnAGzAaYDn4Yur-0Ey48uFuUA0-k00QKce4",
        "preference": "ON",
        "edit_enabled": false,
        "privacy_pack_enabled": true,
      },
      "is_percentage": false,
      "slabs": [
        {"start": 0, "end": 60, "ratio": 0.6},
        {"start": 60, "end": 600, "ratio": 1.5},
        {"start": 600, "end": 1200, "ratio": 1.8},
        {"start": 1200, "end": 2400, "ratio": 2.4},
        {"start": 2400, "end": 3600, "ratio": 2.7},
        {"start": 3600, "end": 3600, "ratio": 3},
      ],
    });

    Get.bottomSheet(
      DemoTransactionDetailsBottomSheet(transactionDetails: transactionDetails),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.0),
          topRight: Radius.circular(16.0),
        ),
      ),
      backgroundColor: const Color(0xFFF9F9F9),
    );
  }

  void _showPayoutBottomSheet(int? transactionId) async {
    final breakdown = GetPayoutBreakdownResponse(
      items: [
        Items(
          amount: 10.0,
          title: LocaleKeys.demoCall.tr,
          type: PayoutItemType.REWARD,
        ),
        Items(
          amount: 10.0,
          title: LocaleKeys.demoChat.tr,
          type: PayoutItemType.REWARD,
        ),
      ],
      platformFee: 1.0,
      tax: Tax(type: "GST", amount: 1.0, percentage: 10.0),
      total: 20.0,
    );

    Get.bottomSheet(
      PayoutDetailsBottomsheet(
        payoutBreakdown: breakdown,
        createdAt: "2022-01-01T00:00:00.000Z",
      ),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.0),
          topRight: Radius.circular(16.0),
        ),
      ),
      backgroundColor: const Color(0xFFF9F9F9),
    );
  }

  bool isSameMonth(String? date1String, String? date2String) {
    try {
      final date1 = DateTime.parse(date1String ?? "");
      final date2 = DateTime.parse(date2String ?? "");
      return date1.year == date2.year && date1.month == date2.month;
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(title: LocaleKeys.demoTransactions.tr),
      floatingActionButton: Obx(() {
        return DemoQuestionWidget(
          question: controller.currentQuestion,
          totalQuestions: controller.demoQuestions.length,
          currentQuestionIndex: controller.currentQuestionIndex.value,
          isTopView: false,
        );
      }),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: SafeArea(
        child: Obx(() {
          return DefaultTabController(
            length: TransactionCategory.values.length,
            child: Column(
              children: [
                Container(
                  constraints: const BoxConstraints.expand(height: 36.0),
                  child: TabBar(
                    isScrollable: true,
                    labelPadding: const EdgeInsets.symmetric(horizontal: 6.0),
                    padding: const EdgeInsets.symmetric(horizontal: 6.0),
                    indicator: null,
                    indicatorColor: Colors.transparent,
                    splashBorderRadius: BorderRadius.circular(8.0),
                    onTap: (index) {
                      controller.changeTransactionTab(
                        TransactionCategory.values[index],
                      );
                    },
                    tabs:
                        TransactionCategory.values
                            .map(
                              (transactionCategory) => Tab(
                                key: Key(transactionCategory.name),
                                child: CustomTab(
                                  label: demoTransactionLabel(
                                    transactionCategory,
                                  ),
                                  selected:
                                      transactionCategory ==
                                      controller.selectedTransactionTab.value,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8.0,
                                    horizontal: 8.0,
                                  ),
                                  hasBorder:
                                      transactionCategory ==
                                              controller
                                                  .selectedTransactionTab
                                                  .value
                                          ? false
                                          : true,
                                  unselectedContentColor: Colors.black45,
                                  borderColor: Colors.black45,
                                ),
                              ),
                            )
                            .toList(),
                  ),
                ),
                Expanded(
                  child: Builder(
                    builder: (_) {
                      return ListView.separated(
                        itemCount:
                            controller
                                .tabTransactionMap[controller
                                    .selectedTransactionTab
                                    .value]
                                ?.toList()
                                .length ??
                            0,
                        separatorBuilder: (_, index) {
                          return const Divider(
                            indent: 24.0,
                            endIndent: 24.0,
                            height: 0.0,
                          );
                        },
                        itemBuilder: (context, index) {
                          var ds =
                              controller
                                  .tabTransactionMap[controller
                                      .selectedTransactionTab
                                      .value]
                                  ?.toList()
                                  .toList()[index];
                          if (ds != null) {
                            bool isPlus =
                                ds.action?.toUpperCase() == "PLUS" ||
                                ds.type == TransactionType.Withdrawal;
                            bool isCall =
                                (ds.type == TransactionType.Call) ||
                                (ds.type == TransactionType.MissedCall) ||
                                (ds.type == TransactionType.Chat);
                            final holdStatus = ds.holdStatus ?? HoldStatus.Paid;
                            final isNewMonth =
                                index == 0 ||
                                !isSameMonth(
                                  ds.createdAt,
                                  controller
                                      .tabTransactionMap[controller
                                          .selectedTransactionTab
                                          .value]
                                      ?.toList()[index - 1]
                                      .createdAt,
                                );
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (isNewMonth)
                                  Container(
                                    width: Get.width,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0,
                                      vertical: 8.0,
                                    ),
                                    color: const Color(0xFFF0F0F0),
                                    child: Text(
                                      DateFormat.yMMM().format(
                                        DateTime.tryParse(ds.createdAt ?? "") ??
                                            DateTime.now(),
                                      ),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                Builder(
                                  builder: (_) {
                                    if (isCall) {
                                      return ListTile(
                                        minVerticalPadding: 16.0,
                                        selected: true,
                                        onTap: () {
                                          if (ds.type == TransactionType.Call) {
                                            _showDurationEarningsBottomSheet();
                                            // Kabir
                                            controller.validateAction(
                                              TutorialDemoFeature
                                                  .TRANSACTIONS_CALL_DETAILS,
                                            );
                                          }
                                        },
                                        title: Text(
                                          ds.title ?? '',
                                          style: TextStyle(
                                            color:
                                                isPlus
                                                    ? (holdStatus.labelColor)
                                                    : Colors.red,
                                            fontSize: FontSize.L,
                                          ),
                                        ),
                                        visualDensity: VisualDensity.compact,
                                        subtitle: Padding(
                                          padding: const EdgeInsets.only(
                                            top: 4.0,
                                          ),
                                          child: Text(
                                            ds.subtitle ?? '',
                                            style: const TextStyle(
                                              fontSize: FontSize.M,
                                              color: Colors.black54,
                                            ),
                                          ),
                                        ),
                                        selectedColor: Colors.black,
                                        dense: true,
                                        trailing: SizedBox(
                                          width: Get.width / 4,
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.end,
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Text(
                                                      "${holdStatus == HoldStatus.Paid ? (isPlus ? '+' : '-') : ''} ₹${ds.getAmount?.toStringAsFixed(2)}",
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      textAlign:
                                                          TextAlign.right,
                                                      style: TextStyle(
                                                        color:
                                                            isPlus
                                                                ? (holdStatus
                                                                    .earningColor)
                                                                : Colors.red,
                                                      ),
                                                    ),
                                                    Text(
                                                      holdStatus ==
                                                              HoldStatus.Paid
                                                          ? (isPlus
                                                              ? LocaleKeys
                                                                  .demoCompletedLabel
                                                                  .tr
                                                              : LocaleKeys
                                                                  .demoDeducted
                                                                  .tr)
                                                          : (holdStatus ==
                                                                  HoldStatus
                                                                      .Hold
                                                              ? LocaleKeys
                                                                  .demoPending
                                                                  .tr
                                                              : LocaleKeys
                                                                  .demoNoEarning
                                                                  .tr),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      textAlign:
                                                          TextAlign.right,
                                                      style: TextStyle(
                                                        color:
                                                            isPlus
                                                                ? (holdStatus
                                                                    .earningColor)
                                                                : Colors.red,
                                                        fontSize: FontSize.M,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  left: 8.0,
                                                ),
                                                child: Visibility(
                                                  visible:
                                                      ds.type ==
                                                      TransactionType.Call,
                                                  replacement: const SizedBox(
                                                    height: 20.0,
                                                    width: 20.0,
                                                  ),
                                                  child: Container(
                                                    height: 20.0,
                                                    width: 20.0,
                                                    padding:
                                                        const EdgeInsets.only(
                                                          left: 2.0,
                                                        ),
                                                    margin:
                                                        const EdgeInsets.only(),
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: Get
                                                          .theme
                                                          .primaryColor
                                                          .withValues(
                                                            alpha: 0.1,
                                                          ),
                                                    ),
                                                    child: Icon(
                                                      Icons
                                                          .chevron_right_rounded,
                                                      size: 14.0,
                                                      color:
                                                          Get
                                                              .theme
                                                              .primaryColor,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    } else {
                                      return ListTile(
                                        minVerticalPadding: 16.0,
                                        onTap: () {
                                          if (ds.type ==
                                              TransactionType.Withdrawal) {
                                            _showPayoutBottomSheet(ds.iD);
                                            controller.validateAction(
                                              TutorialDemoFeature
                                                  .TRANSACTIONS_PAYOUT,
                                            );
                                          }
                                        },
                                        selected: true,
                                        title: Text(
                                          ds.title ?? '',
                                          style: TextStyle(
                                            color:
                                                isPlus
                                                    ? Colors.black87
                                                    : Colors.red,
                                            fontSize: FontSize.L,
                                          ),
                                        ),
                                        visualDensity: VisualDensity.compact,
                                        subtitle: Padding(
                                          padding: const EdgeInsets.only(
                                            top: 4.0,
                                          ),
                                          child: FittedBox(
                                            fit: BoxFit.scaleDown,
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              ds.subtitle ?? '',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize: FontSize.M,
                                                color: Colors.black54,
                                              ),
                                            ),
                                          ),
                                        ),
                                        selectedColor: Colors.black,
                                        dense: true,
                                        trailing: SizedBox(
                                          width: Get.width / 4,
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.end,
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Text(
                                                      "${ds.type == TransactionType.Withdrawal ? "" : (isPlus ? '+' : '-')} ₹${ds.getAmount?.toStringAsFixed(2)}",
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      textAlign:
                                                          TextAlign.right,
                                                      style: TextStyle(
                                                        color:
                                                            isPlus
                                                                ? Colors.green
                                                                : Colors.red,
                                                      ),
                                                    ),
                                                    Text(
                                                      holdStatus ==
                                                              HoldStatus.Paid
                                                          ? (isPlus
                                                              ? LocaleKeys
                                                                  .demoCompletedLabel
                                                                  .tr
                                                              : LocaleKeys
                                                                  .demoDeducted
                                                                  .tr)
                                                          : (holdStatus ==
                                                                  HoldStatus
                                                                      .Hold
                                                              ? LocaleKeys
                                                                  .demoPending
                                                                  .tr
                                                              : LocaleKeys
                                                                  .demoNoEarning
                                                                  .tr),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      textAlign:
                                                          TextAlign.right,
                                                      style: TextStyle(
                                                        color:
                                                            isPlus
                                                                ? (holdStatus
                                                                    .earningColor)
                                                                : Colors.red,
                                                        fontSize: FontSize.M,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  left: 8.0,
                                                ),
                                                child: Visibility(
                                                  visible:
                                                      ds.type ==
                                                      TransactionType
                                                          .Withdrawal,
                                                  replacement: const SizedBox(
                                                    height: 20.0,
                                                    width: 20.0,
                                                  ),
                                                  child: Container(
                                                    height: 20.0,
                                                    width: 20.0,
                                                    padding:
                                                        const EdgeInsets.all(
                                                          2.0,
                                                        ),
                                                    margin:
                                                        const EdgeInsets.only(),
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: Get
                                                          .theme
                                                          .primaryColor
                                                          .withValues(
                                                            alpha: 0.5,
                                                          ),
                                                    ),
                                                    child: Icon(
                                                      Icons
                                                          .chevron_right_rounded,
                                                      size: 14.0,
                                                      color:
                                                          Get
                                                              .theme
                                                              .primaryColor,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ],
                            );
                          }
                          return const SizedBox();
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
