import 'package:dio/dio.dart' hide Headers;
import 'package:retrofit/retrofit.dart';
import 'package:voiceclub_partner/core/constants/api_constants.dart';
import 'package:voiceclub_partner/data/models/hyperverge/get_kyc_transaction_id_response.dart';

part 'kyc_transaction_api_service.g.dart';

@RestApi()
abstract class KycTransactionApiService {
  factory KycTransactionApiService(Dio dio) = _KycTransactionApiService;

  @POST(APIConstants.getKycTransactionIdRoute)
  Future<HttpResponse<GetKycTransactionIdResponseModel>> getKycTransactionId({
    @Field('type') required String type,
  });

  @PUT(APIConstants.markKYCFailedRoute)
  Future<HttpResponse<void>> markKYCFailed({
    @Path('transaction_id') required String transactionId,
  });
}
