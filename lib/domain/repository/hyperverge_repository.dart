import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/data/models/hyperverge/hyperverge_esign_output.dart';
import 'package:voiceclub_partner/data/models/hyperverge/hyperverge_output_api_response.dart';

abstract class HypervergeRepository {
  Future<DataState<HypervergeOutputAPIResponseModel>> getKYCOutput({
    required String transactionId,
  });

  Future<DataState<HypervergeEsignOutputResponse>> getESignOutput({
    required String transactionId,
  });
}
