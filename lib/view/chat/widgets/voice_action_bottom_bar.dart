import 'dart:async';
import 'dart:io';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/core/injection_container.dart';
import 'package:voiceclub_partner/core/services/alert_service.dart';
import 'package:voiceclub_partner/core/services/analytics_service.dart';
import 'package:voiceclub_partner/data/models/chat/chat_group.dart';
import 'package:voiceclub_partner/data/models/chat/member.dart';
import 'package:voiceclub_partner/modules/controller/chat_messages_controller.dart';
import 'package:voiceclub_partner/view/story/upload_story_audio_player.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';

class VoiceActionBottomBar extends StatefulWidget {
  final ChatGroup chatGroup;
  final CategoryCode code;
  final Map<String, dynamic> eventProperties;
  final int accountId;

  const VoiceActionBottomBar({
    super.key,
    required this.chatGroup,
    required this.code,
    required this.eventProperties,
    required this.accountId,
  });

  @override
  State<VoiceActionBottomBar> createState() => _VoiceActionBottomBarState();
}

class _VoiceActionBottomBarState extends State<VoiceActionBottomBar>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late final RecorderController recorderController;
  late ChatMessagesController _chatMessagesController;
  final picker = ImagePicker();

  double _progress = 0.0;
  String? path;
  bool isRecording = false;
  bool isRecordingCompleted = false;
  Directory? appDirectory;
  ValueNotifier<int?> seconds = ValueNotifier<int?>(0);
  Timer? recordingTimer;
  final int _recordingSeconds = 60;
  ChatMember? peer;

  @override
  void initState() {
    _chatMessagesController = Get.find<ChatMessagesController>(
      tag: widget.chatGroup.id.toString(),
    );
    peer =
        widget.chatGroup.members?.firstWhereOrNull(
          (member) => member.accountId != widget.accountId,
        ) ??
        ChatMember();
    _getDir();
    _initialiseControllers();
    super.initState();
  }

  void trackInitMessage({required ChatType chatType}) {
    sl<AnalyticsService>().trackEvent(
      'chatInitiatePartner',
      eventProperties: getEventProperties(chatType: chatType),
    );
  }

  Map<String, dynamic> getEventProperties({required ChatType chatType}) {
    final properties = widget.eventProperties;
    properties['chatType'] = chatType.name;
    return properties;
  }

  void _getDir() async {
    appDirectory = await getApplicationDocumentsDirectory();
    path = "${appDirectory?.path}/recording.m4a";
    setState(() {});
  }

  void _reupload() {
    _controller.reset();
    setState(() {
      path = null;
      seconds.value = null;
      isRecording = false;
      isRecordingCompleted = false;
    });
  }

  void _initialiseControllers() {
    recorderController = RecorderController();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(
        seconds: _recordingSeconds,
      ), // Set the maximum recording time
    )..addListener(() {
      setState(() {
        _progress = _controller.value;
      });
    });
  }

  void _startOrStopRecording() async {
    try {
      if (isRecording) {
        _stopRecording();
      } else {
        await recorderController.record(
          recorderSettings: RecorderSettings(
            androidEncoderSettings: AndroidEncoderSettings(
              androidEncoder: AndroidEncoder.aacLc,
            ),
            sampleRate: 44100,
            bitRate: 128000,
          ),
        );
        _controller.forward();

        // Start the recordingTimer and set a callback to stop it at $recordingSeconds
        recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          if ((seconds.value ?? 0) >= _recordingSeconds) {
            recordingTimer?.cancel(); // Stop the timer
            _stopRecording(); // Stop the recording
          } else {
            seconds.value = (seconds.value ?? 0) + 1;
          }
        });
      }
    } catch (_) {
    } finally {
      setState(() {
        isRecording = !isRecording;
      });
    }
  }

  void _stopRecording() async {
    if (isRecording) {
      recorderController.reset();
      _controller.reset();
      path = await recorderController.stop(false);

      if (path != null && (seconds.value ?? 0) >= 5) {
        isRecordingCompleted = true;
      } else if (path != null) {
        _reupload();
        AlertService.showSnackBar(
          snackBarType: SnackBarType.Warning,
          title: LocaleKeys.liveAlert.tr,
          subtitle: LocaleKeys.liveMinimumRecordingDurationShouldBe.tr,
        );
      }
    }

    setState(() {
      isRecording = false;
    });

    // Cancel the recording timer if it's active
    recordingTimer?.cancel();
  }

  void sendAudio() {
    if (path?.isNotEmpty ?? false) {
      _chatMessagesController.sendMessage(
        peer: peer ?? ChatMember(),
        isSessionOngoing: false,
        chatType: ChatType.ChatTypeAudio,
        tier: widget.chatGroup.tier ?? ChatTier.PRO,
        eventProperties: getEventProperties(chatType: ChatType.ChatTypeAudio),
        code: widget.code,
        attachment: File(path!),
      );
      _reupload();
    }
  }

  void sendImage() async {
    final XFile? photo = await picker.pickImage(source: ImageSource.camera);
    if (photo?.path.isNotEmpty ?? false) {
      _chatMessagesController.sendMessage(
        peer: peer ?? ChatMember(),
        isSessionOngoing: false,
        chatType: ChatType.ChatTypeImage,
        tier: widget.chatGroup.tier ?? ChatTier.PRO,
        eventProperties: getEventProperties(chatType: ChatType.ChatTypeImage),
        code: widget.code,
        attachment: File(photo!.path),
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
    recorderController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double waveformWidth = MediaQuery.of(context).size.width - 240.0;
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Stack(
          alignment: Alignment.center,
          children: [
            isRecordingCompleted
                ? Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        _reupload();
                      },
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12.0),
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
                          path: path!,
                          width: waveformWidth,
                          height: 36.0,
                          eventType: "chatRecordedAudio",
                        ),
                      ),
                    ),
                    Transform.translate(
                      offset: const Offset(-16.0, 0.0),
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
                            child: Padding(
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
                )
                : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    isRecording
                        ? ValueListenableBuilder(
                          valueListenable: seconds,
                          builder: (context, seconds, _) {
                            // Format the time as 0:00
                            final formattedTime =
                                '0:${(seconds ?? 0).toString().padLeft(2, '0')}';
                            return Text(
                              formattedTime,
                              style: const TextStyle(
                                fontSize: 12.0,
                                color: Colors.black,
                              ),
                            );
                          },
                        )
                        : Text(
                          'Press & Hold',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                          ),
                        ),
                    const SizedBox(height: 8.0),
                    GestureDetector(
                      onLongPress: () {
                        _startOrStopRecording(); // Start recording when user long presses
                      },
                      onLongPressEnd: (_) {
                        _startOrStopRecording(); // Stop recording when user releases the button
                      },
                      child: SizedBox(
                        width: 72.0, // Set the desired button size
                        height: 72.0,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 72.0,
                              height: 72.0,
                              child: CircularProgressIndicator(
                                value: _progress,
                                strokeWidth:
                                    4.0, // Set the width of the progress ring
                                backgroundColor:
                                    Colors.transparent, // Background color
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Theme.of(
                                    context,
                                  ).primaryColor.withValues(alpha: 0.75),
                                ), // Progress color
                              ),
                            ),
                            Container(
                              width: 68.0, // Set the desired button size
                              height: 68.0,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Get.theme.primaryColor,
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(
                                      0x1A000000,
                                    ), // Shadow color with opacity
                                    blurRadius: 20.0, // Spread radius
                                    offset: Offset(0, 0), // Shadow offset
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.mic,
                                color: Colors.white,
                                size: 28.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
            // Visibility(
            //   visible: (widget.code.name == CategoryCode.ASTRO.name),
            //   child: (isRecording || isRecordingCompleted)
            //       ? const SizedBox.shrink()
            //       : Positioned(
            //           left: 96.0,
            //           bottom: 16.0,
            //           child: GestureDetector(
            //             onTap: () {
            //               sendImage();
            //             },
            //             child: Container(
            //                 width: 42.0, // Set the desired button size
            //                 height: 42.0,
            //                 decoration: const BoxDecoration(
            //                   shape: BoxShape.circle,
            //                   color: Colors.white,
            //                   boxShadow: [
            //                     BoxShadow(
            //                       color: Color(
            //                           0x1A000000), // Shadow color with opacity
            //                       blurRadius: 20.0, // Spread radius
            //                       offset: Offset(0, 0), // Shadow offset
            //                     ),
            //                   ],
            //                 ),
            //                 child: const Icon(
            //                   Icons.camera_alt_rounded,
            //                   color: ApplicationColors.iconGrey,
            //                   size: 24.0,
            //                 )),
            //           ),
            //         ),
            // ),
          ],
        ),
      ),
    );
  }
}
