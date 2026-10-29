import 'package:equatable/equatable.dart';
import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/domain/repository/social_repository.dart';

class DeleteCommentUsecase
    implements UseCase<DataState<void>, DeleteCommentParams> {
  final SocialRepository _socialRepository;

  DeleteCommentUsecase(this._socialRepository);

  @override
  Future<DataState<void>> call(DeleteCommentParams params) async {
    return _socialRepository.deleteComment(
      postId: params.postId,
      commentId: params.commentId,
    );
  }
}

class DeleteCommentParams extends Equatable {
  final String postId;
  final String commentId;

  const DeleteCommentParams({required this.postId, required this.commentId});

  @override
  List<Object> get props => [postId, commentId];
}
