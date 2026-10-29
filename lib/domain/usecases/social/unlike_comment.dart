import 'package:equatable/equatable.dart';
import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/domain/repository/social_repository.dart';

class UnlikeCommentUsecase
    implements UseCase<DataState<void>, UnlikeCommentParams> {
  final SocialRepository _socialRepository;

  UnlikeCommentUsecase(this._socialRepository);

  @override
  Future<DataState<void>> call(UnlikeCommentParams params) async {
    return _socialRepository.unlikeComment(
      postId: params.postId,
      commentId: params.commentId,
    );
  }
}

class UnlikeCommentParams extends Equatable {
  final String postId;
  final String commentId;

  const UnlikeCommentParams({required this.postId, required this.commentId});

  @override
  List<Object> get props => [postId, commentId];
}
