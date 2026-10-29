import 'package:equatable/equatable.dart';
import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/data/models/social/list_posts_response.dart';
import 'package:voiceclub_partner/domain/repository/social_repository.dart';

class ListMyPostsUsecase
    implements UseCase<DataState<ListPostsResponseModel>, ListMyPostsParams> {
  final SocialRepository _socialRepository;

  ListMyPostsUsecase(this._socialRepository);

  @override
  Future<DataState<ListPostsResponseModel>> call(
    ListMyPostsParams params,
  ) async {
    return _socialRepository.listMyPosts(
      page: params.page,
      pageSize: params.pageSize,
    );
  }
}

class ListMyPostsParams extends Equatable {
  final int page;
  final int pageSize;

  const ListMyPostsParams({required this.page, required this.pageSize});

  @override
  List<Object> get props => [page, pageSize];
}
