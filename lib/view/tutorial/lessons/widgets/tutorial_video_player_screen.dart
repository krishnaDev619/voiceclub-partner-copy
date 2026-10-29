import 'dart:async';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:voiceclub_partner/core/injection_container.dart';
import 'package:voiceclub_partner/core/services/logger.dart';
import 'package:voiceclub_partner/data/models/tutorial/tutorial_lesson.dart';
import 'package:voiceclub_partner/modules/controller/call_controller.dart';
import 'package:voiceclub_partner/view/course/chewie/custom_material_controls.dart';
import 'package:voiceclub_partner/view/tutorial/lessons/controllers/tutorial_lesson_controller.dart';

class TutorialVideoPlayerScreen extends StatefulWidget {
  final VideoPlayerController videoPlayerController;
  final TutorialLesson lesson;
  final bool isCompleted;
  final int stageId;
  final int lessonIndex;

  const TutorialVideoPlayerScreen({
    super.key,
    required this.videoPlayerController,
    required this.lesson,
    required this.isCompleted,
    required this.stageId,
    required this.lessonIndex,
  });

  @override
  State<TutorialVideoPlayerScreen> createState() =>
      _TutorialVideoPlayerScreenState();
}

class _TutorialVideoPlayerScreenState extends State<TutorialVideoPlayerScreen> {
  late ChewieController _chewieController;

  final lessonController = Get.find<TutorialLessonController>();
  bool hasNavigatedBack = false;
  bool showCountdown = false;
  StreamSubscription<String>? callStream;

  @override
  void initState() {
    super.initState();
    _initializeChewieController();
    lessonController.trackLessonEvent(
      "tutorialVideoPlayerScreen",
      additionalProperties: {
        "isRewatch": widget.isCompleted,
        "lessonTitle": widget.lesson.title,
        "lessonId": widget.lesson.id,
        "lessonIndex": widget.lessonIndex + 1,
      },
    );
    widget.videoPlayerController.addListener(_videoListener);
    addCallListener();
  }

  void addCallListener() {
    if (sl.isRegistered<CallController>()) {
      callStream = sl<CallController>().incomingCallPayload.listen((p0) {
        // Check if the call payload is not empty then pause the tutorial
        if (p0.isNotEmpty) {
          _chewieController.pause();
        }
      });
    }
  }

  void _initializeChewieController() {
    _chewieController = ChewieController(
      videoPlayerController: widget.videoPlayerController,
      aspectRatio: 9 / 16,
      allowFullScreen: false,
      autoInitialize: true,
      autoPlay: true,
      looping: false,
      showOptions: false,
      allowedScreenSleep: false,
      allowPlaybackSpeedChanging: false,
      draggableProgressBar: widget.isCompleted,
      customControls: CustomMaterialControls(isCompleted: widget.isCompleted),
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
    callStream?.cancel();
    super.dispose();
  }

  void _updateLessonWatchDuration() async {
    try {
      Logger.logMessage(
        "Updating lesson watch duration with isCompleted: ${widget.isCompleted}",
        name: 'Tutorial',
      );
      if (!widget.isCompleted) {
        lessonController.updateLessonWatchDuration(
          stageId: widget.stageId,
          lessonId: widget.lesson.id ?? 0,
          watchedDuration: widget.videoPlayerController.value.position,
          totalDuration: widget.videoPlayerController.value.duration,
        );
      }
    } catch (e) {
      Logger.logMessage(
        'Error updating lesson watch duration: $e',
        name: "Tutorial",
      );
    }
  }

  // void _onCountdownComplete() {
  //   if (mounted && !hasNavigatedBack) {
  //     hasNavigatedBack = true;
  //     Get.back();
  //     // Proceed to the next video here if needed
  //   }
  // }

  // void _onTap() {}

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
              // if (showCountdown && !(widget.lesson.isCompleted))
              //   Positioned(
              //     right: 10.0,
              //     bottom: 50.0,
              //     child: CountdownOverlay(
              //       onCountdownComplete: _onCountdownComplete,
              //       onTap: _onTap,
              //     ),
              //   ),
            ],
          ),
        ),
      ),
    );
  }
}
