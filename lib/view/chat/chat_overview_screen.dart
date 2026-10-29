import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_workers/utils/debouncer.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/modules/controller/chat_overview_controller.dart';
import 'package:voiceclub_partner/modules/controller/user_controller.dart';
import 'package:voiceclub_partner/view/chat/widgets/bottom_sheet/chat_filter_bottom_sheet.dart';
import 'package:voiceclub_partner/view/chat/widgets/chat_tab_view.dart';
import 'package:voiceclub_partner/view/tutorial/demo/widgets/core/disabled_widget.dart';
import 'package:voiceclub_partner/view/widgets/custom_app_bar.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';
import 'package:voiceclub_partner/view/live_labels.dart';

final chatSearchController = TextEditingController();

class ChatOverviewScreen extends StatefulWidget {
  const ChatOverviewScreen({super.key});

  @override
  State<ChatOverviewScreen> createState() => _ChatOverviewScreenState();
}

class _ChatOverviewScreenState extends State<ChatOverviewScreen> {
  final _debouncer = Debouncer(delay: const Duration(milliseconds: 500));

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ChatOverviewController>(
      builder: (controller) {
        return Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: CustomAppBar(
            title: LocaleKeys.liveFilterChats.trParams({
              'name': liveChatTabLabel(controller.selectedChatTabFilter.value),
            }),
            action: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Disabled(
                  disabled: Get.find<UserController>().currentStage.isLessThan(
                    TutorialStage.S5,
                  ),
                  child: GestureDetector(
                    onTap: () {
                      Get.bottomSheet(const ChatFilterBottomSheet());
                    },
                    child: Container(
                      width: 32.0,
                      height: 32.0,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [Color(0xFFFE6EA3), Color(0xFFFEB677)],
                        ),
                      ),
                      child: const Icon(
                        Icons.add,
                        size: 32.0,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16.0),
              ],
            ),
            showBackButton: false,
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: TextField(
                  controller: chatSearchController,
                  onTapOutside: (_) {
                    FocusManager.instance.primaryFocus?.unfocus();
                  },
                  onChanged: (_) {
                    _debouncer.call(() {
                      controller.fetchChats(
                        page: 1,
                        query: chatSearchController.text,
                      );
                    });
                  },
                  onSubmitted: (query) {
                    Get.focusScope?.unfocus();
                  },
                  maxLines: 1,
                  decoration: InputDecoration(
                    hintText: LocaleKeys.liveSearch.tr,
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
              Expanded(
                child: ChatTabView(searchController: chatSearchController),
              ),
            ],
          ),
        );
      },
    );
  }
}
