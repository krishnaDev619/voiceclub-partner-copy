import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/core/services/avatar_service.dart';
import 'package:voiceclub_partner/data/models/chat/chat_theme.dart';
import 'package:voiceclub_partner/data/models/chat/display_chat_message.dart';
import 'package:voiceclub_partner/data/models/chat/member.dart';
import 'package:voiceclub_partner/view/chat/widgets/messages/chat_audio_message.dart';

class ChatAudioNotificationMessage extends StatefulWidget {
  final String audioUrl;
  final DateTime time;
  final ChatMember supply;
  final ChatMember demand;
  final CategoryCode categoryCode;
  final bool sentByMe;
  final bool isNotification;
  final int groupId;
  final ChatTheme theme;
  final DisplayChatMessage message;

  const ChatAudioNotificationMessage({
    super.key,
    required this.audioUrl,
    required this.time,
    required this.demand,
    required this.categoryCode,
    required this.supply,
    required this.sentByMe,
    required this.isNotification,
    required this.groupId,
    required this.theme,
    required this.message,
  });

  @override
  State<ChatAudioNotificationMessage> createState() =>
      _ChatAudioNotificationMessageState();
}

class _ChatAudioNotificationMessageState
    extends State<ChatAudioNotificationMessage> {
  @override
  Widget build(BuildContext context) {
    if (widget.sentByMe) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Visibility(
            visible: widget.isNotification,
            child: Padding(
              padding: const EdgeInsets.only(right: 4.0, bottom: 4.0),
              child: Text(
                'You sent ${widget.demand.user?.name} an audio notification',
                maxLines: 2,
                overflow: TextOverflow.clip,
                style: const TextStyle(
                  fontSize: FontSize.M,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            decoration: BoxDecoration(
              color: widget.theme.primaryColor,
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CircleAvatar(
                  radius: 16.0,
                  backgroundColor: widget.theme.primaryColor,
                  backgroundImage: FastCachedImageProvider(
                    widget.supply.user?.avatar ??
                        AvatarService.getDemandAvatarUrl(),
                  ),
                ),
                ChatAudioMessage(
                  width: MediaQuery.of(context).size.width * 0.65 - 32.0,
                  audioUrl: widget.audioUrl,
                  groupId: widget.groupId,
                  time: widget.time,
                  sentByMe: widget.sentByMe,
                  isNotification: true,
                  theme: widget.theme,
                  peer: widget.demand,
                  documentId: "",
                  message: widget.message,
                ),
              ],
            ),
          ),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Visibility(
            visible: widget.isNotification,
            child: Padding(
              padding: const EdgeInsets.only(left: 4.0, bottom: 4.0),
              child: Text(
                '${widget.supply.user?.name ?? ''} sent you an audio notification',
                maxLines: 2,
                overflow: TextOverflow.clip,
                style: const TextStyle(
                  fontSize: FontSize.M,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CircleAvatar(
                  radius: 16.0,
                  backgroundColor: widget.theme.primaryColor,
                  backgroundImage: FastCachedImageProvider(
                    widget.supply.user?.avatar ??
                        AvatarService.getDemandAvatarUrl(),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * 0.65,
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            widget.supply.user?.name ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.clip,
                            style: const TextStyle(
                              fontSize: FontSize.M,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          GestureDetector(
                            onTap: () async {},
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 4.0,
                                horizontal: 12.0,
                              ),
                              decoration: BoxDecoration(
                                color: widget.theme.primaryColor,
                                borderRadius: BorderRadius.circular(6.0),
                              ),
                              child: const Text(
                                "Call Now",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: FontSize.M,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    ChatAudioMessage(
                      width: MediaQuery.of(context).size.width * 0.65 - 32.0,
                      audioUrl: widget.audioUrl,
                      time: widget.time,
                      groupId: widget.groupId,
                      sentByMe: widget.sentByMe,
                      isNotification: true,
                      theme: widget.theme,
                      peer: widget.demand,
                      documentId: "",
                      message: widget.message,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      );
    }
  }
}
