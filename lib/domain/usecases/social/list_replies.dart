import 'package:equatable/equatable.dart';
import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/data/models/social/list_replies_response.dart';
import 'package:voiceclub_partner/domain/repository/social_repository.dart';

class ListRepliesUsecase
    implements UseCase<DataState<ListRepliesResponseModel>, ListRepliesParams> {
  final SocialRepository _socialRepository;

  ListRepliesUsecase(this._socialRepository);

  @override
  Future<DataState<ListRepliesResponseModel>> call(
    ListRepliesParams params,
  ) async {
    return _socialRepository.listReplies(
      postId: params.postId,
      commentId: params.commentId,
      page: params.page,
      pageSize: params.pageSize,
    );
  }
}

class ListRepliesParams extends Equatable {
  final String postId;
  final String commentId;
  final int page;
  final int pageSize;

  const ListRepliesParams({
    required this.postId,
    required this.commentId,
    required this.page,
    required this.pageSize,
  });

  @override
  List<Object> get props => [postId, commentId, page, pageSize];
}
