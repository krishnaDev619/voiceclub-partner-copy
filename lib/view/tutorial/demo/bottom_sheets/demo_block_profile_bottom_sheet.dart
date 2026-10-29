import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/services/alert_service.dart';
import 'package:voiceclub_partner/core/services/avatar_service.dart';
import 'package:voiceclub_partner/data/models/blocking/get_blocked_users_response.dart';
import 'package:voiceclub_partner/data/models/notifications/user_data.dart';
import 'package:voiceclub_partner/view/tutorial/demo/controllers/demo_landing_controller.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';

class DemoBlockProfileBottomSheet extends StatefulWidget {
  const DemoBlockProfileBottomSheet({
    super.key,
    required this.name,
    required this.avatar,
    required this.userData,
    required this.isChat,
  });

  final String name, avatar;
  final UserDataModel userData;
  final bool isChat;

  @override
  State<DemoBlockProfileBottomSheet> createState() =>
      _DemoBlockProfileBottomSheetState();
}

class _DemoBlockProfileBottomSheetState
    extends State<DemoBlockProfileBottomSheet> {
  BlockReason selectedReason = BlockReason.Other;
  OtherReason selectedOtherReason = OtherReason.personal;

  Map<OtherReason, String> otherReasons = {
    OtherReason.personal: LocaleKeys.demoBlockPersonal.tr,
    OtherReason.sexual: LocaleKeys.demoBlockSexual.tr,
    OtherReason.harassment: LocaleKeys.demoBlockHarassment.tr,
  };

  final _demoController = Get.find<DemoLandingController>();

  @override
  void initState() {
    super.initState();
  }

  String getReason() {
    if (selectedReason != BlockReason.Other) {
      return selectedReason.name;
    } else {
      return otherReasons[selectedOtherReason] ?? selectedOtherReason.name;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 42.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            widget.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18.0,
                            ),
                          ),
                          const SizedBox(width: 4.0),
                          const Icon(Icons.verified, color: Colors.blue),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        child: Text(
                          LocaleKeys.demoBlockReason.trParams({
                            'name': widget.name,
                          }),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14.0,
                          ),
                        ),
                      ),
                      selectedReason == BlockReason.Other
                          ? Column(
                            children: [
                              for (final other in otherReasons.entries)
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedOtherReason = other.key;
                                    });
                                  },
                                  child: Opacity(
                                    opacity:
                                        other.key == selectedOtherReason
                                            ? 1.0
                                            : 0.3,
                                    child: Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(8.0),
                                      margin: const EdgeInsets.symmetric(
                                        vertical: 4.0,
                                      ),
                                      decoration: BoxDecoration(
                                        border: Border.all(),
                                        borderRadius: BorderRadius.circular(
                                          8.0,
                                        ),
                                      ),
                                      child: Column(
                                        children: [
                                          Text(
                                            other.value,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12.0,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          )
                          : const SizedBox.shrink(),
                    ],
                  ), // Show check icon
                ),
                Transform.translate(
                  offset: const Offset(0, -60),
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: CircleAvatar(
                        radius: 60,
                        backgroundColor: Get.theme.primaryColor,
                        backgroundImage: FastCachedImageProvider(
                          widget.avatar.isNotEmpty
                              ? widget.avatar
                              : AvatarService.getRandomAvatarUrl(),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12.0),
          GestureDetector(
            onTap: () async {
              _demoController.blockedUsers.add(
                BlockedUsers(
                  blockedUser: widget.userData,
                  blockedAccountId: widget.userData.id,
                  reason: getReason(),
                ),
              );
              Get.back(result: true);
              if (widget.isChat) {
                Get.back();
              }
              _demoController.validateAction(TutorialDemoFeature.CHAT_BLOCK);
              AlertService.showSnackBar(
                snackBarType: SnackBarType.Success,
                title: LocaleKeys.demoBlocked.tr,
                subtitle: LocaleKeys.demoBlockedSuccess.trParams({
                  'name': widget.name,
                }),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Get.theme.primaryColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      LocaleKeys.demoBlock.tr,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
