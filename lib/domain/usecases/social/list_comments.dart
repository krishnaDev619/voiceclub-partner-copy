import 'package:equatable/equatable.dart';
import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/data/models/social/list_comments_response.dart';
import 'package:voiceclub_partner/domain/repository/social_repository.dart';

class ListCommentsUsecase
    implements
        UseCase<DataState<ListCommentsResponseModel>, ListCommentsParams> {
  final SocialRepository _socialRepository;

  ListCommentsUsecase(this._socialRepository);

  @override
  Future<DataState<ListCommentsResponseModel>> call(
    ListCommentsParams params,
  ) async {
    return _socialRepository.listComments(
      postId: params.postId,
      page: params.page,
      pageSize: params.pageSize,
    );
  }
}

class ListCommentsParams extends Equatable {
  final String postId;
  final int page;
  final int pageSize;

  const ListCommentsParams({
    required this.postId,
    required this.page,
    required this.pageSize,
  });

  @override
  List<Object> get props => [postId, page, pageSize];
}
