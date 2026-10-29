import 'package:dio/dio.dart';
import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/http_response_handler.dart';
import 'package:voiceclub_partner/data/data_sources/remote/call_logs/call_logs_api_service.dart';
import 'package:voiceclub_partner/data/models/call_logs/fetch_call_logs_for_pair_response.dart';
import 'package:voiceclub_partner/data/models/file/upload_file_response.dart';
import 'package:voiceclub_partner/domain/repository/call_logs_repository.dart';

class CallLogsRepositoryImpl implements CallLogsRepository {
  final CallLogsApiService _callLogsApiService;
  CallLogsRepositoryImpl(this._callLogsApiService);

  @override
  Future<DataState<FetchCallLogsForPairResponseModel>> fetchCallLogsForPair({
    required int userId,
    required int page,
    required int pageSize,
  }) async {
    try {
      final response = await _callLogsApiService.fetchCallLogsForPair(
        userId: userId,
        page: page,
        pageSize: pageSize,
      );

      return toDataState(response);
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<FileResponseModel>> fetchLogRecordingUrl({
    required String filename,
  }) async {
    try {
      final response = await _callLogsApiService.fetchLogRecordingUrl(
        filename: filename,
      );

      return toDataState(response);
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }
}
