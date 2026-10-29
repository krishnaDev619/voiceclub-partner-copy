import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:voiceclub_partner/core/constants/bottom_bar_tab_helper.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/core/injection_container.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/core/services/analytics_service.dart';
import 'package:voiceclub_partner/core/services/call_entry_service.dart';
import 'package:voiceclub_partner/core/services/call_handling_service.dart';
import 'package:voiceclub_partner/core/services/config_fcm_service.dart';
import 'package:voiceclub_partner/core/services/events_service.dart';
import 'package:voiceclub_partner/core/services/location_service.dart';
import 'package:voiceclub_partner/core/services/payout_service.dart';
import 'package:voiceclub_partner/core/services/rating_service.dart';
import 'package:voiceclub_partner/core/services/survey_service.dart';
import 'package:voiceclub_partner/data/models/config/language_info.dart';
import 'package:voiceclub_partner/domain/usecases/config/get_languages.dart';
import 'package:voiceclub_partner/domain/usecases/feature/has_seen_whatsapp_group.dart';
import 'package:voiceclub_partner/domain/usecases/rating/get_all_ratings.dart';
import 'package:voiceclub_partner/modules/controller/call_controller.dart';
import 'package:voiceclub_partner/modules/controller/chat_overview_controller.dart';
import 'package:voiceclub_partner/modules/controller/deeplink_controller.dart';
import 'package:voiceclub_partner/modules/controller/managers_feedback_controller.dart';
import 'package:voiceclub_partner/modules/controller/multi_reward_controller.dart';
import 'package:voiceclub_partner/modules/controller/rewards_controller.dart';
import 'package:voiceclub_partner/modules/controller/tier_controller.dart';
import 'package:voiceclub_partner/modules/controller/user_controller.dart';
import 'package:voiceclub_partner/modules/controller/wallet_controller.dart';
import 'package:voiceclub_partner/view/auth/app_lock_screen.dart';
import 'package:voiceclub_partner/view/chat/chat_overview_screen.dart';
import 'package:voiceclub_partner/view/home/bottom_sheet/join_meeting_bottom_sheet.dart';
import 'package:voiceclub_partner/view/home/bottom_sheet/join_whatsapp_group_bottom_sheet.dart';
import 'package:voiceclub_partner/view/home/explore_screen.dart';
import 'package:voiceclub_partner/view/home/home_screen.dart';
import 'package:voiceclub_partner/view/learning/learning_screen.dart';
import 'package:voiceclub_partner/view/logs/logs_controller.dart';
import 'package:voiceclub_partner/view/logs/logs_screen.dart';
import 'package:voiceclub_partner/view/milestone/controllers/milestone_rewards_controller.dart';
import 'package:voiceclub_partner/view/queries/controller/queries_controller.dart';
import 'package:voiceclub_partner/view/social/controllers/explore_controller.dart';
import 'package:voiceclub_partner/view/widgets/excess_gift_bottom_sheet.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';

class LandingController extends GetxController {
  final dataFetched = false.obs;
  final errorOccurred = false.obs;
  final selectedTab = BottomBarTabType.HOME.obs;
  final languages = <LanguageInfo>[].obs;
  final lastSelectedTab = BottomBarTabType.HOME.obs;
  final bottomBarVisibleTabs = <BottomBarTabType>{};
  final exploreCount = Random().nextInt(10);

  @override
  void onInit() async {
    super.onInit();
    await fetchInitData().then((_) async {
      sl<CallHandlingService>().executeCallBuilder();
      await sl<CallEntryService>().initialize();
      handleDeeplink(true);
      _checkAppLockStatus();
    });
  }

  void _checkAppLockStatus() {
    if (Get.currentRoute != "/LockScreen" &&
        Get.find<UserController>().isAppLockEnabled.value) {
      Get.to(() => AppLockScreen(onUnlock: Get.back), opaque: false);
    }
  }

  void checkRewardsEnabled() {
    bottomBarVisibleTabs.clear();
    bottomBarVisibleTabs.addAll(BottomBarTabHelper.getVisibleTabs());
    update();
  }

