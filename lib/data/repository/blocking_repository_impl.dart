import 'package:dio/dio.dart';
import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/http_response_handler.dart';
import 'package:voiceclub_partner/data/data_sources/remote/blocking/blocking_api_service.dart';
import 'package:voiceclub_partner/data/models/blocking/get_blocked_users_response.dart';
import 'package:voiceclub_partner/domain/repository/blocking_repository.dart';

class BlockingRepositoryImpl implements BlockingRepository {
  final BlockingApiService _blockingApiService;
  BlockingRepositoryImpl(this._blockingApiService);

  @override
  Future<DataState<void>> blockUser(int accountId, String reason) async {
    try {
      final response = await _blockingApiService.blockUser(accountId, reason);

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
  Future<DataState<GetBlockedUsersResponseModel>> getBlockedUsers(
    int page,
    int pageSize,
  ) async {
    try {
      final response = await _blockingApiService.getBlockedUsers(
        page,
        pageSize,
      );

      return toDataState(response);
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<void>> reportUser(int accountId, String reason) async {
    try {
      final response = await _blockingApiService.reportUser(accountId, reason);

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
