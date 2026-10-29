import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/data/models/rating/get_all_ratings_response.dart';
import 'package:voiceclub_partner/domain/repository/rating_repository.dart';

class GetAllRatingsUsecase
    implements UseCase<DataState<GetAllRatingsResponseModel>, NoParams> {
  final RatingRepository _ratingRepository;

  GetAllRatingsUsecase(this._ratingRepository);

  @override
  Future<DataState<GetAllRatingsResponseModel>> call(NoParams params) {
    return _ratingRepository.getAllRatings();
  }
}
