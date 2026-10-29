import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/core/injection_container.dart';
import 'package:voiceclub_partner/data/models/wallet/get_overview_response.dart';
import 'package:voiceclub_partner/domain/usecases/wallet/get_overview.dart';
import 'package:voiceclub_partner/view/home/widgets/earning_overview_widget.dart';
import 'package:voiceclub_partner/view/logs/logs_controller.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';
import 'package:voiceclub_partner/view/home/home_labels.dart';

class OverviewWidget extends StatefulWidget {
  final void Function(BottomBarTabType) changeTab;

  const OverviewWidget({super.key, required this.changeTab});

  @override
  State<OverviewWidget> createState() => _OverviewWidgetState();
}

class _OverviewWidgetState extends State<OverviewWidget>
    with SingleTickerProviderStateMixin {
  final _getSupplyWalletStreamController =
      StreamController<GetOverviewResponseModel>();
  TabController? _tabController;
  final List<OverviewFilter> _overViewFilter = [
    OverviewFilter.ThisWeek,
    OverviewFilter.ThisMonth,
    OverviewFilter.LastMonth,
  ];
  OverviewFilter overviewFilter = OverviewFilter.Today;
  OverviewFilter thirdSelectedOverviewFilter = OverviewFilter.ThisWeek;
  final supplyLogsController = Get.find<LogsController>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchOverviewData(overviewFilter: overviewFilter);
  }

  @override
  void dispose() {
    _getSupplyWalletStreamController.close();
    _tabController?.dispose();
    super.dispose();
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  void updateOverviewFilter(OverviewFilter newFilter) {
    if (newFilter != overviewFilter) {
      setState(() {
        overviewFilter = newFilter;
      });
      _fetchOverviewData(overviewFilter: overviewFilter);
    }
  }

  Future<void> _fetchOverviewData({
    required OverviewFilter overviewFilter,
  }) async {
    var dsData = await sl<GetOverviewUsecase>().call(
      Params(overviewFilter: overviewFilter),
    );
    if (dsData.data != null) {
      _getSupplyWalletStreamController.add(dsData.data!);
    }
    await supplyLogsController.fetchLogs(overviewFilter: overviewFilter);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(12.0)),
        color: Colors.white,
      ),
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 40.0,
            child: Stack(
              children: [
                TabBar(
                  controller: _tabController,
                  padding: const EdgeInsets.symmetric(horizontal: 3.0),
                  labelPadding: const EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 2.0,
                  ),
                  unselectedLabelColor: Colors.black45,
                  labelColor: Get.theme.primaryColor,
                  unselectedLabelStyle: TextStyle(
                    fontFamily: GoogleFonts.mulish().fontFamily,
                    fontSize: FontSize.L,
                    fontWeight: FontWeight.bold,
                    color: Colors.transparent,
                  ),
                  labelStyle: TextStyle(
                    fontFamily: GoogleFonts.mulish().fontFamily,
                    fontSize: FontSize.L,
                    fontWeight: FontWeight.bold,
                    color: Get.theme.primaryColor,
                  ),
                  indicatorWeight: 3,
                  indicatorSize: TabBarIndicatorSize.label,
                  indicatorColor: Get.theme.primaryColor,
                  indicator: UnderlineTabIndicator(
                    borderSide: BorderSide(
                      color: Get.theme.primaryColor,
                      width: 3.0,
                    ),
                    borderRadius: BorderRadius.circular(3.0),
                  ),
                  onTap: (value) {
                    switch (value) {
                      case 0:
                        updateOverviewFilter(OverviewFilter.Today);
                        break;
                      case 1:
                        updateOverviewFilter(OverviewFilter.Yesterday);
                        break;
                      case 2:
                        updateOverviewFilter(thirdSelectedOverviewFilter);
                        break;
                    }
                  },
                  tabAlignment: TabAlignment.fill,
                  tabs: [
                    Text(LocaleKeys.homeToday.tr),
                    Text(LocaleKeys.homeYesterday.tr),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        homeOverviewLabel(thirdSelectedOverviewFilter),
                      ),
                    ),
                  ],
                ),
                Positioned(
                  right: 0.0,
                  top: 8.0,
                  child: PopupMenuButton<OverviewFilter>(
                    onSelected: (value) {
                      setState(() {
                        thirdSelectedOverviewFilter = value;
                      });
                      updateOverviewFilter(thirdSelectedOverviewFilter);
                    },
                    position: PopupMenuPosition.under,
                    itemBuilder: (context) {
                      return _overViewFilter
                          .where(
                            (element) => element != thirdSelectedOverviewFilter,
                          )
                          .map(
                            (e) => PopupMenuItem<OverviewFilter>(
                              value: e,
                              child: Text(homeOverviewLabel(e)),
                            ),
                          )
                          .toList();
                    },
                    child: Icon(
                      Icons.keyboard_arrow_down_outlined,
                      color: Get.theme.primaryColor,
                      size: 20.0,
                    ),
                  ),
                ),
                const Positioned(
                  right: 0.0,
                  left: 0.0,
                  bottom: -3.0,
                  child: Divider(),
                ),
              ],
            ),
          ),
          StreamBuilder<GetOverviewResponseModel>(
            stream: _getSupplyWalletStreamController.stream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.active) {
                var dsValue = snapshot.data;
                final logsResponse = supplyLogsController.logsResponse.value;
                if (dsValue != null) {
                  return EarningOverviewWidget(
                    calls: dsValue.overviewData?.totalCalls ?? 0,
                    earning:
                        dsValue.overviewData?.totalAmount?.toStringAsFixed(2) ??
                        "",
                    missed: logsResponse.missedCall ?? 0,
                    overviewFilter: overviewFilter,
                    changeTab: widget.changeTab,
                  );
                } else {
                  return SizedBox(
                    height: Get.height / 3,
                    child: Center(child: Text(LocaleKeys.homeNoData.tr)),
                  );
                }
              } else if (snapshot.connectionState == ConnectionState.waiting) {
                return SizedBox(
                  height: Get.height / 3,
                  child: const Center(
                    child: SizedBox(
                      height: 24.0,
                      width: 24.0,
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    ),
                  ),
                );
              } else {
                return SizedBox(
                  height: Get.height / 3,
                  child: Center(child: Text(LocaleKeys.homeNoData.tr)),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
