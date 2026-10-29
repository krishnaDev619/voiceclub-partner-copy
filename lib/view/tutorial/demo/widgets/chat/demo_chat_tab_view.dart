import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/view/chat/widgets/custom_tab.dart';
import 'package:voiceclub_partner/view/tutorial/demo/controllers/demo_landing_controller.dart';
import 'package:voiceclub_partner/view/tutorial/demo/widgets/chat/demo_chat_list_view.dart';
import 'package:voiceclub_partner/view/tutorial/demo/widgets/chat/demo_send_new_user_audio_carousel.dart';
import 'package:voiceclub_partner/view/tutorial/demo/demo_labels.dart';

class DemoChatTabView extends StatelessWidget {
  const DemoChatTabView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DemoLandingController>();

    final tabFilters = <ChatTabFilter>[
      ChatTabFilter.ALL,
      ChatTabFilter.UNREAD_TO_REPLY,
    ];

    return Obx(() {
      return Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DefaultTabController(
                length: tabFilters.length,
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
                                  label: demoChatTabLabel(filter),
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
                                                        ? Get.theme.primaryColor
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
              const Expanded(child: DemoChatListView()),
            ],
          ),
          const DemoSendNewUserAudioCarousel(),
        ],
      );
    });
  }
}
