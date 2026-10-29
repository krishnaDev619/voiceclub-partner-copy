import 'dart:ui';

import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/data/models/chat/display_chat_message.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';

class ReactionScreen extends StatefulWidget {
  final DisplayChatMessage message;
  final VoidCallback? onDelete;
  final VoidCallback? onReport;
  final VoidCallback? onCopy;
  final VoidCallback? onReply;
  final Function(String)? onReactionSelected;
  final bool sentByMe;
  final String? reaction;

  const ReactionScreen({
    super.key,
    required this.message,
    required this.sentByMe,
    this.onDelete,
    this.onReport,
    this.onCopy,
    this.onReply,
    this.onReactionSelected,
    this.reaction,
  });

  @override
  State<ReactionScreen> createState() => _ReactionScreenState();
}

class _ReactionScreenState extends State<ReactionScreen> {
  List<Widget> menuList = [];
  List<String> emojis = [
    "😀",
    "😃",
    "😄",
    "😁",
    "😆",
    "😅",
    "😂",
    "🤣",
    "😊",
    "😇",
    "🙂",
    "🙃",
    "😉",
    "😌",
    "😍",
    "🥰",
    "😘",
    "😗",
    "😙",
    "😚",
    "😋",
    "😛",
    "😜",
    "🤪",
    "😝",
    "🤑",
    "🤗",
    "🤭",
    "🤫",
    "🤔",
    "🤐",
    "🤨",
    "😐",
    "😑",
    "😶",
    "😏",
    "😒",
    "🙄",
    "😬",
    "🤥",
    "😌",
    "😔",
    "😪",
    "🤤",
    "😴",
    "😷",
    "🤒",
    "🤕",
    "🤢",
    "🤮",
    "🤧",
    "😵",
    "🤯",
    "🤠",
    "🥳",
    "🥺",
    "😳",
    "😨",
    "😰",
    "😥",
    "😢",
    "😭",
    "😱",
    "😖",
    "😣",
    "😞",
    "😓",
    "😩",
    "😫",
    "🥱",
    "😤",
    "😡",
    "😠",
    "🤬",
    "😈",
    "👿",
    "💀",
    "☠️",
    "💩",
    "🤡",
    "👹",
    "👺",
    "👻",
    "👽",
    "👾",
    "🤖",
    "🎃",
    "😺",
    "😸",
    "😹",
    "😻",
    "😼",
    "😽",
    "🙀",
    "😿",
    "😾",
    "👶",
    "👧",
    "🧒",
    "👦",
    "👩",
    "🧑",
    "👨",
    "👩‍🦱",
    "👨‍🦱",
    "👩‍🦰",
    "👨‍🦰",
    "👱‍",
    "👱‍",
    "👩‍🦳",
    "👨‍🦳",
    "👩‍🦲",
    "👨‍🦲",
    "🧔",
    "👵",
    "🧓",
    "👴",
    "👲",
    "👳‍",
    "👳‍",
    "🧕",
    "👮‍",
    "👮‍",
    "👷‍",
    "👷‍",
    "💂‍",
    "💂‍",
    "🕵️‍♀️",
    "🕵️‍♂️",
    "👩‍",
    "👨‍",
    "👩‍🌾",
    "👨‍🌾",
    "👩‍🍳",
    "👨‍🍳",
    "👩‍🎓",
    "👨‍🎓",
    "👩‍🎤",
    "👨‍🎤",
    "👩‍🏫",
    "👨‍🏫",
    "👩‍🏭",
    "👨‍🏭",
    "👩‍💻",
    "👨‍💻",
    "👩‍💼",
    "👨‍💼",
    "👩‍🔧",
    "👨‍🔧",
    "👩‍🔬",
    "👨‍🔬",
    "👩‍🎨",
    "👨‍🎨",
    "👩‍🚒",
    "👨‍🚒",
    "👩‍",
    "👨‍",
    "👩‍🚀",
    "👨‍🚀",
    "👩‍",
    "👨‍",
    "🦸‍",
    "🦸‍",
    "🦹‍",
    "🦹‍",
    "🤶",
    "🎅",
    "🧙‍",
    "🧙‍",
    "🧝‍",
    "🧝‍",
    "🧛‍",
    "🧛‍",
    "🧟‍",
    "🧟‍",
    "🧞‍",
    "🧞‍",
    "🧜‍",
    "🧜‍",
    "🧚‍",
    "🧚‍",
    "👼",
    "🤰",
    "🤱",
    "🙇‍",
    "🙇‍",
    "💁‍",
    "💁‍",
    "🙅‍",
    "🙅‍",
    "🙆‍",
    "🙆‍",
    "🙋‍",
    "🙋‍",
    "🤦‍",
    "🤦‍",
    "🤷‍",
    "🤷‍",
    "💋‍",
    "️‍❤️‍",
    "👩‍",
    "👩‍",
    "👨‍",
    "💑",
    "👩‍",
    "👩‍",
    "👨‍",
    "💏",
    "👪",
    "👨‍👩‍👦",
    "👨‍👩‍👧",
    "👨‍👩‍👧‍👦",
    "👨‍👩‍👦‍👦",
    "👨‍👩‍👧‍👧",
    "👨‍👨‍👦",
    "👨‍👨‍👧",
    "👨‍👨‍👧‍👦",
    "👨‍👨‍👦‍👦",
    "👨‍👨‍👧‍👧",
    "👩‍👩‍👦",
    "👩‍👩‍👧",
    "👩‍👩‍👧‍👦",
    "👩‍👩‍👦‍👦",
    "👩‍👩‍👧‍👧",
    "👨‍👦",
    "👨‍👦‍👦",
    "👨‍👧",
    "👨‍👧‍👦",
    "👨‍👧‍👧",
    "👩‍👦",
    "👩‍👦‍👦",
    "👩‍👧",
    "👩‍👧‍👦",
    "👩‍👧‍👧",
    "🗣",
    "👤",
    "👥",
    "🧥",
    "👚",
    "👕",
    "👖",
    "🩳",
    "👔",
    "👗",
    "👙",
    "🩱",
    "👘",
    "🥻",
    "🩲",
    "🥿",
    "👠",
    "👡",
    "👢",
    "👞",
    "👟",
    "🥾",
    "🩴",
    "🧦",
    "🧤",
    "🧣",
    "🎩",
    "🧢",
    "👒",
    "🎓",
    "⛑",
    "💄",
    "💍",
    "💼",
    "🩺",
    "🌂",
    "💪",
    "👂",
    "🦻",
    "👃",
    "🧠",
    "🦷",
    "🦴",
    "👀",
    "👁",
    "👅",
    "👄",
    "🗣",
    "👤",
    "👥",
    "🧖‍",
    "🧖‍",
    "🧗‍",
    "🧗‍",
    "🏇",
    "🏂",
    "🏌️‍♀️",
    "🏌️‍♂️",
    "🏄‍",
    "🏄‍",
    "🚣‍",
    "🚣‍",
    "🏊‍",
    "🏊‍",
    "🤽‍",
    "🤽‍",
    "🚴‍",
    "🚴‍",
    "🚵‍",
    "🚵‍",
    "🤹‍",
    "🤹‍",
    "🧘‍",
    "🧘‍",
    "🎪",
    "🎭",
    "🎨",
    "🎰",
    "🎮",
    "🎲",
    "🎳",
    "🎯",
    "🎱",
    "🏹",
    "🛷",
    "🥌",
    "🎿",
    "🏂",
    "⛷",
    "🏋️‍♀️",
    "🏋️‍♂️",
    "🤼‍",
    "🤼‍",
    "🤸‍",
    "🤸‍",
    "🤾‍",
    "🤾‍",
    "🤺",
  ];
  List<String> commonEmojis = ["❤️", "😂", "👍", "🔥", "😢", "👏"];

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {
        menuList = getWidgetList();
        _checkAndFilterEmojis();
      });
    });
    super.initState();
  }

  void _checkAndFilterEmojis() {
    if (widget.reaction?.isNotEmpty ?? false) {
      final contains = commonEmojis.contains(widget.reaction);
      if (!contains) {
        commonEmojis.insert(0, widget.reaction ?? "");
      }
    }
    setState(() {});
  }

  List<Widget> getWidgetList() {
    List<Widget> list = [];
    if (widget.onCopy != null) {
      list.add(
        _popupMenuItem(
          context: context,
          text: LocaleKeys.liveCopy.tr,
          icon: Icons.copy_rounded,
          onTap: widget.onCopy,
        ),
      );
    }
    if (widget.onReply != null) {
      list.add(
        _popupMenuItem(
          context: context,
          text: LocaleKeys.liveReply.tr,
          icon: Icons.reply,
          onTap: widget.onReply,
        ),
      );
    }
    if (widget.onReport != null) {
      list.add(
        _popupMenuItem(
          context: context,
          text: LocaleKeys.liveReport.tr,
          icon: Icons.warning_amber_rounded,
          onTap: widget.onReport,
        ),
      );
    }
    if (widget.onDelete != null) {
      list.add(
        _popupMenuItem(
          context: context,
          text: LocaleKeys.liveDelete.tr,
          icon: Icons.delete_outline_rounded,
          onTap: widget.onDelete,
          isDelete: true,
        ),
      );
    }
    return list;
  }

  Widget get getContentWidget {
    Widget wid = const SizedBox();
    if (widget.message.type == ChatType.ChatTypeText) {
      wid = Text(
        widget.message.content ?? '',
        style: const TextStyle(fontSize: 16),
      );
    } else if (widget.message.type == ChatType.ChatTypeSticker ||
        widget.message.type == ChatType.ChatTypeGift) {
      wid = SizedBox(
        height: 80.0,
        child: FastCachedImage(url: widget.message.attachmentUrl ?? ''),
      );
    } else if (widget.message.type == ChatType.ChatTypeAudio ||
        widget.message.type == ChatType.ChatTypeCall) {
      wid = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.mic_rounded, color: Colors.grey, size: 20.0),
          SizedBox(width: 4.0),
          Text(LocaleKeys.liveAudioMessage.tr, style: TextStyle(fontSize: 16)),
        ],
      );
    }
    return wid;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // Blurred Background
          Positioned.fill(
            child: InkWell(
              onTap: () {
                Get.back();
              }, // Dismiss on tap outside
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                child: Container(
                  color: Colors.black.withValues(
                    alpha: 0.2,
                  ), // Semi-transparent overlay
                ),
              ),
            ),
          ),

          // Reaction & Popup UI
          Positioned(
            left: 20.0,
            top: Get.height * 0.4,
            right: 20.0,
            child: Align(
              alignment:
                  widget.sentByMe
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Reaction Options
                  Visibility(
                    visible: widget.onReactionSelected != null,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(color: Colors.black26, blurRadius: 10),
                        ],
                      ),
                      child: SizedBox(
                        height: 40.0,
                        child: ListView(
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          children: [
                            for (var emoji in commonEmojis)
                              _reactionIcon(emoji),
                            InkWell(
                              onTap: () {
                                _showEmojiBottomSheet(context);
                              },
                              child: CircleAvatar(
                                backgroundColor: Colors.grey[200],
                                child: const Icon(
                                  Icons.add,
                                  size: 24,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Message Bubble
                  Material(
                    color: Colors.transparent,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: getContentWidget,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Popup Menu Items
                  Container(
                    width: Get.width * 0.3,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 6.0,
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      itemCount: menuList.length,
                      separatorBuilder: (context, index) {
                        return const Divider(height: 5.0, thickness: 1.0);
                      },
                      itemBuilder: (context, index) {
                        final widget = menuList[index];
                        return widget;
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper function to display reactions
  Widget _reactionIcon(String emoji) {
    return InkWell(
      onTap: () {
        String emo = emoji;
        if (widget.reaction == emoji) {
          emo = "";
        }
        Get.back(result: emo);
        widget.onReactionSelected?.call(emo);
      },
      child: Container(
        decoration:
            widget.reaction == emoji
                ? BoxDecoration(shape: BoxShape.circle, color: Colors.grey[300])
                : null,
        padding: const EdgeInsets.all(8),
        child: Text(emoji, style: const TextStyle(fontSize: FontSize.xXXL)),
      ),
    );
  }

  // Helper function to display popup menu items
  Widget _popupMenuItem({
    required BuildContext context,
    required String text,
    required IconData icon,
    VoidCallback? onTap,
    bool isDelete = false,
  }) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: InkWell(
        onTap: () {
          Get.back(); // Dismiss the popup
          onTap?.call();
        },
        child: SizedBox(
          width: Get.width * 0.3,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: FontSize.L,
                    color: isDelete ? Colors.red : Colors.black,
                    fontFamily: GoogleFonts.mulish().fontFamily,
                  ),
                ),
              ),
              Icon(icon, color: isDelete ? Colors.red : Colors.black),
            ],
          ),
        ),
      ),
    );
  }

  // Method to show the bottom sheet with the list of emojis
  void _showEmojiBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 6,
              crossAxisSpacing: 4.0,
              mainAxisSpacing: 4.0,
            ),
            itemCount: emojis.length,
            itemBuilder: (BuildContext context, int index) {
              return InkWell(
                onTap: () {
                  Get.back(); // Dismiss the bottom sheet
                  Get.back(result: emojis[index]); // Return the selected emoji
                  widget.onReactionSelected?.call(emojis[index]);
                },
                child: Center(
                  child: Text(
                    emojis[index],
                    style: const TextStyle(fontSize: FontSize.xXXL),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
