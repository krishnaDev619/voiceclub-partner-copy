import 'package:equatable/equatable.dart';
import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/domain/repository/rating_repository.dart';

class AddRatingUsecase implements UseCase<DataState<void>, Params> {
  final RatingRepository _ratingRepository;
  AddRatingUsecase(this._ratingRepository);

  @override
  Future<DataState<void>> call(Params params) {
    return _ratingRepository.addRating(params.accountId, params.rating);
  }
}

class Params extends Equatable {
  final int accountId, rating;
  const Params({required this.accountId, required this.rating});

  @override
  List<Object> get props => [accountId, rating];
}
