import 'package:equatable/equatable.dart';
import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/data/models/social/list_posts_response.dart';
import 'package:voiceclub_partner/domain/repository/social_repository.dart';

class ListPostsUsecase
    implements UseCase<DataState<ListPostsResponseModel>, ListPostsParams> {
  final SocialRepository _socialRepository;

  ListPostsUsecase(this._socialRepository);

  @override
  Future<DataState<ListPostsResponseModel>> call(ListPostsParams params) async {
    return _socialRepository.listPosts(
      page: params.page,
      pageSize: params.pageSize,
    );
  }
}

class ListPostsParams extends Equatable {
  final int page;
  final int pageSize;

  const ListPostsParams({required this.page, required this.pageSize});

  @override
  List<Object> get props => [page, pageSize];
}
