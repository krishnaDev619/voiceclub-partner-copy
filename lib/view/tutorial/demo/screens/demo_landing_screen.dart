import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/view/tutorial/demo/controllers/demo_landing_controller.dart';
import 'package:voiceclub_partner/view/tutorial/demo/widgets/core/demo_question_widget.dart';
import 'package:voiceclub_partner/view/tutorial/demo/widgets/home/demo_close_warning_dialog.dart';

class DemoLandingScreen extends StatefulWidget {
  const DemoLandingScreen({super.key});

  @override
  State<DemoLandingScreen> createState() => _DemoLandingScreenState();
}

class _DemoLandingScreenState extends State<DemoLandingScreen> {
  @override
  void initState() {
    Get.find<DemoLandingController>().trackDemoEvent("demoLandingScreen");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final demoController = Get.find<DemoLandingController>();
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          var result = await Get.dialog<bool>(const DemoCloseWarningDialog());
          if (result ?? false) Get.back();
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Obx(() {
                return DemoQuestionWidget(
                  question: demoController.currentQuestion,
                  totalQuestions: demoController.demoQuestions.length,
                  currentQuestionIndex:
                      demoController.currentQuestionIndex.value,
                );
              }),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12.0),
                      topRight: Radius.circular(12.0),
                    ),
                    border: Border(
                      right: BorderSide(
                        color: Get.theme.primaryColor,
                        width: 4.0,
                      ),
                      left: BorderSide(
                        color: Get.theme.primaryColor,
                        width: 4.0,
                      ),
                      top: BorderSide(
                        color: Get.theme.primaryColor,
                        width: 4.0,
                      ),
                    ),
                  ),
                  margin: const EdgeInsets.only(
                    top: 16.0,
                    right: 16.0,
                    left: 16.0,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12.0),
                    child: GetBuilder<DemoLandingController>(
                      builder: (controller) {
                        return IndexedStack(
                          index: controller.bottomBarVisibleTabs
                              .toList()
                              .indexOf(controller.selectedTab.value),
                          children: controller.tabScreens,
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(12.0),
              bottomRight: Radius.circular(12.0),
            ),
            border: Border(
              right: BorderSide(color: Get.theme.primaryColor, width: 4.0),
              left: BorderSide(color: Get.theme.primaryColor, width: 4.0),
              bottom: BorderSide(color: Get.theme.primaryColor, width: 4.0),
            ),
          ),
          margin: const EdgeInsets.only(bottom: 16.0, left: 16.0, right: 16.0),
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(12.0),
              bottomRight: Radius.circular(12.0),
            ),
            child: GetBuilder<DemoLandingController>(
              builder: (controller) {
                return BottomNavigationBar(
                  type: BottomNavigationBarType.fixed,
                  // backgroundColor: Colors.yellowAccent,
                  selectedItemColor: Get.theme.primaryColor,
                  selectedIconTheme: const IconThemeData(color: Colors.white),
                  selectedFontSize: 12.0,
                  unselectedFontSize: 12.0,
                  selectedLabelStyle: TextStyle(color: Get.theme.primaryColor),
                  unselectedItemColor: ApplicationColors.grey,
                  unselectedLabelStyle: const TextStyle(
                    color: ApplicationColors.grey,
                  ),
                  onTap: (int index) {
                    controller.changeTab(
                      controller.bottomBarVisibleTabs.toList()[index],
                    );
                  },
                  items: controller.bottomTabs,
                  currentIndex: controller.bottomBarVisibleTabs
                      .toList()
                      .indexOf(controller.selectedTab.value),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
