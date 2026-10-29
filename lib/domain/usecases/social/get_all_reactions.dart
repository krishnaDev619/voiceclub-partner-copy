import 'package:equatable/equatable.dart';
import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/data/models/social/get_all_reactions.dart';
import 'package:voiceclub_partner/domain/repository/social_repository.dart';

class GetAllReactionsUsecase
    implements
        UseCase<DataState<GetAllReactionsResponse>, GetAllReactionsParams> {
  final SocialRepository _socialRepository;

  GetAllReactionsUsecase(this._socialRepository);

  @override
  Future<DataState<GetAllReactionsResponse>> call(
    GetAllReactionsParams params,
  ) async {
    return _socialRepository.getAllReactions(
      postId: params.postId,
      reaction: params.reaction,
    );
  }
}

class GetAllReactionsParams extends Equatable {
  final String postId;
  final String reaction;

  const GetAllReactionsParams({required this.postId, required this.reaction});

  @override
  List<Object> get props => [postId, reaction];
}
