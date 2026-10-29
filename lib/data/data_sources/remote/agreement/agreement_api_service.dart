import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:voiceclub_partner/core/constants/api_constants.dart';
import 'package:voiceclub_partner/data/models/kyc_file/get_file_url.dart';

part 'agreement_api_service.g.dart';

@RestApi()
abstract class AgreementApiService {
  factory AgreementApiService(Dio dio) = _AgreementApiService;

  @PUT(APIConstants.updateSignDocumentRoute)
  Future<HttpResponse> updateSignDocument({
    @Field('document_path') required String documentPath,
    @Field('phone_number') required String phoneNumber,
  });

  @GET(APIConstants.getKycFileUrlRoute)
  Future<HttpResponse<GetFileUrlResponseModel>> getFileUrl({
    @Path('filename') required String fileName,
  });
}
