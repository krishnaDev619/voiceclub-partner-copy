import 'package:equatable/equatable.dart';
import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/domain/repository/social_repository.dart';

class CreateCommentUsecase
    implements UseCase<DataState<void>, CreateCommentParams> {
  final SocialRepository _socialRepository;

  CreateCommentUsecase(this._socialRepository);

  @override
  Future<DataState<void>> call(CreateCommentParams params) async {
    String attachmentUrl = params.mediaUrl;
    return _socialRepository.createComment(
      postId: params.postId,
      commentType: params.commentType,
      textContent: params.textContent,
      mediaUrl: attachmentUrl,
    );
  }
}

class CreateCommentParams extends Equatable {
  final String postId;
  final String commentType;
  final String textContent;
  final String mediaUrl;

  const CreateCommentParams({
    required this.postId,
    required this.commentType,
    required this.textContent,
    required this.mediaUrl,
  });

  @override
  List<Object> get props => [postId, commentType, textContent, mediaUrl];
}