  Future<void> fetchInitData() async {
    try {
      dataFetched.value = false;
      errorOccurred.value = false;
      final supplyUserController = Get.find<UserController>();
      await supplyUserController.fetchData(fetchOnlineDuration: true);

      // Fetch rating data
      await sl<GetAllRatingsUsecase>().call(NoParams()).then((
        ratingsResponse,
      ) async {
        final ratings = ratingsResponse.data?.ratings;
        await RatingService.storeRatedAccountIds(ratings ?? []);
      });

      Get.put(ChatOverviewController(categoryCode: CategoryCode.GOSSIP));

      // Initialize controllers
      final walletController = Get.put(WalletController());
      await walletController.fetchData();
      Get.put(LogsController());
      Get.put(TierController());
      Get.put(ExploreController());
      Get.put(RewardsController());
      Get.put(ManagersFeedbackController());
      Get.put(QueriesController());
      Get.put(MilestoneRewardsController());
      final multiRewardsController = Get.put(MultiRewardController());
      await multiRewardsController.getActiveRewards();
      checkRewardsEnabled();

      updateTabs();

      await _fetchLanguages();
      dataFetched.value = true;
      update();
      _checkWhatsAppGroup();
      sl<SurveyService>().checkAndInitiateSurvey();
      _checkExcessGiftAmount();
      sl<PayoutService>().showRecentPayout();
      _checkOngoingMeeting();
      // Fetch location and Update
      sl<LocationService>().checkAndUpdateLocation();
      sl<AnalyticsService>().trackEnabledGrowthBookFeatures();
    } catch (_) {
      dataFetched.value = false;
      errorOccurred.value = true;
    }
  }

  Future<void> updateTabs() async {
    changeTab(BottomBarTabType.CHATS);
    lastSelectedTab.value = BottomBarTabType.CHATS;
  }

  Future<void> _fetchLanguages() async {
    try {
      final response = await sl<GetLanguagesUseCase>().call(NoParams());
      if (response.data != null) {
        if (response.data?.languages?.isNotEmpty ?? false) {
          languages.value = response.data?.languages ?? [];
        }
      }
    } catch (_) {}
  }

  Future<void> _checkExcessGiftAmount() async {
    final walletController = Get.find<WalletController>();
    final giftAmount = walletController.giftAmount.value;
    final finalValue = walletController.finalValue.value;
    if (giftAmount > 0 && finalValue > 0 && (giftAmount / finalValue) > 0.3) {
      Get.bottomSheet(
        ExcessGiftBottomSheet(
          totalEarning: finalValue.round(),
          giftEarning: giftAmount.round(),
        ),
      );
    }
  }

  Future<void> _checkWhatsAppGroup() async {
    final userController = Get.find<UserController>();
    if (userController.partnerStatus.value == PartnerCurrentStatus.LIVE) {
      if (userController.userDetails.value.primaryLanguage
              ?.trim()
              .toLowerCase() !=
          "telugu") {
        final hasSeenWhatsAppGroup = await sl<HasSeenWhatsAppGroupUseCase>()
            .call(
              HasSeenWhatsAppGroupParams(
                accountId:
                    userController.userDetails.value.accountId.toString(),
              ),
            );
        if (!hasSeenWhatsAppGroup) {
          Get.bottomSheet(const JoinWhatsAppGroupBottomSheet());
        }
      }
    }
  }

  Future<void> _checkOngoingMeeting() async {
    try {
      // Check if conditions are met to show bottom sheet
      if (Get.currentRoute != "/LandingScreen" ||
          (Get.isBottomSheetOpen ?? false) ||
          sl<CallController>().isOnCall) {
        return;
      }

      final userController = Get.find<UserController>();
      final meetings = userController.meetings;

      // Find ongoing meetings with valid Google Meet links
      final ongoingMeetings =
          meetings
              .where(
                (meeting) =>
                    meeting.isMeetingOngoing &&
                    (meeting.googleMeetLink?.isNotEmpty ?? false) &&
                    meeting.id != null,
              )
              .toList();

      if (ongoingMeetings.isEmpty) {
        return;
      }

      // Get the first ongoing meeting
      final meeting = ongoingMeetings.first;

      // Check if we've already shown this meeting's bottom sheet
      final prefs = await SharedPreferences.getInstance();
      final lastShownMeetingIdKey = 'last_shown_meeting_id';
      final lastShownMeetingId = prefs.getInt(lastShownMeetingIdKey);

      // Show bottom sheet if we haven't shown it for this meeting ID
      if (lastShownMeetingId != meeting.id) {
        // Small delay to ensure UI is ready
        await Future.delayed(const Duration(milliseconds: 500));

        // Double-check conditions after delay
        if (Get.currentRoute == "/LandingScreen" &&
            !(Get.isBottomSheetOpen ?? false) &&
            !sl<CallController>().isOnCall) {
          Get.bottomSheet(
            JoinMeetingBottomSheet(meeting: meeting),
            isScrollControlled: true,
          );

          // Mark this meeting as shown
          if (meeting.id != null) {
            await prefs.setInt(lastShownMeetingIdKey, meeting.id!);
          }
        }
      }
    } catch (_) {
      // Silently handle errors
    }
  }

