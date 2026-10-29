import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:voiceclub_partner/core/constants/asset_constants.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/core/services/avatar_service.dart';
import 'package:voiceclub_partner/data/models/chat/chat_group.dart';
import 'package:voiceclub_partner/data/models/chat/chat_theme.dart';
import 'package:voiceclub_partner/data/models/chat/display_chat_message.dart';
import 'package:voiceclub_partner/data/models/chat/member.dart';
import 'package:voiceclub_partner/data/models/notifications/user_data.dart';
import 'package:voiceclub_partner/modules/controller/user_controller.dart';
import 'package:voiceclub_partner/view/notes/notes_section.dart';
import 'package:voiceclub_partner/view/chat/widgets/chat_profile_picture.dart';
import 'package:voiceclub_partner/view/chat/widgets/date_separator.dart';
import 'package:voiceclub_partner/view/tutorial/demo/bottom_sheets/demo_block_profile_bottom_sheet.dart';
import 'package:voiceclub_partner/view/tutorial/demo/controllers/demo_landing_controller.dart';
import 'package:voiceclub_partner/view/tutorial/demo/screens/demo_call_history_screen.dart';
import 'package:voiceclub_partner/view/tutorial/demo/widgets/chat/demo_chat_action_bottom_bar.dart';
import 'package:voiceclub_partner/view/tutorial/demo/widgets/chat/demo_chat_display_widget.dart';
import 'package:voiceclub_partner/view/tutorial/demo/widgets/chat/demo_notes_bottom_sheet.dart';
import 'package:voiceclub_partner/view/tutorial/demo/widgets/core/disabled_widget.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';

class DemoChatScreen extends StatefulWidget {
  final bool isNew;
  final ChatGroup chatGroup;

  const DemoChatScreen({
    super.key,
    required this.isNew,
    required this.chatGroup,
  });

  @override
  State<DemoChatScreen> createState() => _DemoChatScreenState();
}

class _DemoChatScreenState extends State<DemoChatScreen> {
  DateTime? currentDate;
  late ChatMember peer, me;
  late ChatGroup chatGroup;
  final demoController = Get.find<DemoLandingController>();

