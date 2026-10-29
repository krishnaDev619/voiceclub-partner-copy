import 'dart:async';
import 'dart:math';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/data/models/chat/chat_theme.dart';
import 'package:voiceclub_partner/data/models/chat/display_chat_message.dart';
import 'package:voiceclub_partner/data/models/chat/member.dart';
import 'package:voiceclub_partner/modules/controller/chat_messages_controller.dart';
import 'package:voiceclub_partner/view/chat/widgets/chat_timestamp_widget.dart';
import 'package:voiceclub_partner/view/chat/widgets/messages/popup_menu_container.dart';
import 'package:voiceclub_partner/view/chat/widgets/messages/replied_message_widget.dart';

class ChatAudioMessage extends StatefulWidget {
  final String audioUrl;
  final DateTime time;
  final double width, height;
  final bool sentByMe;
  final bool isNotification;
  final int groupId;
  final ChatMember peer;
  final ChatTheme theme;
  final String documentId;
  final DisplayChatMessage message;

  const ChatAudioMessage({
    super.key,
    required this.width,
    required this.audioUrl,
    required this.time,
    required this.sentByMe,
    required this.groupId,
    required this.theme,
    required this.peer,
    required this.documentId,
    required this.message,
    this.isNotification = false,
    this.height = 36,
  });

  @override
  State<ChatAudioMessage> createState() => _ChatAudioMessageState();
}

class _ChatAudioMessageState extends State<ChatAudioMessage> {
  late PlayerController controller;
  late StreamSubscription<PlayerState> playerStateSubscription;
  int? duration;
  bool isPlayerInitialized = false;
  late ChatMessagesController messagesController;

  final playerWaveStyle = const PlayerWaveStyle(
    fixedWaveColor: Colors.white54,
    liveWaveColor: Colors.white,
    spacing: 6,
  );

