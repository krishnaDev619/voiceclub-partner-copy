import 'dart:async';
import 'dart:io';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:vibration/vibration.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/core/services/alert_service.dart';
import 'package:voiceclub_partner/modules/controller/broadcast_controller.dart';
import 'package:voiceclub_partner/view/story/upload_story_audio_player.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';

const max = 280;
const min = 10;

class BroadcastActionBottomBar extends StatefulWidget {
  const BroadcastActionBottomBar({super.key});

  @override
  State<BroadcastActionBottomBar> createState() =>
      _BroadcastActionBottomBarState();
}

class _BroadcastActionBottomBarState extends State<BroadcastActionBottomBar>
    with TickerProviderStateMixin {
  final _messageController = TextEditingController();
  late final RecorderController recorderController;
  String? path;
  bool isRecording = false;
  bool isRecordingCompleted = false;
  Directory? appDirectory;
  ValueNotifier<int?> seconds = ValueNotifier<int?>(0);
  Timer? recordingTimer;
  final bool _isUploading = false;
  bool _hasText = false;
  final _recordingSeconds = 60;
  AnimationController? _animationController;
  String inputMessage = "";
  final textFieldFocusNode = FocusNode();

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
    super.initState();
  }

  void _getDir() async {
    appDirectory = await getApplicationDocumentsDirectory();
    path = "${appDirectory?.path}/recording.m4a";
    setState(() {});
  }

  void _reupload() {
    setState(() {
      path = null;
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
    recorderController = RecorderController();
  }

  void _startOrStopRecording() async {
    try {
      if (isRecording) {
        _stopRecording();
      } else {
        _animationController?.forward();
        Vibration.vibrate(duration: 100);
        await recorderController.record(
          recorderSettings: RecorderSettings(
            androidEncoderSettings: AndroidEncoderSettings(
              androidEncoder: AndroidEncoder.aacLc,
            ),
            sampleRate: 44100,
            bitRate: 128000,
          ),
        );

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
    try {
      if (isRecording) {
        _animationController?.reverse();
        recorderController.reset();
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
    } catch (_) {}
  }

  void sendTextMessage() {
    if (_hasText) {
      final message = _messageController.text.trim();
      if (message.isNotEmpty) {
        if (message.length < min) {
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
          Get.find<BroadcastController>().handleBroadcastMessage(
            message: message,
            messageType: ChatType.ChatTypeText,
            attachment: null,
          );
        }
      }
    }
  }

  void sendAudio() {
    if (path?.isNotEmpty ?? false) {
      Get.find<BroadcastController>().handleBroadcastMessage(
        messageType: ChatType.ChatTypeAudio,
        attachment: File(path!),
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
    _animationController?.dispose();
    _messageController.dispose();
    recorderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double waveformWidth = MediaQuery.of(context).size.width - 240.0;
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 8.0,
        left: 8.0,
        right: 8.0,
      ),
      child:
          isRecordingCompleted
              ? Row(
                children: [
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: 8.0,
                        horizontal: 12.0,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20.0),
                        border: Border.all(
                          color: Colors.grey.shade300,
                          width: 1.0,
                        ),
                      ),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              _reupload();
                            },
                            child: const Padding(
                              padding: EdgeInsets.only(left: 4.0, right: 8.0),
                              child: Icon(
                                Icons.close,
                                size: 20.0,
                                color: ApplicationColors.grey,
                              ),
                            ),
                          ),
                          Expanded(
                            child: UploadStoryAudioPlayer(
                              path: path!,
                              width: waveformWidth,
                              eventType: "chatRecordedAudio",
                              height: 36.0,
                            ),
                          ),
                        ],
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
                          radius: 30,
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
                                        size: 30,
                                      ),
                                    ),
                                  ),
                        ),
                      ),
                    ),
                  ),
                ],
              )
              : Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
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
                              border: Border.all(
                                color: Colors.grey.shade300,
                                width: 1.0,
                              ),
                            ),
                            child:
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
                                    : TextField(
                                      controller: _messageController,
                                      focusNode: textFieldFocusNode,
                                      minLines: 1,
                                      maxLines: 5,
                                      onTap: () {},
                                      onChanged: (value) {
                                        setState(() {
                                          inputMessage = value;
                                        });
                                      },
                                      decoration: InputDecoration(
                                        hintText: !isRecording ? 'Message' : "",
                                        isCollapsed: true,
                                        // contentPadding: const EdgeInsets.all(0),
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
                        ),
                      ],
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
                                Get
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
                        onLongPress: () {
                          _startOrStopRecording(); // Start recording when user long presses
                        },
                        onLongPressEnd: (_) {
                          _startOrStopRecording(); // Stop recording when user releases the button
                        },
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 48.0,
                              height: 48.0,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color:
                                    Get
                                        .theme
                                        .primaryColor, // Set your desired button color
                              ),
                              child: const Icon(Icons.mic, color: Colors.white),
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
                                        Get
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
    );
  }
}
