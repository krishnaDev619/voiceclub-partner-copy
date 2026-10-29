import 'package:equatable/equatable.dart';
import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/data/models/social/list_posts_response.dart';
import 'package:voiceclub_partner/domain/repository/social_repository.dart';

class ListMyUserPostsUsecase
    implements
        UseCase<DataState<ListPostsResponseModel>, ListMyUserPostsParams> {
  final SocialRepository _socialRepository;

  ListMyUserPostsUsecase(this._socialRepository);

  @override
  Future<DataState<ListPostsResponseModel>> call(
    ListMyUserPostsParams params,
  ) async {
    return _socialRepository.listMyUserPosts(
      page: params.page,
      pageSize: params.pageSize,
    );
  }
}

class ListMyUserPostsParams extends Equatable {
  final int page;
  final int pageSize;

  const ListMyUserPostsParams({required this.page, required this.pageSize});

  @override
  List<Object> get props => [page, pageSize];
}
