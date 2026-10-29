import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/core/injection_container.dart';
import 'package:voiceclub_partner/core/services/growthbook_service.dart';
import 'package:voiceclub_partner/modules/controller/chat_overview_controller.dart';
import 'package:voiceclub_partner/view/chat/widgets/active_chats_carousel.dart';
import 'package:voiceclub_partner/view/chat/widgets/chat_list_view.dart';
import 'package:voiceclub_partner/view/chat/widgets/custom_tab.dart';
import 'package:voiceclub_partner/view/live_labels.dart';
import 'package:voiceclub_partner/view/chat/widgets/send_new_user_audio_carousel.dart';

class ChatTabView extends GetView<ChatOverviewController> {
  final TextEditingController searchController;

  const ChatTabView({super.key, required this.searchController});

  @override
  Widget build(BuildContext context) {
    if (controller.isLoading.value) {
      return Center(
        child: SizedBox(
          height: 32.0,
          width: 32.0,
          child: CircularProgressIndicator(color: Get.theme.primaryColor),
        ),
      );
    } else {
      final tabFilters = <ChatTabFilter>[
        ChatTabFilter.ALL,
        if (sl<GrowthBookService>().isFeatureEnabled(
          FeatureFlag.gooduserchattab,
        ))
          ChatTabFilter.HIGH_PAY_WITH_COUNT_MULTIPLE,
        ChatTabFilter.UNREAD_TO_REPLY,
      ];

      return Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Visibility(
                visible: searchController.text.isEmpty,
                child: const ActiveChatsCarousel(),
              ),
              DefaultTabController(
                length: tabFilters.length,
                child: Visibility(
                  visible: searchController.text.isEmpty,
                  child: Container(
                    margin: const EdgeInsets.only(top: 8.0),
                    constraints: const BoxConstraints.expand(height: 36.0),
                    child: TabBar(
                      isScrollable: true,
                      labelPadding: const EdgeInsets.symmetric(horizontal: 6.0),
                      padding: const EdgeInsets.symmetric(horizontal: 6.0),
                      indicator: null,
                      indicatorColor: Colors.transparent,
                      splashBorderRadius: BorderRadius.circular(8.0),
                      onTap: (index) {
                        controller.changeChatTab(tabFilters[index]);
                      },
                      tabs:
                          tabFilters
                              .map(
                                (filter) => Tab(
                                  key: Key(filter.name),
                                  child: CustomTab(
                                    label: liveChatTabLabel(filter),
                                    selected:
                                        filter ==
                                        controller.selectedChatTabFilter.value,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8.0,
                                      horizontal: 8.0,
                                    ),
                                    hasBorder:
                                        filter ==
                                                controller
                                                    .selectedChatTabFilter
                                                    .value
                                            ? false
                                            : true,
                                    unselectedContentColor: Colors.black45,
                                    borderColor: Colors.black45,
                                    trailing: Builder(
                                      builder: (context) {
                                        bool selected =
                                            filter ==
                                            controller
                                                .selectedChatTabFilter
                                                .value;
                                        int count = 0;
                                        if (filter == ChatTabFilter.ALL) {
                                          count = controller.unseenCount.value;
                                        } else if (filter ==
                                            ChatTabFilter.UNREAD_TO_REPLY) {
                                          count = controller.replyCount.value;
                                        }
                                        if (count > 0) {
                                          return Container(
                                            height: 28.0,
                                            width: 28.0,
                                            padding: const EdgeInsets.all(3.0),
                                            decoration: BoxDecoration(
                                              color:
                                                  selected
                                                      ? Colors.white
                                                      : Colors.black45,
                                              shape: BoxShape.circle,
                                            ),
                                            child: FittedBox(
                                              child: Text(
                                                count > 99
                                                    ? "99+"
                                                    : count.toString(),
                                                maxLines: 1,
                                                style: TextStyle(
                                                  fontSize: FontSize.S,
                                                  color:
                                                      selected
                                                          ? Get
                                                              .theme
                                                              .primaryColor
                                                          : Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          );
                                        } else {
                                          return const SizedBox.shrink();
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ChatListView(
                  categoryCode: controller.categoryCode,
                  searchController: searchController,
                ),
              ),
            ],
          ),
          const SendNewUserAudioCarousel(isHomeScreen: false),
        ],
      );
    }
  }
}
