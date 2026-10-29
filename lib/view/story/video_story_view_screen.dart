import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:voiceclub_partner/core/services/story_helper_service.dart';
import 'package:voiceclub_partner/data/models/stories/story_view_data.dart';
import 'package:voiceclub_partner/modules/controller/story_controller.dart';
import 'package:voiceclub_partner/view/auth/widgets/cancel_alert.dart';
import 'package:voiceclub_partner/view/story/story_progress_indicator.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';

class VideoStoryViewScreen extends StatefulWidget {
  const VideoStoryViewScreen({
    super.key,
    required this.videoPlayerController,
    required this.durationInMilliseconds,
  });

  final VideoPlayerController videoPlayerController;
  final int durationInMilliseconds;

  @override
  State<VideoStoryViewScreen> createState() => _VideoStoryViewScreenState();
}

class _VideoStoryViewScreenState extends State<VideoStoryViewScreen>
    with TickerProviderStateMixin {
  AnimationController? _animationController;
  Animation<double>? _currentAnimation;
  VideoPlayerController? _videoPlayerController;
  final _supplyStoryController = Get.find<StoryController>();
  StoryViewDataModel? storyViewDataModel;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    storyViewDataModel = _supplyStoryController.storyData.value;
    _videoPlayerController = widget.videoPlayerController;
    _animationController = AnimationController(
      duration: Duration(milliseconds: widget.durationInMilliseconds),
      vsync: this,
    );
    _currentAnimation = Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(_animationController!);
    // Listen to animation completion
    _animationController?.addStatusListener((status) async {
      if (status == AnimationStatus.completed) {
        // Animation completed, pop the screen
        if (!_supplyStoryController.seen.value) {
          _supplyStoryController.markAsSeen();
        }
        await Future.delayed(const Duration(milliseconds: 500));
        Get.back();
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _play();
    });
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  void _play() {
    _videoPlayerController?.play();
    _animationController?.forward();
  }

  void _pause() {
    _videoPlayerController?.pause();
    _animationController?.stop();
  }

  @override
  void dispose() {
    _animationController?.dispose();
    _videoPlayerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = StoryHelperService.hexToColor(
      storyViewDataModel?.story?.color ?? 'FFFFFF',
    );
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onLongPress: () {
            _pause();
          },
          onLongPressEnd: (_) {
            _play();
          },
          onVerticalDragEnd: (details) {
            if (details.primaryVelocity! > 0) {
              // Swipe down detected
              Get.back();
            }
          },
          onTapUp: (TapUpDetails details) {
            double screenWidth = MediaQuery.of(context).size.width;
            double tapX = details.localPosition.dx;

            if (tapX < screenWidth / 2) {
            } else {
              Get.back();
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                PageBar(_currentAnimation),
                const SizedBox(height: 16.0),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8.0,
                        horizontal: 12.0,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: Text(
                        'My Status',
                        style: TextStyle(
                          color: backgroundColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Text(
                      'Expires in ${StoryHelperService.calculateTimeToExpire(storyViewDataModel?.story?.createdAt ?? '')}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12.0,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () async {
                        _pause();
                        if (!_isDeleting) {
                          bool shouldDelete = await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return CancelAlertDialog(
                                title: LocaleKeys.liveDeleteStatus.tr,
                                subtitle:
                                    'Are you sure you want to delete your status?',
                              );
                            },
                          );
                          if (shouldDelete) {
                            setState(() {
                              _isDeleting = true;
                            });
                            await _supplyStoryController.deleteStory(
                              storyViewDataModel?.story?.color ?? 'FFFFFF',
                              (widget.durationInMilliseconds ~/ 1000),
                            );
                            setState(() {
                              _isDeleting = false;
                            });
                            Get.back();
                          } else {
                            _play();
                          }
                        }
                      },
                      child:
                          _isDeleting
                              ? const SizedBox(
                                height: 16.0,
                                width: 16.0,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.0,
                                ),
                              )
                              : const Icon(
                                Icons.delete_outline_rounded,
                                size: 28.0,
                                color: Colors.white,
                              ),
                    ),
                    const SizedBox(width: 8.0),
                    GestureDetector(
                      onTap: () {
                        Get.back();
                      },
                      child: const Icon(
                        Icons.close,
                        size: 28.0,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8.0),
                  ],
                ),
                const SizedBox(height: 8.0),
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _videoPlayerController?.value.size.width ?? 0,
                      height: _videoPlayerController?.value.size.height ?? 0,
                      child: VideoPlayer(_videoPlayerController!),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.remove_red_eye, color: Colors.white),
                      const SizedBox(width: 4.0),
                      Text(
                        _supplyStoryController.viewCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
