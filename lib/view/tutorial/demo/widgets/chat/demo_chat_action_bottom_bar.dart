import 'dart:async';
import 'dart:io';

import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart' as fonts;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:vibration/vibration.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/core/injection_container.dart';
import 'package:voiceclub_partner/core/services/alert_service.dart';
import 'package:voiceclub_partner/core/services/growthbook_service.dart';
import 'package:voiceclub_partner/core/services/logger.dart';
import 'package:voiceclub_partner/data/models/chat/gift_data.dart';
import 'package:voiceclub_partner/data/models/chat/growthbook_stickers_response.dart';
import 'package:voiceclub_partner/data/models/chat/member.dart';
import 'package:voiceclub_partner/view/chat/widgets/chat_action_bottom_bar.dart';
import 'package:voiceclub_partner/view/chat/widgets/custom_emoji_keyboard.dart';
import 'package:voiceclub_partner/view/story/upload_story_audio_player.dart';
import 'package:voiceclub_partner/view/tutorial/demo/bottom_sheets/demo_chat_sticker_bottom_sheet.dart';
import 'package:voiceclub_partner/view/tutorial/demo/controllers/demo_landing_controller.dart';
import 'package:voiceclub_partner/view/tutorial/demo/widgets/core/disabled_widget.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';

class DemoChatActionBottomBar extends StatefulWidget {
  final ChatMember peer;

  const DemoChatActionBottomBar({super.key, required this.peer});

  @override
  State<DemoChatActionBottomBar> createState() =>
      _DemoChatActionBottomBarState();
}

class _DemoChatActionBottomBarState extends State<DemoChatActionBottomBar>
    with TickerProviderStateMixin {
  final controller = Get.find<DemoLandingController>();
  final _messageController = TextEditingController();
  final AudioRecorder recorder = AudioRecorder();
  late String path;
  bool isRecording = false;
  bool isRecordingCompleted = false;
  Directory? appDirectory;
  ValueNotifier<int?> seconds = ValueNotifier<int?>(0);
  Timer? recordingTimer;
  final bool _isUploading = false;
  bool _hasText = false;
  final int _recordingSeconds = 60;
  AnimationController? _animationController;
  String inputMessage = "";
  final textFieldFocusNode = FocusNode();
  bool _emojiShowing = false;
  GrowthbookStickersResponseModel? stickers;

  @override
  void initState() {
    _getDir();
    _initialiseControllers();
    _messageController.addListener(() {
      if (_messageController.text.isEmpty) {
        setState(() {
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

  Future<void> _startRecording() async {
    if (isRecording) return;

    try {
      final hasPermission = await Permission.microphone.isGranted;
      if (!hasPermission) {
        await recorder.hasPermission();
        return;
      }

      seconds.value = 0;
      recordingTimer?.cancel();

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
    } catch (e) {
      Logger.logMessage(
        "Start recording failed: $e",
        name: "DemoChatActionBottomBar",
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

      if (!mounted) return;

      if (recordedPath != null && (seconds.value ?? 0) >= 5) {
        path = recordedPath;
        isRecordingCompleted = true;
      } else {
        AlertService.showSnackBar(
          snackBarType: SnackBarType.Warning,
          title: LocaleKeys.demoAlert.tr,
          subtitle: LocaleKeys.demoMinRecording.tr,
        );
        _cleanupRecordingState();
        return;
      }
    } catch (e) {
      Logger.logMessage(
        "Stop recording failed: $e",
        name: "DemoChatActionBottomBar",
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

  void sendTextMessage() {
    if (_hasText) {
      final message = _messageController.text.trim();
      if (message.isNotEmpty) {
        if (message.length < min) {
          AlertService.showSnackBar(
            snackBarType: SnackBarType.Warning,
            title: LocaleKeys.demoAlert.tr,
            subtitle: LocaleKeys.demoMinMessageLength.trParams({'min': '$min'}),
          );
        } else if (message.length > max) {
          AlertService.showSnackBar(
            snackBarType: SnackBarType.Warning,
            title: LocaleKeys.demoAlert.tr,
            subtitle: LocaleKeys.demoMaxMessageLength.trParams({'max': '$max'}),
          );
        } else {
          controller.sendMessage(message);
          _messageController.clear();
        }
      }
    }
  }

  void sendAudio() {
    if (path.isNotEmpty) {
      controller.sendMessage(
        LocaleKeys.demoAudioRecordingSent.tr,
        chatType: ChatType.ChatTypeAudio,
      );
      controller.pendingAudios.clear();
      controller.validateAction(TutorialDemoFeature.CHAT_NEW_USER);
      _reupload();
    }
  }

  void openStickerBottomSheet() {
    if (stickers != null) {
      if (widget.peer.user?.id != null) {
        Get.bottomSheet(
          DemoChatStickerBottomSheet(
            demandName: widget.peer.user?.name ?? '',
            demandUid: widget.peer.user?.id ?? 0,
            stickers: stickers!,
            onSendGift: sendSticker,
          ),
          isScrollControlled: true,
        );
      }
    }
  }

  void sendSticker(GiftData giftData) async {
    controller.validateAction(TutorialDemoFeature.CHAT_STICKERS);
    if (giftData.stickerUrl?.isNotEmpty ?? false) {
      controller.sendMessage(
        "",
        chatType: ChatType.ChatTypeSticker,
        attachmentUrl: giftData.stickerUrl ?? "",
      );
    }
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void dispose() {
    recordingTimer?.cancel();
    recorder.dispose();
    _animationController?.dispose();
    _messageController.dispose();
    textFieldFocusNode.dispose();
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
                          eventType: "chatRecordedAudioDemo",
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
                            backgroundColor: Get.theme.primaryColor,
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
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                isRecording || isRecordingCompleted
                                    ? Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          margin: const EdgeInsets.symmetric(
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
                                                  .addPostFrameCallback((_) {
                                                    textFieldFocusNode
                                                        .requestFocus();
                                                  });
                                            } else {
                                              WidgetsBinding.instance
                                                  .addPostFrameCallback((_) {
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
                                              : Icons.emoji_emotions_outlined,
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
                                    },
                                    onChanged: (value) {
                                      setState(() {
                                        inputMessage = value;
                                      });
                                    },
                                    decoration: InputDecoration(
                                      hintText:
                                          !isRecording
                                              ? LocaleKeys.demoMessageHint.tr
                                              : "",
                                      isCollapsed: true,
                                      focusedBorder: const OutlineInputBorder(
                                        borderSide: BorderSide.none,
                                      ),
                                      border: const OutlineInputBorder(
                                        borderSide: BorderSide.none,
                                      ),
                                      counterText:
                                          (inputMessage.length < min &&
                                                  inputMessage.isNotEmpty)
                                              ? "${inputMessage.length.toString()}/$min"
                                              : "",
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8.0),
                                Disabled(
                                  disabled: controller.currentStage.isLessThan(
                                    TutorialStage.S4,
                                  ),
                                  child: Visibility(
                                    visible: !_hasText && stickers != null,
                                    replacement: const SizedBox(height: 24.0),
                                    child: SizedBox(
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          GestureDetector(
                                            onTap: openStickerBottomSheet,
                                            child: Transform.rotate(
                                              angle:
                                                  -45 * (3.14159265359 / 180),
                                              child: const Icon(
                                                Icons.attach_file,
                                                color:
                                                    ApplicationColors.iconGrey,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
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
                                  color: Get.theme.primaryColor,
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
                                      color: Get.theme.primaryColor,
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
                                          color: Get.theme.primaryColor,
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
                            indicatorColor: Get.theme.primaryColor,
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
