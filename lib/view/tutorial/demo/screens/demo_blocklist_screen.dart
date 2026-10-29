import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/services/avatar_service.dart';
import 'package:voiceclub_partner/view/auth/widgets/cancel_alert.dart';
import 'package:voiceclub_partner/view/tutorial/demo/controllers/demo_landing_controller.dart';
import 'package:voiceclub_partner/view/widgets/custom_app_bar.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';

class DemoBlocklistScreen extends StatefulWidget {
  const DemoBlocklistScreen({super.key});

  @override
  State<DemoBlocklistScreen> createState() => _DemoBlocklistScreenState();
}

class _DemoBlocklistScreenState extends State<DemoBlocklistScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final demoController = Get.find<DemoLandingController>();
    return Obx(() {
      final blockedUsers = demoController.blockedUsers;
      return Scaffold(
        appBar: CustomAppBar(title: LocaleKeys.demoBlocklist.tr),
        body:
            blockedUsers.isEmpty
                ? Center(child: Text(LocaleKeys.demoNoBlockedUsers.tr))
                : ListView.builder(
                  itemCount: blockedUsers.length,
                  itemBuilder: (context, index) {
                    final ds = blockedUsers.toList()[index];
                    String name = ds.blockedUser?.name ?? '';
                    if (name.isEmpty) {
                      return const SizedBox.shrink();
                    } else {
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade100),
                        ),
                        child: ListTile(
                          selected: true,
                          leading: CircleAvatar(
                            foregroundImage: FastCachedImageProvider(
                              AvatarService.getRandomAvatarUrl(),
                            ),
                          ),
                          title: Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            ds.reason ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.grey),
                          ),
                          selectedColor: Colors.black,
                          dense: true,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              GestureDetector(
                                onTap: () async {
                                  bool shouldUnblock = await showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return CancelAlertDialog(
                                        title: LocaleKeys.demoUnblock.tr,
                                        subtitle:
                                            LocaleKeys.demoUnblockConfirm.tr,
                                      );
                                    },
                                  );

                                  if (shouldUnblock) {
                                    demoController.blockedUsers.remove(ds);
                                    demoController.validateAction(
                                      TutorialDemoFeature.CHAT_UNBLOCK,
                                    );
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      width: 1.0,
                                      color: Get.theme.primaryColor,
                                    ),
                                    borderRadius: BorderRadius.circular(6.0),
                                  ),
                                  child: Text(LocaleKeys.demoUnblock.tr),
                                ),
                              ),
                              const SizedBox(width: 4.0),
                            ],
                          ),
                        ),
                      );
                    }
                  },
                ),
      );
    });
  }
}
