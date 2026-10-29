import 'package:equatable/equatable.dart';
import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/data/models/social/fetch_all_reactions_response.dart';
import 'package:voiceclub_partner/domain/repository/social_repository.dart';

class GetPostReactionsUsecase
    implements
        UseCase<
          DataState<GetAllPostReactionsResponseModel>,
          GetPostReactionsParams
        > {
  final SocialRepository _socialRepository;

  GetPostReactionsUsecase(this._socialRepository);

  @override
  Future<DataState<GetAllPostReactionsResponseModel>> call(
    GetPostReactionsParams params,
  ) async {
    return _socialRepository.getPostReactions(postId: params.postId);
  }
}

class GetPostReactionsParams extends Equatable {
  final String postId;

  const GetPostReactionsParams({required this.postId});

  @override
  List<Object> get props => [postId];
}
