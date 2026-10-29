import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:voiceclub_partner/core/services/logger.dart';

/// Service to manage video playback specifically for social feed videos
/// This is separate from VideoService to avoid conflicts with other video players
class SocialVideoService {
  // Global video controllers registry for social feed
  static final Map<String, VideoPlayerController> _activeControllers = {};
  static final RxString _pauseAllTrigger = ''.obs;

  // Track currently visible video controller
  static String? _currentVisibleVideoId;
  static final RxString _visibleVideoChanged = ''.obs;

  // Global video control methods

  /// Register a video controller to be managed globally
  static void registerVideoController(
    String controllerId,
    VideoPlayerController controller,
  ) {
    try {
      _activeControllers[controllerId] = controller;
      Logger.logMessage('Registered social video controller: $controllerId');
    } catch (e) {
      Logger.logMessage(
        'Error registering social video controller $controllerId: $e',
      );
    }
  }

  /// Unregister a video controller
  static void unregisterVideoController(String controllerId) {
    try {
      _activeControllers.remove(controllerId);
      Logger.logMessage('Unregistered social video controller: $controllerId');
    } catch (e) {
      Logger.logMessage(
        'Error unregistering social video controller $controllerId: $e',
      );
    }
  }

  /// Pause all currently playing social videos
  static Future<void> pauseAllVideos() async {
    try {
      for (final controller in _activeControllers.values) {
        if (controller.value.isPlaying) {
          await controller.pause();
        }
      }
      // Clear current visible video
      _currentVisibleVideoId = null;
      // Trigger reactive notification for any listening widgets
      _pauseAllTrigger.value = DateTime.now().millisecondsSinceEpoch.toString();
      Logger.logMessage('Paused all social videos');
    } catch (e) {
      Logger.logMessage('Error pausing all social videos: $e');
    }
  }

  /// Pause all currently playing videos except the specified one
  static Future<void> pauseAllVideosExcept(String excludedControllerId) async {
    try {
      for (final entry in _activeControllers.entries) {
        if (entry.key != excludedControllerId && entry.value.value.isPlaying) {
          await entry.value.pause();
        }
      }
      Logger.logMessage(
        'Paused all social videos except: $excludedControllerId',
      );
    } catch (e) {
      Logger.logMessage(
        'Error pausing social videos except $excludedControllerId: $e',
      );
    }
  }

  /// Get the reactive trigger for pause all events
  static RxString get pauseAllTrigger => _pauseAllTrigger;

  /// Check if any video is currently playing
  static bool get hasPlayingVideo {
    return _activeControllers.values.any(
      (controller) => controller.value.isPlaying,
    );
  }

  /// Get count of active video controllers
  static int get activeControllersCount => _activeControllers.length;

  /// Set the currently visible video (for auto-play management)
  static void setVisibleVideo(String? controllerId) {
    if (_currentVisibleVideoId != controllerId) {
      _currentVisibleVideoId = controllerId;
      _visibleVideoChanged.value =
          DateTime.now().millisecondsSinceEpoch.toString();
      Logger.logMessage('Visible social video changed to: $controllerId');
    }
  }

  /// Get the currently visible video ID
  static String? get currentVisibleVideoId => _currentVisibleVideoId;

  /// Get the reactive trigger for visible video changes
  static RxString get visibleVideoChanged => _visibleVideoChanged;

  /// Handle visibility change for a specific video
  /// If it becomes visible (>50% visible), play it and pause others
  /// If it becomes invisible (<50% visible), pause it
  static Future<void> handleVideoVisibilityChange(
    String controllerId,
    double visibleFraction,
  ) async {
    try {
      final controller = _activeControllers[controllerId];
      if (controller == null) return;

      // Consider video visible if more than 50% is visible
      final isVisible = visibleFraction >= 0.5;

      if (isVisible) {
        // This video is now visible - play it and pause others
        setVisibleVideo(controllerId);

        // Pause all other videos
        await pauseAllVideosExcept(controllerId);

        // Play this video if not already playing
        if (!controller.value.isPlaying) {
          await controller.play();
          Logger.logMessage('Auto-playing visible social video: $controllerId');
        }
      } else {
        // This video is no longer visible - pause it
        if (controller.value.isPlaying &&
            _currentVisibleVideoId == controllerId) {
          await controller.pause();
          Logger.logMessage('Pausing invisible social video: $controllerId');

          // Clear current visible video if this was it
          if (_currentVisibleVideoId == controllerId) {
            _currentVisibleVideoId = null;
          }
        }
      }
    } catch (e) {
      Logger.logMessage(
        'Error handling social video visibility for $controllerId: $e',
      );
    }
  }

  /// Check if a specific video is the currently visible one
  static bool isVideoVisible(String controllerId) {
    return _currentVisibleVideoId == controllerId;
  }

  /// Dispose all video controllers (useful for cleanup)
  static void disposeAll() {
    try {
      for (final controller in _activeControllers.values) {
        controller.dispose();
      }
      _activeControllers.clear();
      _currentVisibleVideoId = null;
      Logger.logMessage('Disposed all social video controllers');
    } catch (e) {
      Logger.logMessage('Error disposing social video controllers: $e');
    }
  }
}
