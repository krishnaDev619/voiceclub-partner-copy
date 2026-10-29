import 'package:equatable/equatable.dart';
import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/domain/repository/social_repository.dart';

class UnlikeReplyUsecase
    implements UseCase<DataState<void>, UnlikeReplyParams> {
  final SocialRepository _socialRepository;

  UnlikeReplyUsecase(this._socialRepository);

  @override
  Future<DataState<void>> call(UnlikeReplyParams params) async {
    return _socialRepository.unlikeReply(
      postId: params.postId,
      commentId: params.commentId,
      replyId: params.replyId,
    );
  }
}

class UnlikeReplyParams extends Equatable {
  final String postId;
  final String commentId;
  final String replyId;

  const UnlikeReplyParams({
    required this.postId,
    required this.commentId,
    required this.replyId,
  });

  @override
  List<Object> get props => [postId, commentId, replyId];
}
