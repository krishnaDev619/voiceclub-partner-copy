import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/injection_container.dart';
import 'package:voiceclub_partner/core/services/analytics_service.dart';
import 'package:voiceclub_partner/core/services/notify_demand_service.dart';
import 'package:voiceclub_partner/data/models/chat/chat_group.dart';
import 'package:voiceclub_partner/data/models/chat/chat_theme.dart';
import 'package:voiceclub_partner/data/models/chat/display_chat_message.dart';
import 'package:voiceclub_partner/data/models/chat/member.dart';
import 'package:voiceclub_partner/domain/usecases/chat/save_scroll_position.dart'
    as save;
import 'package:voiceclub_partner/modules/controller/chat_messages_controller.dart';
import 'package:voiceclub_partner/modules/controller/user_controller.dart';
import 'package:voiceclub_partner/view/chat/widgets/blocked_indicator_widget.dart';
import 'package:voiceclub_partner/view/chat/widgets/bottom_sheet/first_call_bottom_sheet.dart';
import 'package:voiceclub_partner/view/chat/widgets/chat_action_bottom_bar.dart';
import 'package:voiceclub_partner/view/chat/widgets/chat_display_widget.dart';
import 'package:voiceclub_partner/view/chat/widgets/chat_options_menu.dart';
import 'package:voiceclub_partner/view/chat/widgets/chat_profile_picture.dart';
import 'package:voiceclub_partner/view/chat/widgets/date_separator.dart';
import 'package:voiceclub_partner/view/chat/widgets/reverse_call_section.dart';
import 'package:voiceclub_partner/view/tutorial/demo/widgets/core/disabled_widget.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';

class ChatScreen extends StatefulWidget {
  final ChatGroup chatGroup;
  final CategoryCode categoryCode;
  final int selfAccountId;
  final bool isNew;
  final String? searchTerm;
  final String screenName;
  final ChatTabFilter filter;

  const ChatScreen({
    super.key,
    required this.chatGroup,
    required this.categoryCode,
    required this.selfAccountId,
    required this.searchTerm,
    required this.screenName,
    this.isNew = false,
    required this.filter,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final controllerFactory = sl<ChatMessagesControllerFactory>();
  final _scrollController = ScrollController();
  DateTime? currentDate;
  late ChatMessagesController _controller;
  late int chatGroupId;
  late ChatMember peer, me;
  Timer? _debounceTimer;
  String? customName;

  final _userController = Get.find<UserController>();

  @override
  void initState() {
    chatGroupId = widget.chatGroup.id ?? 0;
    customName = widget.chatGroup.customName;
    me =
        widget.chatGroup.members?.firstWhereOrNull(
          (element) => element.accountId == widget.selfAccountId,
        ) ??
        ChatMember();
    peer =
        widget.chatGroup.members?.firstWhereOrNull(
          (member) => member.accountId != widget.selfAccountId,
        ) ??
        ChatMember();
    _controller = controllerFactory.create(
      chatGroupId: chatGroupId,
      scrollController: _scrollController,
      filter: widget.filter,
    );
    Get.put(_controller, tag: chatGroupId.toString());
    sl<AnalyticsService>().trackEvent(
      'chatOpenPartner',
      eventProperties: getEventProperties(),
    );

    _controller.getReverseStats(peer.accountId ?? 0);

    // Listen for reverse calling stats changes to show first call bottom sheet
    ever(_controller.reverseCallingStatsResponse, (stats) {
      if (stats.toReceiveReverseCall == true &&
          stats.isCallAllowed == true &&
          !((stats.rechargedDuration ?? 0) > 0) &&
          !Get.find<UserController>().currentStage.isLessThan(
            TutorialStage.S3,
          )) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.bottomSheet(
            FirstCallBottomSheet(
              userName: peer.user?.name ?? LocaleKeys.demoUser.tr,
              reverseCallingStatsResponse: stats,
              demandPeer: peer,
              chatGroupId: chatGroupId,
            ),
            isScrollControlled: true,
            isDismissible: true,
            backgroundColor: Colors.transparent,
          );
        });
      }
    });

