import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:video_player/video_player.dart';
import 'package:voiceclub_partner/core/constants/asset_constants.dart';
import 'package:voiceclub_partner/core/injection_container.dart';
import 'package:voiceclub_partner/core/services/analytics_service.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';
import 'package:voiceclub_partner/view/course/chewie/custom_material_controls.dart';

class PlayVideoScreen extends StatefulWidget {
  final String videoUrl;
  final String videoKey;
  final bool isFromOnboarding;
  final bool isFromShowcase;
  final bool isForce;
  final bool isMetricFlow;
  final bool trackWatchDurationEvent;
  final double? aspectRatio;

  const PlayVideoScreen({
    super.key,
    required this.videoUrl,
    this.videoKey = '',
    this.isFromOnboarding = false,
    this.isFromShowcase = false,
    this.isForce = false,
    this.isMetricFlow = false,
    this.trackWatchDurationEvent = false,
    this.aspectRatio,
  });

  @override
  State<PlayVideoScreen> createState() => _PlayVideoScreenState();
}

class _PlayVideoScreenState extends State<PlayVideoScreen> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    if (!widget.isMetricFlow) {
      sl<AnalyticsService>().trackEvent(
        "playVideoScreen",
        eventProperties: {
          'videoUrl': widget.videoUrl,
          'isForce': widget.isForce,
          'isFromOnboarding': widget.isFromOnboarding,
        },
      );
    }
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    _videoPlayerController = VideoPlayerController.networkUrl(
      Uri.parse(widget.videoUrl),
    );

    try {
      await _videoPlayerController.initialize();

      if (mounted) {
        _chewieController = ChewieController(
          videoPlayerController: _videoPlayerController,
          autoPlay: true,
          looping: false,
          aspectRatio: widget.aspectRatio,
          allowFullScreen: true,
          allowMuting: true,
          allowPlaybackSpeedChanging: true,
          showControls: true,
          draggableProgressBar: !widget.isForce,
          customControls: CustomMaterialControls(isCompleted: !widget.isForce),
          errorBuilder: (context, errorMessage) {
            return _buildErrorWidget();
          },
        );

        _videoPlayerController.addListener(_videoListener);
        setState(() {});
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _hasError = true;
        });
      }
    }
  }

  void _videoListener() {
    if (_videoPlayerController.value.hasError) {
      setState(() {
        _hasError = true;
      });
    }

    if (_videoPlayerController.value.isCompleted) {
      if (widget.isFromOnboarding ||
          widget.isMetricFlow ||
          widget.isFromShowcase) {
        Get.back(result: true);
      }
    }
  }

  @override
  void dispose() {
    if (_videoPlayerController.value.isInitialized &&
        widget.trackWatchDurationEvent) {
      sl<AnalyticsService>().trackEvent(
        "onescoreWatchVideoClosed",
        eventProperties: {
          "watchDuration": _videoPlayerController.value.position.inSeconds,
        },
      );
    }
    _videoPlayerController.removeListener(_videoListener);
    _chewieController?.dispose();
    _videoPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !widget.isForce,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        extendBody: true,
        appBar: AppBar(
          backgroundColor: Colors.black,
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.black,
            statusBarIconBrightness: Brightness.light,
          ),
          actions: [
            if (!widget.isForce)
              IconButton(
                padding: const EdgeInsets.all(4.0),
                onPressed: () => Get.back(),
                icon: const Icon(Icons.close, color: Colors.white, size: 30.0),
              ),
          ],
        ),
        backgroundColor: Colors.black,
        body: SafeArea(
          child:
              _hasError
                  ? _buildErrorWidget()
                  : _chewieController != null
                  ? Chewie(controller: _chewieController!)
                  : const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(AssetConstants.comingSoonAnimation, repeat: true),
          const SizedBox(height: 32.0),
          Text(
            LocaleKeys.videoError.tr,
            style: const TextStyle(
              fontSize: 24.0,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: Get.height * 0.2),
        ],
      ),
    );
  }
}
