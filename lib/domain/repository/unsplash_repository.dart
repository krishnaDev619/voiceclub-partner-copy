import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/data/models/unsplash/search_photos_response.dart';

abstract class UnsplashRepository {
  Future<DataState<SearchPhotosResponseModel>> searchPhotos({
    required int page,
    required int perPage,
    required String query,
  });
}
