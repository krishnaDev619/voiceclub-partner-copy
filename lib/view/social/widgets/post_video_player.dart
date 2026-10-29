import 'dart:async';

import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:voiceclub_partner/core/services/logger.dart';
import 'package:voiceclub_partner/core/services/social_video_service.dart';
import 'package:voiceclub_partner/view/social/controllers/explore_controller.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';

class PostVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final String? thumbnailUrl;
  final double width;
  final double height;
  final Color backgroundColor;
  final bool autoPlay;
  final String avatarUrl;

  const PostVideoPlayer({
    super.key,
    required this.videoUrl,
    this.thumbnailUrl,
    required this.width,
    required this.height,
    required this.backgroundColor,
    required this.avatarUrl,
    this.autoPlay = false,
  });

  @override
  State<PostVideoPlayer> createState() => _PostVideoPlayerState();
}

class _PostVideoPlayerState extends State<PostVideoPlayer> {
  VideoPlayerController? _videoPlayerController;
  bool _hasError = false;
  bool _isLoading = true;
  late String _controllerId;
  bool _isMuted = false;

  @override
  void initState() {
    super.initState();
    // Use video URL as unique ID for this video controller
    _controllerId = 'video_${widget.videoUrl.hashCode}';
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    if (_videoPlayerController != null) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final uri = Uri.tryParse(widget.videoUrl);
      if (uri == null) {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
        return;
      }

      _videoPlayerController = VideoPlayerController.networkUrl(uri);

      await _videoPlayerController!.initialize();

      if (!mounted) return;

      if (_videoPlayerController!.value.hasError) {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
        return;
      }

      // Register with SocialVideoService
      SocialVideoService.registerVideoController(
        _controllerId,
        _videoPlayerController!,
      );

      // Set initial volume to 1 (Unmuted) and enable looping
      _videoPlayerController!.setVolume(1.0);
      _videoPlayerController!.setLooping(true);

      // Add listener to update UI when video state changes
      _videoPlayerController!.addListener(() {
        if (!mounted) return;
        if (mounted) {
          setState(() {});
        }
      });

      setState(() {
        _isLoading = false;
      });

      // Don't auto-play here - let VisibilityDetector handle it
      // This prevents off-screen videos from playing during pagination
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  void _handleVisibilityChanged(VisibilityInfo info) {
    // Handle visibility changes - let SocialVideoService manage play/pause
    SocialVideoService.handleVideoVisibilityChange(
      _controllerId,
      info.visibleFraction,
    );
  }

  void _toggleMute() async {
    if (_videoPlayerController == null) return;

    // Remember if video was playing before mute/unmute
    final wasPlaying = _videoPlayerController!.value.isPlaying;

    setState(() {
      _isMuted = !_isMuted;
    });

    // Change volume without pausing
    await _videoPlayerController!.setVolume(_isMuted ? 0.0 : 1.0);

    // Ensure video continues playing if it was playing before
    if (wasPlaying && !_videoPlayerController!.value.isPlaying) {
      await _videoPlayerController!.play();
    }

    // Pause all audio players when unmuting video
    if (!_isMuted) {
      try {
        Get.find<ExploreController>().pauseAllPlayers();
      } catch (_) {}
    }

    Logger.logMessage('Video ${_isMuted ? "muted" : "unmuted"}');
  }

  @override
  void dispose() {
    SocialVideoService.unregisterVideoController(_controllerId);
    _videoPlayerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key(_controllerId),
      onVisibilityChanged: _handleVisibilityChanged,
      child: Container(
        width: widget.width,
        height: widget.height,
        color: widget.backgroundColor,
        child: Stack(
          children: [
            _buildContent(),
            // Avatar overlay (top right)
            Positioned(
              top: 20,
              right: 20,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: ClipOval(
                  child: FastCachedImage(
                    url: widget.avatarUrl,
                    fit: BoxFit.cover,
                    loadingBuilder:
                        (context, url) =>
                            Container(color: Colors.grey.shade300),
                    errorBuilder:
                        (context, url, error) => Container(
                          color: Colors.grey.shade300,
                          child: const Icon(Icons.person, color: Colors.white),
                        ),
                  ),
                ),
              ),
            ),
            // Mute/Unmute button (bottom right)
            Positioned(
              bottom: 10,
              right: 10,
              child: GestureDetector(
                onTap: _toggleMute,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isMuted
                        ? Icons.volume_off_rounded
                        : Icons.volume_up_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_hasError) {
      return _buildErrorWidget();
    }

    if (_isLoading || _videoPlayerController == null) {
      return _buildLoadingWidget();
    }

    return _buildVideoPlayer();
  }

  Widget _buildVideoPlayer() {
    final size = _videoPlayerController!.value.size;
    final aspectRatio =
        size.width > 0 && size.height > 0 ? size.width / size.height : 16 / 9;

    return Center(
      child: AspectRatio(
        aspectRatio: aspectRatio,
        child: VideoPlayer(_videoPlayerController!),
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Container(
      color: widget.backgroundColor,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 3,
            ),
            const SizedBox(height: 16),
            const Text(
              'Loading video...',
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      color: widget.backgroundColor,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.white70, size: 64),
            const SizedBox(height: 16),
            const Text(
              'Unable to load video',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Please check your connection',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _hasError = false;
                  _videoPlayerController?.dispose();
                  _videoPlayerController = null;
                });
                _initializeVideo();
              },
              icon: const Icon(Icons.refresh),
              label: Text(LocaleKeys.liveRetry.tr),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
