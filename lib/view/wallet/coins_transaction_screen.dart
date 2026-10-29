import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:voiceclub_partner/core/constants/asset_constants.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/core/injection_container.dart';
import 'package:voiceclub_partner/core/services/analytics_service.dart';
import 'package:voiceclub_partner/modules/controller/coins_transaction_controller.dart';
import 'package:voiceclub_partner/view/widgets/custom_app_bar.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';

class CoinsTransactionScreen extends StatefulWidget {
  const CoinsTransactionScreen({super.key});

  @override
  State<CoinsTransactionScreen> createState() => _CoinsTransactionScreenState();
}

class _CoinsTransactionScreenState extends State<CoinsTransactionScreen> {
  late ScrollController _scrollController;
  final _controller = Get.find<CoinsTransactionController>();
  int page = 1;

  @override
  void initState() {
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
      "coinsTransactionScreenPartner",
      eventProperties: {"currentBalance": _controller.coinBalance.value},
    );
    super.initState();
  }

  void fetchData({bool isInit = false}) {
    _controller.fetchCoinsTransaction(page, isInit: isInit);
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
      child: GetBuilder<CoinsTransactionController>(
        builder: (controller) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: CustomAppBar(title: LocaleKeys.liveTransactions.tr),
            body: SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: Obx(() {
                      return (controller.coinsTransactions.isEmpty &&
                              controller.isLoading.value)
                          ? const Center(child: CircularProgressIndicator())
                          : controller.coinsTransactions.isEmpty
                          ? Center(
                            child: Text(LocaleKeys.liveNoTransactionFound.tr),
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
                              itemCount: controller.coinsTransactions.length,
                              separatorBuilder: (_, index) {
                                return const Divider(
                                  indent: 24.0,
                                  endIndent: 24.0,
                                  height: 0.0,
                                );
                              },
                              itemBuilder: (context, index) {
                                if (index >=
                                    controller.coinsTransactions.length) {
                                  return const SizedBox.shrink();
                                }
                                var ds =
                                    controller.coinsTransactions
                                        .toList()[index];
                                final isNewMonth =
                                    index == 0 ||
                                    !isSameMonth(
                                      ds.createdAt,
                                      controller.coinsTransactions
                                          .toList()[index - 1]
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
                                    ListTile(
                                      minVerticalPadding: 16.0,
                                      leading: Container(
                                        padding: const EdgeInsets.all(10.0),
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Color(0xFFFFD8D8),
                                        ),
                                        child: SvgPicture.asset(
                                          AssetConstants.coinIc,
                                          width: 20.0,
                                          height: 20.0,
                                        ),
                                      ),
                                      title: Text(
                                        ds.title ?? '',
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: FontSize.L,
                                        ),
                                      ),
                                      visualDensity: VisualDensity.compact,
                                      subtitle: Padding(
                                        padding: const EdgeInsets.only(
                                          top: 4.0,
                                        ),
                                        child: Text(
                                          DateFormat(
                                            "dd MMM yyyy HH:mm",
                                          ).format(
                                            DateTime.tryParse(
                                                  ds.createdAt ?? "",
                                                )?.toLocal() ??
                                                DateTime.now(),
                                          ),
                                          style: const TextStyle(
                                            fontSize: FontSize.M,
                                            color: Colors.black54,
                                          ),
                                        ),
                                      ),
                                      selectedColor: Colors.black,
                                      dense: true,
                                      trailing: SizedBox(
                                        width: Get.width / 3,
                                        child: Text(
                                          "${ds.sign == PayoutItemSign.PLUS ? '+' : '-'} ${ds.amount?.toStringAsFixed(2)} Coins",
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.right,
                                          style: TextStyle(
                                            color:
                                                ds.sign == PayoutItemSign.PLUS
                                                    ? Colors.green
                                                    : Colors.red,
                                            fontSize: FontSize.xL,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          );
                    }),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
