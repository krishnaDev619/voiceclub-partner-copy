import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:voiceclub_partner/core/constants/api_constants.dart';
import 'package:voiceclub_partner/data/models/unsplash/search_photos_response.dart';

part 'unsplash_api_service.g.dart';

@RestApi()
abstract class UnsplashApiService {
  factory UnsplashApiService(Dio dio) = _UnsplashApiService;

  @GET(APIConstants.unsplashSearchPhotosRoute)
  Future<HttpResponse<SearchPhotosResponseModel>> searchPhotos({
    @Query('page') required int page,
    @Query('per_page') required int perPage,
    @Query('query') required String query,
  });
}
