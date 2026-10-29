import 'package:equatable/equatable.dart';
import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/domain/repository/social_repository.dart';

class UnReactPostUsecase
    implements UseCase<DataState<void>, UnReactPostParams> {
  final SocialRepository _socialRepository;

  UnReactPostUsecase(this._socialRepository);

  @override
  Future<DataState<void>> call(UnReactPostParams params) async {
    return _socialRepository.unReactPost(postId: params.postId);
  }
}

class UnReactPostParams extends Equatable {
  final String postId;

  const UnReactPostParams({required this.postId});

  @override
  List<Object> get props => [postId];
}
