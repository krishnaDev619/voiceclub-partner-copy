import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:voiceclub_partner/core/constants/asset_constants.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/core/injection_container.dart';
import 'package:voiceclub_partner/core/services/analytics_service.dart';
import 'package:voiceclub_partner/core/services/intro_audio_policy_service.dart';
import 'package:voiceclub_partner/view/audios/controllers/intro_audio_controller.dart';
import 'package:voiceclub_partner/view/profile/widgets/intro_sample_audio_player.dart';
import 'package:voiceclub_partner/view/widgets/custom_button.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';

final introAudioShowcaseKey = GlobalKey();
const String introAudioShowcaseScopeName = '_introAudioBottomSheetScope';

class IntroAudioBottomSheet extends StatefulWidget {
  final String primaryText;
  final String secondaryText;
  final String cityName;
  final String language;
  final RecordingAudioStatus? status;
  final RecordingAudioType audioType;
  final String audioUrl;

  const IntroAudioBottomSheet({
    super.key,
    required this.primaryText,
    required this.secondaryText,
    required this.cityName,
    required this.language,
    required this.audioType,
    this.status,
    required this.audioUrl,
  });

  @override
  State<IntroAudioBottomSheet> createState() => _IntroAudioBottomSheetState();
}

class _IntroAudioBottomSheetState extends State<IntroAudioBottomSheet>
    with TickerProviderStateMixin {
  late IntroAudioController controller;
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  late ShowcaseView _showcaseView;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _showcaseView = ShowcaseView.register(scope: introAudioShowcaseScopeName);
    sl<AnalyticsService>().trackEvent(
      "introAudioBottomSheet",
      eventProperties: sl<IntroAudioPolicyService>().analyticsProperties,
    );
    controller = Get.put(
      IntroAudioController(
        primaryText: widget.primaryText,
        secondaryText: widget.secondaryText,
        cityName: widget.cityName,
        language: widget.language,
      ),
    );
    _audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
      if (state == PlayerState.completed) {
        setState(() {
          _isPlaying = false;
        });
      }
    });

    // Animation setup for pulsing effect
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
      lowerBound: 0.0,
      upperBound: 1.0,
    );
    _pulseAnimation = Tween<double>(begin: 80, end: 100).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _pulseController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _pulseController.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _pulseController.forward();
      }
    });

    // Listen for recording completion state changes to stop audio player
    ever(controller.isRecordingCompleted, (bool completed) {
      if (!completed && _isPlaying) {
        _audioPlayer.stop();
        setState(() {
          _isPlaying = false;
        });
      }
      // Reset audio player when recording is completed to ensure it uses the new path
      if (completed) {
        _audioPlayer.stop();
        setState(() {
          _isPlaying = false;
        });
      }
    });

    // Listen for processing workflow to stop audio player during analysis
    ever(controller.isProcessingWorkflow, (bool processing) {
      if (processing && _isPlaying) {
        _audioPlayer.stop();
        setState(() {
          _isPlaying = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _audioPlayer.dispose();
    _showcaseView.unregister();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Listen to recording state and start/stop pulse animation
    ever(controller.isRecording, (bool isRecording) {
      if (isRecording) {
        _pulseController.forward();
      } else {
        _pulseController.stop();
        _pulseController.value = 0.0;
      }
    });
  }

  Future<void> _playPauseAudio() async {
    if (controller.path == null) return;

    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.play(DeviceFileSource(controller.path!));
    }

    setState(() {
      _isPlaying = !_isPlaying;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Obx(() {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Visibility(
              visible: controller.canCloseSheet,
              child: Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: GestureDetector(
                    onTap: () => Get.back(),
                    child: const Icon(
                      Icons.close,
                      size: 28.0,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            Container(
              width: double.maxFinite,
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12.0),
                  topRight: Radius.circular(12.0),
                ),
              ),
              child:
                  controller.showGoLiveUI.value
                      ? _buildGoLiveContent(context, controller)
                      : controller.showTeamReviewUI.value
                      ? _buildTeamReviewContent(context, controller)
                      : controller.rejectionReason.value != null
                      ? _buildAnalysisFailedContent(context, controller)
                      : controller.isShowingProcessingUI
                      ? _buildProcessingUI(context, controller)
                      : _buildNormalContent(context, controller),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildGoLiveContent(
    BuildContext context,
    IntroAudioController controller,
  ) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Celebration animation background
        Positioned.fill(
          child: Lottie.asset(
            AssetConstants.celebrationAnimation,
            fit: BoxFit.cover,
          ),
        ),

        // Main content
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40.0),

            // Success icon
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: Colors.green,
                size: 80.0,
              ),
            ),

            const SizedBox(height: 24.0),

            // Congratulations text
            Text(
              LocaleKeys.congratulationsBang.tr,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: FontSize.xXXL,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 16.0),

            // Subtitle text
            Text(
              LocaleKeys.settingUpYourAccount.tr,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: FontSize.L,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 40.0),

            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: CircularProgressIndicator(),
            ),

            const SizedBox(height: 20.0),
          ],
        ),
      ],
    );
  }

  Widget _buildAnalysisFailedContent(
    BuildContext context,
    IntroAudioController controller,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          controller.rejectionReason.value ??
              LocaleKeys.repeatedWordsNaturally.tr,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          LocaleKeys.feedbackLabel.trParams({
            'feedback': controller.rejectionFeedback.value ?? '',
          }),
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Colors.black54,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 48),
        Image.asset(AssetConstants.analysisFailed, width: 200, height: 200),
        const SizedBox(height: 48),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: controller.reupload,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE57373),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                elevation: 0,
              ),
              child: Text(
                LocaleKeys.recordAgain.tr,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildTeamReviewContent(
    BuildContext context,
    IntroAudioController controller,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),

          // Success icon with a different color for team review
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.red.shade100,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.warning_rounded,
              color: Colors.red,
              size: 60.0,
            ),
          ),

          const SizedBox(height: 24.0),

          // Title
          Text(
            LocaleKeys.underReview.tr,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: FontSize.xXL,
              color: Colors.black,
            ),
          ),

          const SizedBox(height: 16.0),

          // Main message
          Text(
            LocaleKeys.exceededMaximumAttempts.tr,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: FontSize.L,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 8.0),

          // Secondary message
          Text(
            LocaleKeys.teamWillContactYou.tr,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: FontSize.L,
              color: Colors.black54,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 32.0),

          // Close button
          CustomButton(
            text: LocaleKeys.continueLabel.tr,
            onTap: () => Get.back(),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildNormalContent(
    BuildContext context,
    IntroAudioController controller,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          LocaleKeys.profileIntroductionAudio.tr,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: FontSize.xL,
          ),
        ),
        const SizedBox(height: 4.0),
        if (widget.audioUrl.isNotEmpty)
          IntroSampleAudioPlayer(audioUrl: widget.audioUrl),
        const SizedBox(height: 16.0),
        // Language variant selection
        if (controller.availableVariantCount > 1)
          _buildLanguageVariantSelector(),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFEDEDED),
              borderRadius: BorderRadius.circular(12.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SvgPicture.asset(AssetConstants.speak, width: 30, height: 30),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Obx(
                      () => Text(
                        controller.currentInstructionText,
                        style: const TextStyle(
                          fontSize: FontSize.xL,
                          color: Colors.black87,
                          height: 1.75,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (controller.isRecordingCompleted.value && controller.path != null)
          _buildCompletedUI(context, controller)
        else
          _buildRecordingUI(context, controller),
      ],
    );
  }

  Widget _buildProcessingUI(
    BuildContext context,
    IntroAudioController controller,
  ) {
    return SizedBox(
      width: double.infinity,
      height: Get.height * 0.4,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            LocaleKeys.doNotCloseTheApp.tr,
            style: TextStyle(
              fontSize: FontSize.xL,
              color: Get.theme.primaryColor,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const Spacer(),
          Visibility(
            visible: controller.isAnalysisFailed.value,
            replacement: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(shape: BoxShape.circle),
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Get.theme.primaryColor),
                strokeWidth: 5.0,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: controller.reupload,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE57373),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    LocaleKeys.tryAgain.tr,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            controller.processingStatus.value,
            style: const TextStyle(
              fontSize: FontSize.xL,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildCompletedUI(
    BuildContext context,
    IntroAudioController controller,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      _audioPlayer.stop();
                      setState(() {
                        _isPlaying = false;
                      });
                      controller.reupload();
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
                      child: const CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 32,
                        child: Icon(Icons.mic, color: Colors.black, size: 32),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12.0),
                  Text(
                    LocaleKeys.reupload.tr,
                    style: const TextStyle(color: Colors.black),
                  ),
                ],
              ),
              Column(
                children: [
                  GestureDetector(
                    onTap: _playPauseAudio,
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
                        backgroundColor: Colors.blue,
                        radius: 32,
                        child: Icon(
                          _isPlaying ? Icons.pause : Icons.play_arrow,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12.0),
                  Text(
                    _isPlaying ? LocaleKeys.pause.tr : LocaleKeys.play.tr,
                    style: const TextStyle(color: Colors.black),
                  ),
                ],
              ),
              Column(
                children: [
                  GestureDetector(
                    onTap: () async {
                      // Stop audio player if playing
                      if (_isPlaying) {
                        await _audioPlayer.stop();
                        setState(() {
                          _isPlaying = false;
                        });
                      }
                      await controller.analyzeAudioWithOpenAI(
                        audioType: widget.audioType,
                        language: widget.language,
                      );
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
                            controller.isUploading.value
                                ? const SizedBox(
                                  height: 24.0,
                                  width: 24.0,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 3.0,
                                  ),
                                )
                                : const Icon(
                                  Icons.send_rounded,
                                  color: Colors.white,
                                  size: 32,
                                ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12.0),
                  Text(
                    LocaleKeys.liveSubmit.tr,
                    style: TextStyle(color: Colors.black),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageVariantSelector() {
    return Obx(
      () => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children:
              controller.availableVariants.map((variant) {
                final isSelected =
                    controller.selectedLanguageVariant.value == variant;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: GestureDetector(
                    onTap: () => controller.selectLanguageVariant(variant),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      decoration: BoxDecoration(
                        color:
                            isSelected
                                ? const Color(
                                  0xFFE57373,
                                ) // Red color for selected
                                : const Color(
                                  0xFFF5F5F5,
                                ), // Light gray for unselected
                        borderRadius: BorderRadius.circular(20.0),
                        border: Border.all(
                          color:
                              isSelected
                                  ? const Color(0xFFE57373)
                                  : const Color(0xFFE0E0E0),
                          width: 1.0,
                        ),
                      ),
                      child: Text(
                        variant.displayName,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontSize: FontSize.M,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
        ),
      ),
    );
  }

  Widget _buildRecordingUI(
    BuildContext context,
    IntroAudioController controller,
  ) {
    return Column(
      children: [
        controller.isRecording.value
            ? const SizedBox(height: 12)
            : Text(
              LocaleKeys.holdToRecord.tr,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
            ),
        const SizedBox(height: 12),
        Container(
          height: 50,
          width: MediaQuery.of(context).size.width - 180,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Center(
            child:
                controller.isRecording.value
                    ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          LocaleKeys.recordingInProgress.tr,
                          style: TextStyle(
                            color: Get.theme.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        ValueListenableBuilder<int?>(
                          valueListenable: controller.seconds,
                          builder: (context, seconds, _) {
                            final formattedTime =
                                '0:${(seconds ?? 0).toString().padLeft(2, '0')}';
                            return Text(
                              formattedTime,
                              style: TextStyle(
                                fontSize: 16.0,
                                color: Get.theme.primaryColor,
                              ),
                            );
                          },
                        ),
                      ],
                    )
                    : Icon(
                      Icons.graphic_eq,
                      color: Colors.grey.shade400,
                      size: 24,
                    ),
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onLongPress: () => controller.startOrStopRecording(widget.status),
          onLongPressEnd: (_) => controller.startOrStopRecording(widget.status),
          child: SizedBox(
            height: 100,
            width: 100,
            child: Center(
              child: AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  final size =
                      controller.isRecording.value
                          ? _pulseAnimation.value
                          : 80.0;
                  final radius =
                      controller.isRecording.value
                          ? _pulseAnimation.value / 2
                          : 40.0;
                  return Container(
                    height: size,
                    width: size,
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
                      backgroundColor:
                          widget.status != RecordingAudioStatus.Pending
                              ? Get.theme.primaryColor
                              : Colors.grey,
                      radius: radius,
                      child: Icon(
                        controller.isRecording.value ? Icons.stop : Icons.mic,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
