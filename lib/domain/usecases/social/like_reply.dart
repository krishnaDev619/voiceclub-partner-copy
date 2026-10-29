import 'package:equatable/equatable.dart';
import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/domain/repository/social_repository.dart';

class LikeReplyUsecase implements UseCase<DataState<void>, LikeReplyParams> {
  final SocialRepository _socialRepository;

  LikeReplyUsecase(this._socialRepository);

  @override
  Future<DataState<void>> call(LikeReplyParams params) async {
    return _socialRepository.likeReply(
      postId: params.postId,
      commentId: params.commentId,
      replyId: params.replyId,
    );
  }
}

class LikeReplyParams extends Equatable {
  final String postId;
  final String commentId;
  final String replyId;

  const LikeReplyParams({
    required this.postId,
    required this.commentId,
    required this.replyId,
  });

  @override
  List<Object> get props => [postId, commentId, replyId];
}
