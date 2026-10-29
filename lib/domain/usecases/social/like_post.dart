import 'package:equatable/equatable.dart';
import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/domain/repository/social_repository.dart';

class LikePostUsecase implements UseCase<DataState<void>, LikePostParams> {
  final SocialRepository _socialRepository;

  LikePostUsecase(this._socialRepository);

  @override
  Future<DataState<void>> call(LikePostParams params) async {
    return _socialRepository.likePost(postId: params.postId);
  }
}

class LikePostParams extends Equatable {
  final String postId;

  const LikePostParams({required this.postId});

  @override
  List<Object> get props => [postId];
}
