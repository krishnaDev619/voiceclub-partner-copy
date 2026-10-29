import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/core/injection_container.dart';
import 'package:voiceclub_partner/core/services/analytics_service.dart';
import 'package:voiceclub_partner/modules/controller/wallet_controller.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';
import 'package:voiceclub_partner/view/milestone/widgets/lifetime_rewards_section.dart';
import 'package:voiceclub_partner/view/milestone/widgets/yearly_rewards_section.dart';

class MilestoneRewardsScreen extends StatefulWidget {
  final int currentYearlyEarning;
  final int currentLifetimeEarning;
  final int selectedTabIndex;
  final bool isFromHomeScreen;

  const MilestoneRewardsScreen({
    super.key,
    required this.currentYearlyEarning,
    required this.currentLifetimeEarning,
    this.selectedTabIndex = 0,
    this.isFromHomeScreen = false,
  });

  @override
  State<MilestoneRewardsScreen> createState() => _MilestoneRewardsScreenState();
}

class _MilestoneRewardsScreenState extends State<MilestoneRewardsScreen> {
  int selectedTab = 0;
  @override
  void initState() {
    super.initState();
    sl<AnalyticsService>().trackEvent(
      "milestoneRewardsScreen",
      eventProperties: {
        "currentYearlyEarning": widget.currentYearlyEarning,
        "currentLifetimeEarning": widget.currentLifetimeEarning,
        "payoutCount":
            Get.find<WalletController>().payoutCountResponse.value.payoutCount,
        "isFromHomeScreen": widget.isFromHomeScreen,
      },
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        selectedTab = widget.selectedTabIndex;
      });
    });
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) super.setState(fn);
  }

  ({bool isToday, String formattedDate}) getNextPayoutDate() {
    final today = DateTime.now();
    final currentDay = today.day;
    final daysInMonth = DateTime(today.year, today.month + 1, 0).day;

    if (currentDay == 10 || currentDay == 20 || currentDay == daysInMonth) {
      return (isToday: true, formattedDate: LocaleKeys.liveToday.tr);
    }
    if (currentDay < 10) {
      return (
        isToday: false,
        formattedDate: DateFormat('10 MMM yyyy').format(today),
      );
    }
    if (currentDay < 20) {
      return (
        isToday: false,
        formattedDate: DateFormat('20 MMM yyyy').format(today),
      );
    }
    return (
      isToday: false,
      formattedDate: DateFormat('$daysInMonth MMM yyyy').format(today),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildTabBar(),
            Expanded(
              child:
                  selectedTab == 0
                      ? YearlyRewardsSection(
                        currentYearlyEarning: widget.currentYearlyEarning,
                      )
                      : LifetimeRewardsSection(
                        currentLifetimeEarning: widget.currentLifetimeEarning,
                      ),
            ),
            _buildFooterNote(),
          ],
        ),
      ),
    );
  }

  // 1. Tab Bar
  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF5F5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        mainAxisSize: MainAxisSize.min,
        children: [
          _tabButton(LocaleKeys.liveYearlyRewards.tr, selectedTab == 0, 0),
          _tabButton(LocaleKeys.liveLifetimeRewards.tr, selectedTab == 1, 1),
        ],
      ),
    );
  }

  Widget _tabButton(String title, bool isSelected, int tabIndex) {
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            selectedTab = tabIndex;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 2.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: isSelected ? Gradients.primaryGradient() : null,
          ),
          child: Center(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 4. Footer Note
  Widget _buildFooterNote() {
    final payoutInfo = getNextPayoutDate();
    final earningsNote =
        payoutInfo.isToday
            ? LocaleKeys.liveEarningsUpToDate.tr
            : LocaleKeys.liveEarningsWillUpdateOn.trParams({
              'date': payoutInfo.formattedDate,
            });
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Divider(height: 0.0),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.info_outline, size: 16, color: Colors.grey),
              const SizedBox(width: 12.0),
              Expanded(
                child: Text(
                  '$earningsNote\n${LocaleKeys.liveMilestoneRewardsActiveSince.tr}',
                  style: const TextStyle(color: Colors.grey, fontSize: 10),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
