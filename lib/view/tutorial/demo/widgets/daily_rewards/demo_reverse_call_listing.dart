import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/core/services/alert_service.dart';
import 'package:voiceclub_partner/data/models/account/rewards_stats.dart';
import 'package:voiceclub_partner/view/rewards/daily_rewards/widgets/rewards_progress_bar.dart';
import 'package:voiceclub_partner/view/tutorial/demo/controllers/demo_landing_controller.dart';
import 'package:voiceclub_partner/view/widgets/custom_profile_picture.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';

class DemoReverseCallListing extends StatefulWidget {
  final IncentiveCalls reverseCalls;
  const DemoReverseCallListing({super.key, required this.reverseCalls});

  @override
  State<DemoReverseCallListing> createState() => _DemoReverseCallListingState();
}

class _DemoReverseCallListingState extends State<DemoReverseCallListing> {
  int currentPage = 1;
  final controller = Get.find<DemoLandingController>();

  @override
  void initState() {
    super.initState();
  }

  void outgoingCallFailedSnackBar() {
    AlertService.showSnackBar(
      snackBarType: SnackBarType.Error,
      title: LocaleKeys.demoCallFailed.tr,
      subtitle: LocaleKeys.demoTryAgain.tr,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          LocaleKeys.demoReverseCall.tr,
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
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            RewardsProgressBar(
              rewards: widget.reverseCalls,
              type: RewardsProgressBarType.reverseCalls,
            ),
            const SizedBox(height: 10.0),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.reverseCallsData.users?.length,
              itemBuilder: (context, index) {
                final user = controller.reverseCallsData.users?[index];
                return ListTile(
                  minLeadingWidth: 10.0,
                  leading: CustomProfilePicture(
                    name: user?.user?.name ?? "",
                    avatarURL: user?.user?.avatar ?? "",
                    radius: 20.0,
                  ),
                  dense: true,
                  title: Text(
                    user?.user?.name ?? "",
                    style: const TextStyle(
                      fontWeight: Weight.heavy,
                      fontSize: FontSize.xL,
                    ),
                  ),
                  trailing: GestureDetector(
                    onTap: () async {
                      await Get.defaultDialog(
                        title: LocaleKeys.demoReverseCall.tr,
                        titleStyle: const TextStyle(
                          color: ApplicationColors.gossip,
                          fontWeight: FontWeight.bold,
                        ),
                        middleText: LocaleKeys.demoPlacedReverseCall.trParams({
                          'name': user?.user?.name ?? '',
                        }),
                        middleTextStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                        textConfirm: LocaleKeys.okay.tr,
                        onConfirm: () => Get.back(),
                      );
                      controller.validateAction(
                        TutorialDemoFeature.DAILY_REWARD_REVERSE_CALL,
                      );
                    },
                    child: Container(
                      width: 80.0,
                      decoration: BoxDecoration(
                        color: Get.theme.primaryColor,
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              LocaleKeys.demoCallButton.tr,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: Weight.heavy,
                              ),
                            ),
                            Icon(Icons.call, color: Colors.white, size: 14.0),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
