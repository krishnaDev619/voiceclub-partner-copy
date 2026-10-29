import 'dart:async';
import 'dart:io';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/core/constants/url_constants.dart';
import 'package:voiceclub_partner/core/injection_container.dart';
import 'package:voiceclub_partner/core/services/alert_service.dart';
import 'package:voiceclub_partner/core/services/analytics_service.dart';
import 'package:voiceclub_partner/core/services/intro_audio_policy_service.dart';
import 'package:voiceclub_partner/core/services/clean_voice_service.dart';
import 'package:voiceclub_partner/domain/usecases/file/upload_file.dart';
import 'package:voiceclub_partner/modules/controller/user_controller.dart';
import 'package:voiceclub_partner/modules/controller/voice_controller.dart';
import 'package:voiceclub_partner/view/profile/widgets/recording_audio_player.dart';
import 'package:voiceclub_partner/view/profile/widgets/sample_audio_player.dart';
import 'package:voiceclub_partner/view/profile/widgets/upload_audio_bottom_sheet/upload_audio_bottom_sheet_controller.dart';
import 'package:voiceclub_partner/view/story/upload_story_audio_player.dart';
import 'package:voiceclub_partner/view/story/waveform_background.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';

class UploadAudioBottomSheet extends StatefulWidget {
  final String title;
  final String subtitle;
  final Future<bool> Function(String path) uploadFunction;
  final RecordingAudioStatus? status;
  final String? recordingUrl;
  final String sampleAudioUrl;
  final String type;
  final String? language;
  final String? pendingAudioUrl;
  final String languageType;
  final String? reason;

  const UploadAudioBottomSheet({
    required super.key,
    required this.title,
    required this.subtitle,
    required this.uploadFunction,
    required this.status,
    required this.recordingUrl,
    required this.type,
    required this.language,
    required this.languageType,
    required this.sampleAudioUrl,
    this.pendingAudioUrl,
    this.reason,
  });

  @override
  State<UploadAudioBottomSheet> createState() => _UploadAudioBottomSheetState();
}

class _UploadAudioBottomSheetState extends State<UploadAudioBottomSheet> {
  late final RecorderController recorderController;

  String? path;
  bool isRecording = false;
  bool isRecordingCompleted = false;
  Directory? appDirectory;
  ValueNotifier<int?> seconds = ValueNotifier<int?>(0);
  Timer? recordingTimer;
  bool _isUploading = false;
  String eventType = '';

  @override
  void initState() {
    Get.put(UploadAudioBottomSheetController());
    eventType = widget.type;
    _getDir();
    _initialiseControllers();
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
    recorderController = RecorderController();
  }

