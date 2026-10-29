import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/core/injection_container.dart';
import 'package:voiceclub_partner/core/services/app_update_service.dart';
import 'package:voiceclub_partner/core/services/call_entry_service.dart';
import 'package:voiceclub_partner/core/services/events_service.dart';
import 'package:voiceclub_partner/view/landing/landing_controller.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen>
    with WidgetsBindingObserver {
  final _callEntryService = sl<CallEntryService>();

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  // Implement lifecycle event methods
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.paused:
        _callEntryService.pauseStream();
        break;
      case AppLifecycleState.resumed:
        // Handle the async resumeStream method
        _callEntryService.resumeStream().then((_) {
          EventsService.getAndMarkPendingEvents();
          AppUpdateService.fetchConfigStatus(isSplash: false);
        });
        break;
      default:
        break;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!(Get.isRegistered<LandingController>())) {
      Get.put(LandingController(), permanent: true);
    }

    Widget buildLanding({required bool blockBack}) {
      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) {
            return;
          }
          if (blockBack) {
            return;
          }
          final landingController = Get.find<LandingController>();
          landingController.changeTab(landingController.lastSelectedTab.value);
        },
        child: Scaffold(
          extendBodyBehindAppBar: true,
          resizeToAvoidBottomInset: false,
          body: GetBuilder<LandingController>(
            builder: (controller) {
              if (controller.dataFetched.value &&
                  !controller.errorOccurred.value) {
                return IndexedStack(
                  index: controller.bottomBarVisibleTabs.toList().indexOf(
                    controller.selectedTab.value,
                  ),
                  children: controller.tabScreens,
                );
              } else if (!controller.dataFetched.value) {
                return const Center(child: CircularProgressIndicator());
              } else {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(LocaleKeys.somethingWentWrong.tr),
                      const SizedBox(height: 8.0),
                      TextButton(
                        onPressed: () {
                          controller.fetchInitData();
                        },
                        child: Text(
                          LocaleKeys.homeReload.tr,
                          style: TextStyle(color: Get.theme.primaryColor),
                        ),
                      ),
                    ],
                  ),
                );
              }
            },
          ),
          bottomNavigationBar: GetBuilder<LandingController>(
            builder: (controller) {
              if (controller.dataFetched.value &&
                  !controller.errorOccurred.value) {
                return BottomNavigationBar(
                  type: BottomNavigationBarType.fixed,
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
                      isManual: true,
                    );
                  },
                  items: controller.bottomTabs,
                  currentIndex: controller.bottomBarVisibleTabs
                      .toList()
                      .indexOf(controller.selectedTab.value),
                );
              } else {
                return const SizedBox.shrink();
              }
            },
          ),
        ),
      );
    }

    return buildLanding(blockBack: false);
  }
}
