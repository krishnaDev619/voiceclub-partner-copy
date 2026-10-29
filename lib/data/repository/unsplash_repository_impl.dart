import 'package:dio/dio.dart';
import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/data/data_sources/remote/unsplash/unsplash_api_service.dart';
import 'package:voiceclub_partner/data/models/unsplash/search_photos_response.dart';
import 'package:voiceclub_partner/domain/repository/unsplash_repository.dart';

class UnsplashRepositoryImpl implements UnsplashRepository {
  final UnsplashApiService _unsplashApiService;

  UnsplashRepositoryImpl(this._unsplashApiService);

  @override
  Future<DataState<SearchPhotosResponseModel>> searchPhotos({
    required String query,
    required int page,
    required int perPage,
  }) async {
    try {
      final response = await _unsplashApiService.searchPhotos(
        query: query,
        page: page,
        perPage: perPage,
      );
      return DataSuccess(response.data);
    } on DioException catch (e) {
      return DataFailed(e);
    } catch (e) {
      return DataFailed(
        DioException(
          requestOptions: RequestOptions(path: ''),
          error: e.toString(),
        ),
      );
    }
  }
}
