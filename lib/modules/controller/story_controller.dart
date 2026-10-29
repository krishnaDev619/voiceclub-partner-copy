import 'dart:io';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get/get.dart';
import 'package:video_compress/video_compress.dart';
import 'package:voiceclub_partner/core/injection_container.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/core/services/analytics_service.dart';
import 'package:voiceclub_partner/core/services/file_service.dart' as ext;
import 'package:voiceclub_partner/data/models/stories/story_view_data.dart';
import 'package:voiceclub_partner/domain/usecases/stories/delete_story.dart'
    as delete_story;
import 'package:voiceclub_partner/domain/usecases/stories/get_my_story.dart'
    as get_my_story;
import 'package:voiceclub_partner/domain/usecases/stories/upload_other_file_types.dart'
    as upload_other_file_types;
import 'package:voiceclub_partner/domain/usecases/stories/upload_story.dart'
    as upload_story_use_case;
import 'package:voiceclub_partner/domain/usecases/stories/upload_story_audio_file.dart'
    as upload_story_audio_file;

class StoryController extends GetxController {
  final hasStory = false.obs;
  final viewCount = 0.obs;
  final storyData = StoryViewDataModel().obs;
  final path = ''.obs;
  final isLoading = false.obs;
  final seen = false.obs;

  final _uploadStoryUseCase = sl<upload_story_use_case.UploadStoryUsecase>();
  final _getMyStoryUseCase = sl<get_my_story.GetMyStoryUsecase>();
  final _uploadStoryAudioFileUseCase =
      sl<upload_story_audio_file.UploadStoryAudioFileUsecase>();
  final _uploadOtherFileTypesUseCase =
      sl<upload_other_file_types.UploadOtherFileTypesUsecase>();
  final _deleteStoryUseCase = sl<delete_story.DeleteStoryUsecase>();

  @override
  void onInit() {
    fetchStory();
    super.onInit();
  }

  Future<void> uploadStory(
    String color,
    String audioFilePath,
    String duration,
  ) async {
    try {
      File audioFile = File(audioFilePath);
      await _uploadStoryAudioFileUseCase
          .call(upload_story_audio_file.Params(recordingFile: audioFile))
          .then((response) async {
            final url = response.data?.url ?? '';
            if (url.isNotEmpty) {
              await _uploadStoryUseCase.call(
                upload_story_use_case.Params(
                  color: color,
                  mediaType: 'AUDIO',
                  mediaUrl: url,
                ),
              );
            }
          });
      sl<AnalyticsService>().trackEvent(
        'postStorySuccess',
        eventProperties: {
          'storyColor': color,
          'storyDuration': duration,
          "type": "AUDIO",
        },
      );
    } catch (e) {
      sl<AnalyticsService>().trackEvent(
        'postStoryFailed',
        eventProperties: {
          'storyColor': color,
          'storyDuration': duration,
          "type": "AUDIO",
          'reason': e.toString(),
        },
      );
    }
    await Future.delayed(const Duration(seconds: 2));
    fetchStory();
  }

  Future<void> uploadVideoStory(String videoFilePath, String duration) async {
    try {
      final mediaInfo = await VideoCompress.compressVideo(
        videoFilePath,
        quality: VideoQuality.MediumQuality,
        deleteOrigin: false, // It's false by default
      );
      await _uploadOtherFileTypesUseCase
          .call(
            upload_other_file_types.Params(
              extension: ext.FileService.getFileExtension(
                mediaInfo?.file ?? File(videoFilePath),
              ),
              file: mediaInfo?.file ?? File(videoFilePath),
            ),
          )
          .then((response) async {
            final url = response.data?.url ?? '';
            if (url.isNotEmpty) {
              await _uploadStoryUseCase.call(
                upload_story_use_case.Params(
                  mediaUrl: url,
                  color: "FFFFFF",
                  mediaType: 'VIDEO',
                ),
              );
            }
          });
      sl<AnalyticsService>().trackEvent(
        'postStorySuccess',
        eventProperties: {'storyDuration': duration, "type": "VIDEO"},
      );
    } catch (e) {
      sl<AnalyticsService>().trackEvent(
        'postStoryFailed',
        eventProperties: {
          'storyDuration': duration,
          'type': "VIDEO",
          'reason': e.toString(),
        },
      );
    }
    await Future.delayed(const Duration(seconds: 2));
    fetchStory();
  }

  Future<void> deleteStory(String color, int storyDuration) async {
    try {
      if (hasStory.value) {
        await _deleteStoryUseCase.call(
          delete_story.Params(storyId: storyData.value.story?.id ?? 0),
        );
        sl<AnalyticsService>().trackEvent(
          'storyDeleteSuccess',
          eventProperties: {
            'color': color,
            'storyDuration': storyDuration,
            'type': storyData.value.story?.mediaType ?? '',
            'storyViewCount': viewCount.value,
          },
        );
        seen.value = false;
        await Future.delayed(const Duration(milliseconds: 2));
        fetchStory();
      }
    } catch (e) {
      sl<AnalyticsService>().trackEvent(
        'storyDeleteFailed',
        eventProperties: {
          'color': color,
          'storyDuration': storyDuration,
          'type': storyData.value.story?.mediaType ?? '',
          'storyViewCount': viewCount.value,
          'reason': e.toString(),
        },
      );
    }
  }

  void markAsSeen() {
    seen.value = true;
    update();
  }

  Future<void> downloadAndStoreFile(String fileUrl) async {
    try {
      final file = await DefaultCacheManager().getSingleFile(fileUrl);
      path.value = file.path;
    } catch (_) {}
  }

  void fetchStory() async {
    try {
      isLoading.value = true;
      update();
      await _getMyStoryUseCase.call(NoParams()).then((response) async {
        final data = response.data;
        if (data != null) {
          hasStory.value = data.hasStory ?? false;
          viewCount.value = data.viewCount ?? 0;
          storyData.value = data.storyData ?? StoryViewDataModel();
          seen.value = data.storyData?.isSeen ?? false;
          await downloadAndStoreFile(data.storyData?.story?.mediaUrl ?? '');
        }
      });
    } catch (e) {
      seen.value = false;
      hasStory.value = false;
      viewCount.value = 0;
      storyData.value = StoryViewDataModel();
    } finally {
      isLoading.value = false;
      update();
    }
  }
}
