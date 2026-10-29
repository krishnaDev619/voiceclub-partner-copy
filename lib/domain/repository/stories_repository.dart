import 'dart:io';

import 'package:voiceclub_partner/core/resources/data_state.dart';

import '../../data/models/file/upload_file_response.dart';
import '../../data/models/stories/get_my_story_response.dart';

abstract class StoriesRepository {
  Future<DataState<FileResponseModel>> uploadStoryAudioFile(File recordingFile);
  Future<DataState<FileResponseModel>> uploadOtherFileTypes({
    required File file,
    required String extension,
  });
  Future<DataState<void>> uploadStory(
    String color,
    String mediaUrl,
    String mediaType,
  );
  Future<DataState<GetMyStoryResponseModel>> getMyStory();
  Future<DataState<void>> deleteStory(int storyId);
}
