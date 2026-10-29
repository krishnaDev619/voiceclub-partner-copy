import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/data/models/rating/get_all_ratings_response.dart';

abstract class RatingRepository {
  // API methods
  Future<DataState<GetAllRatingsResponseModel>> getAllRatings();
  Future<DataState<void>> addRating(int accountId, int rating);
}
