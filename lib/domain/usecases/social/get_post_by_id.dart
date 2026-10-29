import 'package:equatable/equatable.dart';
import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/data/models/social/get_post_by_id_response.dart';
import 'package:voiceclub_partner/domain/repository/social_repository.dart';

class GetPostByIdUsecase
    implements UseCase<DataState<GetPostByIdResponseModel>, GetPostParams> {
  final SocialRepository _socialRepository;

  GetPostByIdUsecase(this._socialRepository);

  @override
  Future<DataState<GetPostByIdResponseModel>> call(GetPostParams params) async {
    return _socialRepository.getPostById(postId: params.postId);
  }
}

class GetPostParams extends Equatable {
  final String postId;

  const GetPostParams({required this.postId});

  @override
  List<Object> get props => [postId];
}