    // Listen for scroll events
    _scrollController.addListener(() {
      _onScroll();
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        // Reached the end, load more messages
        _controller.fetchMoreChats();
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (widget.isNew) {
        sl<AnalyticsService>().trackEvent(
          "newUserChat",
          eventProperties: {
            'categoryName': widget.categoryCode.name,
            'demandName': peer.user?.name ?? '',
            'demandNumber': peer.user?.phoneNumber ?? '',
            'demandUid': peer.user?.id ?? '',
            'tier': widget.chatGroup.tier?.name ?? '',
            'groupId': widget.chatGroup.id ?? 0,
          },
        );
        Get.dialog(
          AlertDialog(
            icon: Align(
              alignment: Alignment.topLeft,
              child: Icon(
                Icons.person_add,
                color: Get.theme.primaryColor,
                size: 25,
              ),
            ),
            title: Text(LocaleKeys.liveNewUser.tr, textAlign: TextAlign.start),
            content: Text(LocaleKeys.livePleaseSendAnAudioMessage.tr),
            actions: [
              TextButton(
                onPressed: () {
                  Get.back();
                },
                child: Text(LocaleKeys.liveOk.tr),
              ),
            ],
          ),
        );
      }
    });
    super.initState();
  }

  void _onScroll() {
    // Start or reset the debounce timer whenever a scroll event occurs
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      // If the scrolling has paused for 500 milliseconds, save the scroll position
      sl<save.SaveScrollPositionUsecase>().call(
        save.Params(
          chatGroupId: chatGroupId,
          scrollPosition: _scrollController.offset,
        ),
      );
    });
  }

  Map<String, dynamic> getEventProperties() {
    const prefix = 'demand';
    final eventProperites = {
      'categoryName': widget.categoryCode.name,
      '${prefix}Name': peer.user?.name ?? '',
      '${prefix}Number': peer.user?.phoneNumber ?? '',
      '${prefix}Uid': peer.user?.id ?? '',
      'tier': widget.chatGroup.tier?.name ?? '',
      'groupId': widget.chatGroup.id ?? 0,
      'screenName': widget.screenName,
      if (widget.searchTerm?.isNotEmpty ?? false)
        'searchTerm': widget.searchTerm,
      'theme': _controller.theme.id,
      'tabFilter': widget.filter.chatTabFilterName,
    };
    return eventProperites;
  }

  bool isToday(DateTime? dateTime) {
    return isSameDate(dateTime, DateTime.now());
  }

  bool isSameDate(DateTime? date1, DateTime? date2) {
    return date1?.day == date2?.day &&
        date1?.month == date2?.month &&
        date1?.year == date2?.year;
  }

  Widget _getActionBar(ChatTheme theme) {
    if (widget.chatGroup.isBlocked ?? false) {
      return const BlockedIndicatorWidget();
    } else {
      return ChatActionBottomBar(
        chatGroup: widget.chatGroup,
        eventProperties: getEventProperties(),
        code: widget.categoryCode,
        accountId: widget.selfAccountId,
        theme: theme,
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = _controller.theme;
    return Scaffold(
      backgroundColor:
          (widget.chatGroup.tier == ChatTier.PREMIUM)
              ? const Color(0xFF68361C)
              : const Color(0xFFFFF6F6),
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: theme.appBarBackgroundColor,
          statusBarIconBrightness: theme.statusBarIconBrightness,
        ),
        elevation: 0.0,
        backgroundColor: theme.appBarBackgroundColor,
        leadingWidth: 32.0,
        leading: BackButton(color: theme.appBarContentColor),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ChatProfilePicture(person: peer),
            const SizedBox(width: 10),
            Flexible(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${widget.chatGroup.title}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                      color: theme.appBarContentColor,
                    ),
                  ),
                  Visibility(
                    visible: customName?.isNotEmpty ?? false,
                    child: Text(
                      customName ?? "",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.appBarContentColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          Visibility(
            visible: widget.chatGroup.tier == ChatTier.PREMIUM,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Tooltip(
                triggerMode: TooltipTriggerMode.tap,
                message: LocaleKeys.liveGiftingActivatedFor.trParams({
                  'name': peer.user?.name ?? '',
                }),
                child: Icon(
                  Icons.card_giftcard_rounded,
                  color: theme.appBarContentColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8.0),
          Disabled(
            disabled: _userController.currentStage.isLessThan(TutorialStage.S4),
            child: FutureBuilder(
              future: NotifyDemandService().isAllowedToSendNormalNotification(
                demandUserId: peer.user?.id ?? 0,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.data != null && (snapshot.data ?? false)) {
                    return InkWell(
                      onTap: () {
                        if (peer.user?.id != null) {
                          NotifyDemandService().sendNotificationToDemand(
                            logId: 0,
                            demandUid: peer.user?.id ?? 0,
                            isAudio: false,
                            userName: peer.user?.name ?? "",
                            screenName: 'ChatScreen',
                          );
                        }
                      },
                      child: Icon(
                        Icons.notifications_active,
                        color: theme.appBarContentColor,
                      ),
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                } else {
                  return const SizedBox.shrink();
                }
              },
            ),
          ),
          if (!(widget.chatGroup.isBlocked ?? false))
            ChatOptionsMenuButton(
              chatGroup: widget.chatGroup,
              peer: peer,
              theme: theme,
              customName: customName,
              eventProperties: getEventProperties(),
              onCustomNameChanged: (newNickname) {
                setState(() {
                  customName = newNickname;
                });
              },
            ),
          const SizedBox(width: 10.0),
        ],
      ),
      body: SafeArea(
        child: GetBuilder<ChatMessagesController>(
          tag: chatGroupId.toString(),
          builder: (controller) {
            return Stack(
              children: [
                Container(
                  height: double.infinity,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color:
                        (widget.chatGroup.tier == ChatTier.PREMIUM)
                            ? const Color(0xFFFFF6E0)
                            : const Color(0xFFFFF6F6),
                    image: DecorationImage(
                      image: AssetImage(theme.assetPath ?? ""),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Expanded(
                        child: StreamBuilder<List<DisplayChatMessage>>(
                          stream: controller.chats.stream,
                          builder: (context, snapshot) {
                            final messages = snapshot.data?.toList() ?? [];
                            return Column(
                              children: [
                                Expanded(
                                  child: ListView(
                                    controller: _scrollController,
                                    shrinkWrap: true,
                                    reverse: true,
                                    padding: const EdgeInsets.only(
                                      bottom: 4.0,
                                      top: 48.0,
                                    ),
                                    children: [
                                      for (int i = 0; i < messages.length; i++)
                                        getChatListWidget(messages, i),
                                    ],
                                  ),
                                ),
                                _getActionBar(theme),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Visibility(
                  visible: _controller.isLoading.value,
                  child: const Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: EdgeInsets.all(10.0),
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 16.0,
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(strokeWidth: 1.5),
                        ),
                      ),
                    ),
                  ),
                ),
                Obx(
                  () => Align(
                    alignment: Alignment.topCenter,
                    child: Disabled(
                      disabled: _userController.currentStage.isLessThan(
                        TutorialStage.S3,
                      ),
                      child: ReverseCallSection(
                        theme: theme,
                        peerData: peer,
                        chatGroupId: chatGroupId,
                        filter: widget.filter,
                        reverseCallingStatsResponse:
                            _controller.reverseCallingStatsResponse.value,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget getChatListWidget(List<DisplayChatMessage> messages, int index) {
    if (messages.isEmpty) {
      return Text(LocaleKeys.liveNoMessagesYet.tr);
    } else {
      final message = messages[index];
      bool isLatestMessage = false;
      final sentByMe = message.senderAccountId == widget.selfAccountId;
      bool consecutive = false;
      DisplayChatMessage? nextMessage;
      if (index != messages.length - 1) {
        nextMessage = messages[index + 1];
        consecutive = message.senderAccountId == nextMessage.senderAccountId;
      }
      if (isToday(message.createdAt)) {
        final todaysMessages =
            messages.where((m) => isToday(m.createdAt) && sentByMe).toList();
        if (todaysMessages.isNotEmpty) {
          isLatestMessage = (message == todaysMessages.first);
        }
      }
      if (nextMessage == null ||
          (!isSameDate(currentDate, message.createdAt) &&
              !isSameDate(message.createdAt, nextMessage.createdAt))) {
        currentDate = message.createdAt;
        return Column(
          children: [
            DateSeparator(currentDate ?? DateTime.now()),
            ChatDisplayWidget(
              key: Key(
                '${message.createdAt.toString()}${message.type.toString()}',
              ),
              message: message,
              groupId: widget.chatGroup.id ?? 0,
              categoryCode: widget.categoryCode,
              sentByMe: sentByMe,
              myData: me,
              consecutive: false,
              peerData: peer,
              tier: widget.chatGroup.tier ?? ChatTier.PRO,
              isLatestMessage: isLatestMessage,
              theme: _controller.theme,
            ),
          ],
        );
      } else {
        return ChatDisplayWidget(
          key: Key('${message.createdAt.toString()}${message.type.toString()}'),
          message: message,
          groupId: widget.chatGroup.id ?? 0,
          categoryCode: widget.categoryCode,
          sentByMe: sentByMe,
          myData: me,
          consecutive: consecutive,
          peerData: peer,
          tier: widget.chatGroup.tier ?? ChatTier.PRO,
          isLatestMessage: isLatestMessage,
          theme: _controller.theme,
        );
      }
    }
  }
}
