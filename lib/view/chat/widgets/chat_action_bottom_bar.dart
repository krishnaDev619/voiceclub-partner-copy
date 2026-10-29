import 'dart:async';
import 'dart:io';

import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart' as fonts;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pinput/pinput.dart';
import 'package:record/record.dart';
import 'package:vibration/vibration.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/core/injection_container.dart';
import 'package:voiceclub_partner/core/services/alert_service.dart';
import 'package:voiceclub_partner/core/services/analytics_service.dart';
import 'package:voiceclub_partner/core/services/growthbook_service.dart';
import 'package:voiceclub_partner/core/services/logger.dart';
import 'package:voiceclub_partner/data/models/chat/chat_group.dart';
import 'package:voiceclub_partner/data/models/chat/chat_theme.dart';
import 'package:voiceclub_partner/data/models/chat/gift_data.dart';
import 'package:voiceclub_partner/data/models/chat/growthbook_stickers_response.dart';
import 'package:voiceclub_partner/data/models/chat/member.dart';
import 'package:voiceclub_partner/data/models/config/feature.dart';
import 'package:voiceclub_partner/modules/controller/call_controller.dart';
import 'package:voiceclub_partner/modules/controller/chat_messages_controller.dart';
import 'package:voiceclub_partner/modules/controller/user_controller.dart';
import 'package:voiceclub_partner/view/chat/widgets/bottom_sheet/chat_sticker_bottom_sheet.dart';
import 'package:voiceclub_partner/view/chat/widgets/custom_emoji_keyboard.dart';
import 'package:voiceclub_partner/view/chat/widgets/reply_message_widget.dart';
import 'package:voiceclub_partner/view/story/upload_story_audio_player.dart';
import 'package:voiceclub_partner/view/tutorial/demo/widgets/core/disabled_widget.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';

const max = 280;
const min = 10;

class ChatActionBottomBar extends StatefulWidget {
  final ChatGroup chatGroup;
  final CategoryCode code;
  final Map<String, dynamic> eventProperties;
  final int accountId;
  final bool isSessionOngoing;
  final List<Feature> features;
  final ChatTheme theme;

  const ChatActionBottomBar({
    super.key,
    required this.chatGroup,
    required this.code,
    required this.eventProperties,
    required this.accountId,
    this.isSessionOngoing = false,
    this.features = const [],
    required this.theme,
  });

  @override
  State<ChatActionBottomBar> createState() => _ChatActionBottomBarState();
}

