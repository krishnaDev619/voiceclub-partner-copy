import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/data/models/hyperverge/get_kyc_transaction_id_response.dart';

abstract class KycTransactionRepository {
  Future<DataState<GetKycTransactionIdResponseModel>> getKycTransactionId({
    required String type,
  });

  Future<DataState<void>> markKYCFailed({required String transactionId});
}
