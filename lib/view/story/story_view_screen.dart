import 'dart:async';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/core/injection_container.dart';
import 'package:voiceclub_partner/core/services/analytics_service.dart';
import 'package:voiceclub_partner/core/services/story_helper_service.dart';
import 'package:voiceclub_partner/data/models/stories/story_view_data.dart';
import 'package:voiceclub_partner/modules/controller/story_controller.dart';
import 'package:voiceclub_partner/view/auth/widgets/cancel_alert.dart';
import 'package:voiceclub_partner/view/story/story_progress_indicator.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';

class StoryViewScreen extends StatefulWidget {
  const StoryViewScreen({
    super.key,
    required this.width,
    required this.audioPlayerController,
    required this.durationInMilliseconds,
  });

  final double width;
  final PlayerController audioPlayerController;
  final int durationInMilliseconds;

  @override
  State<StoryViewScreen> createState() => _StoryViewScreenState();
}

class _StoryViewScreenState extends State<StoryViewScreen>
    with TickerProviderStateMixin {
  AnimationController? _animationController;
  Animation<double>? _currentAnimation;
  PlayerController? _audioPlayerController;
  StreamSubscription<PlayerState>? playerStateSubscription;
  final _supplyStoryController = Get.find<StoryController>();
  StoryViewDataModel? storyViewDataModel;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    storyViewDataModel = _supplyStoryController.storyData.value;
    sl<AnalyticsService>().trackEvent(
      'viewStoryPartner',
      eventProperties: {
        'storyViewCount': _supplyStoryController.viewCount.value,
        'storyDuration': (widget.durationInMilliseconds ~/ 1000),
      },
    );
    _audioPlayerController = widget.audioPlayerController;
    playerStateSubscription = _audioPlayerController?.onPlayerStateChanged
        .listen((_) {
          setState(() {});
        });
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
    _audioPlayerController?.startPlayer();
    _animationController?.forward();
  }

  void _pause() {
    _audioPlayerController?.pausePlayer();
    _animationController?.stop();
  }

  @override
  void dispose() {
    _animationController?.dispose();
    playerStateSubscription?.cancel();
    _audioPlayerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = StoryHelperService.hexToColor(
      storyViewDataModel?.story?.color ?? 'FFFFFF',
    );
    double waveformWidth = MediaQuery.of(context).size.width - 180.0;
    return Scaffold(
      backgroundColor: backgroundColor,
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
                const Spacer(),
                Center(
                  child: Container(
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CircleAvatar(
                          backgroundColor: Get.theme.primaryColor,
                          radius: 14.0,
                          backgroundImage: FastCachedImageProvider(
                            storyViewDataModel?.account?.user?.avatar ?? '',
                          ),
                        ),
                        const SizedBox(width: 12.0),
                        Expanded(
                          child: AudioFileWaveforms(
                            enableSeekGesture: false,
                            playerController: _audioPlayerController!,
                            size: Size(waveformWidth, 50),
                            waveformType: WaveformType.fitWidth,
                            playerWaveStyle: const PlayerWaveStyle(
                              spacing: 6.0,
                              scaleFactor: 100.0,
                              waveThickness: 3.0,
                              liveWaveColor: Color(0xFF787878),
                              fixedWaveColor: Color(0xFFD9D9D9),
                            ),
                            decoration: const BoxDecoration(
                              color: Colors.transparent,
                            ),
                            padding: const EdgeInsets.all(0.0),
                            margin: const EdgeInsets.only(left: 3.0),
                          ),
                        ),
                        const SizedBox(width: 12.0),
                        SizedBox(
                          width: 32.0,
                          child: Builder(
                            builder: (context) {
                              // Format the time as 0:00
                              final formattedTime =
                                  '0:${(widget.durationInMilliseconds ~/ 1000).toString().padLeft(2, '0')}';
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
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.only(bottom: 32.0),
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
