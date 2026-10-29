import 'package:dio/dio.dart';
import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/http_response_handler.dart';
import 'package:voiceclub_partner/data/data_sources/remote/hyperverge/hyperverge_api_service.dart';
import 'package:voiceclub_partner/data/models/hyperverge/hyperverge_esign_output.dart';
import 'package:voiceclub_partner/data/models/hyperverge/hyperverge_output_api_response.dart';
import 'package:voiceclub_partner/domain/repository/hyperverge_repository.dart';

class HypervergeRepositoryImpl extends HypervergeRepository {
  final HypervergeApiService _hypervergeApiService;

  HypervergeRepositoryImpl(this._hypervergeApiService);

  @override
  Future<DataState<HypervergeOutputAPIResponseModel>> getKYCOutput({
    required String transactionId,
  }) async {
    try {
      final response = await _hypervergeApiService.getKYCOutput(
        transactionId: transactionId,
      );
      return toDataState(response);
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<HypervergeEsignOutputResponse>> getESignOutput({
    required String transactionId,
  }) async {
    try {
      final response = await _hypervergeApiService.getESignOutput(
        transactionId: transactionId,
      );
      return toDataState(response);
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }
}