  void _startOrStopRecording() async {
    if (widget.status != RecordingAudioStatus.Pending) {
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

          // Start the recordingTimer and set a callback to stop it at 30 seconds
          recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
            if ((seconds.value ?? 0) >= 30) {
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

  Future<String> _uploadAudioFile(String audioFilePath) async {
    String url = '';
    try {
      File audioFile = File(audioFilePath);
      final response = await sl<UploadFileUsecase>().call(
        UploadFileParams(recordingFile: audioFile),
      );
      url = response.data?.url ?? '';
    } catch (_) {}
    return url;
  }

  @override
  void dispose() {
    recorderController.dispose();
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
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: GestureDetector(
                onTap: () {
                  Get.back();
                },
                child: const Icon(Icons.close, size: 28.0, color: Colors.white),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24.0),
            decoration: const BoxDecoration(
              color: Color(0xFFF9F9F9),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12.0),
                topRight: Radius.circular(12.0),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: FontSize.xL,
                  ),
                ),
                const SizedBox(height: 4.0),
                // Text(
                //   widget.language ?? "",
                //   textAlign: TextAlign.center,
                //   style: TextStyle(
                //     fontWeight: FontWeight.bold,
                //     fontSize: FontSize.L,
                //     color: Get.theme.primaryColor,
                //   ),
                // ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 32.0,
                  ),
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: LocaleKeys.livePleaseRecordYourAudioIn.tr,
                        ),
                        TextSpan(
                          text: widget.language ?? "",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Get.theme.primaryColor,
                          ),
                        ),
                        TextSpan(text: LocaleKeys.liveUsingTheName.tr),
                        TextSpan(
                          text:
                              Get.find<UserController>()
                                  .userDetails
                                  .value
                                  .user
                                  ?.name ??
                              "",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Get.theme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: FontSize.L),
                  ),
                ),
                SampleAudioPlayer(
                  key: UniqueKey(),
                  audioUrl: widget.sampleAudioUrl,
                ),
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 32.0,
                    vertical: 16.0,
                  ),
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
                            key: UniqueKey(),
                            path: path!,
                            width: waveformWidth,
                            eventType: eventType,
                          )
                          : Visibility(
                            visible:
                                isRecording ||
                                (widget.recordingUrl?.isEmpty ?? true),
                            replacement: RecordingAudioPlayer(
                              key: UniqueKey(),
                              width: waveformWidth,
                              audioUrl: widget.recordingUrl ?? '',
                              pendingAudioUrl: widget.pendingAudioUrl ?? '',
                              status: widget.status,
                            ),
                            child: Row(
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
                                        margin: const EdgeInsets.only(
                                          left: 3.0,
                                        ),
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
                ),
                Column(
                  children: [
                    isRecordingCompleted
                        ? Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32.0),
                          child: Column(
                            children: [
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
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
                                      Text(
                                        LocaleKeys.reupload.tr,
                                        style: const TextStyle(
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      GestureDetector(
                                        onTap: () async {
                                          bool error = false;
                                          setState(() {
                                            _isUploading = true;
                                          });
                                          var fileUrl = '';
                                          try {
                                            if (path?.isNotEmpty ?? false) {
                                              final cleanedAudioFile =
                                                  await CleanVoiceService.cleanVoiceFromFile(
                                                    File(path!),
                                                  );
                                              fileUrl = await _uploadAudioFile(
                                                cleanedAudioFile.path,
                                              );
                                              if (fileUrl.isNotEmpty) {
                                                error = await widget
                                                    .uploadFunction(fileUrl);
                                                await Get.find<UserController>()
                                                    .fetchData();
                                              } else {
                                                error = true;
                                              }
                                            }
                                          } catch (_) {
                                            error = true;
                                          } finally {
                                            setState(() {
                                              _isUploading = false;
                                            });
                                            Get.back();
                                            if (error) {
                                              AlertService.showSnackBar(
                                                snackBarType:
                                                    SnackBarType.Warning,
                                                title:
                                                    LocaleKeys
                                                        .liveSomethingWentWrong2
                                                        .tr,
                                                subtitle:
                                                    LocaleKeys
                                                        .livePleaseTryAgainLater
                                                        .tr,
                                              );
                                            } else {
                                              sl<AnalyticsService>().trackEvent(
                                                "partnerAudioSuccess",
                                                eventProperties: {
                                                  'audioType': eventType,
                                                  'language': widget.language,
                                                  'languageType':
                                                      widget.languageType,
                                                  'recordUrl': fileUrl,
                                                  'duration': seconds.value
                                                      ?.toStringAsFixed(1),
                                                  ...sl<
                                                        IntroAudioPolicyService
                                                      >()
                                                      .analyticsProperties,
                                                },
                                              );
                                              var isRegistered =
                                                  Get.isRegistered<
                                                    VoiceController
                                                  >();
                                              if (isRegistered) {
                                                Get.find<VoiceController>()
                                                    .checkAndUpdateCurrentStep();
                                              }
                                            }
                                          }
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
                                      Text(
                                        LocaleKeys.upload.tr,
                                        style: const TextStyle(
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )
                        : Column(
                          children: [
                            isRecording
                                ? Text(
                                  '',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade700,
                                  ),
                                )
                                : Visibility(
                                  visible:
                                      (widget.recordingUrl?.isEmpty ?? true),
                                  replacement:
                                      widget.status?.getStatusWidget(
                                        widget.reason,
                                      ) ??
                                      Text(
                                        LocaleKeys.livePressHoldToRecord.tr,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                  child: Text(
                                    LocaleKeys.livePressHoldToSpeak.tr,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ),
                            const SizedBox(height: 12),
                            GestureDetector(
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
                                  backgroundColor:
                                      widget.status !=
                                              RecordingAudioStatus.Pending
                                          ? Get.theme.primaryColor
                                          : ApplicationColors.grey,
                                  radius: 32,
                                  child: Icon(
                                    isRecording ? Icons.stop : Icons.mic,
                                    color: Colors.white,
                                    size: 32,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
