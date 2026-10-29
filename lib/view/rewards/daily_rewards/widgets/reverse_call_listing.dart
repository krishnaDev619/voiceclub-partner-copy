import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/core/injection_container.dart';
import 'package:voiceclub_partner/core/services/alert_service.dart';
import 'package:voiceclub_partner/data/models/account/reverse_call_user.dart';
import 'package:voiceclub_partner/data/models/chat/member.dart';
import 'package:voiceclub_partner/domain/usecases/calling/get_reverse_calling_stats.dart';
import 'package:voiceclub_partner/modules/controller/reverse_call_list_controller.dart';
import 'package:voiceclub_partner/modules/controller/rewards_controller.dart';
import 'package:voiceclub_partner/modules/controller/user_controller.dart';
import 'package:voiceclub_partner/view/chat/widgets/outgoing_call_dialog.dart';
import 'package:voiceclub_partner/view/rewards/daily_rewards/widgets/rewards_progress_bar.dart';
import 'package:voiceclub_partner/view/widgets/custom_profile_picture.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';

class ReverseCallListing extends StatefulWidget {
  const ReverseCallListing({super.key});

  @override
  State<ReverseCallListing> createState() => _ReverseCallListingState();
}

class _ReverseCallListingState extends State<ReverseCallListing> {
  int currentPage = 1;
  late ScrollController _scrollController;
  final controller = Get.find<ReverseCallListController>();
  final rewardsController = Get.find<RewardsController>();

  @override
  void initState() {
    _scrollController =
        ScrollController()..addListener(() {
          if (_scrollController.position.atEdge) {
            if (_scrollController.position.pixels != 0) {
              if (currentPage <= controller.totalPages.value) {
                setState(() {
                  currentPage++;
                });
                controller.fetchReverseCalls(page: currentPage);
              }
            }
          }
        });
    super.initState();
  }

  void openReverseCallDialog({required ReverseCallUser user}) async {
    try {
      Get.context?.loaderOverlay.show();
      var response = await sl<GetReverseCallingStatsUsecase>().call(
        GetReverseCallingStatsParams(demandAccountId: user.accountId ?? 0),
      );
      if (response.data != null && response.error == null) {
        final reverseCallingStatsResponse = response.data;
        if (reverseCallingStatsResponse != null) {
          HapticFeedback.vibrate();
          Get.dialog(
            OutgoingCallDialog(
              reverseCallingStatsResponse: reverseCallingStatsResponse,
              demandPeer: ChatMember(
                accountId: user.accountId ?? 0,
                user: user.user,
              ),
              screenName: 'ReverseCallListing',
            ),
          );
        } else {
          outgoingCallFailedSnackBar();
        }
      } else {
        outgoingCallFailedSnackBar();
      }
    } catch (_) {
      outgoingCallFailedSnackBar();
    } finally {
      Get.context?.loaderOverlay.hide();
    }
  }

  void outgoingCallFailedSnackBar() {
    AlertService.showSnackBar(
      snackBarType: SnackBarType.Error,
      title: LocaleKeys.liveCallFailed.tr,
      subtitle: LocaleKeys.livePleaseTryAgainLater.tr,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          LocaleKeys.liveReverseCall.tr,
          style: const TextStyle(
            fontWeight: Weight.heavy,
            fontSize: 20,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.1,
      ),
      body: Obx(() {
        return RefreshIndicator(
          triggerMode: RefreshIndicatorTriggerMode.anywhere,
          onRefresh: () async {
            controller.fetchReverseCalls(page: 1);
            rewardsController.fetchRewardsStats();
            Get.find<UserController>().getOnlineDuration();
          },
          child: SingleChildScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                if (rewardsController.rewardsStats.value?.reverseCalls != null)
                  RewardsProgressBar(
                    rewards:
                        rewardsController.rewardsStats.value!.reverseCalls!,
                    type: RewardsProgressBarType.reverseCalls,
                  ),

                controller.reverseCallsList.isNotEmpty
                    ? ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: controller.reverseCallsList.length,
                      itemBuilder: (context, index) {
                        final user =
                            controller.reverseCallsList.toList()[index];
                        return ListTile(
                          minLeadingWidth: 10.0,
                          leading: CustomProfilePicture(
                            name: user.user?.name ?? "",
                            avatarURL: user.user?.avatar ?? "",
                            radius: 20.0,
                          ),
                          dense: true,
                          title: Text(
                            user.user?.name ?? "",
                            style: const TextStyle(
                              fontWeight: Weight.heavy,
                              fontSize: FontSize.xL,
                            ),
                          ),
                          trailing:
                              index == 0
                                  ? GestureDetector(
                                    onTap: () {
                                      openReverseCallDialog(user: user);
                                    },
                                    child: Container(
                                      width: 80.0,
                                      decoration: BoxDecoration(
                                        color: Get.theme.primaryColor,
                                        borderRadius: BorderRadius.circular(
                                          5.0,
                                        ),
                                      ),
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 8.0,
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              LocaleKeys.liveCall.tr,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: Weight.heavy,
                                              ),
                                            ),
                                            Icon(
                                              Icons.call,
                                              color: Colors.white,
                                              size: 14.0,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  )
                                  : GestureDetector(
                                    onTap: () {
                                      openReverseCallDialog(user: user);
                                    },
                                    child: Container(
                                      width: 80.0,
                                      decoration: BoxDecoration(
                                        color: Get.theme.primaryColor,
                                        borderRadius: BorderRadius.circular(
                                          5.0,
                                        ),
                                      ),
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 8.0,
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              LocaleKeys.liveCall.tr,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: Weight.heavy,
                                              ),
                                            ),
                                            Icon(
                                              Icons.call,
                                              color: Colors.white,
                                              size: 14.0,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                        );
                      },
                    )
                    : controller.isLoading.value
                    ? Padding(
                      padding: EdgeInsets.only(top: Get.height * 0.3),
                      child: const Center(child: CircularProgressIndicator()),
                    )
                    : Padding(
                      padding: EdgeInsets.only(top: Get.height * 0.3),
                      child: Center(
                        child: Text(LocaleKeys.liveNoCallsFound.tr),
                      ),
                    ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
