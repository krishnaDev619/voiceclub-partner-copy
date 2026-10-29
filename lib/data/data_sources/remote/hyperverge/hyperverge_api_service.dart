import 'package:dio/dio.dart' hide Headers;
import 'package:retrofit/retrofit.dart';
import 'package:voiceclub_partner/core/constants/api_constants.dart';
import 'package:voiceclub_partner/data/models/hyperverge/hyperverge_output_api_response.dart';
import 'package:voiceclub_partner/data/models/hyperverge/hyperverge_esign_output.dart';

part 'hyperverge_api_service.g.dart';

@RestApi()
abstract class HypervergeApiService {
  factory HypervergeApiService(Dio dio) = _HypervergeApiService;

  @POST(APIConstants.getKYCOutputRoute)
  Future<HttpResponse<HypervergeOutputAPIResponseModel>> getKYCOutput({
    @Field('transaction_id') required String transactionId,
  });

  @POST(APIConstants.getKYCOutputRoute)
  Future<HttpResponse<HypervergeEsignOutputResponse>> getESignOutput({
    @Field('transaction_id') required String transactionId,
  });
}
