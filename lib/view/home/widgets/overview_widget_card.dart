import 'package:flutter/material.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/view/home/widgets/home_actions_card.dart';
import 'package:voiceclub_partner/view/home/widgets/overview_widget.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';
import 'package:get/get.dart';

class OverviewWidgetCard extends StatefulWidget {
  final void Function(BottomBarTabType) changeTab;

  const OverviewWidgetCard({super.key, required this.changeTab});

  @override
  State<OverviewWidgetCard> createState() => _OverviewWidgetCardState();
}

class _OverviewWidgetCardState extends State<OverviewWidgetCard> {
  bool isOverviewExpanded = false;

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
            title: HomeActionCardContent(
              title: LocaleKeys.homeOverview.tr,
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
            children: [OverviewWidget(changeTab: widget.changeTab)],
          ),
        ),
      ),
    );
  }
}
