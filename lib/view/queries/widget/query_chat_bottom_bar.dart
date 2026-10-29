import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:vibration/vibration.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/core/injection_container.dart';
import 'package:voiceclub_partner/core/services/alert_service.dart';
import 'package:voiceclub_partner/core/services/logger.dart';
import 'package:voiceclub_partner/modules/controller/call_controller.dart';
import 'package:voiceclub_partner/view/queries/controller/queries_controller.dart';
import 'package:voiceclub_partner/view/story/upload_story_audio_player.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';

class QueryChatBottomBar extends StatefulWidget {
  const QueryChatBottomBar({super.key});

  @override
  State<QueryChatBottomBar> createState() => _QueryChatBottomBarState();
}

class _QueryChatBottomBarState extends State<QueryChatBottomBar>
    with TickerProviderStateMixin {
  final queriesController = Get.find<QueriesController>();
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
  final int _recordingSeconds = 60;
  AnimationController? _animationController;
  String inputMessage = "";
  final textFieldFocusNode = FocusNode();
  Worker? _callListener;

  @override
  initState() {
    super.initState();
    _getDir();
    _initialiseControllers();
    _registerCallListener();
    _messageController.addListener(() {
      setState(() {
        _hasText = _messageController.text.isNotEmpty;
      });
    });
  }

  Future<void> _getDir() async {
    final dir = await getApplicationDocumentsDirectory();
    if (!mounted) return;
    appDirectory = dir;
    path = "${dir.path}/recording.m4a";
  }

  void _resetAudioRecorder() {
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
        _resetAudioRecorder();
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

      _animationController?.forward();

      Vibration.vibrate(duration: 100);

      setState(() => isRecording = true);

      await recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.wav,
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

  void _sendText() {
    if (_hasText) {
      final message = _messageController.text.trim();
      if (message.isNotEmpty) {
        queriesController.sendMessage(
          content: message,
          messageType: QueryMessageType.TEXT,
        );
        _messageController.clear();
      }
    }
  }

  void _sendImage(File imageFile) {
    queriesController.sendMessage(
      messageType: QueryMessageType.IMAGE,
      attachment: imageFile,
    );
  }

  Future<void> _sendAudio() async {
    if (path.isNotEmpty == true) {
      queriesController.sendMessage(
        messageType: QueryMessageType.AUDIO,
        attachment: File(path),
      );
      _resetAudioRecorder();
    }
  }

  Future<void> _sendVideo(File videoFile) async {
    try {
      queriesController.sendMessage(
        messageType: QueryMessageType.VIDEO,
        attachment: videoFile,
      );
    } catch (e) {
      Logger.logMessage(
        "Error while sending video: ${e.toString()}",
        name: "QueryChatBottomBar",
      );
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
    return Obx(() {
      if (queriesController.currentSessionDetails.value?.mediaAllowed == true) {
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
                            _resetAudioRecorder();
                          },
                          child: const Padding(
                            padding: EdgeInsets.only(left: 4.0, right: 8.0),
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
                              borderRadius: BorderRadius.circular(24.0),
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
                            onTap: _sendAudio,
                            child: Container(
                              margin: const EdgeInsets.only(left: 8.0),
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
                                backgroundColor: Color(0xFF1EAB61),
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
                                          padding: const EdgeInsets.only(
                                            left: 4.0,
                                          ),
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
                                    if (isRecording || isRecordingCompleted)
                                      Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
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
                                    else
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          GestureDetector(
                                            onTap: () async {
                                              final xFile = await picker
                                                  .pickImage(
                                                    source: ImageSource.gallery,
                                                  );
                                              if (xFile != null) {
                                                final file = File(xFile.path);
                                                _sendImage(file);
                                              }
                                            },
                                            child: Container(
                                              width: 40.0,
                                              height: 40.0,
                                              padding: const EdgeInsets.all(
                                                8.0,
                                              ),
                                              child: const Icon(
                                                Icons.image,
                                                color: Color(0xFF1EAB61),
                                                size: 24.0,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 4.0),
                                          GestureDetector(
                                            onTap: () async {
                                              final xFile = await picker
                                                  .pickVideo(
                                                    source: ImageSource.gallery,
                                                  );
                                              if (xFile != null) {
                                                final file = File(xFile.path);
                                                _sendVideo(file);
                                              }
                                            },
                                            child: Container(
                                              width: 40.0,
                                              height: 40.0,
                                              padding: const EdgeInsets.all(
                                                8.0,
                                              ),
                                              child: const Icon(
                                                Icons.videocam,
                                                color: Color(0xFF1EAB61),
                                                size: 24.0,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8.0),
                                          Expanded(
                                            child: TextField(
                                              controller: _messageController,
                                              focusNode: textFieldFocusNode,
                                              minLines: 1,
                                              textCapitalization:
                                                  TextCapitalization.sentences,
                                              maxLines: 5,
                                              onChanged: (value) {
                                                setState(() {
                                                  inputMessage = value;
                                                });
                                              },
                                              decoration: InputDecoration(
                                                hintText:
                                                    !isRecording
                                                        ? LocaleKeys
                                                            .liveMessage
                                                            .tr
                                                        : "",
                                                isCollapsed: true,
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
                                  onTap: _sendText,
                                  child: Container(
                                    width: 44.0,
                                    height: 44.0,
                                    padding: const EdgeInsets.only(left: 3.0),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Color(0xFF1EAB61),
                                    ),
                                    child: Transform.rotate(
                                      angle: 5.5,
                                      child: const Icon(
                                        Icons.send_rounded,
                                        color: ApplicationColors.white,
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
                                          color: Color(0xFF1EAB61),
                                        ),
                                        child: const Icon(
                                          Icons.mic_rounded,
                                          color: ApplicationColors.white,
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
                                              color: Color(0xFF1EAB61),
                                            ),
                                            child: const Icon(
                                              Icons.mic,
                                              color: ApplicationColors.white,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                          ],
                        ),
                      ),
                    ],
                  ),
        );
      }

      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 8.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 12.0,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 18.0,
                        horizontal: 16.0,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _messageController,
                                  focusNode: textFieldFocusNode,
                                  minLines: 1,
                                  textCapitalization:
                                      TextCapitalization.sentences,
                                  maxLines: 5,
                                  onChanged: (value) {
                                    setState(() {
                                      inputMessage = value;
                                    });
                                  },
                                  decoration: InputDecoration(
                                    hintText:
                                        !isRecording
                                            ? LocaleKeys.liveMessage.tr
                                            : "",
                                    isCollapsed: true,
                                    focusedBorder: const OutlineInputBorder(
                                      borderSide: BorderSide.none,
                                    ),
                                    border: const OutlineInputBorder(
                                      borderSide: BorderSide.none,
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
                  GestureDetector(
                    onTap: _sendText,
                    child: Container(
                      width: 44.0,
                      height: 44.0,
                      padding: const EdgeInsets.only(left: 3.0),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF1EAB61),
                      ),
                      child: Transform.rotate(
                        angle: 5.5,
                        child: const Icon(
                          Icons.send_rounded,
                          color: ApplicationColors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}
