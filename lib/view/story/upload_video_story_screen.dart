import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:voiceclub_partner/modules/controller/story_controller.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';

class UploadVideoStoryScreen extends StatefulWidget {
  final String path;
  const UploadVideoStoryScreen({super.key, required this.path});

  @override
  State<UploadVideoStoryScreen> createState() => _UploadVideoStoryScreenState();
}

class _UploadVideoStoryScreenState extends State<UploadVideoStoryScreen>
    with WidgetsBindingObserver {
  VideoPlayerController? _videoPlayerController;
  Future<void>? _prepareFuture;
  bool _isUploading = false;
  final _supplyStoryController = Get.find<StoryController>();

  @override
  void initState() {
    _prepareFuture = _prepare();
    super.initState();
  }

  Future<void> _prepare() async {
    try {
      _videoPlayerController = VideoPlayerController.file(File(widget.path));
      await _videoPlayerController?.initialize();
      _videoPlayerController?.setLooping(true);
      _play();
    } catch (_) {}
  }

  void _play() {
    if (!(_videoPlayerController?.value.isPlaying ?? true)) {
      _videoPlayerController?.play();
    }
  }

  void _pause() {
    if (_videoPlayerController?.value.isPlaying ?? false) {
      _videoPlayerController?.pause();
    }
  }

  // Implement lifecycle event methods
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      // Perform action when the screen becomes invisible
      _pause();
    } else if (state == AppLifecycleState.resumed) {
      // Perform action when the app becomes visible again
      _play();
    }
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.grey,
      body: FutureBuilder(
        future: _prepareFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Show loading indicator with a colored background
            return Center(
              child: SizedBox(
                height: 32.0,
                width: 32.0,
                child: CircularProgressIndicator(
                  strokeWidth: 2.0,
                  backgroundColor: Colors.white.withValues(alpha: 0.1),
                  color: Colors.white,
                ),
              ),
            );
          } else if (snapshot.hasError) {
            // Handle error
            return Center(child: Text(LocaleKeys.liveAnErrorOccurred.tr));
          } else {
            return GestureDetector(
              behavior: HitTestBehavior.translucent,
              onLongPress: () {
                _pause();
              },
              onLongPressEnd: (_) {
                _play();
              },
              child: Stack(
                children: [
                  Container(
                    clipBehavior: Clip.hardEdge,
                    height: double.infinity,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: SizedBox.expand(
                      child: FittedBox(
                        fit: BoxFit.cover,
                        child: SizedBox(
                          width: _videoPlayerController?.value.size.width ?? 0,
                          height:
                              _videoPlayerController?.value.size.height ?? 0,
                          child: VideoPlayer(_videoPlayerController!),
                        ),
                      ),
                    ),
                  ),
                  SafeArea(
                    right: false,
                    left: false,
                    bottom: false,
                    maintainBottomViewPadding: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        12.0,
                        16.0,
                        20.0,
                        16.0,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            children: [
                              const Spacer(),
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
                            ],
                          ),
                          const Spacer(),
                          Column(
                            children: [
                              GestureDetector(
                                onTap: () async {
                                  setState(() {
                                    _isUploading = true;
                                  });
                                  await _supplyStoryController.uploadVideoStory(
                                    widget.path,
                                    (_videoPlayerController
                                            ?.value
                                            .duration
                                            .inSeconds)
                                        .toString(),
                                  );
                                  setState(() {
                                    _isUploading = false;
                                  });
                                  Get.back();
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
                              const SizedBox(height: 12.0),
                              const Text(
                                'Post Status',
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
