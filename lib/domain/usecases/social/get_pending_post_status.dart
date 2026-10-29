import 'package:equatable/equatable.dart';
import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/data/models/social/get_pending_post_status_response.dart';
import 'package:voiceclub_partner/domain/repository/social_repository.dart';

class GetPendingPostStatusUsecase
    implements
        UseCase<
          DataState<GetPendingPostStatusResponseModel>,
          GetPendingPostStatusParams
        > {
  final SocialRepository _socialRepository;

  GetPendingPostStatusUsecase(this._socialRepository);

  @override
  Future<DataState<GetPendingPostStatusResponseModel>> call(
    GetPendingPostStatusParams params,
  ) async {
    return _socialRepository.getPendingPostStatus(postId: params.postId);
  }
}

class GetPendingPostStatusParams extends Equatable {
  final String postId;

  const GetPendingPostStatusParams({required this.postId});

  @override
  List<Object> get props => [postId];
}
