import 'package:equatable/equatable.dart';
import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/domain/repository/social_repository.dart';

class UnlikePostUsecase implements UseCase<DataState<void>, UnlikePostParams> {
  final SocialRepository _socialRepository;

  UnlikePostUsecase(this._socialRepository);

  @override
  Future<DataState<void>> call(UnlikePostParams params) async {
    return _socialRepository.unlikePost(postId: params.postId);
  }
}

class UnlikePostParams extends Equatable {
  final String postId;

  const UnlikePostParams({required this.postId});

  @override
  List<Object> get props => [postId];
}
