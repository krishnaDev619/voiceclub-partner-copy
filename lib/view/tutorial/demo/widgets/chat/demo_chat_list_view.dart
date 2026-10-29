import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/data/models/chat/chat_message.dart';
import 'package:voiceclub_partner/modules/controller/user_controller.dart';
import 'package:voiceclub_partner/view/chat/widgets/last_message_widget.dart';
import 'package:voiceclub_partner/view/tutorial/demo/controllers/demo_landing_controller.dart';
import 'package:voiceclub_partner/view/tutorial/demo/screens/demo_chat_screen.dart';
import 'package:voiceclub_partner/view/widgets/custom_profile_picture.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';

class DemoChatListView extends StatefulWidget {
  const DemoChatListView({super.key});

  @override
  State<DemoChatListView> createState() => _DemoChatListViewState();
}

class _DemoChatListViewState extends State<DemoChatListView> {
  @override
  void initState() {
    super.initState();
  }

  String _formatLastMessageTimestamp(String timestamp) {
    final now = DateTime.now().toUtc();
    final messageTime = DateTime.parse(timestamp);
    final difference = now.difference(messageTime);

    if (difference.inHours < 24) {
      // Less than 24 hours ago but different day, display 'yesterday'.
      if (now.day != messageTime.day) {
        return LocaleKeys.demoYesterday.tr;
      }
      // Less than 24 hours ago and same day, display time in 24-hour format in the phone's time zone.
      else {
        final formatter = DateFormat.Hm(); // HH:mm
        return formatter.format(messageTime);
      }
    } else if (difference.inDays == 1) {
      // Exactly 1 day ago, display 'yesterday'.
      return LocaleKeys.demoYesterday.tr;
    } else if (difference.inDays < 7) {
      // Between 2 to 6 days ago, display the day of the week.
      final formatter = DateFormat.EEEE('en_US'); // EEEE
      return formatter.format(messageTime);
    } else {
      // More than a week ago, display in the format DD/MM/YY.
      final formatter = DateFormat('dd/MM/yy');
      return formatter.format(messageTime);
    }
  }

  Widget _getChatDisplay(String? name) {
    return CustomProfilePicture(
      name: name ?? "P",
      avatarURL: "",
      backgroundColor: Get.theme.primaryColor,
      radius: 27,
    );
  }

  @override
  Widget build(BuildContext context) {
    final selfAccountId =
        Get.find<UserController>().userDetails.value.accountId ?? 0;
    return GetBuilder<DemoLandingController>(
      builder: (controller) {
        final chatList =
            controller.groups[controller.selectedChatTabFilter.value]
                ?.toList() ??
            [];
        if (chatList.isEmpty) {
          return Center(
            child: Text(
              LocaleKeys.demoNoChats.tr,
              style: const TextStyle(color: Colors.black),
            ),
          );
        } else {
          return ListView.separated(
            itemCount: chatList.length,
            padding: const EdgeInsets.only(bottom: 100.0),
            separatorBuilder:
                (context, index) =>
                    const Divider(height: 0.0, indent: 24.0, endIndent: 24.0),
            itemBuilder: (context, index) {
              final chatGroup = chatList[index];
              // final sender = chatGroup.members?.firstWhereOrNull(
              //     (member) => member.accountId != selfAccountId);
              bool isPinned = false;
              return ListTile(
                onTap: () {
                  Get.to(
                    () => DemoChatScreen(isNew: false, chatGroup: chatGroup),
                  );
                },
                leading: GestureDetector(
                  onTap: () async {},
                  child: SizedBox(
                    height: 60.0,
                    width: 54.0,
                    child: Stack(
                      children: [
                        _getChatDisplay(chatGroup.title),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Visibility(
                            visible:
                                chatGroup.tier?.name == ChatTier.PREMIUM.name,
                            child: Container(
                              height: 14.0,
                              width: 54.0,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  stops: const [0.027, 0.973],
                                  colors: [
                                    Get.theme.primaryColor.withValues(
                                      alpha: 0.3,
                                    ),
                                    Get.theme.primaryColor,
                                  ],
                                  transform: const GradientRotation(
                                    86.73,
                                  ), // Adjust the gradient rotation angle
                                ),
                                borderRadius: BorderRadius.circular(4.0),
                              ),
                              child: FittedBox(
                                child: Text(
                                  LocaleKeys.demoBestFriend.tr,
                                  maxLines: 1,
                                  overflow: TextOverflow.clip,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: FontSize.xS,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
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
                title: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        "${(chatGroup.title ?? '')}${(chatGroup.customName?.isNotEmpty ?? false) ? (" (${chatGroup.customName})") : ""}",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Visibility(
                      visible: isPinned,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 2.0),
                        child: Icon(
                          Icons.favorite,
                          size: 16.0,
                          color: Get.theme.primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
                subtitle: LastMessageWidget(
                  message: chatGroup.lastMessage ?? ChatMessage(),
                  seen: (chatGroup.unseenCount ?? 0) == 0,
                  isMe: chatGroup.lastMessage?.senderAccountId == selfAccountId,
                  senderName: chatGroup.title ?? '',
                ),
                trailing: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Text(
                      _formatLastMessageTimestamp(
                        chatGroup.lastMessageAt ?? '',
                      ),
                      style: TextStyle(
                        fontSize: 12.0,
                        color:
                            (chatGroup.unseenCount ?? 0) > 0
                                ? Get.theme.primaryColor
                                : Colors.black,
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Visibility(
                          visible: (chatGroup.unseenCount ?? 0) > 0,
                          replacement: const Padding(
                            padding: EdgeInsets.only(top: 4.0),
                            child: SizedBox(height: 20.0),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: CircleAvatar(
                              backgroundColor: Get.theme.primaryColor,
                              radius: 10,
                              child: Text(
                                chatGroup.unseenCount.toString(),
                                style: const TextStyle(
                                  fontSize: FontSize.M,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        }
      },
    );
  }
}
