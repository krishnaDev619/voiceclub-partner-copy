import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/constants/url_constants.dart';
import 'package:voiceclub_partner/core/injection_container.dart';
import 'package:voiceclub_partner/core/services/alert_service.dart';
import 'package:voiceclub_partner/core/services/analytics_service.dart';
import 'package:voiceclub_partner/domain/usecases/social/create_post.dart';
import 'package:voiceclub_partner/modules/controller/call_controller.dart';
import 'package:voiceclub_partner/view/social/controllers/explore_controller.dart';
import 'package:voiceclub_partner/view/social/widgets/upload_story_audio_player.dart';
import 'package:voiceclub_partner/view/social/widgets/waveform_background.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';

class CreateAudioPostScreen extends StatefulWidget {
  const CreateAudioPostScreen({super.key});

  @override
  State<CreateAudioPostScreen> createState() => _CreateAudioPostScreenState();
}

class _CreateAudioPostScreenState extends State<CreateAudioPostScreen> {
  late Color _selectedColor;
  final List<Color> _availableColors = [
    const Color(0xFF7A4069),
    const Color(0xFF205072),
    const Color(0xFF145C52),
    const Color(0xFF2E1F27),
    const Color(0xFF00C4C8),
    const Color(0xFF3D2C8D),
  ];
  late final RecorderController recorderController;

  String? path;
  bool isRecording = false;
  bool isRecordingCompleted = false;
  Directory? appDirectory;
  ValueNotifier<int?> seconds = ValueNotifier<int?>(0);
  Timer? recordingTimer;
  bool _isUploading = false;
  Worker? _callListener;

  @override
  void initState() {
    _getDir();
    _initialiseControllers();
    _registerCallListener();
    _selectedColor =
        _availableColors[Random().nextInt(_availableColors.length)];
    sl<AnalyticsService>().trackEvent(
      "newPostInitiatePartner",
      eventProperties: {"postType": PostMediaType.AUDIO.name},
    );
    super.initState();
  }

