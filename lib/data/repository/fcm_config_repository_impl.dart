import 'package:dio/dio.dart';
import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/domain/repository/fcm_config_repository.dart';

import '../data_sources/remote/fcm/fcm_config_api_service.dart';

class FCMConfigRepositoryImpl implements FCMConfigRepository {
  final FCMConfigApiService _fcmConfigApiService;
  FCMConfigRepositoryImpl(this._fcmConfigApiService);

  @override
  Future<DataState<void>> updateSupplyFCM({
    required String token,
    String? version,
    int? buildNumber,
  }) async {
    try {
      final response = await _fcmConfigApiService.updateSupplyFCM(
        token: token,
        version: version,
        buildNumber: buildNumber,
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
