import 'package:dio/dio.dart';
import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/http_response_handler.dart';
import 'package:voiceclub_partner/data/data_sources/remote/kyc_transaction/kyc_transaction_api_service.dart';
import 'package:voiceclub_partner/data/models/hyperverge/get_kyc_transaction_id_response.dart';
import 'package:voiceclub_partner/domain/repository/kyc_transaction_repository.dart';

class KycTransactionRepositoryImpl extends KycTransactionRepository {
  final KycTransactionApiService _transactionApiService;
  KycTransactionRepositoryImpl(this._transactionApiService);

  @override
  Future<DataState<void>> markKYCFailed({required String transactionId}) async {
    try {
      final response = await _transactionApiService.markKYCFailed(
        transactionId: transactionId,
      );
      return toDataState(response);
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<GetKycTransactionIdResponseModel>> getKycTransactionId({
    required String type,
  }) async {
    try {
      final response = await _transactionApiService.getKycTransactionId(
        type: type,
      );
      return toDataState(response);
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }
}
