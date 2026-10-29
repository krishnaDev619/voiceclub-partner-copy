import 'package:equatable/equatable.dart';
import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/domain/repository/social_repository.dart';

class CreateReplyUsecase
    implements UseCase<DataState<void>, CreateReplyParams> {
  final SocialRepository _socialRepository;

  CreateReplyUsecase(this._socialRepository);

  @override
  Future<DataState<void>> call(CreateReplyParams params) async {
    return _socialRepository.createReply(
      postId: params.postId,
      commentId: params.commentId,
      textContent: params.textContent,
    );
  }
}

class CreateReplyParams extends Equatable {
  final String postId;
  final String commentId;
  final String textContent;

  const CreateReplyParams({
    required this.postId,
    required this.commentId,
    required this.textContent,
  });

  @override
  List<Object> get props => [postId, commentId, textContent];
}