  @override
  void initState() {
    super.initState();
    controller = PlayerController();
    messagesController = Get.find<ChatMessagesController>(
      tag: widget.groupId.toString(),
    );
    playerStateSubscription = controller.onPlayerStateChanged.listen((state) {
      if (state.isInitialised && mounted) {
        controller.setFinishMode(finishMode: FinishMode.pause);
        isPlayerInitialized = true;
      }
      setState(() {});
    });
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  List<double> generateWaveformData({
    int length = 100, // Length of the waveform data
    double amplitude = 0.2, // Amplitude of the waveform
  }) {
    Random random = Random();
    List<double> waveformData = [];

    for (int i = 0; i < length; i++) {
      // Generate random amplitude values between 0.3 and 0.7
      double value =
          random.nextDouble() *
          0.4; // Scaling to fit -amplitude to amplitude range

      waveformData.add((value / 5));
    }

    return waveformData;
  }

  Future<void> _preparePlayer() async {
    final audioFile = await DefaultCacheManager().getSingleFile(
      widget.audioUrl,
    );
    await controller
        .preparePlayer(
          path: audioFile.path,
          shouldExtractWaveform: true,
          noOfSamples: playerWaveStyle.getSamplesForWidth(widget.width),
        )
        .then((_) async {
          duration = (await controller.getDuration()) ~/ 1000;
          setState(() {});
        });
    if (Get.isRegistered<ChatMessagesController>(
      tag: widget.groupId.toString(),
    )) {
      Get.find<ChatMessagesController>(
            tag: widget.groupId.toString(),
          ).playerControllersMap[controller.playerKey] =
          controller;
    }
  }

  @override
  void dispose() {
    playerStateSubscription.cancel();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuContainer(
      reaction: widget.message.reaction,
      onDelete: () {
        messagesController.onDeleteSelected(
          message: widget.message,
          peerData: widget.peer,
        );
      },
      onReactionSelected: (reaction) {
        messagesController.onReactionSelected(
          message: widget.message,
          reaction: reaction,
          peerData: widget.peer,
        );
      },
      onReply: () {
        messagesController.onReplySelected(message: widget.message);
      },
      sentByMe: widget.sentByMe,
      message: widget.message,
      enabled: !widget.sentByMe,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.65,
        decoration: BoxDecoration(
          color: const Color(0xFFFFEDE0),
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: IntrinsicWidth(
          child: Container(
            decoration:
                widget.message.replyMessage != null
                    ? BoxDecoration(
                      color: widget.theme.primaryColor,
                      borderRadius: BorderRadius.circular(12.0),
                    )
                    : null,
            padding:
                widget.message.replyMessage != null
                    ? const EdgeInsets.all(6.0)
                    : null,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RepliedMessageWidget(
                  replyMessage: widget.message.replyMessage,
                  theme: widget.theme,
                  chatGroupId: widget.groupId,
                  peerName: widget.peer.user?.name ?? '',
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.65,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 4.0,
                  ),
                  decoration: BoxDecoration(
                    color:
                        widget.isNotification
                            ? (widget.sentByMe
                                ? const Color(
                                  0xFFFF8787,
                                ).withValues(alpha: 0.75)
                                : const Color(0xFFF7F7F7))
                            : (widget.sentByMe
                                ? widget.theme.primaryColor
                                : Colors.white),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () async {
                              if (!isPlayerInitialized) {
                                await _preparePlayer();
                              }
                              if (Get.isRegistered<ChatMessagesController>(
                                tag: widget.groupId.toString(),
                              )) {
                                messagesController.stopAndStartPlayer(
                                  playerKey: controller.playerKey,
                                  screenName: "ChatScreen",
                                );
                              }
                            },
                            child: Icon(
                              controller.playerState.isPlaying
                                  ? Icons.pause
                                  : Icons.play_arrow,
                              color:
                                  widget.sentByMe
                                      ? Colors.white
                                      : widget.theme.primaryColor,
                            ),
                          ),
                          const SizedBox(width: 8.0),
                          Expanded(
                            child:
                                isPlayerInitialized
                                    ? AudioFileWaveforms(
                                      key: Key("${widget.audioUrl}Main"),
                                      padding: const EdgeInsets.all(0.0),
                                      margin: const EdgeInsets.only(left: 3.0),
                                      enableSeekGesture: false,
                                      playerController: controller,
                                      size: Size(widget.width, widget.height),
                                      waveformType: WaveformType.fitWidth,
                                      playerWaveStyle: PlayerWaveStyle(
                                        spacing: 5.0,
                                        scaleFactor: 120.0,
                                        waveThickness: 2.0,
                                        liveWaveColor:
                                            widget.sentByMe
                                                ? Colors.white
                                                : const Color(0xFF787878),
                                        fixedWaveColor:
                                            widget.sentByMe
                                                ? Colors.white54
                                                : const Color(0xFFD9D9D9),
                                      ),
                                      decoration: const BoxDecoration(
                                        color: Colors.transparent,
                                      ),
                                    )
                                    : AudioFileWaveforms(
                                      key: Key("${widget.audioUrl}Duplicate"),
                                      padding: const EdgeInsets.all(0.0),
                                      margin: const EdgeInsets.only(left: 3.0),
                                      enableSeekGesture: false,
                                      playerController: PlayerController(),
                                      waveformData: generateWaveformData(),
                                      size: Size(widget.width, widget.height),
                                      waveformType: WaveformType.fitWidth,
                                      playerWaveStyle: PlayerWaveStyle(
                                        spacing: 5.0,
                                        scaleFactor: 120.0,
                                        waveThickness: 2.0,
                                        liveWaveColor:
                                            widget.sentByMe
                                                ? Colors.white
                                                : const Color(0xFF787878),
                                        fixedWaveColor:
                                            widget.sentByMe
                                                ? Colors.white54
                                                : const Color(0xFFD9D9D9),
                                      ),
                                      decoration: const BoxDecoration(
                                        color: Colors.transparent,
                                      ),
                                    ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Builder(
                            builder: (context) {
                              // Format the time as 0:00
                              final formattedTime =
                                  '0:${(duration ?? 0).toString().padLeft(2, '0')}';
                              return Padding(
                                padding: const EdgeInsets.only(
                                  left: 4.0,
                                  bottom: 1.0,
                                ),
                                child: Text(
                                  formattedTime,
                                  style: TextStyle(
                                    fontSize: FontSize.M,
                                    color:
                                        isPlayerInitialized
                                            ? (widget.sentByMe
                                                ? Colors.white
                                                : Colors.black)
                                            : widget.theme.primaryColor,
                                  ),
                                ),
                              );
                            },
                          ),
                          ChatTimestampWidget(
                            key: UniqueKey(),
                            timestamp: widget.time,
                            sentByMe: widget.sentByMe,
                            chatGroupId: widget.groupId,
                            messageId: widget.documentId,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
