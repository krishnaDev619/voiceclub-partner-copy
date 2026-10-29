import 'package:dio/dio.dart';
import 'package:voiceclub_partner/core/resources/data_state.dart';

import '../../domain/repository/notifications_repository.dart';
import '../data_sources/remote/notifications/notifications_api_service.dart';

class NotificationsRepositoryImpl implements NotificationsRepository {
  final NotificationsApiService _notificationsApiService;
  NotificationsRepositoryImpl(this._notificationsApiService);

  @override
  Future<DataState<void>> addNotification({
    required int uid,
    required bool isAudio,
    required String audioUrl,
  }) async {
    try {
      final response = await _notificationsApiService.addNotification(
        uid: uid,
        isAudio: isAudio,
        audioUrl: audioUrl,
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
  Future<DataState<void>> testNotification() async {
    try {
      final response = await _notificationsApiService.testNotification();

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
