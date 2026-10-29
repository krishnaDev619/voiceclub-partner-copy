import 'dart:io';

import 'package:dio/dio.dart';
import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/http_response_handler.dart';

import '../../domain/repository/stories_repository.dart';
import '../data_sources/remote/stories/stories_api_service.dart';
import '../models/file/upload_file_response.dart';
import '../models/stories/get_my_story_response.dart';

class StoriesRepositoryImpl implements StoriesRepository {
  final StoriesApiService _supplyStoriesApiService;
  StoriesRepositoryImpl(this._supplyStoriesApiService);

  @override
  Future<DataState<void>> deleteStory(int storyId) async {
    try {
      final response = await _supplyStoriesApiService.deleteStory(storyId);

      if (response.response.statusCode == 200) {
        return const DataSuccess(null);
      } else {
        return DataFailed(
          DioException(
            error: response.response.statusCode,
            message: response.response.statusMessage,
            response: response.response,
            requestOptions: response.response.requestOptions,
          ),
        );
      }
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<GetMyStoryResponseModel>> getMyStory() async {
    try {
      final response = await _supplyStoriesApiService.getMyStory();

      return toDataState(response);
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<void>> uploadStory(
    String color,
    String mediaUrl,
    String mediaType,
  ) async {
    try {
      final response = await _supplyStoriesApiService.uploadStory(
        color,
        mediaUrl,
        mediaType,
      );

      if (response.response.statusCode == 200) {
        return const DataSuccess(null);
      } else {
        return DataFailed(
          DioException(
            error: response.response.statusCode,
            message: response.response.statusMessage,
            response: response.response,
            requestOptions: response.response.requestOptions,
          ),
        );
      }
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<FileResponseModel>> uploadStoryAudioFile(
    File recordingFile,
  ) async {
    try {
      final response = await _supplyStoriesApiService.uploadStoryAudioFile(
        recordingFile,
      );

      return toDataState(response);
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<FileResponseModel>> uploadOtherFileTypes({
    required File file,
    required String extension,
  }) async {
    try {
      final response = await _supplyStoriesApiService.uploadOtherFileTypes(
        file: file,
        extension: extension,
      );

      return toDataState(response);
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }
}
