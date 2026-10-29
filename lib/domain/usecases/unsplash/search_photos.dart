import 'package:equatable/equatable.dart';
import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/data/models/unsplash/search_photos_response.dart';
import 'package:voiceclub_partner/domain/repository/unsplash_repository.dart';

class SearchPhotosUsecase
    implements
        UseCase<DataState<SearchPhotosResponseModel>, SearchPhotosParams> {
  final UnsplashRepository _unsplashRepository;
  SearchPhotosUsecase(this._unsplashRepository);

  @override
  Future<DataState<SearchPhotosResponseModel>> call(SearchPhotosParams params) {
    return _unsplashRepository.searchPhotos(
      page: params.page,
      perPage: params.perPage,
      query: params.query,
    );
  }
}

class SearchPhotosParams extends Equatable {
  final int page, perPage;
  final String query;
  const SearchPhotosParams({
    required this.page,
    required this.perPage,
    required this.query,
  });

  @override
  List<Object> get props => [page, perPage, query];
}
