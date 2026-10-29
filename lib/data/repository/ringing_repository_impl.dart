import 'dart:async';

import 'package:dio/dio.dart';
import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/data/data_sources/remote/ringing/ringing_api_service.dart';
import 'package:voiceclub_partner/domain/repository/ringing_repository.dart';

class RingingRepositoryImpl implements RingingRepository {
  final RingingApiService _ringingApiService;

  RingingRepositoryImpl(this._ringingApiService);

  @override
  Future<DataState<void>> setRing({required String channelId}) async {
    try {
      final response = await _ringingApiService.setRing(
        channelId: channelId,
        isNotification: true,
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
}
