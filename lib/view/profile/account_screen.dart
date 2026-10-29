import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/constants/url_constants.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/core/injection_container.dart';
import 'package:voiceclub_partner/core/services/alert_service.dart';
import 'package:voiceclub_partner/core/services/analytics_service.dart';
import 'package:voiceclub_partner/core/services/app_info_service.dart';
import 'package:voiceclub_partner/core/services/auth_service.dart';
import 'package:voiceclub_partner/core/services/intro_audio_policy_service.dart';
import 'package:voiceclub_partner/modules/controller/user_controller.dart';
import 'package:voiceclub_partner/view/milestone/widgets/milestone_rewards_widget.dart';
import 'package:voiceclub_partner/view/profile/blocklist_screen.dart';
import 'package:voiceclub_partner/view/profile/record_voices_screen.dart';
import 'package:voiceclub_partner/view/profile/troubleshooting_screen.dart';
import 'package:voiceclub_partner/view/profile/widgets/custom_tile.dart';
import 'package:voiceclub_partner/view/tutorial/demo/widgets/core/disabled_widget.dart';
import 'package:voiceclub_partner/view/widgets/custom_app_bar.dart';
import 'package:voiceclub_partner/view/widgets/custom_profile_picture.dart';
import 'package:voiceclub_partner/view/widgets/notification_switch_bottom_sheet.dart';
import 'package:voiceclub_partner/web.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final controller = Get.find<UserController>();
  final _authService = sl<AuthService>();

  @override
  void initState() {
    sl<AnalyticsService>().trackEvent("partnerAccountScreen");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final userDetails = controller.userDetails.value;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(title: ""),
      body: SafeArea(
        child: Obx(() {
          return SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 48.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 16.0,
                          bottom: 8.0,
                          left: 16.0,
                        ),
                        child: CustomProfilePicture(
                          avatarURL: userDetails.user?.avatar ?? '',
                          name: userDetails.user?.name ?? '',
                          backgroundColor: Get.theme.primaryColor,
                          radius: 36.0,
                        ),
                      ),
                      const SizedBox(width: 16.0),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8.0),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                userDetails.user?.name ??
                                    LocaleKeys.demoAnon.tr,
                                style: const TextStyle(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8.0),
                              const Icon(
                                Icons.verified,
                                color: Colors.green,
                                size: 18.0,
                              ),
                            ],
                          ),
                          InkWell(
                            onTap: () {
                              Clipboard.setData(
                                ClipboardData(
                                  text: userDetails.accountId?.toString() ?? "",
                                ),
                              );
                              AlertService.showSnackBar(
                                snackBarType: SnackBarType.Success,
                                title: LocaleKeys.homeIdCopied.tr,
                                subtitle: LocaleKeys.homeShareWithManager.tr,
                              );
                            },
                            child: Chip(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              backgroundColor: const Color(0xFFFFD9D8),
                              label: Text(
                                LocaleKeys.homeAccountId.trParams({
                                  'id': userDetails.accountId?.toString() ?? '',
                                }),
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),

                          SizedBox(
                            height: 20,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (userDetails.kamName?.isNotEmpty ?? false)
                                  Text(
                                    LocaleKeys.demoManagerName.trParams({
                                      'name': userDetails.kamName?.trim() ?? '',
                                    }),
                                    style: const TextStyle(
                                      color: ApplicationColors.grey,
                                      fontSize: FontSize.L,
                                    ),
                                  ),
                                const SizedBox(width: 6.0),
                                CircleAvatar(
                                  backgroundColor: Colors.grey,
                                  radius: 2.5,
                                ),
                                const SizedBox(width: 6.0),
                                FutureBuilder<AppInfo>(
                                  future: AppInfoService().getAppInfo(),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData) {
                                      return Center(
                                        child: Text(
                                          "v${snapshot.data?.version}",
                                          style: TextStyle(
                                            color: Colors.grey.shade500,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      );
                                    }
                                    return const SizedBox.shrink();
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const MilestoneRewardsWidget(),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (sl<IntroAudioPolicyService>()
                        .shouldShowAccountRecordVoices(
                          stage: controller.currentStage,
                          hasUploadedAllAudios: controller.hasUploadedAllAudios,
                          audioApprovalStatus: controller.audioApprovalStatus,
                          accountId: controller.accountId,
                        ))
                      CustomTile(
                        title: LocaleKeys.liveRecordYourVoices.tr,
                        icon: Icons.record_voice_over,
                        onTap: () {
                          Get.to(() => const RecordVoicesScreen());
                        },
                      ),

                    // CustomTile(
                    //   title: "Raise Complaint",
                    //   icon: Icons.support_agent,
                    //   onTap: () {
                    //     Get.to(() => const ComplaintScreen());
                    //   },
                    // ),
                    const SizedBox(height: 10),
                    Disabled(
                      disabled: controller.isOnlineOrBusy,
                      child: CustomTile(
                        title: LocaleKeys.liveDeviceHealthTroubleshooting.tr,
                        icon: Icons.troubleshoot,
                        onTap: () {
                          Get.to(() => const TroubleshootingScreen());
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    CustomTile(
                      title: LocaleKeys.liveNotifications.tr,
                      icon:
                          controller.isNotificationsEnabled
                              ? Icons.notifications
                              : Icons.notifications_off,
                      onTap: () {
                        Get.bottomSheet(const NotificationSwitchBottomSheet());
                      },
                    ),
                    const SizedBox(height: 10),
                    CustomTile(
                      title: LocaleKeys.liveBlocklist.tr,
                      icon: Icons.supervised_user_circle_sharp,
                      onTap: () {
                        Get.to(() => const BlocklistScreen());
                      },
                    ),
                    const SizedBox(height: 10),
                    if (userDetails.aadharSignDone == true ||
                        userDetails.kycCompleted == true)
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          VerificationTile(
                            key: UniqueKey(),
                            userId: userDetails.user?.id ?? 0,
                            isVerified:
                                userDetails.aadharSignDone == true ||
                                userDetails.kycCompleted == true,
                            phone: userDetails.user?.phoneNumber ?? '',
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    CustomTile(
                      onTap: controller.updateLockStatus,
                      icon: Icons.lock_rounded,
                      title: LocaleKeys.liveLockYourApp.tr,
                      trailing: Switch(
                        value: controller.isAppLockEnabled.value,
                        onChanged: (value) {
                          controller.updateLockStatus();
                        },
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    CustomTile(
                      onTap: () {
                        Get.to(
                          () => WebViewExample(
                            title: LocaleKeys.privacyPolicy.tr,
                            url: URLConstants.privacyPolicyUrl,
                          ),
                        );
                      },
                      title: LocaleKeys.privacyPolicy.tr,
                      icon: Icons.privacy_tip,
                    ),
                    const SizedBox(height: 10),
                    CustomTile(
                      onTap: () {
                        Get.dialog(
                          AlertDialog(
                            title: Text(
                              LocaleKeys.liveLogoutConfirm.tr,
                              style: const TextStyle(fontSize: 13),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Get.back();
                                },
                                child: Text(LocaleKeys.cancel.tr),
                              ),
                              TextButton(
                                onPressed: () {
                                  _authService.logout();
                                },
                                child: Text(LocaleKeys.logout.tr),
                              ),
                            ],
                          ),
                        );
                      },
                      title: LocaleKeys.logout.tr,
                      icon: Icons.logout_rounded,
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
