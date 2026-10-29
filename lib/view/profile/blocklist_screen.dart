import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/core/injection_container.dart';
import 'package:voiceclub_partner/core/services/analytics_service.dart';
import 'package:voiceclub_partner/core/services/avatar_service.dart';
import 'package:voiceclub_partner/modules/controller/blocklist_controller.dart';
import 'package:voiceclub_partner/view/auth/widgets/cancel_alert.dart';
import 'package:voiceclub_partner/view/widgets/custom_app_bar.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';

class BlocklistScreen extends StatefulWidget {
  const BlocklistScreen({super.key});

  @override
  State<BlocklistScreen> createState() => _BlocklistScreenState();
}

class _BlocklistScreenState extends State<BlocklistScreen> {
  final _blockListController = Get.put<BlockListController>(
    BlockListController(),
  );
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    _blockListController.fetchBlocklistData();
    sl<AnalyticsService>().trackEvent("blocklistScreen");

    _scrollController.addListener(() {
      if (_scrollController.position.maxScrollExtent > 0) {
        if (_scrollController.position.atEdge) {
          if (_scrollController.position.pixels == 0) {
          } else {
            if (_blockListController.currentPage.value <
                _blockListController.totalPages.value) {
              _blockListController.currentPage.value++;
              _blockListController.fetchBlocklistData();
            }
          }
        }
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Scaffold(
        appBar: CustomAppBar(title: LocaleKeys.liveBlocklist.tr),
        body:
            _blockListController.blockedUsers.isEmpty
                ? Center(child: Text(LocaleKeys.liveNoBlockedUsers.tr))
                : SafeArea(
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: _blockListController.blockedUsers.length,
                    itemBuilder: (context, index) {
                      final ds =
                          _blockListController.blockedUsers.toList()[index];
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
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
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
                                    bool? shouldUnblock = await showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return CancelAlertDialog(
                                          title: LocaleKeys.liveUnblockUser.tr,
                                          subtitle:
                                              LocaleKeys
                                                  .liveUnblockUserConfirm
                                                  .tr,
                                        );
                                      },
                                    );

                                    if (shouldUnblock ?? false) {
                                      await _blockListController.blockUser(
                                        accountId: ds.blockedAccountId ?? 0,
                                        reason: ds.reason ?? '',
                                      );

                                      sl<AnalyticsService>().trackEvent(
                                        'unblockDemand',
                                        eventProperties: {
                                          'demandName': ds.blockedUser?.name,
                                          'demandNumber':
                                              ds.blockedUser?.phoneNumber,
                                        },
                                      );
                                      _blockListController.blockedUsers.clear();
                                      _blockListController.currentPage.value =
                                          1;
                                      await _blockListController
                                          .fetchBlocklistData();
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
                                    child: Text(LocaleKeys.liveUnblock.tr),
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
                ),
      );
    });
  }
}