class _ChatActionBottomBarState extends State<ChatActionBottomBar>
    with TickerProviderStateMixin {
  late ChatMessagesController _chatMessagesController;
  final _messageController = TextEditingController();
  final AudioRecorder recorder = AudioRecorder();
  final picker = ImagePicker();
  late String path;
  bool isRecording = false;
  bool isRecordingCompleted = false;
  Directory? appDirectory;
  ValueNotifier<int?> seconds = ValueNotifier<int?>(0);
  Timer? recordingTimer;
  final bool _isUploading = false;
  bool _hasText = false;
  int _recordingSeconds = 60;
  ChatMember? peer;
  AnimationController? _animationController;
  bool pretext = false;
  String inputMessage = "";
  final textFieldFocusNode = FocusNode();
  bool _emojiShowing = false;
  GrowthbookStickersResponseModel? stickers;
  Worker? _callListener;

  @override
  void initState() {
    _getDir();
    _chatMessagesController = Get.find<ChatMessagesController>(
      tag: widget.chatGroup.id.toString(),
    );
    peer =
        widget.chatGroup.members?.firstWhereOrNull(
          (member) => member.accountId != widget.accountId,
        ) ??
        ChatMember();
    _getRecordingSeconds();
    _initialiseControllers();
    _registerCallListener();
    _messageController.addListener(() {
      if (_messageController.text.isEmpty) {
        setState(() {
          pretext = false;
          _hasText = false;
        });
      } else {
        if (!_hasText) {
          setState(() {
            _hasText = true;
          });
        }
      }
    });
    stickers = sl<GrowthBookService>().getGrowthbookStickers();
    super.initState();
  }

  Map<String, dynamic> getEventProperties({required ChatType chatType}) {
    final properties = widget.eventProperties;
    properties['chatType'] = chatType.name;
    if (chatType == ChatType.ChatTypeAudio) {
      properties['audioDurationInSeconds'] = seconds.value;
    }
    return properties;
  }

  void _getRecordingSeconds() {
    try {
      _recordingSeconds = 60;
    } catch (_) {}
  }

  Future<void> _getDir() async {
    final dir = await getApplicationDocumentsDirectory();
    if (!mounted) return;
    appDirectory = dir;
    path = "${dir.path}/recording.m4a";
  }

  void _reupload() {
    setState(() {
      seconds.value = null;
      isRecording = false;
      isRecordingCompleted = false;
    });
  }

  void _initialiseControllers() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
  }

  void _registerCallListener() {
    _callListener = ever(sl<CallController>().incomingCallPayload, (
      callPayload,
    ) {
      if (callPayload.isNotEmpty && isRecording) {
        _stopRecording();
      }
    });
  }

  Future<void> _startRecording() async {
    Logger.logMessage(
      "Starting recording with isRecording: $isRecording, name: ChatActionBottomBar",
    );
    if (isRecording) return;

    try {
      final hasPermission = await Permission.microphone.isGranted;
      if (!hasPermission) {
        await recorder.hasPermission();
        return;
      }

      seconds.value = 0;
      recordingTimer?.cancel();

      _chatMessagesController.pauseAllPlayers();
      _animationController?.forward();

      Vibration.vibrate(duration: 100);

      setState(() => isRecording = true);

      await recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          sampleRate: 44100,
          autoGain: true,
          bitRate: 128000,
        ),
        path: path,
      );

      recordingTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        final current = seconds.value ?? 0;
        if (current >= _recordingSeconds) {
          _stopRecording();
        } else {
          seconds.value = current + 1;
        }
      });

      sl<AnalyticsService>().trackEvent(
        'chatInitiatePartner',
        eventProperties: getEventProperties(chatType: ChatType.ChatTypeAudio),
      );
    } catch (e) {
      Logger.logMessage(
        "Start recording failed: $e",
        name: "ChatActionBottomBar",
        isCritical: true,
      );
      _cleanupRecordingState();
    }
  }

  Future<void> _stopRecording() async {
    if (!isRecording) return;

    try {
      recordingTimer?.cancel();
      recordingTimer = null;

      _animationController?.reverse();

      final recordedPath = await recorder.stop();

      Logger.logMessage(
        "Recorded path: $recordedPath",
        name: "ChatActionBottomBar",
      );

      if (!mounted) return;

      if (recordedPath != null && (seconds.value ?? 0) >= 5) {
        path = recordedPath;
        isRecordingCompleted = true;
      } else {
        AlertService.showSnackBar(
          snackBarType: SnackBarType.Warning,
          title: LocaleKeys.liveAlert.tr,
          subtitle: LocaleKeys.liveMinimumRecordingDurationShouldBe.tr,
        );
        _cleanupRecordingState();
        return;
      }
    } catch (e) {
      Logger.logMessage(
        "Stop recording failed: $e",
        name: "ChatActionBottomBar",
        isCritical: true,
      );
      _cleanupRecordingState();
    } finally {
      setState(() => isRecording = false);
    }
  }

  void _cleanupRecordingState() {
    recordingTimer?.cancel();
    recordingTimer = null;

    recorder.cancel();

    seconds.value = 0;
    isRecording = false;
    isRecordingCompleted = false;

    if (mounted) setState(() {});
  }

  bool containsEightOrMoreDigits(String input) {
    RegExp digitRegex = RegExp(r'\d');

    // Find all digit matches in the input string
    Iterable<RegExpMatch> matches = digitRegex.allMatches(input);

    // Count the number of digit matches
    int digitCount = matches.length;

    // Check if the count is eight or more
    return digitCount >= 8;
  }

  bool textInputCheck(String input) {
    // Check for 8 or more digits
    if (containsEightOrMoreDigits(input)) {
      Vibration.vibrate();
      sl<AnalyticsService>().trackEvent(
        "chatFailPartner",
        eventProperties: {
          "reason": "phoneNumber",
          "content": input,
          ...getEventProperties(chatType: ChatType.ChatTypeText),
        },
      );
      AlertService.showSnackBar(
        title: LocaleKeys.liveWarning.tr,
        subtitle: LocaleKeys.livePleaseDoNotSharePhone.tr,
        snackBarType: SnackBarType.Error,
      );
      return false;
    }

    // No 8 or more digits or vulgar words found
    return true;
  }

  void sendTextMessage() {
    if (_hasText) {
      final message = _messageController.text.trim();
      if (message.isNotEmpty) {
        if (message.length < min && widget.code == CategoryCode.GOSSIP) {
          AlertService.showSnackBar(
            snackBarType: SnackBarType.Warning,
            title: LocaleKeys.liveAlert.tr,
            subtitle: LocaleKeys.liveMinMessageLength.trParams({'min': '$min'}),
          );
        } else if (message.length > max) {
          AlertService.showSnackBar(
            snackBarType: SnackBarType.Warning,
            title: LocaleKeys.liveAlert.tr,
            subtitle: LocaleKeys.liveMaxMessageLength.trParams({'max': '$max'}),
          );
        } else {
          if (textInputCheck(message)) {
            _chatMessagesController.sendMessage(
              peer: peer ?? ChatMember(),
              isSessionOngoing: widget.isSessionOngoing,
              tier: widget.chatGroup.tier ?? ChatTier.PRO,
              chatType: ChatType.ChatTypeText,
              eventProperties: getEventProperties(
                chatType: ChatType.ChatTypeText,
              ),
              code: widget.code,
              content: message,
              pretext: pretext,
            );
            _messageController.clear();
          }
        }
      }
    }
  }

  void sendAudio() {
    if (path.isNotEmpty == true) {
      _chatMessagesController.sendMessage(
        peer: peer ?? ChatMember(),
        chatType: ChatType.ChatTypeAudio,
        tier: widget.chatGroup.tier ?? ChatTier.PRO,
        eventProperties: getEventProperties(chatType: ChatType.ChatTypeAudio),
        code: widget.code,
        isSessionOngoing: widget.isSessionOngoing,
        attachment: File(path),
      );
      _reupload();
    }
  }

  void sendImage({ImageSource imageSource = ImageSource.camera}) async {
    final XFile? photo = await picker.pickImage(source: imageSource);
    if (photo?.path.isNotEmpty ?? false) {
      _chatMessagesController.sendMessage(
        peer: peer ?? ChatMember(),
        isSessionOngoing: widget.isSessionOngoing,
        chatType: ChatType.ChatTypeImage,
        tier: widget.chatGroup.tier ?? ChatTier.PRO,
        eventProperties: getEventProperties(chatType: ChatType.ChatTypeImage),
        code: widget.code,
        attachment: File(photo!.path),
      );
    }
  }

  void sendSticker(GiftData giftData) async {
    if (giftData.stickerUrl?.isNotEmpty ?? false) {
      _chatMessagesController.sendMessage(
        peer: peer ?? ChatMember(),
        isSessionOngoing: widget.isSessionOngoing,
        chatType: ChatType.ChatTypeSticker,
        tier: widget.chatGroup.tier ?? ChatTier.PRO,
        eventProperties: getEventProperties(chatType: ChatType.ChatTypeSticker),
        code: widget.code,
        attachmentUrl: giftData.stickerUrl ?? "",
      );
    }
  }

  void openStickerBottomSheet() {
    if (stickers != null) {
      final peer = widget.chatGroup.members?.firstWhere(
        (member) => member.accountId != widget.accountId,
      );
      if (peer?.user?.id != null) {
        Get.bottomSheet(
          ChatStickerBottomSheet(
            demandName: peer?.user?.name ?? '',
            demandUid: peer?.user?.id ?? 0,
            theme: widget.theme,
            stickers: stickers!,
            onSendGift: sendSticker,
          ),
          isScrollControlled: true,
        );
      }
    }
  }

  void setPretext(String text) {
    if (text.isNotEmpty) {
      _messageController.setText(text.trim());
      setState(() {
        pretext = true;
      });
    }
  }

  @override
  void dispose() {
    recordingTimer?.cancel();
    recorder.dispose();
    _animationController?.dispose();
    _messageController.dispose();
    _callListener?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double waveformWidth = MediaQuery.of(context).size.width - 240.0;
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 8.0,
      ),
      child:
          isRecordingCompleted
              ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        _reupload();
                      },
                      child: const Padding(
                        padding: EdgeInsets.only(left: 4.0, right: 12.0),
                        child: Icon(
                          Icons.close,
                          size: 28.0,
                          color: ApplicationColors.grey,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 10.0,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 20,
                            ),
                          ],
                        ),
                        child: UploadStoryAudioPlayer(
                          path: path,
                          width: waveformWidth,
                          eventType: "chatRecordedAudio",
                          height: 36.0,
                        ),
                      ),
                    ),
                    Transform.translate(
                      offset: const Offset(-12.0, 0.0),
                      child: GestureDetector(
                        onTap: () async {
                          sendAudio();
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 20,
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            backgroundColor: widget.theme.primaryColor,
                            radius: 32,
                            child:
                                _isUploading
                                    ? const SizedBox(
                                      height: 24.0,
                                      width: 24.0,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 3.0,
                                      ),
                                    )
                                    : Padding(
                                      padding: const EdgeInsets.only(left: 4.0),
                                      child: Transform.rotate(
                                        angle: 5.5,
                                        child: const Icon(
                                          Icons.send_rounded,
                                          color: Colors.white,
                                          size: 32,
                                        ),
                                      ),
                                    ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
              : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 12.0,
                              horizontal: 12.0,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            child: Column(
                              children: [
                                ReplyMessageWidget(
                                  key: UniqueKey(),
                                  theme: widget.theme,
                                  chatGroupId: widget.chatGroup.id ?? 0,
                                  peerName: peer?.user?.name ?? "",
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    isRecording || isRecordingCompleted
                                        ? Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Container(
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 12.0,
                                                    vertical: 8.0,
                                                  ),
                                              height: 8.0,
                                              width: 8.0,
                                              decoration: const BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.red,
                                              ),
                                            ),
                                            ValueListenableBuilder(
                                              valueListenable: seconds,
                                              builder: (context, seconds, _) {
                                                // Format the time as 0:00
                                                final formattedTime =
                                                    '0:${(seconds ?? 0).toString().padLeft(2, '0')}';
                                                return Text(
                                                  formattedTime,
                                                  style: const TextStyle(
                                                    fontSize: 14.0,
                                                    color: Colors.black,
                                                  ),
                                                );
                                              },
                                            ),
                                          ],
                                        )
                                        : Padding(
                                          padding: const EdgeInsets.only(
                                            right: 8.0,
                                          ),
                                          child: GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                _emojiShowing = !_emojiShowing;
                                                if (!_emojiShowing) {
                                                  WidgetsBinding.instance
                                                      .addPostFrameCallback((
                                                        _,
                                                      ) {
                                                        textFieldFocusNode
                                                            .requestFocus();
                                                      });
                                                } else {
                                                  WidgetsBinding.instance
                                                      .addPostFrameCallback((
                                                        _,
                                                      ) {
                                                        SystemChannels.textInput
                                                            .invokeMethod(
                                                              'TextInput.hide',
                                                            );
                                                      });
                                                }
                                              });
                                            },
                                            child: Icon(
                                              _emojiShowing
                                                  ? Icons.keyboard
                                                  : Icons
                                                      .emoji_emotions_outlined,
                                              color: ApplicationColors.iconGrey,
                                            ),
                                          ),
                                        ),
                                    Expanded(
                                      child: TextField(
                                        controller: _messageController,
                                        focusNode: textFieldFocusNode,
                                        minLines: 1,
                                        maxLines: 5,
                                        onTap: () {
                                          setState(() {
                                            _emojiShowing = false;
                                          });
                                          sl<AnalyticsService>().trackEvent(
                                            'chatInitiatePartner',
                                            eventProperties: getEventProperties(
                                              chatType: ChatType.ChatTypeText,
                                            ),
                                          );
                                        },
                                        onChanged: (value) {
                                          setState(() {
                                            inputMessage = value;
                                          });
                                        },
                                        decoration:
                                            widget.code == CategoryCode.GOSSIP
                                                ? InputDecoration(
                                                  hintText:
                                                      !isRecording
                                                          ? 'Message'
                                                          : "",
                                                  isCollapsed: true,
                                                  // contentPadding: const EdgeInsets.all(0),
                                                  focusedBorder:
                                                      const OutlineInputBorder(
                                                        borderSide:
                                                            BorderSide.none,
                                                      ),
                                                  border:
                                                      const OutlineInputBorder(
                                                        borderSide:
                                                            BorderSide.none,
                                                      ),
                                                  counterText:
                                                      (inputMessage.length <
                                                                  min &&
                                                              inputMessage
                                                                  .isNotEmpty)
                                                          ? "${inputMessage.length.toString()}/$min"
                                                          : "",
                                                )
                                                : InputDecoration.collapsed(
                                                  hintText:
                                                      LocaleKeys.liveMessage.tr,
                                                ),
                                      ),
                                    ),
                                    const SizedBox(width: 8.0),
                                    Disabled(
                                      disabled: Get.find<UserController>()
                                          .currentStage
                                          .isLessThan(TutorialStage.S4),
                                      child: Visibility(
                                        visible: !_hasText,
                                        replacement: const SizedBox(
                                          height: 24.0,
                                        ),
                                        child: PopupMenuButton(
                                          offset: Offset(0.0, -64.0),
                                          position: PopupMenuPosition.over,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8.0,
                                            ),
                                          ),
                                          padding: const EdgeInsets.only(
                                            left: 8.0,
                                            right: 8.0,
                                          ),
                                          elevation: 4.0,
                                          onSelected: (value) async {
                                            if (value == "stickers") {
                                              openStickerBottomSheet();
                                            }
                                          },
                                          itemBuilder: (_) {
                                            return [
                                              if (stickers != null)
                                                PopupMenuItem(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 8.0,
                                                        vertical: 6.0,
                                                      ),
                                                  height: 24.0,
                                                  textStyle: const TextStyle(
                                                    fontSize: FontSize.L,
                                                  ),
                                                  value: 'stickers',
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      const Icon(
                                                        Icons
                                                            .emoji_emotions_outlined,
                                                      ),
                                                      const SizedBox(
                                                        width: 8.0,
                                                      ),
                                                      Expanded(
                                                        child: Text(
                                                          "Stickers",
                                                          maxLines: 1,
                                                          overflow:
                                                              TextOverflow
                                                                  .ellipsis,
                                                          style: TextStyle(
                                                            fontSize:
                                                                FontSize.L,
                                                            color: Colors.black,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontFamily:
                                                                fonts.GoogleFonts.mulish()
                                                                    .fontFamily,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                            ];
                                          },
                                          child: Transform.rotate(
                                            angle: -45 * (3.14159265359 / 180),
                                            child: const Icon(
                                              Icons.attach_file,
                                              color: ApplicationColors.iconGrey,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        _hasText
                            ? GestureDetector(
                              onTap: () {
                                sendTextMessage();
                              },
                              child: Container(
                                width: 48.0,
                                height: 48.0,
                                padding: const EdgeInsets.only(left: 3.0),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color:
                                      widget
                                          .theme
                                          .primaryColor, // Set your desired button color
                                ),
                                child: Transform.rotate(
                                  angle: 5.5,
                                  child: const Icon(
                                    Icons.send_rounded,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            )
                            : GestureDetector(
                              onLongPressStart: (_) => _startRecording(),
                              onLongPressEnd: (_) => _stopRecording(),
                              onLongPressCancel: () => _stopRecording(),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Container(
                                    width: 48.0,
                                    height: 48.0,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color:
                                          widget
                                              .theme
                                              .primaryColor, // Set your desired button color
                                    ),
                                    child: const Icon(
                                      Icons.mic,
                                      color: Colors.white,
                                    ),
                                  ),
                                  if (isRecording)
                                    ScaleTransition(
                                      scale: Tween<double>(
                                        begin: 1.0,
                                        end: 3.0,
                                      ).animate(
                                        CurvedAnimation(
                                          parent: _animationController!,
                                          curve: Curves.easeInOut,
                                        ),
                                      ),
                                      child: Container(
                                        width: 48.0,
                                        height: 48.0,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color:
                                              widget
                                                  .theme
                                                  .primaryColor, // Set your desired button color
                                        ),
                                        child: const Icon(
                                          Icons.mic,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                      ],
                    ),
                  ),
                  Offstage(
                    offstage: !_emojiShowing,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: EmojiPicker(
                        textEditingController: _messageController,
                        onEmojiSelected: (_, _) {
                          setState(() {
                            inputMessage = _messageController.text;
                          });
                        },
                        config: Config(
                          height: 256,
                          checkPlatformCompatibility: true,
                          emojiTextStyle: DefaultEmojiTextStyle.copyWith(
                            fontFamily:
                                fonts.GoogleFonts.notoColorEmoji().fontFamily,
                            fontSize: 24.0,
                          ),
                          emojiViewConfig: const EmojiViewConfig(
                            backgroundColor: Colors.white,
                          ),
                          skinToneConfig: const SkinToneConfig(),
                          categoryViewConfig: CategoryViewConfig(
                            backgroundColor: Colors.white,
                            dividerColor: Colors.white,
                            indicatorColor: widget.theme.primaryColor,
                            iconColorSelected: Colors.black,
                            iconColor: ApplicationColors.iconGrey,
                            customCategoryView: (
                              config,
                              state,
                              tabController,
                              pageController,
                            ) {
                              return CustomEmojiKeyboard(
                                config,
                                state,
                                tabController,
                                pageController,
                              );
                            },
                            categoryIcons: const CategoryIcons(
                              recentIcon: Icons.access_time_outlined,
                              smileyIcon: Icons.emoji_emotions_outlined,
                              animalIcon: Icons.cruelty_free_outlined,
                              foodIcon: Icons.coffee_outlined,
                              activityIcon: Icons.sports_soccer_outlined,
                              travelIcon: Icons.directions_car_filled_outlined,
                              objectIcon: Icons.lightbulb_outline,
                              symbolIcon: Icons.emoji_symbols_outlined,
                              flagIcon: Icons.flag_outlined,
                            ),
                          ),
                          bottomActionBarConfig: const BottomActionBarConfig(
                            backgroundColor: Colors.white,
                            buttonColor: Colors.white,
                            buttonIconColor: ApplicationColors.iconGrey,
                          ),
                          searchViewConfig: SearchViewConfig(
                            backgroundColor: Colors.white,
                            customSearchView: (config, state, showEmojiView) {
                              return EmojiSearchView(
                                config,
                                state,
                                showEmojiView,
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
    );
  }
}
