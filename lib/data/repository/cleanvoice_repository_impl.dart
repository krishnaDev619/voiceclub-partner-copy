import 'dart:io';

import 'package:dio/dio.dart';
import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/http_response_handler.dart';
import 'package:voiceclub_partner/data/data_sources/remote/cleanvoice/cleanvoice_api_service.dart';
import 'package:voiceclub_partner/data/models/cleanvoice/create_edit_response.dart';
import 'package:voiceclub_partner/data/models/cleanvoice/upload_response.dart';
import 'package:voiceclub_partner/data/models/cleanvoice/edit_response.dart';
import 'package:voiceclub_partner/domain/repository/cleanvoice_repository.dart';

class CleanVoiceRepositoryImpl implements CleanVoiceRepository {
  final CleanVoiceApiService _cleanVoiceApiService;

  CleanVoiceRepositoryImpl(this._cleanVoiceApiService);

  @override
  Future<DataState<CleanVoiceUploadResponseModel>> getSignedUrl({
    required String filename,
  }) async {
    try {
      final response = await _cleanVoiceApiService.getSignedUrl(
        filename: filename,
      );

      return toDataState(response);
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<void>> uploadFileToSignedUrl({
    required String signedUrl,
    required File audioFile,
  }) async {
    try {
      final fileBytes = await audioFile.readAsBytes();

      // Create a new Dio instance for uploading to the signed URL
      final uploadDio = Dio();

      final response = await uploadDio.put(
        signedUrl,
        data: fileBytes,
        options: Options(
          headers: {
            'Content-Type': 'audio/mp4', // Adjust based on file type
          },
        ),
      );

      if (response.statusCode == 200) {
        return const DataSuccess(null);
      } else {
        return DataFailed(
          DioException(
            error: response.statusCode,
            message: response.statusMessage,
            response: response,
            requestOptions: response.requestOptions,
          ),
        );
      }
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<CreateEditResponse>> createEdit({
    required String fileUrl,
    Map<String, dynamic>? config,
  }) async {
    try {
      final body = {
        'input': {
          'files': [fileUrl],
          'config':
              config ??
              {
                'filler_sound': true,
                'stuttering': true,
                'breath': true,
                'mouth_sound': true,
                'dead_air': true,
                'normalize': true,
                'remove_noise': true,
                'export_format': 'mp3',
              },
        },
      };

      final response = await _cleanVoiceApiService.createEdit(body: body);

      return toDataState(response);
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<CleanVoiceEditResponseModel>> getEditStatus({
    required String editId,
  }) async {
    try {
      final response = await _cleanVoiceApiService.getEditStatus(
        editId: editId,
      );

      return toDataState(response);
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<void>> deleteEdit({required String editId}) async {
    try {
      final response = await _cleanVoiceApiService.deleteEdit(editId: editId);

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
}
