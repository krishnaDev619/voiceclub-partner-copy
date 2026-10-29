import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:voiceclub_partner/data/models/course/probation_lesson.dart';
import 'package:voiceclub_partner/modules/controller/probation_course_controller.dart';
import 'package:voiceclub_partner/view/course/chewie/custom_material_controls.dart';
import 'package:voiceclub_partner/view/course/widgets/countdown_overlay.dart';

class ProbationCourseVideoPlayerScreen extends StatefulWidget {
  final VideoPlayerController videoPlayerController;
  final ProbationLesson lesson;
  final int chapterId;
  final bool fromOnboardingFlow;

  const ProbationCourseVideoPlayerScreen({
    super.key,
    required this.videoPlayerController,
    required this.lesson,
    required this.chapterId,
    this.fromOnboardingFlow = false,
  });

  @override
  State<ProbationCourseVideoPlayerScreen> createState() =>
      _ProbationCourseVideoPlayerScreenState();
}

class _ProbationCourseVideoPlayerScreenState
    extends State<ProbationCourseVideoPlayerScreen> {
  late ChewieController _chewieController;
  final courseController = Get.find<ProbationCourseController>();
  bool hasNavigatedBack = false;
  bool showCountdown = false;

  @override
  void initState() {
    super.initState();
    _initializeChewieController();
    widget.videoPlayerController.addListener(_videoListener);
  }

  void _initializeChewieController() {
    _chewieController = ChewieController(
      videoPlayerController: widget.videoPlayerController,
      aspectRatio: 9 / 16,
      allowFullScreen: false,
      autoInitialize: true,
      startAt: widget.lesson.startDuration,
      autoPlay: true,
      looping: false,
      showOptions: false,
      allowedScreenSleep: false,
      allowPlaybackSpeedChanging: false,
      draggableProgressBar:
          widget.fromOnboardingFlow ? false : widget.lesson.isCompleted,
      customControls: CustomMaterialControls(
        isCompleted: widget.lesson.isCompleted,
      ),
      materialProgressColors: ChewieProgressColors(
        playedColor: const Color(0xFFEE6464),
        bufferedColor: const Color(0xFFCCCCCC),
        handleColor: const Color(0xFFEE6464),
        backgroundColor: const Color(0xFF606060),
      ),
      errorBuilder: (context, errorMessage) {
        return Center(
          child: Text(
            errorMessage,
            style: const TextStyle(color: Colors.white),
          ),
        );
      },
    );
  }

  void _videoListener() {
    final position = widget.videoPlayerController.value.position;
    final duration = widget.videoPlayerController.value.duration;
    if (position >= duration) {
      if (mounted) {
        if (!hasNavigatedBack) {
          hasNavigatedBack = true;
          Get.back();
        }
      }
    } else if (duration - position <= const Duration(seconds: 5) &&
        !showCountdown) {
      setState(() {
        showCountdown = true;
      });
    }
  }

  @override
  void dispose() {
    _updateLessonWatchDuration();
    widget.videoPlayerController.removeListener(_videoListener);
    widget.videoPlayerController.dispose();
    _chewieController.dispose();
    super.dispose();
  }

  Future<void> _updateLessonWatchDuration() async {
    try {
      if (!widget.lesson.isCompleted) {
        await courseController.updateLessonWatchDuration(
          chapterId: widget.chapterId,
          lessonId: widget.lesson.id,
          watchedDuration: widget.videoPlayerController.value.position,
          totalDuration: widget.videoPlayerController.value.duration,
        );
      }
    } catch (e) {
      // Logger.logError('Error updating lesson watch duration: $e');
    }
  }

  void _onCountdownComplete() {
    if (mounted && !hasNavigatedBack) {
      hasNavigatedBack = true;
      Get.back();
      // Proceed to the next video here if needed
    }
  }

  void _onTap() {}

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          hasNavigatedBack = true;
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black54,
        body: SafeArea(
          child: Stack(
            children: [
              Container(
                alignment: Alignment.center,
                height: Get.height,
                width: Get.width,
                child: Center(
                  child: Chewie(
                    key: UniqueKey(),
                    controller: _chewieController,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  onPressed: () {
                    hasNavigatedBack = true;
                    Get.back();
                  },
                  icon: const Icon(
                    Icons.close,
                    size: 30.0,
                    color: Colors.white,
                  ),
                ),
              ),
              if (showCountdown && !(widget.lesson.isCompleted))
                Positioned(
                  right: 10.0,
                  bottom: 50.0,
                  child: CountdownOverlay(
                    onCountdownComplete: _onCountdownComplete,
                    onTap: _onTap,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
