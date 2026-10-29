import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:voiceclub_partner/core/constants/api_constants.dart';
import 'package:voiceclub_partner/data/models/cleanvoice/create_edit_response.dart';
import 'package:voiceclub_partner/data/models/cleanvoice/upload_response.dart';
import 'package:voiceclub_partner/data/models/cleanvoice/edit_response.dart';

part 'cleanvoice_api_service.g.dart';

@RestApi()
abstract class CleanVoiceApiService {
  factory CleanVoiceApiService(Dio dio) = _CleanVoiceApiService;

  @POST(APIConstants.cleanVoiceUploadRoute)
  Future<HttpResponse<CleanVoiceUploadResponseModel>> getSignedUrl({
    @Query('filename') required String filename,
  });

  @POST(APIConstants.cleanVoiceEditsRoute)
  Future<HttpResponse<CreateEditResponse>> createEdit({
    @Body() required Map<String, dynamic> body,
  });

  @GET(APIConstants.cleanVoiceEditsByIdRoute)
  Future<HttpResponse<CleanVoiceEditResponseModel>> getEditStatus({
    @Path('id') required String editId,
  });

  @DELETE(APIConstants.cleanVoiceEditsByIdRoute)
  Future<HttpResponse<void>> deleteEdit({@Path('id') required String editId});
}