  @override
  void initState() {
    chatGroup = widget.chatGroup;
    me =
        chatGroup.members?.firstWhereOrNull(
          (element) =>
              element.accountId == Get.find<UserController>().accountId,
        ) ??
        ChatMember();
    peer =
        chatGroup.members?.firstWhereOrNull(
          (member) => member.accountId != Get.find<UserController>().accountId,
        ) ??
        ChatMember();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (widget.isNew) {
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
            title: Text(
              LocaleKeys.demoNewUserBang.tr,
              textAlign: TextAlign.start,
            ),
            content: Text(LocaleKeys.demoPleaseSendAudio.tr),
            actions: [
              TextButton(
                onPressed: () {
                  Get.back();
                },
                child: Text(LocaleKeys.ok.tr),
              ),
            ],
          ),
        );
      }
    });
    super.initState();
  }

  bool isToday(DateTime? dateTime) {
    return isSameDate(dateTime, DateTime.now());
  }

  bool isSameDate(DateTime? date1, DateTime? date2) {
    return date1?.day == date2?.day &&
        date1?.month == date2?.month &&
        date1?.year == date2?.year;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final theme = demoController.theme.value;
      final messages = demoController.chats.toList();
      return Scaffold(
        backgroundColor:
            (chatGroup.tier == ChatTier.PREMIUM)
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
                child: Text(
                  '${chatGroup.title}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16,
                    color: theme.appBarContentColor,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            Disabled(
              disabled: demoController.currentStage.isLessThan(
                TutorialStage.S3,
              ),
              child: GestureDetector(
                onTap: () async {
                  await Get.defaultDialog(
                    title: LocaleKeys.demoReverseCall.tr,
                    titleStyle: const TextStyle(
                      color: ApplicationColors.gossip,
                      fontWeight: FontWeight.bold,
                    ),
                    middleText: LocaleKeys.demoPlacedReverseCall.trParams({
                      'name': peer.user?.name ?? '',
                    }),
                    middleTextStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                    textConfirm: LocaleKeys.okay.tr,
                    onConfirm: () => Get.back(),
                  );
                  demoController.validateAction(
                    TutorialDemoFeature.CHAT_REVERSE_CALL,
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    border:
                        theme == defaultTheme
                            ? Border.all(color: Colors.white)
                            : null,
                    color: theme.primaryColor,
                  ),
                  margin: const EdgeInsets.symmetric(
                    vertical: 12.0,
                    horizontal: 4.0,
                  ),
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      const Icon(Icons.call, color: Colors.white, size: 16),
                      const SizedBox(width: 4.0),
                      Text(
                        LocaleKeys.demoCall.tr,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: FontSize.M,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8.0),
            Disabled(
              disabled: demoController.currentStage.isLessThan(
                TutorialStage.S4,
              ),
              child: GestureDetector(
                onTap: () {
                  demoController.validateAction(
                    TutorialDemoFeature.CHAT_NOTIFICATION,
                  );
                  demoController.sendMessage(
                    LocaleKeys.demoYouSendNotification.tr,
                    chatType: ChatType.ChatTypeNotification,
                  );
                },
                child: Icon(
                  Icons.notifications_active,
                  color: theme.appBarContentColor,
                ),
              ),
            ),
            Disabled(
              disabled: demoController.currentStage.isLessThan(
                TutorialStage.S4,
              ),
              child: PopupMenuButton(
                position: PopupMenuPosition.under,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                elevation: 8,
                onSelected: (value) async {
                  // if (value == "theme") {
                  //   final oldTheme = demoController.theme.value;
                  //   final newTheme = await Get.bottomSheet<ChatTheme?>(
                  //     isScrollControlled: true,
                  //     DemoChangeThemeBottomSheet(
                  //       currentTheme: theme,
                  //       themes: Get.find<ChatOverviewController>().chatThemes,
                  //       onThemeSelected: (value) {
                  //         demoController.viewChangedTheme(value);
                  //       },
                  //     ),
                  //   );
                  //   if (newTheme != null) {
                  //     demoController.changeTheme(newTheme: newTheme);
                  //   } else {
                  //     demoController.viewChangedTheme(oldTheme);
                  //   }
                  // } else
                  if (value == "block") {
                    Get.bottomSheet(
                      Container(
                        padding: const EdgeInsets.all(10.0),
                        child: DemoBlockProfileBottomSheet(
                          name: peer.user?.name ?? "",
                          avatar: AvatarService.getRandomAvatarUrl(),
                          userData: peer.user ?? UserDataModel(),
                          isChat: true,
                        ),
                      ),
                      isScrollControlled: true,
                      isDismissible: true,
                      backgroundColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                    );
                  } else if (value == 'history') {
                    // demoController
                    //     .validateAction(TutorialDemoFeature.CALL_HISTORY);
                    Get.to(
                      () => DemoCallHistoryScreen(
                        userId: peer.user?.id ?? 0,
                        avatar:
                            (peer.user?.avatar?.isNotEmpty ?? false)
                                ? peer.user?.avatar ??
                                    AvatarService.getRandomAvatarUrl()
                                : AvatarService.getRandomAvatarUrl(),
                        name: peer.user?.name ?? LocaleKeys.demoAnon.tr,
                      ),
                    );
                  }
                },
                itemBuilder: (BuildContext bc) {
                  return [
                    // PopupMenuItem(
                    //   padding: const EdgeInsets.symmetric(
                    //       horizontal: 8.0, vertical: 6.0),
                    //   height: 24.0,
                    //   textStyle: const TextStyle(
                    //     fontSize: FontSize.L,
                    //   ),
                    //   value: 'theme',
                    //   child: Row(
                    //     mainAxisSize: MainAxisSize.min,
                    //     children: [
                    //       CircleAvatar(
                    //         radius: 10.0,
                    //         backgroundColor: theme.primaryColor,
                    //       ),
                    //       const SizedBox(
                    //         width: 8.0,
                    //       ),
                    //       Expanded(
                    //         child: Row(
                    //           mainAxisSize: MainAxisSize.min,
                    //           children: [
                    //             Shimmer.fromColors(
                    //               baseColor: theme.appBarBackgroundColor,
                    //               highlightColor: theme.appBarContentColor,
                    //               child: Text(
                    //                 "Change Theme",
                    //                 maxLines: 1,
                    //                 overflow: TextOverflow.ellipsis,
                    //                 style: TextStyle(
                    //                   fontSize: FontSize.L,
                    //                   fontWeight: FontWeight.bold,
                    //                   color: Colors.black,
                    //                   fontFamily:
                    //                       GoogleFonts.mulish().fontFamily,
                    //                 ),
                    //               ),
                    //             ),
                    //             Container(
                    //               margin: const EdgeInsets.only(left: 8.0),
                    //               padding: const EdgeInsets.symmetric(
                    //                 horizontal: 4.0,
                    //                 vertical: 2.0,
                    //               ),
                    //               decoration: BoxDecoration(
                    //                 color: theme.appBarBackgroundColor,
                    //                 borderRadius: BorderRadius.circular(4.0),
                    //               ),
                    //               child: Text(
                    //                 "NEW",
                    //                 style: TextStyle(
                    //                   fontSize: 8,
                    //                   color: theme.appBarContentColor,
                    //                 ),
                    //               ),
                    //             ),
                    //           ],
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    PopupMenuItem(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 6.0,
                      ),
                      height: 24.0,
                      textStyle: const TextStyle(fontSize: FontSize.L),
                      value: 'history',
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.history, size: 20.0),
                          const SizedBox(width: 8.0),
                          Expanded(
                            child: Text(
                              LocaleKeys.demoCallHistory.tr,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: FontSize.L,
                                color: Colors.black,
                                fontFamily: GoogleFonts.mulish().fontFamily,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 6.0,
                      ),
                      height: 24.0,
                      textStyle: const TextStyle(fontSize: FontSize.L),
                      value: 'block',
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.block, size: 20.0),
                          const SizedBox(width: 8.0),
                          Expanded(
                            child: Text(
                              LocaleKeys.demoBlockNamed.trParams({
                                'name': peer.user?.name ?? '',
                              }),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: FontSize.L,
                                color: Colors.black,
                                fontFamily: GoogleFonts.mulish().fontFamily,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ];
                },
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Icon(Icons.more_vert, color: theme.appBarContentColor),
                ),
              ),
            ),
            const SizedBox(width: 10.0),
          ],
        ),
        body: SafeArea(
          child: GetBuilder<DemoLandingController>(
            builder: (controller) {
              return Stack(
                children: [
                  Container(
                    height: double.infinity,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color:
                          (chatGroup.tier == ChatTier.PREMIUM)
                              ? const Color(0xFFFFF6E0)
                              : const Color(0xFFFFF6F6),
                      image: DecorationImage(
                        image: AssetImage(
                          theme.assetPath ?? AssetConstants.chatBackground,
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: ListView(
                      shrinkWrap: true,
                      reverse: true,
                      padding: const EdgeInsets.only(bottom: 96.0, top: 48.0),
                      children: [
                        for (int i = 0; i < messages.length; i++)
                          getChatListWidget(messages, i),
                      ],
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: DemoChatActionBottomBar(peer: peer),
                  ),
                  Align(
                    alignment: Alignment.topCenter,
                    child: Disabled(
                      disabled: controller.currentStage.isLessThan(
                        TutorialStage.S5,
                      ),
                      child: GestureDetector(
                        onTap: () {
                          Get.bottomSheet(
                            DemoNotesBottomSheet(
                              userName: peer.user?.name ?? "",
                              accountId: peer.accountId ?? 0,
                              userNumber: peer.user?.phoneNumber ?? "",
                              screenName: "Demo Chat",
                              theme: theme,
                              existingNickname: "",
                              nicknameChangeCallback: (_) {},
                            ),
                            isScrollControlled: true,
                          );
                        },
                        child: NotesSection(theme: theme),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      );
    });
  }

  Widget getChatListWidget(List<DisplayChatMessage> messages, int index) {
    final theme = Get.find<DemoLandingController>().theme.value;

    if (messages.isEmpty) {
      return Text(LocaleKeys.demoNoMessages.tr);
    } else {
      final message = messages[index];
      bool isLatestMessage = false;
      const sentByMe = true;
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
          (!isSameDate(DateTime.now(), message.createdAt) &&
              !isSameDate(message.createdAt, nextMessage.createdAt))) {
        currentDate = message.createdAt;
        return Column(
          children: [
            DateSeparator(currentDate ?? DateTime.now()),
            DemoChatDisplayWidget(
              key: Key(
                '${message.createdAt.toString()}${message.type.toString()}',
              ),
              message: message,
              groupId: chatGroup.id ?? 0,
              categoryCode: CategoryCode.GOSSIP,
              sentByMe: sentByMe,
              myData: me,
              consecutive: false,
              peerData: peer,
              tier: ChatTier.PRO,
              isLatestMessage: isLatestMessage,
              theme: Get.find<DemoLandingController>().theme.value,
            ),
          ],
        );
      } else {
        return DemoChatDisplayWidget(
          key: Key('${message.createdAt.toString()}${message.type.toString()}'),
          message: message,
          groupId: chatGroup.id ?? 0,
          categoryCode: CategoryCode.GOSSIP,
          sentByMe: sentByMe,
          myData: me,
          consecutive: consecutive,
          peerData: peer,
          tier: chatGroup.tier ?? ChatTier.PRO,
          isLatestMessage: isLatestMessage,
          theme: theme,
        );
      }
    }
  }
}
