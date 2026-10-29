import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/core/services/formatter.dart';
import 'package:voiceclub_partner/view/tutorial/demo/widgets/home/demo_home_action_card.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';
import 'package:voiceclub_partner/view/tutorial/demo/demo_labels.dart';

class DemoOverviewWidget extends StatefulWidget {
  const DemoOverviewWidget({super.key});

  @override
  State<DemoOverviewWidget> createState() => _DemoOverviewWidgetState();
}

class _DemoOverviewWidgetState extends State<DemoOverviewWidget>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  final List<OverviewFilter> _overViewFilter = [
    OverviewFilter.ThisWeek,
    OverviewFilter.ThisMonth,
    OverviewFilter.LastMonth,
  ];
  OverviewFilter overviewFilter = OverviewFilter.Today;
  OverviewFilter thirdSelectedOverviewFilter = OverviewFilter.ThisWeek;
  bool isOverviewExpanded = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      color: Colors.white,
      margin: EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: .0),
        child: ListTileTheme(
          minVerticalPadding: 0.0,
          child: ExpansionTile(
            title: DemoHomeActionCardContent(
              title: LocaleKeys.demoOverview.tr,
              isCardExpandable: true,
              isCardExpanded: isOverviewExpanded,
            ),
            onExpansionChanged: (newValue) {
              setState(() {
                isOverviewExpanded = newValue;
              });
            },
            tilePadding: EdgeInsets.zero,
            shape: Border.fromBorderSide(BorderSide.none),
            collapsedShape: Border.fromBorderSide(BorderSide.none),
            childrenPadding: EdgeInsets.zero,
            showTrailingIcon: false,
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
                        Text(LocaleKeys.demoToday.tr),
                        Text(LocaleKeys.demoYesterday.tr),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            demoOverviewLabel(thirdSelectedOverviewFilter),
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
                                (element) =>
                                    element != thirdSelectedOverviewFilter,
                              )
                              .map(
                                (e) => PopupMenuItem<OverviewFilter>(
                                  value: e,
                                  child: Text(demoOverviewLabel(e)),
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
              ListView(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  const SizedBox(height: 8.0),
                  ListTile(
                    dense: true,
                    visualDensity: VisualDensity.compact,
                    leading: Text(
                      LocaleKeys.demoEarning.tr,
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    trailing: Text(
                      "₹${Formatter.formatStringToLargeNumber(overviewFilter == OverviewFilter.Today ? "400" : "200")}",
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    dense: true,
                    visualDensity: VisualDensity.compact,
                    leading: Text(
                      LocaleKeys.demoMinutes.tr,
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    trailing: Text(
                      Formatter.formatStringToLargeNumber(
                        Formatter.formattedTime(
                          timeInSecond:
                              overviewFilter == OverviewFilter.Today
                                  ? 4394
                                  : 2549,
                        ),
                      ),
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    dense: true,
                    visualDensity: VisualDensity.compact,
                    leading: Text(
                      LocaleKeys.demoCalls.tr,
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    trailing: Text(
                      Formatter.formatLargeNumber(
                        overviewFilter == OverviewFilter.Today ? 24 : 12,
                      ),
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    dense: true,
                    visualDensity: VisualDensity.compact,
                    leading: Text(
                      LocaleKeys.demoMissed.tr,
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    trailing: Text(
                      Formatter.formatLargeNumber(
                        overviewFilter == OverviewFilter.Today ? 5 : 1,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
