import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:voiceclub_partner/core/constants/api_constants.dart';
import 'package:voiceclub_partner/data/models/localization/ui_language.dart';

part 'ui_language_api_service.g.dart';

@RestApi()
abstract class UiLanguageApiService {
  factory UiLanguageApiService(Dio dio) = _UiLanguageApiService;

  @GET(APIConstants.getUiLanguagesRoute)
  Future<HttpResponse<UiLanguagesResponse>> getLanguages({
    @Query('category') String? category,
    @Query('role') String? role,
  });
}
