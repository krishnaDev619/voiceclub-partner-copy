import 'dart:io';

import 'package:dio/dio.dart';
import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/http_response_handler.dart';

import 'package:voiceclub_partner/data/data_sources/remote/file/file_api_service.dart';
import 'package:voiceclub_partner/data/models/file/upload_file_response.dart';
import 'package:voiceclub_partner/domain/repository/file_repository.dart';

class FileRepositoryImpl implements FileRepository {
  final FileApiService _fileApiService;
  FileRepositoryImpl(this._fileApiService);

  @override
  Future<DataState<FileResponseModel>> getSignedFileUrl({
    required String fileName,
  }) async {
    try {
      final response = await _fileApiService.getSignedFileUrl(
        fileName: fileName,
      );

      return toDataState(response);
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<FileResponseModel>> uploadFile({
    required File recordingFile,
  }) async {
    try {
      final response = await _fileApiService.uploadFile(
        recordingFile: recordingFile,
      );

      return toDataState(response);
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }
}
