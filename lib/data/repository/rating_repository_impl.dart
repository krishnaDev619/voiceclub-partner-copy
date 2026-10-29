import 'package:dio/dio.dart';
import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/http_response_handler.dart';
import 'package:voiceclub_partner/data/data_sources/remote/rating/rating_api_service.dart';
import 'package:voiceclub_partner/data/models/rating/get_all_ratings_response.dart';
import 'package:voiceclub_partner/domain/repository/rating_repository.dart';

class RatingRepositoryImpl implements RatingRepository {
  final RatingApiService _ratingApiService;
  RatingRepositoryImpl(this._ratingApiService);

  @override
  Future<DataState<GetAllRatingsResponseModel>> getAllRatings() async {
    try {
      final response = await _ratingApiService.getAllRatings();

      return toDataState(response);
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<void>> addRating(int accountId, int rating) async {
    try {
      final response = await _ratingApiService.addRating(accountId, rating);

      if (response.response.statusCode == 200) {
        return const DataSuccess(null);
      } else {
        return DataFailed(
          DioException(
            error: response.response.statusCode,
            message: response.response.statusMessage,
            response: response.response,
            requestOptions: response.response.requestOptions,
          ),
        );
      }
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }
}