  void _updateChats({required bool isUnread}) {
    chatSearchController.clear();
    final chatTabFilter =
        (Get.find<ChatOverviewController>().unseenCount.value > 0 && isUnread
            ? ChatTabFilter.UNREAD_TO_REPLY
            : ChatTabFilter.ALL);
    Get.find<ChatOverviewController>().changeChatTab(chatTabFilter);
    Get.find<ChatOverviewController>().fetchChats(page: 1);
  }

  Future<void> changeTab(
    BottomBarTabType tab, {
    bool isUnread = false,
    bool isManual = false,
  }) async {
    if (selectedTab.value != tab) {
      if (isManual) {
        lastSelectedTab.value = selectedTab.value;
      }
      Get.find<ExploreController>().pauseAllPlayers();
      if (FocusManager.instance.primaryFocus?.hasFocus ?? false) {
        FocusManager.instance.primaryFocus?.unfocus();
      }
      // Fetch chats if chatTab is tapped
      final userController = Get.find<UserController>();
      if (tab == BottomBarTabType.HOME) {
        // Update fcm here so that it updates frequently
        ConfigFCMService.updateFCM();
        userController.fetchData(fetchOnlineDuration: true);
        EventsService.getAndMarkPendingEvents();
        final managersFeedbackController =
            Get.find<ManagersFeedbackController>();
        await managersFeedbackController.getManagersFeedback();
      }
      if (tab == BottomBarTabType.CHATS) {
        final chatOverviewController = Get.find<ChatOverviewController>();
        sl<AnalyticsService>().trackEvent(
          'chatHomeScreenSupply',
          eventProperties:
              userController.userDetails.value.category?.categoryCode ==
                      CategoryCode.GOSSIP
                  ? {
                    "newUserChatCount":
                        chatOverviewController.pendingAudios.length,
                    "unreadMessageCount":
                        chatOverviewController.unseenCount.value,
                  }
                  : null,
        );
        _updateChats(isUnread: isUnread);
      } else if (userController.userDetails.value.category?.categoryCode ==
              CategoryCode.GOSSIP &&
          tab == BottomBarTabType.LOGS) {
        logsSearchController.clear();
        Get.find<LogsController>().fetchLogs();
      } else if (userController.userDetails.value.category?.categoryCode ==
              CategoryCode.GOSSIP &&
          tab == BottomBarTabType.SOCIAL) {
        Get.find<ExploreController>().fetchInitialForYouPosts();
      }
      selectedTab.value = tab;
      update();
    }
  }

  List<Widget> get tabScreens => <Widget>[
    if (bottomBarVisibleTabs.contains(BottomBarTabType.HOME))
      HomeScreen(changeTab: changeTab),
    if (bottomBarVisibleTabs.contains(BottomBarTabType.LOGS))
      const LogsScreen(),
    if (bottomBarVisibleTabs.contains(BottomBarTabType.CHATS))
      const ChatOverviewScreen(),
    if (bottomBarVisibleTabs.contains(BottomBarTabType.SOCIAL))
      const ExploreScreen(),
    if (bottomBarVisibleTabs.contains(BottomBarTabType.LEARNING))
      const LearningScreen(),
  ];

