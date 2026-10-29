import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/constants/url_constants.dart';
import 'package:voiceclub_partner/core/injection_container.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/core/services/analytics_service.dart';
import 'package:voiceclub_partner/core/services/avatar_service.dart';
import 'package:voiceclub_partner/core/services/logger.dart';
import 'package:voiceclub_partner/data/models/account/get_reverse_calls_reseponse.dart';
import 'package:voiceclub_partner/data/models/account/rewards_stats.dart';
import 'package:voiceclub_partner/data/models/blocking/get_blocked_users_response.dart';
import 'package:voiceclub_partner/data/models/chat/chat_filter_option.dart';
import 'package:voiceclub_partner/data/models/chat/chat_group.dart';
import 'package:voiceclub_partner/data/models/chat/chat_message.dart';
import 'package:voiceclub_partner/data/models/chat/chat_reply_message.dart';
import 'package:voiceclub_partner/data/models/chat/chat_theme.dart';
import 'package:voiceclub_partner/data/models/chat/display_chat_message.dart';
import 'package:voiceclub_partner/data/models/chat/member.dart';
import 'package:voiceclub_partner/data/models/chat/pending_audio.dart';
import 'package:voiceclub_partner/data/models/chat/preset_group.dart';
import 'package:voiceclub_partner/data/models/log.dart';
import 'package:voiceclub_partner/data/models/metrics/get_metrics_score.dart';
import 'package:voiceclub_partner/data/models/notifications/user_data.dart';
import 'package:voiceclub_partner/data/models/tutorial/demo_question_model.dart';
import 'package:voiceclub_partner/data/models/wallet/result_wallet.dart';
import 'package:voiceclub_partner/data/models/wallet/tax_items.dart';
import 'package:voiceclub_partner/domain/usecases/account/mark_onboarding_stage_course_completed.dart';
import 'package:voiceclub_partner/modules/controller/user_controller.dart';
import 'package:voiceclub_partner/view/onboarding/onboarding_status_router.dart';
import 'package:voiceclub_partner/view/profile/troubleshooting_screen.dart';
import 'package:voiceclub_partner/view/tutorial/demo/controllers/demo_audio_button_controller.dart';
import 'package:voiceclub_partner/view/tutorial/demo/models/demo_chat_filter.dart';
import 'package:voiceclub_partner/view/tutorial/demo/screens/demo_broadcast_list_view.dart';
import 'package:voiceclub_partner/view/tutorial/demo/screens/demo_chat_overview_screen.dart';
import 'package:voiceclub_partner/view/tutorial/demo/screens/demo_home_screen.dart';
import 'package:voiceclub_partner/view/tutorial/demo/screens/demo_logs_screen.dart';
import 'package:voiceclub_partner/view/tutorial/demo/screens/demo_mock_screen.dart';
import 'package:voiceclub_partner/view/tutorial/demo/widgets/core/demo_correct_answer_bottomsheet.dart';
import 'package:voiceclub_partner/view/tutorial/demo/widgets/core/promotion_bottom_sheet.dart';
import 'package:voiceclub_partner/view/tutorial/lessons/controllers/tutorial_lesson_controller.dart';
import 'package:voiceclub_partner/view/widgets/status_switch_bottom_sheet.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';

class DemoLandingController extends GetxController {
  final TutorialStage currentStage;
  final List<DemoQuestionModel> demoQuestions;

  DemoLandingController({
    required this.currentStage,
    required this.demoQuestions,
  });

  RxBool isTamil = false.obs;

  @override
  void onReady() {
    super.onReady();
    Get.find<DemoAudioButtonController>().playNewAudio(
      currentQuestion.audioExplanationUrl ?? "",
    );
    isTamil.value =
        userController.userDetails.value.primaryLanguage
            ?.toLowerCase()
            .trim() ==
        "tamil";
  }

  final currentQuestionIndex = 0.obs;

  // Getter for the current question
  DemoQuestionModel get currentQuestion =>
      demoQuestions[currentQuestionIndex.value];

  // Check if the action matches the expected action
  Future<bool> validateAction(
    TutorialDemoFeature performedFeatureAction,
  ) async {
    if (performedFeatureAction == currentQuestion.featureAction) {
      HapticFeedback.vibrate();
      // Move to the next question if the current action is valid
      await Future.delayed(const Duration(seconds: 1));
      HapticFeedback.vibrate();
      trackDemoEvent(
        "demoAnswerSuccess",
        additionalProperties: {"featureAction": performedFeatureAction.name},
      );
      await Get.bottomSheet(
        const DemoCorrectAnswerBottomSheet(isLastQuestion: false),
      );
      homeScrollController.jumpTo(0.0);
      changeTab(BottomBarTabType.HOME);
      if (Get.currentRoute != '/DemoLandingScreen') {
        Get.until((route) => route.settings.name == '/DemoLandingScreen');
      }
      _nextQuestion();
      return true;
    } else {
      trackDemoEvent(
        "demoWrongAction",
        additionalProperties: {"featureAction": performedFeatureAction.name},
      );
    }
    return false;
  }

