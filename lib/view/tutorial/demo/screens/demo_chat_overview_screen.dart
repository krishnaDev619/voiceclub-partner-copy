import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/view/tutorial/demo/bottom_sheets/demo_chat_filter_bottom_sheet.dart';
import 'package:voiceclub_partner/view/tutorial/demo/controllers/demo_landing_controller.dart';
import 'package:voiceclub_partner/view/tutorial/demo/widgets/chat/demo_chat_tab_view.dart';
import 'package:voiceclub_partner/view/tutorial/demo/widgets/core/disabled_widget.dart';
import 'package:voiceclub_partner/view/widgets/custom_app_bar.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';
import 'package:voiceclub_partner/view/tutorial/demo/demo_labels.dart';

class DemoChatOverviewScreen extends StatefulWidget {
  const DemoChatOverviewScreen({super.key});

  @override
  State<DemoChatOverviewScreen> createState() => _DemoChatOverviewScreenState();
}

class _DemoChatOverviewScreenState extends State<DemoChatOverviewScreen> {
  final _demoController = Get.find<DemoLandingController>();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DemoLandingController>(
      builder: (controller) {
        return Scaffold(
          appBar: CustomAppBar(
            title: LocaleKeys.demoChatsTitle.trParams({
              'tab': demoChatTabLabel(controller.selectedChatTabFilter.value),
            }),
            action: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Disabled(
                  disabled: _demoController.currentStage.isLessThan(
                    TutorialStage.S5,
                  ),
                  child: GestureDetector(
                    onTap: () {
                      Get.bottomSheet(const DemoChatFilterBottomSheet());
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
                  readOnly: true,
                  maxLines: 1,
                  decoration: InputDecoration(
                    hintText: LocaleKeys.demoSearch.tr,
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
              const Expanded(child: DemoChatTabView()),
            ],
          ),
        );
      },
    );
  }
}
