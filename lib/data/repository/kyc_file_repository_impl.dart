import 'dart:io';

import 'package:dio/dio.dart';
import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/http_response_handler.dart';
import 'package:voiceclub_partner/data/data_sources/remote/kyc_file/kyc_file_api_service.dart';
import 'package:voiceclub_partner/data/models/kyc_file/upload_kyc_file_response.dart';
import 'package:voiceclub_partner/domain/repository/kyc_file_repository.dart';

class KYCFileRepositoryImpl implements KYCFileRepository {
  final KYCFileApiService _kycFileApiService;

  KYCFileRepositoryImpl(this._kycFileApiService);

  @override
  Future<DataState<UploadKYCFileResponseModel>> uploadKYCFile({
    required File file,
    required String extension,
  }) async {
    try {
      final response = await _kycFileApiService.uploadKYCFile(
        file: file,
        extension: extension,
      );

      return toDataState(response);
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }
}