  List<BottomNavigationBarItem> get bottomTabs => <BottomNavigationBarItem>[
    if (bottomBarVisibleTabs.contains(BottomBarTabType.HOME))
      BottomNavigationBarItem(
        icon: Obx(() {
          return Container(
            height: 40,
            width: 60,
            decoration:
                selectedTab.value == BottomBarTabType.HOME
                    ? BoxDecoration(
                      color: Get.theme.primaryColor,
                      borderRadius: BorderRadius.circular(40.0),
                    )
                    : null,
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: const Center(child: Icon(CupertinoIcons.home)),
          );
        }),
        label: LocaleKeys.homeTabHome.tr,
      ),
    if (bottomBarVisibleTabs.contains(BottomBarTabType.LOGS))
      BottomNavigationBarItem(
        icon: Obx(() {
          return Container(
            height: 40,
            width: 60,
            decoration:
                selectedTab.value == BottomBarTabType.LOGS
                    ? BoxDecoration(
                      color: Get.theme.primaryColor,
                      borderRadius: BorderRadius.circular(40.0),
                    )
                    : null,
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: const Center(child: Icon(Icons.call_outlined)),
          );
        }),
        label: LocaleKeys.homeTabLogs.tr,
      ),
    if (bottomBarVisibleTabs.contains(BottomBarTabType.CHATS))
      BottomNavigationBarItem(
        icon: Obx(() {
          return Container(
            height: 40,
            width: 60,
            decoration:
                selectedTab.value == BottomBarTabType.CHATS
                    ? BoxDecoration(
                      color: Get.theme.primaryColor,
                      borderRadius: BorderRadius.circular(40.0),
                    )
                    : null,
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(Icons.textsms_outlined),
                  Align(
                    alignment: Alignment.topRight,
                    child: Obx(() {
                      final count =
                          Get.find<ChatOverviewController>().unseenCount.value;
                      if (count > 0) {
                        return Transform.translate(
                          offset: const Offset(4.0, -6.0),
                          child: Container(
                            height: 16.0,
                            width: 16.0,
                            padding: const EdgeInsets.all(2.0),
                            decoration: const BoxDecoration(
                              color: Color(0xFFFF4444),
                              shape: BoxShape.circle,
                            ),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                count > 9 ? '9+' : count.toString(),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: FontSize.xS,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        );
                      } else {
                        return const SizedBox.shrink();
                      }
                    }),
                  ),
                ],
              ),
            ),
          );
        }),
        label: LocaleKeys.homeTabChat.tr,
      ),
    if (bottomBarVisibleTabs.contains(BottomBarTabType.SOCIAL))
      BottomNavigationBarItem(
        icon: Container(
          height: 40,
          width: 60,
          decoration:
              selectedTab.value == BottomBarTabType.SOCIAL
                  ? BoxDecoration(
                    color: Get.theme.primaryColor,
                    borderRadius: BorderRadius.circular(40.0),
                  )
                  : null,
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(Icons.post_add_rounded),
                Align(
                  alignment: Alignment.topRight,
                  child: Transform.translate(
                    offset: const Offset(4.0, -6.0),
                    child: Container(
                      height: 16.0,
                      width: 16.0,
                      padding: const EdgeInsets.all(2.0),
                      decoration: BoxDecoration(
                        color: Get.theme.primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          "${exploreCount == 0 ? "1" : exploreCount}",
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: FontSize.xS,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        label: LocaleKeys.homeTabSocial.tr,
      ),
    if (bottomBarVisibleTabs.contains(BottomBarTabType.LEARNING))
      BottomNavigationBarItem(
        icon: Container(
          height: 40,
          width: 60,
          decoration:
              selectedTab.value == BottomBarTabType.LEARNING
                  ? BoxDecoration(
                    color: Get.theme.primaryColor,
                    borderRadius: BorderRadius.circular(40.0),
                  )
                  : null,
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: const Center(child: Icon(Icons.book_outlined)),
        ),
        label: LocaleKeys.homeTabLearning.tr,
      ),
  ];

  void handleDeeplink(bool isInit) {
    try {
      final deeplinkController = Get.find<DeeplinkController>();

      if (deeplinkController.deeplink.value.path.isNotEmpty) {
        deeplinkController.handleDeeplink(isInit);
      }
      deeplinkController.deeplink.listen((_) {
        if (deeplinkController.deeplink.value.path.isNotEmpty) {
          deeplinkController.handleDeeplink(false);
        }
      });
    } catch (_) {}
  }

  @override
  void onClose() {
    sl<CallHandlingService>().dispose();
    sl<CallEntryService>().dispose();
    super.onClose();
  }
}
