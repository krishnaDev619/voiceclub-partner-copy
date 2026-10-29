import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/modules/controller/user_controller.dart';
import 'package:voiceclub_partner/view/profile/troubleshooting_screen.dart';
import 'package:voiceclub_partner/view/profile/widgets/custom_tile.dart';
import 'package:voiceclub_partner/view/tutorial/demo/controllers/demo_landing_controller.dart';
import 'package:voiceclub_partner/view/tutorial/demo/screens/demo_blocklist_screen.dart';
import 'package:voiceclub_partner/view/tutorial/demo/widgets/core/disabled_widget.dart';
import 'package:voiceclub_partner/view/tutorial/demo/widgets/home/demo_notification_switch_bottom_sheet.dart';
import 'package:voiceclub_partner/view/widgets/custom_app_bar.dart';
import 'package:voiceclub_partner/view/widgets/custom_profile_picture.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';

class DemoAccountScreen extends StatefulWidget {
  const DemoAccountScreen({super.key});

  @override
  State<DemoAccountScreen> createState() => _DemoAccountScreenState();
}

class _DemoAccountScreenState extends State<DemoAccountScreen> {
  final controller = Get.find<UserController>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final userDetails = controller.userDetails.value;
    final demoController = Get.find<DemoLandingController>();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(title: ""),
      body: Obx(() {
        return SingleChildScrollView(
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
                              userDetails.user?.name ?? LocaleKeys.demoAnon.tr,
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
                        Text(
                          LocaleKeys.demoVcPartnerDemo.tr,
                          style: TextStyle(
                            color: ApplicationColors.grey,
                            fontSize: FontSize.M,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16.0),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomTile(
                    title: LocaleKeys.demoPhone.tr,
                    subtitle: userDetails.user?.phoneNumber,
                    icon: Icons.phone_outlined,
                  ),
                  const SizedBox(height: 10),
                  CustomTile(
                    title: LocaleKeys.demoRecordVoices.tr,
                    icon: Icons.record_voice_over,
                    onTap: () {
                      // Get.to(() => const RecordVoicesScreen());
                    },
                  ),
                  const SizedBox(height: 10),
                  Visibility(
                    visible:
                        controller.partnerStatus.value !=
                            PartnerCurrentStatus.PROBATION &&
                        controller.partnerStatus.value !=
                            PartnerCurrentStatus.ONBOARDED,
                    replacement: CustomTile(
                      title: LocaleKeys.demoContactManager.tr,
                      icon: Icons.support_agent,
                      onTap: () {
                        // sendWhatsAppMessageToProbationKAM(
                        //     kamName: userDetails.kamName,
                        //     kamPhone: userDetails.kamPhone);
                      },
                    ),
                    child: CustomTile(
                      title: LocaleKeys.demoRaiseComplaint.tr,
                      icon: Icons.support_agent,
                      onTap: () {
                        // Get.to(() => const ComplaintScreen());
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  Disabled(
                    disabled: !controller.isOnlineOrBusy,
                    child: CustomTile(
                      title: LocaleKeys.demoDeviceHealth.tr,
                      icon: Icons.troubleshoot,
                      onTap: () {
                        Get.to(() => const TroubleshootingScreen());
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  CustomTile(
                    title: LocaleKeys.demoNotifications.tr,
                    icon:
                        demoController.isNotificationsEnabled.value
                            ? Icons.notifications_active
                            : Icons.notifications_off,
                    onTap: () {
                      Get.bottomSheet(
                        const DemoNotificationSwitchBottomSheet(),
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  Disabled(
                    disabled: demoController.currentStage.isLessThan(
                      TutorialStage.S4,
                    ),
                    child: CustomTile(
                      title: LocaleKeys.demoBlocklist.tr,
                      icon: Icons.supervised_user_circle_sharp,
                      onTap: () {
                        Get.to(() => const DemoBlocklistScreen());
                      },
                    ),
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
                    onTap: () {
                      // Get.to(() => const WebViewExample(
                      //       title: LocaleKeys.demoPrivacyPolicy.tr,
                      //       url: "https://voiceclub.app/privacy-policy/",
                      //     ));
                    },
                    title: LocaleKeys.demoPrivacyPolicy.tr,
                    icon: Icons.privacy_tip,
                  ),
                  const SizedBox(height: 10),
                  CustomTile(
                    onTap: () {
                      // Get.dialog(AlertDialog(
                      //   title: const Text(
                      //     "Are you sure you want to logout?",
                      //     style: TextStyle(fontSize: 13),
                      //   ),
                      //   actions: [
                      //     TextButton(
                      //         onPressed: () {
                      //           Get.back();
                      //         },
                      //         child: const Text("Cancel")),
                      //     TextButton(
                      //         onPressed: () {
                      //           // _authService.logout();
                      //         },
                      //         child: const Text("Logout"))
                      //   ],
                      // ));
                    },
                    title: LocaleKeys.demoLogout.tr,
                    icon: Icons.logout_rounded,
                  ),
                ],
              ),
            ],
          ),
        );
      }),
    );
  }
}
