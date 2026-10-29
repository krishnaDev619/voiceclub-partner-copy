import 'dart:io';

import 'package:dio/dio.dart';
import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/features/onboarding/data/data_sources/liveness/liveness_api_service.dart';
import 'package:voiceclub_partner/features/onboarding/data/models/liveness/check_liveness_hyperverge_response.dart';
import 'package:voiceclub_partner/features/onboarding/data/models/liveness/check_liveness_idto_response.dart';
import 'package:voiceclub_partner/features/onboarding/domain/repository/liveness_repository.dart';

class LivenessRepositoryImpl extends LivenessRepository {
  final LivenessApiService _livenessApiService;

  LivenessRepositoryImpl(this._livenessApiService);

  @override
  Future<DataState<CheckLivenessHypervergeResponse>> checkLivenessHyperverge({
    required File image,
  }) async {
    try {
      final response = await _livenessApiService.checkLivenessHyperverge(
        image: image,
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

  @override
  Future<DataState<CheckLivenessIdtoResponse>> checkLivenessIdto({
    required String imageBase64,
  }) async {
    try {
      final response = await _livenessApiService.checkLivenessIdto(
        imageBase64: imageBase64,
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
