import 'package:equatable/equatable.dart';
import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/domain/repository/social_repository.dart';

class LikeCommentUsecase
    implements UseCase<DataState<void>, LikeCommentParams> {
  final SocialRepository _socialRepository;

  LikeCommentUsecase(this._socialRepository);

  @override
  Future<DataState<void>> call(LikeCommentParams params) async {
    return _socialRepository.likeComment(
      postId: params.postId,
      commentId: params.commentId,
    );
  }
}

class LikeCommentParams extends Equatable {
  final String postId;
  final String commentId;

  const LikeCommentParams({required this.postId, required this.commentId});

  @override
  List<Object> get props => [postId, commentId];
}
