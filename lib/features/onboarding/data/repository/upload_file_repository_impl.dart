import 'dart:io';

import 'package:dio/dio.dart';
import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/features/onboarding/data/data_sources/upload_file/upload_file_api_service.dart';
import 'package:voiceclub_partner/features/onboarding/data/models/verify_gender/upload_file_response_model.dart';
import 'package:voiceclub_partner/features/onboarding/domain/repository/upload_file_repository.dart';

class UploadFileRepositoryImpl implements UploadFileRepository {
  final UploadFileApiService _uploadFileApiService;

  UploadFileRepositoryImpl(this._uploadFileApiService);

  @override
  Future<DataState<UploadFileResponseModel>> uploadOnboardingFile({
    required String extension,
    required File file,
  }) async {
    try {
      final response = await _uploadFileApiService.uploadOnboardingFile(
        extension: extension,
        file: file,
      );

      if (response.response.statusCode == 200) {
        return DataSuccess(response.data);
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
