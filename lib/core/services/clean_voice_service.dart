import 'dart:io';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:voiceclub_partner/core/injection_container.dart';
import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/services/analytics_service.dart';
import 'package:voiceclub_partner/core/services/intro_audio_policy_service.dart';
import 'package:voiceclub_partner/core/services/logger.dart';
import 'package:voiceclub_partner/domain/usecases/cleanvoice/clean_audio_usecase.dart';
import 'package:voiceclub_partner/domain/usecases/cleanvoice/poll_edit_status_usecase.dart';

class CleanVoiceService {
  /// Attempt CleanVoice processing with 2-minute timeout and proper error handling
  static Future<File> cleanVoiceFromFile(File audioFile) async {
    try {
      // 1. Start the CleanVoice cleaning process
      final filename =
          'intro_audio_${DateTime.now().millisecondsSinceEpoch}.m4a';
      final cleanResult = await sl<CleanAudioUseCase>().call(
        CleanAudioParams(
          audioFile: audioFile,
          filename: filename,
          config: {
            'filler_sound': true,
            'stuttering': true,
            'breath': true,
            'mouth_sound': true,
            'dead_air': true,
            'normalize': true,
            'remove_noise': true,
            'export_format': 'm4a',
          },
        ),
      );

      if (cleanResult is! DataSuccess) {
        throw Exception('Failed to start CleanVoice processing');
      }

      final editResponse = cleanResult.data!;
      Logger.logMessage("CleanVoice job started with ID: ${editResponse.id}");

      // 2. Poll for completion with 2-minute timeout
      final pollResult = await sl<PollEditStatusUseCase>().call(
        PollEditStatusParams(
          editId: editResponse.id,
          pollInterval: const Duration(seconds: 2), // Status timer
          timeout: const Duration(minutes: 1), // Max duration for polling
        ),
      );

      if (pollResult is! DataSuccess) {
        throw Exception(
          'CleanVoice processing failed or timed out after 2 minutes',
        );
      }

      final completedResponse = pollResult.data!;
      if (completedResponse.result?.downloadUrl?.isEmpty == true) {
        throw Exception('No download URL available from CleanVoice');
      }

      // 3. Download the cleaned audio
      sl<AnalyticsService>().trackEvent(
        "cleanAudioSuccess",
        eventProperties: sl<IntroAudioPolicyService>().analyticsProperties,
      );
      final cleanedFile = await _downloadCleanedAudio(
        completedResponse.result!.downloadUrl!,
        'cleaned_$filename',
      );

      return cleanedFile;
    } catch (e) {
      Logger.logMessage(
        "CleanVoice processing failed: $e. Using original audio.",
      );
      sl<AnalyticsService>().trackEvent(
        "cleanAudioFallback",
        eventProperties: {
          "error": e.toString(),
          "screenName": "clean_voice_service",
          ...sl<IntroAudioPolicyService>().analyticsProperties,
        },
      );
      return audioFile;
    }
  }

  /// Download cleaned audio file from CleanVoice
  static Future<File> _downloadCleanedAudio(
    String downloadUrl,
    String filename,
  ) async {
    final cleanedAudioFile = await DefaultCacheManager().getSingleFile(
      downloadUrl,
    );
    Logger.logMessage(
      "Cleaned audio file path: ${cleanedAudioFile.path}",
      name: "CleanVoiceService",
    );

    return cleanedAudioFile;
  }
}
