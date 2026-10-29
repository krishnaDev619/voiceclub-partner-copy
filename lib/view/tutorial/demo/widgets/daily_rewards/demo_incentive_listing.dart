import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/data/models/account/rewards_stats.dart';
import 'package:voiceclub_partner/view/rewards/daily_rewards/widgets/rewards_progress_bar.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';

class DemoIncentiveListing extends StatefulWidget {
  final IncentiveCalls incentiveCalls;
  const DemoIncentiveListing({super.key, required this.incentiveCalls});

  @override
  State<DemoIncentiveListing> createState() => _DemoIncentiveListingState();
}

class _DemoIncentiveListingState extends State<DemoIncentiveListing> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          LocaleKeys.demo30MinReward.tr,
          style: TextStyle(
            fontWeight: Weight.heavy,
            fontSize: 20,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.1,
      ),
      body: SafeArea(
        child: SizedBox(
          height: Get.height,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                RewardsProgressBar(
                  rewards: widget.incentiveCalls,
                  type: RewardsProgressBarType.incentive,
                ),
                const SizedBox(height: 10.0),
                SizedBox(
                  height: 54.0,
                  child: TextField(
                    readOnly: true,
                    onTapOutside: (_) {
                      FocusManager.instance.primaryFocus?.unfocus();
                    },
                    decoration: InputDecoration(
                      hintText: LocaleKeys.demoSearch.tr,
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                    ),
                  ),
                ),
                const SizedBox(height: 10.0),
                Container(
                  padding: const EdgeInsets.all(6.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFFA2E479).withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: Row(
                    children: [
                      const Text("🤑", style: TextStyle(fontSize: 16.0)),
                      const SizedBox(width: 16.0),
                      Expanded(
                        child: Text(
                          LocaleKeys.demoCall30Min.tr,
                          style: TextStyle(color: Colors.black, fontSize: 12.0),
                        ),
                      ),
                    ],
                  ),
                ),
                Builder(
                  builder: (_) {
                    return Padding(
                      padding: EdgeInsets.only(top: Get.height * 0.3),
                      child: Center(
                        child: Text(LocaleKeys.demoNoUsersFound.tr),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