  void _getDir() async {
    appDirectory = await getTemporaryDirectory();
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
    recorderController = RecorderController();
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

  void _startOrStopRecording() async {
    try {
      if (isRecording) {
        _stopRecording();
      } else {
        await recorderController.record(
          path: path,
          recorderSettings: RecorderSettings(
            androidEncoderSettings: AndroidEncoderSettings(
              androidEncoder: AndroidEncoder.aacLc,
            ),
            sampleRate: 44100,
            bitRate: 128000,
          ),
        );

        // Start the recordingTimer and set a callback to stop it at 60 seconds
        recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          if ((seconds.value ?? 0) >= 60) {
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

  void _uploadAudio() async {
    setState(() {
      _isUploading = true;
    });

    try {
      if (path == null) {
        throw Exception('No audio file available');
      }

      final audioFile = File(path!);
      if (!await audioFile.exists()) {
        throw Exception('Audio file not found');
      }

      final response = await sl<CreatePostUsecase>().call(
        CreatePostParams(
          postType: PostMediaType.AUDIO,
          textContent: "",
          mediaUrl: '',
          postColor:
              '#${_selectedColor.toARGB32().toRadixString(16).substring(2)}',
          fontStyle: 'default',
          attachment: audioFile,
          textOverlay: '',
        ),
      );
      if (response.error != null) {
        AlertService.showSnackBar(
          snackBarType: SnackBarType.Error,
          title: response.errorMessage,
          subtitle: response.errorDetail,
        );
      } else {
        Get.back(closeOverlays: true);
        Get.find<ExploreController>().showPostStatusWidget(
          response.data!.postId ?? '',
        );
        sl<AnalyticsService>().trackEvent(
          "newPostSuccessPartner",
          eventProperties: {
            "postId": response.data?.postId,
            "postType": PostMediaType.AUDIO.name,
          },
        );
      }
    } catch (e) {
      AlertService.showSnackBar(
        snackBarType: SnackBarType.Error,
        title: LocaleKeys.errorTitle.tr,
        subtitle: e.toString(),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  void dispose() {
    recorderController.dispose();
    _callListener?.dispose();
    super.dispose();
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    double waveformWidth = MediaQuery.of(context).size.width - 180.0;
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 72.0,
        backgroundColor: _selectedColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () {
            Get.back();
          },
        ),
        actions: [
          // Circular color buttons
          for (Color color in _availableColors)
            GestureDetector(
              onTap: () {
                setState(() {
                  _selectedColor = color;
                });
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 5),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color:
                        _selectedColor == color
                            ? Colors.white
                            : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: CircleAvatar(backgroundColor: color, radius: 13),
              ),
            ),
          const SizedBox(width: 8.0),
        ],
      ),
      body: Container(
        color: _selectedColor,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox.shrink(),
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 32.0),
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
                child:
                    isRecordingCompleted
                        ? UploadStoryAudioPlayer(
                          path: path!,
                          width: waveformWidth,
                          eventType: "storyRecord",
                        )
                        : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CircleAvatar(
                              backgroundColor: Get.theme.primaryColor,
                              backgroundImage: FastCachedImageProvider(
                                URLConstants.defaultPartnerAvatar,
                              ),
                              radius: 14.0,
                            ),
                            const SizedBox(width: 12.0),
                            Expanded(
                              child: Stack(
                                alignment: Alignment.centerLeft,
                                children: [
                                  WaveformBackground(width: waveformWidth),
                                  AudioWaveforms(
                                    enableGesture: true,
                                    size: Size(waveformWidth, 50),
                                    recorderController: recorderController,
                                    waveStyle: const WaveStyle(
                                      waveThickness: 4.0,
                                      scaleFactor: 20,
                                      waveColor: Color(0xFF787878),
                                      extendWaveform: true,
                                      showMiddleLine: false,
                                    ),
                                    decoration: const BoxDecoration(
                                      color: Colors.transparent,
                                    ),
                                    padding: const EdgeInsets.all(0.0),
                                    margin: const EdgeInsets.only(left: 3.0),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12.0),
                            SizedBox(
                              width: 32.0,
                              child: ValueListenableBuilder(
                                valueListenable: seconds,
                                builder: (context, seconds, _) {
                                  // Format the time as 0:00
                                  final formattedTime =
                                      '0:${(seconds ?? 0).toString().padLeft(2, '0')}';
                                  return Text(
                                    formattedTime,
                                    style: const TextStyle(fontSize: 12.0),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
              ),
              Column(
                children: [
                  isRecordingCompleted
                      ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32.0),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 6.0,
                                horizontal: 14.0,
                              ),
                              color: Colors.transparent,
                              child: const Text(
                                '',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  width: 80.0,
                                  child: Column(
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          _reupload();
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withValues(
                                                  alpha: 0.1,
                                                ),
                                                blurRadius: 20,
                                              ),
                                            ],
                                          ),
                                          child: const CircleAvatar(
                                            backgroundColor: Colors.white,
                                            radius: 32,
                                            child: Icon(
                                              Icons.mic,
                                              color: Colors.black,
                                              size: 32,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 12.0),
                                      const Text(
                                        'Re-upload',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  width: 80.0,
                                  child: Column(
                                    children: [
                                      GestureDetector(
                                        onTap: _uploadAudio,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withValues(
                                                  alpha: 0.1,
                                                ),
                                                blurRadius: 20,
                                              ),
                                            ],
                                          ),
                                          child: CircleAvatar(
                                            backgroundColor:
                                                Get.theme.primaryColor,
                                            radius: 32,
                                            child:
                                                _isUploading
                                                    ? const SizedBox(
                                                      height: 24.0,
                                                      width: 24.0,
                                                      child:
                                                          CircularProgressIndicator(
                                                            color: Colors.white,
                                                            strokeWidth: 3.0,
                                                          ),
                                                    )
                                                    : Padding(
                                                      padding:
                                                          const EdgeInsets.only(
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
                                      const SizedBox(height: 12.0),
                                      const Text(
                                        'Publish',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      )
                      : Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 6.0,
                              horizontal: 14.0,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  isRecording
                                      ? Colors.transparent
                                      : Colors.black.withValues(alpha: 0.35),
                              borderRadius: BorderRadius.circular(16.0),
                            ),
                            child: Text(
                              isRecording ? '' : 'Press & Hold to Speak',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.55,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Visibility(
                                    visible: false,
                                    child: GestureDetector(
                                      onTap: () async {},
                                      child: Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withValues(
                                                alpha: 0.1,
                                              ),
                                              blurRadius: 20,
                                            ),
                                          ],
                                        ),
                                        child: CircleAvatar(
                                          backgroundColor:
                                              Get.theme.primaryColor,
                                          radius: 24,
                                          child: const Icon(
                                            Icons.videocam_rounded,
                                            color: Colors.white,
                                            size: 24,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.center,
                                  child: GestureDetector(
                                    onLongPress: () {
                                      _startOrStopRecording(); // Start recording when user long presses
                                    },
                                    onLongPressEnd: (_) {
                                      _startOrStopRecording(); // Stop recording when user releases the button
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(
                                              alpha: 0.1,
                                            ),
                                            blurRadius: 20,
                                          ),
                                        ],
                                      ),
                                      child: CircleAvatar(
                                        backgroundColor: Get.theme.primaryColor,
                                        radius: 32,
                                        child: Icon(
                                          isRecording ? Icons.stop : Icons.mic,
                                          color: Colors.white,
                                          size: 32,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12.0),
                          const Text(''),
                        ],
                      ),
                  const SizedBox(height: 32.0),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
