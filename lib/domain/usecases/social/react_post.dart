import 'package:equatable/equatable.dart';
import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/domain/repository/social_repository.dart';

class ReactPostUsecase implements UseCase<DataState<void>, ReactPostParams> {
  final SocialRepository _socialRepository;

  ReactPostUsecase(this._socialRepository);

  @override
  Future<DataState<void>> call(ReactPostParams params) async {
    return _socialRepository.reactPost(
      postId: params.postId,
      reactionType: params.reactionType,
    );
  }
}

class ReactPostParams extends Equatable {
  final String postId;
  final String reactionType;

  const ReactPostParams({required this.postId, required this.reactionType});

  @override
  List<Object> get props => [postId, reactionType];
}