  // Move to the next question
  void _nextQuestion() async {
    if (currentQuestionIndex.value < demoQuestions.length - 1) {
      currentQuestionIndex.value++;
      Get.find<DemoAudioButtonController>().playNewAudio(
        currentQuestion.audioExplanationUrl ?? "",
      );
      if (currentQuestion.featureAction == TutorialDemoFeature.CHAT_NEW_USER) {
        pendingAudios.add(
          PendingAudio(
            id: 34,
            accountId: 342233,
            timeLeftInSecs: 300,
            user: UserDataModel(
              id: 324256,
              name: 'Paraag',
              avatar: AvatarService.getRandomAvatarUrl(),
            ),
          ),
        );
      }
    } else {
      // If all questions are completed
      await sl<MarkOnboardingStageCourseCompletedUseCase>().call(NoParams());
      // Fire demo completed event
      sl<AnalyticsService>().trackEvent(
        'demoCompleted',
        eventProperties: {'stage': currentStage.name},
      );
      sl<AnalyticsService>().updateDemoCompletedDate();
      await Get.bottomSheet(
        const DemoCorrectAnswerBottomSheet(isLastQuestion: true),
      );
      if (currentStage == TutorialStage.S3 ||
          currentStage == TutorialStage.S7) {
        await Get.bottomSheet(PromotionBottomSheet(currentStage: currentStage));
      }
      await OnboardingStatusRouter.continueAfterStageCourse(
        completedStage: currentStage,
      );
    }
  }

  // Landing Screen
  final selectedTab = BottomBarTabType.HOME.obs;
  final bottomBarVisibleTabs = <BottomBarTabType>{
    BottomBarTabType.HOME,
    BottomBarTabType.LOGS,
    BottomBarTabType.CHATS,
  };

  void changeTab(BottomBarTabType tab) {
    if (selectedTab.value != tab) {
      if (FocusManager.instance.primaryFocus?.hasFocus ?? false) {
        FocusManager.instance.primaryFocus?.unfocus();
      }
      selectedTab.value = tab;
      update();
    }
  }

  List<Widget> get tabScreens => <Widget>[
    const DemoHomeScreen(),
    const DemoLogsScreen(),
    const DemoChatOverviewScreen(),
    const DemoMockScreen(),
  ];

