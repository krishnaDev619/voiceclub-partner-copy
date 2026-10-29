import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/core/injection_container.dart';
import 'package:voiceclub_partner/core/services/analytics_service.dart';
import 'package:voiceclub_partner/core/services/formatter.dart';
import 'package:voiceclub_partner/core/services/logger.dart';
import 'package:voiceclub_partner/data/models/wallet/get_payout_breakdown.dart';
import 'package:voiceclub_partner/data/models/wallet/transaction_details.dart';
import 'package:voiceclub_partner/modules/controller/wallet_controller.dart';
import 'package:voiceclub_partner/view/chat/widgets/custom_tab.dart';
import 'package:voiceclub_partner/view/wallet/widgets/payout_details_bottom_sheet.dart';
import 'package:voiceclub_partner/view/wallet/widgets/transaction_details_bottom_sheet.dart';
import 'package:voiceclub_partner/view/widgets/custom_app_bar.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';
import 'package:voiceclub_partner/view/live_labels.dart';

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({super.key});

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  late ScrollController _scrollController;
  int page = 1; // 'page' will added by 1 if we load more
  final _walletController = Get.find<WalletController>();

  @override
  void initState() {
    fetchData(isInit: true);
    _scrollController =
        ScrollController()..addListener(() {
          if (_scrollController.position.atEdge) {
            if (_scrollController.position.pixels == 0) {
            } else {
              setState(() {
                ++page;
              });
              fetchData();
            }
          }
        });
    sl<AnalyticsService>().trackEvent(
      "transactionScreenPartner",
      eventProperties: {"currentBalance": _walletController.finalValue.value},
    );

    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void fetchData({bool isInit = false}) {
    _walletController.getWalletTransactionFetch(
      page,
      transactionCategory: _walletController.selectedTransactionTab.value,
      isInit: isInit,
    );
  }

  void _showDurationEarningsBottomSheet(int? transactionId) async {
    TransactionDetailsModel? transactionDetails;
    try {
      Get.context?.loaderOverlay.show();
      transactionDetails = await _walletController.getTransactionDetails(
        transactionId ?? 0,
      );
    } catch (_) {
    } finally {
      Get.context?.loaderOverlay.hide();
      if (transactionDetails != null) {
        Get.bottomSheet(
          TransactionDetailsBottomSheet(transactionDetails: transactionDetails),
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
    }
  }

  void _showPayoutBottomSheet(int? transactionId, String createdAt) async {
    GetPayoutBreakdownResponse? payoutBreakdownResponse;
    try {
      Get.context?.loaderOverlay.show();
      payoutBreakdownResponse = await _walletController.getPayoutBreakdown(
        transactionId ?? 0,
      );
      if (payoutBreakdownResponse != null) {
        Get.bottomSheet(
          PayoutDetailsBottomsheet(
            payoutBreakdown: payoutBreakdownResponse,
            createdAt: createdAt,
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
    } catch (e) {
      Logger.logMessage(
        "Error while fetching payout breakdown ${e.toString()}",
      );
    } finally {
      Get.context?.loaderOverlay.hide();
    }
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
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          SchedulerBinding.instance.addPostFrameCallback((_) {
            _walletController.transactions.clear();
          });
        }
      },
      child: GetBuilder<WalletController>(
        builder: (controller) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: CustomAppBar(title: LocaleKeys.liveTransactions.tr),
            body: SafeArea(
              child: DefaultTabController(
                length: TransactionCategory.values.length,
                child: Column(
                  children: [
                    Container(
                      constraints: const BoxConstraints.expand(height: 36.0),
                      child: TabBar(
                        isScrollable: true,
                        labelPadding: const EdgeInsets.symmetric(
                          horizontal: 6.0,
                        ),
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
                                    key: Key(transactionCategory.displayName),
                                    child:
                                        transactionCategory ==
                                                TransactionCategory.CALL
                                            ? CustomTab(
                                              label: liveTransactionLabel(
                                                transactionCategory,
                                              ),
                                              selected:
                                                  transactionCategory ==
                                                  controller
                                                      .selectedTransactionTab
                                                      .value,
                                              padding:
                                                  const EdgeInsets.symmetric(
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
                                              unselectedContentColor:
                                                  Colors.black45,
                                              borderColor: Colors.black45,
                                            )
                                            : CustomTab(
                                              label: liveTransactionLabel(
                                                transactionCategory,
                                              ),
                                              selected:
                                                  transactionCategory ==
                                                  controller
                                                      .selectedTransactionTab
                                                      .value,
                                              padding:
                                                  const EdgeInsets.symmetric(
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
                                              unselectedContentColor:
                                                  Colors.black45,
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
                          return (controller.transactions.isEmpty &&
                                  controller.isLoading.value)
                              ? const Center(child: CircularProgressIndicator())
                              : controller.transactions.isEmpty
                              ? Center(
                                child: Text(
                                  LocaleKeys.liveNoTransactionFound.tr,
                                ),
                              )
                              : RefreshIndicator(
                                onRefresh: () async {
                                  setState(() {
                                    page = 1;
                                  });
                                  fetchData();
                                  return;
                                },
                                child: ListView.separated(
                                  controller: _scrollController,
                                  itemCount: controller.transactions.length,
                                  separatorBuilder: (_, index) {
                                    return const Divider(
                                      indent: 24.0,
                                      endIndent: 24.0,
                                      height: 0.0,
                                    );
                                  },
                                  itemBuilder: (context, index) {
                                    if (index >=
                                        controller.transactions.length) {
                                      return const SizedBox.shrink();
                                    }
                                    var ds =
                                        controller.transactions.toList()[index];
                                    bool isPlus =
                                        ds.action?.toUpperCase() == "PLUS";
                                    bool isCall =
                                        (ds.type == TransactionType.Call) ||
                                        (ds.type ==
                                            TransactionType.MissedCall) ||
                                        (ds.type == TransactionType.Chat) ||
                                        (ds.type == TransactionType.Game);
                                    final holdStatus =
                                        ds.holdStatus ?? HoldStatus.Paid;
                                    final isNewMonth =
                                        index == 0 ||
                                        !isSameMonth(
                                          ds.createdAt,
                                          controller.transactions
                                              .toList()[index - 1]
                                              .createdAt,
                                        );
                                    return Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                                DateTime.tryParse(
                                                      ds.createdAt ?? "",
                                                    ) ??
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
                                                  if (ds.type ==
                                                          TransactionType
                                                              .Call ||
                                                      ds.type ==
                                                          TransactionType
                                                              .Game) {
                                                    _showDurationEarningsBottomSheet(
                                                      ds.iD,
                                                    );
                                                  }
                                                },
                                                title: Text(
                                                  ds.title ?? '',
                                                  style: TextStyle(
                                                    color:
                                                        isPlus
                                                            ? (holdStatus
                                                                .labelColor)
                                                            : Colors.red,
                                                    fontSize: FontSize.L,
                                                  ),
                                                ),
                                                visualDensity:
                                                    VisualDensity.compact,
                                                subtitle: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
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
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .end,
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            Text(
                                                              "${holdStatus == HoldStatus.Paid ? (isPlus ? '+' : '-') : ''} ₹${ds.getAmount?.toStringAsFixed(2)}",
                                                              maxLines: 1,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              textAlign:
                                                                  TextAlign
                                                                      .right,
                                                              style: TextStyle(
                                                                color:
                                                                    isPlus
                                                                        ? (holdStatus
                                                                            .earningColor)
                                                                        : Colors
                                                                            .red,
                                                              ),
                                                            ),
                                                            Text(
                                                              holdStatus ==
                                                                      HoldStatus
                                                                          .Paid
                                                                  ? (isPlus
                                                                      ? 'Completed'
                                                                      : 'Deducted')
                                                                  : (holdStatus ==
                                                                          HoldStatus
                                                                              .Hold
                                                                      ? 'Pending'
                                                                      : 'No earning'),
                                                              maxLines: 1,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              textAlign:
                                                                  TextAlign
                                                                      .right,
                                                              style: TextStyle(
                                                                color:
                                                                    isPlus
                                                                        ? (holdStatus
                                                                            .earningColor)
                                                                        : Colors
                                                                            .red,
                                                                fontSize:
                                                                    FontSize.M,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets.only(
                                                              left: 8.0,
                                                            ),
                                                        child: Visibility(
                                                          visible:
                                                              ds.type ==
                                                                  TransactionType
                                                                      .Call ||
                                                              ds.type ==
                                                                  TransactionType
                                                                      .Game,
                                                          replacement:
                                                              const SizedBox(
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
                                                              shape:
                                                                  BoxShape
                                                                      .circle,
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
                                                      TransactionType
                                                          .Withdrawal) {
                                                    _showPayoutBottomSheet(
                                                      ds.iD,
                                                      ds.createdAt ?? "",
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
                                                visualDensity:
                                                    VisualDensity.compact,
                                                subtitle: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                        top: 4.0,
                                                      ),
                                                  child: FittedBox(
                                                    fit: BoxFit.scaleDown,
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    child: Text(
                                                      '${ds.subtitle} ${ds.type == TransactionType.Refund ? '\n${Formatter.getFormattedDateTime(ds.createdAt ?? "")}' : ''}',
                                                      maxLines:
                                                          ds.type ==
                                                                  TransactionType
                                                                      .Refund
                                                              ? 2
                                                              : 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
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
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .end,
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            Text(
                                                              "${ds.type == TransactionType.Withdrawal ? "" : (isPlus ? '+' : '-')} ₹${ds.getAmount?.toStringAsFixed(2)}",
                                                              maxLines: 1,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              textAlign:
                                                                  TextAlign
                                                                      .right,
                                                              style: TextStyle(
                                                                color:
                                                                    isPlus
                                                                        ? Colors
                                                                            .green
                                                                        : Colors
                                                                            .red,
                                                              ),
                                                            ),
                                                            Text(
                                                              holdStatus ==
                                                                      HoldStatus
                                                                          .Paid
                                                                  ? (isPlus
                                                                      ? 'Completed'
                                                                      : 'Deducted')
                                                                  : (holdStatus ==
                                                                          HoldStatus
                                                                              .Hold
                                                                      ? 'Pending'
                                                                      : 'No earning'),
                                                              maxLines: 1,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              textAlign:
                                                                  TextAlign
                                                                      .right,
                                                              style: TextStyle(
                                                                color:
                                                                    isPlus
                                                                        ? (holdStatus
                                                                            .earningColor)
                                                                        : Colors
                                                                            .red,
                                                                fontSize:
                                                                    FontSize.M,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets.only(
                                                              left: 8.0,
                                                            ),
                                                        child: Visibility(
                                                          visible:
                                                              ds.type ==
                                                              TransactionType
                                                                  .Withdrawal,
                                                          replacement:
                                                              const SizedBox(
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
                                                              shape:
                                                                  BoxShape
                                                                      .circle,
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
                                  },
                                ),
                              );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