  List<BottomNavigationBarItem> get bottomTabs => <BottomNavigationBarItem>[
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
      label: LocaleKeys.demoHome.tr,
    ),
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
      label: LocaleKeys.demoLogs.tr,
    ),
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
          child: const Center(child: Icon(Icons.textsms_outlined)),
        );
      }),
      label: LocaleKeys.demoChat.tr,
    ),
  ];

  // AppBar
  final isNotificationsEnabled = false.obs;

  void updateNotificationPreference() {
    Get.context?.loaderOverlay.show();
    Future.delayed(const Duration(seconds: 1), () {
      Get.context?.loaderOverlay.hide();
      isNotificationsEnabled.value = !isNotificationsEnabled.value;
      if (isNotificationsEnabled.value) {
        validateAction(TutorialDemoFeature.NOTIFICATION);
      }
    });
  }

  // Home Screen
  final homeScrollController = ScrollController();

  // User Controller
  final userController = Get.find<UserController>();

  // Online Activity
  final isOnline = false.obs;

  void showUpdateStatusBottomSheet(bool value) async {
    if (value != isOnline.value) {
      if (value == true) {
        final troubleshooting =
            await Get.to<bool?>(
              () => const TroubleshootingScreen(autoStart: true),
            ) ??
            false;
        if (troubleshooting == false) return;
      }
      final result =
          await Get.bottomSheet<bool>(
            StatusSwitchBottomSheet(
              online: value,
              durationHours: "3",
              durationMinutes: "24",
              requiredDurationInHours: 7,
            ),
          ) ??
          false;
      if (result) {
        Get.context?.loaderOverlay.show();
        Future.delayed(const Duration(seconds: 1), () {
          Get.context?.loaderOverlay.hide();
          isOnline.value = !isOnline.value;
          if (isOnline.value) {
            validateAction(TutorialDemoFeature.ACTIVITY_STATUS);
          }
        });
      }
    }
  }

  // Logs
  final logs =
      <LogModel>{
        LogModel(
          accountId: 123,
          lastCalledAt:
              DateTime.now()
                  .subtract(const Duration(seconds: 324))
                  .toIso8601String(),
          callCount: 3,
          name: "Paraag",
          isBlocked: false,
          uid: 1,
        ),
        LogModel(
          accountId: 342,
          lastCalledAt:
              DateTime.now()
                  .subtract(const Duration(seconds: 4245))
                  .toIso8601String(),
          callCount: 3,
          name: "Sammy",
          isBlocked: false,
          uid: 45,
        ),
        LogModel(
          accountId: 3143,
          lastCalledAt:
              DateTime.now()
                  .subtract(const Duration(seconds: 6345))
                  .toIso8601String(),
          callCount: 3,
          name: "Pratham",
          isBlocked: false,
          uid: 23,
        ),
      }.obs;
  final selectedOverviewFilter = OverviewFilter.Today.obs;
  final selectedLogType = LogType.Missed.obs;

  void changeSelectedOverviewFilter(OverviewFilter newFilter) {
    if (selectedOverviewFilter.value != newFilter) {
      selectedOverviewFilter.value = newFilter;
      if (selectedOverviewFilter.value == OverviewFilter.LastMonth) {
        validateAction(TutorialDemoFeature.LOGS_LAST_MONTH);
      }
    }
  }

  void changeSelectedLogType(LogType newLogType) {
    if (selectedLogType.value != newLogType) {
      selectedLogType.value = newLogType;
      if (selectedLogType.value == LogType.Busy) {
        validateAction(TutorialDemoFeature.LOGS_BUSY);
      }
    }
  }

  // Transactions
  final tabTransactionMap = <TransactionCategory, Set<ResultWalletModel>>{
    TransactionCategory.ALL: {
      ResultWalletModel(
        iD: 1,
        paymentId: 0,
        title: LocaleKeys.demoEarningWith.trParams({'name': 'Aarav'}),
        subtitle: "20/12/2024 12:34:20 PM 00:03:15",
        paymentValue: 3.15,
        getAmount: 3.15,
        action: "PLUS",
        status: 1,
        holdStatus: HoldStatus.Paid,
        createdAt:
            DateTime.now()
                .subtract(const Duration(minutes: 15))
                .toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
        taxItems: [TaxItems(name: "GST", rate: 0.18)],
        type: TransactionType.Call,
      ),
      ResultWalletModel(
        iD: 2,
        paymentId: 0,
        title: LocaleKeys.demoMoneyWithdrawnSuccess.tr,
        subtitle: "20/12/2024 12:04:20 PM",
        paymentValue: 4.2,
        getAmount: 4.2,
        action: "PLUS",
        status: 1,
        holdStatus: HoldStatus.Paid,
        createdAt:
            DateTime.now().subtract(const Duration(hours: 1)).toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
        taxItems: [TaxItems(name: "GST", rate: 0.18)],
        type: TransactionType.Withdrawal,
      ),
      ResultWalletModel(
        iD: 3,
        paymentId: 0,
        title: LocaleKeys.demoEarningWith.trParams({'name': 'Manoj'}),
        subtitle: "20/12/2024 11:24:50 AM 00:02:45",
        paymentValue: 2.45,
        getAmount: 2.45,
        action: "PLUS",
        status: 1,
        holdStatus: HoldStatus.Paid,
        createdAt:
            DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
        taxItems: [TaxItems(name: "GST", rate: 0.18)],
        type: TransactionType.Call,
      ),
      ResultWalletModel(
        iD: 4,
        paymentId: 0,
        title: LocaleKeys.demoEarningWith.trParams({'name': 'Rahul'}),
        subtitle: "19/12/2024 09:24:50 PM 00:05:00",
        paymentValue: 5.0,
        getAmount: 5.0,
        action: "PLUS",
        status: 1,
        holdStatus: HoldStatus.Paid,
        createdAt:
            DateTime.now()
                .subtract(const Duration(days: 2, hours: 5))
                .toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
        taxItems: [TaxItems(name: "GST", rate: 0.18)],
        type: TransactionType.Call,
      ),
      ResultWalletModel(
        iD: 5,
        paymentId: 0,
        title: LocaleKeys.demoEarningWith.trParams({'name': 'Ishan'}),
        subtitle: "19/12/2024 08:32:54 PM 00:01:30",
        paymentValue: 1.3,
        getAmount: 1.3,
        action: "PLUS",
        status: 1,
        holdStatus: HoldStatus.Paid,
        createdAt:
            DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
        taxItems: [TaxItems(name: "GST", rate: 0.18)],
        type: TransactionType.Call,
      ),
    },
    TransactionCategory.CALL: {
      ResultWalletModel(
        iD: 4,
        paymentId: 0,
        title: LocaleKeys.demoEarningWith.trParams({'name': 'Rahul'}),
        subtitle: "19/12/2024 09:24:50 PM 00:05:00",
        paymentValue: 5.0,
        getAmount: 5.0,
        action: "PLUS",
        status: 1,
        holdStatus: HoldStatus.Paid,
        createdAt:
            DateTime.now()
                .subtract(const Duration(days: 2, hours: 5))
                .toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
        taxItems: [TaxItems(name: "GST", rate: 0.18)],
        type: TransactionType.Call,
      ),
      ResultWalletModel(
        iD: 7,
        paymentId: 0,
        title: LocaleKeys.demoEarningWith.trParams({'name': 'Ishan'}),
        subtitle: "19/12/2024 08:32:54 PM 00:01:30",
        paymentValue: 1.3,
        getAmount: 1.3,
        action: "PLUS",
        status: 1,
        holdStatus: HoldStatus.Paid,
        createdAt:
            DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
        taxItems: [TaxItems(name: "GST", rate: 0.18)],
        type: TransactionType.Call,
      ),
      ResultWalletModel(
        iD: 8,
        paymentId: 0,
        title: LocaleKeys.demoEarningWith.trParams({'name': 'Manoj'}),
        subtitle: "19/12/2024 08:32:54 PM 00:02:30",
        paymentValue: 6.3,
        getAmount: 8.4,
        action: "PLUS",
        status: 1,
        holdStatus: HoldStatus.Paid,
        createdAt:
            DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
        taxItems: [TaxItems(name: "GST", rate: 0.18)],
        type: TransactionType.Call,
      ),
      ResultWalletModel(
        iD: 9,
        paymentId: 0,
        title: LocaleKeys.demoEarningWith.trParams({'name': 'Aarav'}),
        subtitle: "19/12/2024 08:32:54 PM 00:02:30",
        paymentValue: 9.3,
        getAmount: 10.3,
        action: "PLUS",
        status: 1,
        holdStatus: HoldStatus.Paid,
        createdAt:
            DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
        taxItems: [TaxItems(name: "GST", rate: 0.18)],
        type: TransactionType.Call,
      ),
    },
    TransactionCategory.CHAT: {
      ResultWalletModel(
        iD: 10,
        paymentId: 0,
        title: LocaleKeys.demoChatWith.trParams({'name': 'Vasu'}),
        subtitle: LocaleKeys.demoChatCountOn.trParams({
          'count': '1',
          'date': '11/01/2025',
        }),
        paymentValue: 2.3,
        getAmount: 2.0,
        action: "PLUS",
        status: 1,
        holdStatus: HoldStatus.Paid,
        createdAt:
            DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
        taxItems: [TaxItems(name: "GST", rate: 0.18)],
        type: TransactionType.Chat,
      ),
      ResultWalletModel(
        iD: 11,
        paymentId: 0,
        title: LocaleKeys.demoChatWith.trParams({'name': 'Pratham'}),
        subtitle: LocaleKeys.demoChatCountOn.trParams({
          'count': '3',
          'date': '11/01/2025',
        }),
        paymentValue: 10.3,
        getAmount: 6.0,
        action: "PLUS",
        status: 1,
        holdStatus: HoldStatus.Paid,
        createdAt:
            DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
        taxItems: [TaxItems(name: "GST", rate: 0.18)],
        type: TransactionType.Chat,
      ),
    },
    TransactionCategory.PENALTY: {
      ResultWalletModel(
        iD: 12,
        paymentId: 0,
        title: LocaleKeys.demoDailyPenaltyOnline.tr,
        subtitle: LocaleKeys.demoOnlineHoursDate.trParams({
          'hours': '0.0',
          'date': '06/01/2025',
        }),
        paymentValue: 2.3,
        getAmount: 50,
        action: "MINUS",
        status: 1,
        holdStatus: HoldStatus.Paid,
        createdAt:
            DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
        taxItems: [TaxItems(name: "GST", rate: 0.18)],
        type: TransactionType.Penalty,
      ),
      ResultWalletModel(
        iD: 13,
        paymentId: 0,
        title: LocaleKeys.demoPenaltyCallRejection.tr,
        subtitle: LocaleKeys.demoPenaltyRejectDetail.trParams({
          'date': '03/01/2025',
        }),
        paymentValue: 4.3,
        getAmount: 10.0,
        action: "MINUS",
        status: 1,
        holdStatus: HoldStatus.Paid,
        createdAt:
            DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
        taxItems: [TaxItems(name: "GST", rate: 0.18)],
        type: TransactionType.Chat,
      ),
    },
    TransactionCategory.REWARD: {
      ResultWalletModel(
        iD: 14,
        paymentId: 0,
        title: LocaleKeys.demoUserConversion.tr,
        subtitle: LocaleKeys.demoIncentiveTalk.trParams({'name': 'sjtdutd'}),
        paymentValue: 5,
        getAmount: 50,
        action: "PLUS",
        status: 1,
        holdStatus: HoldStatus.Paid,
        createdAt:
            DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
        taxItems: [TaxItems(name: "GST", rate: 0.18)],
        type: TransactionType.Reward,
      ),
      ResultWalletModel(
        iD: 15,
        paymentId: 0,
        title: LocaleKeys.demoDailyRewardOnline.tr,
        subtitle: LocaleKeys.demoOnlineHoursDate.trParams({
          'hours': '12.8',
          'date': '25-12-2024',
        }),
        paymentValue: 100,
        getAmount: 100,
        action: "PLUS",
        status: 1,
        holdStatus: HoldStatus.Paid,
        createdAt:
            DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
        taxItems: [TaxItems(name: "GST", rate: 0.18)],
        type: TransactionType.Reward,
      ),
    },
    TransactionCategory.WITHDRAW: {
      ResultWalletModel(
        iD: 16,
        paymentId: 0,
        title: LocaleKeys.demoMoneyWithdrawn.tr,
        subtitle: LocaleKeys.demoMoneyWithdrawnOk.tr,
        paymentValue: 10000,
        getAmount: 10000,
        action: "MINUS",
        status: 1,
        holdStatus: HoldStatus.Paid,
        createdAt:
            DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
        taxItems: [TaxItems(name: "GST", rate: 0.18)],
        type: TransactionType.Withdrawal,
      ),
      ResultWalletModel(
        iD: 17,
        paymentId: 0,
        title: LocaleKeys.demoMoneyWithdrawn.tr,
        subtitle: LocaleKeys.demoMoneyWithdrawnOk.tr,
        paymentValue: 293.00003,
        getAmount: 293.00003,
        action: "MINUS",
        status: 1,
        holdStatus: HoldStatus.Paid,
        createdAt:
            DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
        taxItems: [TaxItems(name: "GST", rate: 0.18)],
        type: TransactionType.Withdrawal,
      ),
    },
    TransactionCategory.GIFT: {
      ResultWalletModel(
        iD: 18,
        paymentId: 0,
        title: LocaleKeys.demoGiftFrom.trParams({'name': 'Vasu'}),
        subtitle: LocaleKeys.demoChocolateAt.trParams({'date': '11/01/2025'}),
        paymentValue: 5,
        getAmount: 5,
        action: "PLUS",
        status: 1,
        holdStatus: HoldStatus.Paid,
        createdAt:
            DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
        taxItems: [TaxItems(name: "GST", rate: 0.18)],
        type: TransactionType.Gift,
      ),
      ResultWalletModel(
        iD: 19,
        paymentId: 0,
        title: LocaleKeys.demoGiftFrom.trParams({'name': 'Pratham'}),
        subtitle: LocaleKeys.demoChocolateAt.trParams({'date': '11/01/2025'}),
        paymentValue: 10,
        getAmount: 10,
        action: "PLUS",
        status: 1,
        holdStatus: HoldStatus.Paid,
        createdAt:
            DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
        taxItems: [TaxItems(name: "GST", rate: 0.18)],
        type: TransactionType.Gift,
      ),
    },
  };
  final selectedTransactionTab = TransactionCategory.ALL.obs;

  void changeTransactionTab(TransactionCategory newTransactionCategory) {
    if (selectedTransactionTab.value != newTransactionCategory) {
      selectedTransactionTab.value = newTransactionCategory;
      if (selectedTransactionTab.value == TransactionCategory.PENALTY) {
        if (currentStage == TutorialStage.S2) {
          validateAction(
            TutorialDemoFeature.TRANSACTIONS_ONLINE_DURATION_PENALTY,
          );
        }
      } else if (selectedTransactionTab.value == TransactionCategory.CHAT) {
        validateAction(TutorialDemoFeature.TRANSACTIONS_CHAT);
      } else if (selectedTransactionTab.value == TransactionCategory.REWARD) {
        validateAction(TutorialDemoFeature.TRANSACTIONS_REWARD);
      } else if (selectedTransactionTab.value == TransactionCategory.CALL) {
        validateAction(TutorialDemoFeature.TRANSACTIONS_CALL);
      }
    }
  }

  // Chat Overview Screen
  final selectedChatTabFilter = ChatTabFilter.ALL.obs;
  final groups =
      <ChatTabFilter, List<ChatGroup>>{
        ChatTabFilter.ALL: [
          ChatGroup(
            id: 1,
            category: CategoryCode.GOSSIP,
            title: "Paraag",
            lastMessageAt: "2025-01-07T21:56:11.356963Z",
            members: [
              ChatMember(
                accountId: 342233,
                user: UserDataModel(id: 324256, name: 'Paraag'),
              ),
              ChatMember(
                accountId: Get.find<UserController>().accountId,
                user: Get.find<UserController>().userDetails.value.user,
              ),
            ],
            lastMessage: ChatMessage(
              content: LocaleKeys.demoHiThere.tr,
              senderAccountId: 1,
              attachmentUrl: "",
              type: ChatType.ChatTypeText,
            ),
          ),
          ChatGroup(
            id: 2,
            category: CategoryCode.GOSSIP,
            title: "Sammy",
            lastMessageAt: "2025-01-07T21:56:11.356963Z",
            members: [
              ChatMember(
                accountId: 342233,
                user: UserDataModel(id: 324256, name: 'Sammy'),
              ),
              ChatMember(
                accountId: Get.find<UserController>().accountId,
                user: Get.find<UserController>().userDetails.value.user,
              ),
            ],
            lastMessage: ChatMessage(
              content: LocaleKeys.demoWhatDoingHi.tr,
              senderAccountId: 1,
              attachmentUrl: "",
              type: ChatType.ChatTypeText,
            ),
          ),
        ],
        ChatTabFilter.UNREAD_TO_REPLY: [
          ChatGroup(
            id: 7,
            category: CategoryCode.GOSSIP,
            title: "Preetham",
            lastMessageAt: "2025-01-07T21:56:11.356963Z",
            members: [
              ChatMember(
                accountId: 985745,
                user: UserDataModel(id: 324256, name: 'Preetham'),
              ),
              ChatMember(
                accountId: Get.find<UserController>().accountId,
                user: Get.find<UserController>().userDetails.value.user,
              ),
            ],
            lastMessage: ChatMessage(
              content: LocaleKeys.demoHowDoYouDo.tr,
              senderAccountId: 1,
              attachmentUrl: "",
              type: ChatType.ChatTypeText,
            ),
          ),
          ChatGroup(
            id: 8,
            category: CategoryCode.GOSSIP,
            title: "Nikhil",
            lastMessageAt: "2025-01-07T21:56:11.356963Z",
            members: [
              ChatMember(
                accountId: 098748,
                user: UserDataModel(id: 324256, name: 'Nikhil'),
              ),
              ChatMember(
                accountId: Get.find<UserController>().accountId,
                user: Get.find<UserController>().userDetails.value.user,
              ),
            ],
            lastMessage: ChatMessage(
              content: LocaleKeys.demoWhatAreYouDoing.tr,
              senderAccountId: 1,
              attachmentUrl: "",
              type: ChatType.ChatTypeText,
            ),
          ),
        ],
      }.obs;
  final pendingAudios = <PendingAudio>{}.obs;

  void changeChatTab(ChatTabFilter newFilter) {
    if (selectedChatTabFilter.value != newFilter) {
      selectedChatTabFilter.value = newFilter;
      if (selectedChatTabFilter.value == ChatTabFilter.UNREAD_TO_REPLY) {
        validateAction(TutorialDemoFeature.CHAT_LISTING_REPLY);
      }
    }
    update();
  }

  // Chat Screen
  final theme = defaultTheme.obs;

  final chats = <DisplayChatMessage>[].obs;
  final presetsList = <PresetGroup>{}.obs;

  void sendMessage(
    String message, {
    bool isAudio = false,
    ChatType? chatType,
    String? attachmentUrl,
  }) {
    chats.insert(
      0,
      DisplayChatMessage(
        id: Random().nextInt(1000).toString(),
        attachmentUrl: attachmentUrl ?? "",
        content: message,
        createdAt: DateTime.now(),
        externalId: '',
        reaction: "",
        senderAccountId: Get.find<UserController>().userDetails.value.user?.id,
        type: chatType ?? ChatType.ChatTypeText,
        updatedAt: DateTime.now(),
        isDeletedByPartner: false,
        replyMessage: const ChatReplyMessage(),
        postId: "1",
      ),
    );
  }

  /// View changed theme locally
  void viewChangedTheme(ChatTheme newTheme) {
    if (theme.value != newTheme) {
      theme(newTheme);
    }
  }

  /// Change the theme on Firebase and locally
  void changeTheme({required ChatTheme newTheme}) async {
    theme(newTheme);
    validateAction(TutorialDemoFeature.CHAT_THEME);
  }

  // Broadcast
  final selectedChatFilter = DemoChatFilter().obs;
  final selectedFilterOption = "".obs;

  final matchingFilteredGroups =
      <ChatGroup>{
        ChatGroup(
          id: 1,
          category: CategoryCode.GOSSIP,
          title: "Paraag",
          lastMessageAt: "2025-01-07T21:56:11.356963Z",
          lastMessage: ChatMessage(
            content: LocaleKeys.demoHiThere.tr,
            senderAccountId: 1,
            attachmentUrl: "",
            type: ChatType.ChatTypeText,
          ),
        ),
        ChatGroup(
          id: 2,
          category: CategoryCode.GOSSIP,
          title: "Pratham",
          lastMessageAt: "2025-01-07T21:56:11.356963Z",
          lastMessage: ChatMessage(
            content: LocaleKeys.demoHiThere.tr,
            senderAccountId: 1,
            attachmentUrl: "",
            type: ChatType.ChatTypeText,
          ),
        ),
        ChatGroup(
          id: 3,
          category: CategoryCode.GOSSIP,
          title: "Sammy",
          lastMessageAt: "2025-01-07T21:56:11.356963Z",
          lastMessage: ChatMessage(
            content: LocaleKeys.demoHiThere.tr,
            senderAccountId: 1,
            attachmentUrl: "",
            type: ChatType.ChatTypeText,
          ),
        ),
      }.obs;

  final filterOptions =
      <DemoChatFilter>{
        DemoChatFilter(
          name: LocaleKeys.demoCall1to3.tr,
          description: LocaleKeys.demoEarlyFriends.tr,
          icon: Icons.av_timer_sharp,
          options: [
            ChatFilterOption(
              name: LocaleKeys.demoCall1to3.tr,
              code: "NEW_USERS",
            ),
          ],
        ),
        DemoChatFilter(
          name: LocaleKeys.demoCall4to9.tr,
          description: LocaleKeys.demoGoodFriends.tr,
          icon: Icons.favorite_border_rounded,
          options: [
            ChatFilterOption(
              name: LocaleKeys.demoCall4to9.tr,
              code: "MID_USERS",
            ),
          ],
        ),
        DemoChatFilter(
          name: LocaleKeys.demoOver9Calls.tr,
          description: LocaleKeys.demoBestFriends.tr,
          icon: Icons.person,
          options: [
            ChatFilterOption(
              name: LocaleKeys.demoOver9Calls.tr,
              code: "OLD_USERS",
            ),
          ],
        ),
      }.obs;

  void switchChatFilter(DemoChatFilter chatFilter) async {
    selectedChatFilter.value = chatFilter;
    selectedFilterOption.value = chatFilter.options?.first.code ?? "";
    Get.to(() => const DemoBroadcastListView());
  }

  // Daily Rewards
  final reverseCallsData = GetReverseCallsResponse.fromJson({
    "users": [
      {
        "user": {
          "id": 293010,
          "name": "Jogesh",
          "phone_number": "1144444444",
          "avatar": "",
          "status": "ACTIVE",
          "fcm_token": "invalid",
          "preference": "ON",
          "edit_enabled": false,
        },
        "account_id": 292902,
      },
      {
        "user": {
          "id": 292297,
          "name": "Freddy",
          "phone_number": "3213211231",
          "avatar": "",
          "status": "ACTIVE",
          "fcm_token": "invalid",
          "preference": "ON",
          "edit_enabled": false,
        },
        "account_id": 292247,
      },
      {
        "user": {
          "id": 292937,
          "name": "Tanmay",
          "phone_number": "1411111113",
          "avatar": "",
          "status": "ACTIVE",
          "fcm_token": "invalid",
          "preference": "ON",
          "edit_enabled": false,
        },
        "account_id": 292836,
      },
      {
        "user": {
          "id": 102366,
          "name": "Rakesh Verma",
          "phone_number": "7898490535",
          "avatar": "",
          "status": "ACTIVE",
          "fcm_token": "invalid",
          "preference": "ON",
          "edit_enabled": false,
        },
        "account_id": 102344,
      },
    ],
  });
  final rewardStats = RewardsStatsResponse.fromJson({
    "online_duration": {
      "current_hours": 0,
      "amount": 50,
      "penalty_threshold": 4,
      "reward_threshold": 8,
      "penalty_amount": 50,
      "reward_amount": 20,
      "achieved_threshold": "",
    },
    "incentive_calls": {
      "current_count": 0,
      "amount": 0,
      "thresholds": [
        {"count": 1, "amount": 10},
        {"count": 2, "amount": 30},
        {"count": 3, "amount": 50},
      ],
    },
    "reverse_calls": {
      "current_count": 0,
      "amount": 0,
      "thresholds": [
        {"count": 5, "amount": 10},
        {"count": 10, "amount": 20},
        {"count": 15, "amount": 40},
      ],
    },
    "chat_received": {
      "current_count": 0,
      "amount": 0,
      "thresholds": [
        {"count": 15, "amount": 15},
        {"count": 25, "amount": 40},
      ],
    },
    "is_leave": false,
    "reward_date": "07/11/2025",
  });

  // Blocklist
  final blockedUsers = <BlockedUsers>{}.obs;

  // Metrics
  late final metricsData =
      GetMetricsScoreResponse.fromJson({
        "aggregate": {
          "name": "one_score",
          "tag": "RED",
          "value": 16.50,
          "score": 16.50,
          "label": LocaleKeys.demoYourScore.tr,
          "units": LocaleKeys.demoPoints.tr,
          "max_value": 100,
          "cutoffs": [
            {"tag": "RED", "percentage": 0},
            {"tag": "YELLOW", "percentage": 60},
            {"tag": "GREEN", "percentage": 80},
          ],
          "video_url": "",
        },
        "metrics": [
          {
            "name": "average_call_old",
            "tag": "RED",
            "value": 4,
            "score": 33,
            "label": LocaleKeys.demoAvgCallOld.tr,
            "units": LocaleKeys.demoMinUnit.tr,
            "max_value": 12,
            "cutoffs": [
              {"tag": "RED", "percentage": 0},
              {"tag": "YELLOW", "percentage": 60},
              {"tag": "GREEN", "percentage": 80},
            ],
            "video_url": URLConstants.oneScoreAvgCallOldVideo,
            "icon_url": URLConstants.oneScoreAvgCallOldIcon,
          },
          {
            "name": "average_call_new",
            "tag": "YELLOW",
            "value": 6.5,
            "score": 65,
            "label": LocaleKeys.demoAvgCallNew.tr,
            "units": LocaleKeys.demoMinUnit.tr,
            "max_value": 10,
            "cutoffs": [
              {"tag": "RED", "percentage": 0},
              {"tag": "YELLOW", "percentage": 60},
              {"tag": "GREEN", "percentage": 80},
            ],
            "video_url": URLConstants.oneScoreAvgCallNewVideo,
            "icon_url": URLConstants.oneScoreAvgCallNewIcon,
          },
          {
            "name": "average_chat_received",
            "tag": "RED",
            "value": 90,
            "score": 56.25,
            "label": LocaleKeys.demoAvgChats.tr,
            "units": LocaleKeys.demoChatsPerDay.tr,
            "max_value": 160,
            "cutoffs": [
              {"tag": "RED", "percentage": 0},
              {"tag": "YELLOW", "percentage": 60},
              {"tag": "GREEN", "percentage": 80},
            ],
            "video_url": URLConstants.oneScoreChatReceivedVideo,
            "icon_url": URLConstants.oneScoreChatReceivedIcon,
          },
          {
            "name": "average_incentive_count",
            "tag": "YELLOW",
            "value": 0.8,
            "score": 66,
            "label": LocaleKeys.demoAvgIncentive.tr,
            "units": LocaleKeys.demoCallsUnit.tr,
            "max_value": 1.2,
            "cutoffs": [
              {"tag": "RED", "percentage": 0},
              {"tag": "YELLOW", "percentage": 60},
              {"tag": "GREEN", "percentage": 80},
            ],
            "video_url": URLConstants.oneScoreReward30minsVideo,
            "icon_url": URLConstants.oneScoreReward30minsIcon,
          },
          {
            "name": "average_online_duration",
            "tag": "RED",
            "value": 4,
            "score": 50,
            "label": LocaleKeys.demoAvgOnline.tr,
            "units": LocaleKeys.demoHoursUnit.tr,
            "max_value": 8,
            "cutoffs": [
              {"tag": "RED", "percentage": 0},
              {"tag": "YELLOW", "percentage": 60},
              {"tag": "GREEN", "percentage": 80},
            ],
            "video_url": URLConstants.oneScoreOnlineDurationVideo,
            "icon_url": URLConstants.oneScoreOnlineDurationIcon,
          },
        ],
        "history": [
          {
            "date": "2026-01-29T05:30:00+05:30",
            "score_aggregate": 20.38592904259761,
            "tag_aggregate": "RED",
            "variant": "",
          },
        ],
        "updated_at": "2026-01-29T03:26:32.784032+05:30",
        "firing_cutoff": 10,
      }).obs;

  double getIntervalPercentage(num? score) {
    return (((score ?? 0.0) / (metricsData.value.aggregate?.maxValue ?? 1.0)) *
        100);
  }

  void trackDemoEvent(
    String eventName, {
    Map<String, dynamic>? additionalProperties,
  }) {
    try {
      Get.find<TutorialLessonController>().trackLessonEvent(
        eventName,
        additionalProperties: {
          "currentDemoQuestion": currentQuestion.question,
          "totalDemoQuestions": demoQuestions.length,
          "currentDemoQuestionIndex": (currentQuestionIndex.value + 1),
          ...?additionalProperties,
        },
      );
    } catch (e) {
      Logger.logMessage("Error in trackDemoEvent ${e.toString()}");
    }
  }
}
