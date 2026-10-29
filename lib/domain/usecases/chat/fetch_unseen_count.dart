import 'package:equatable/equatable.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/data/models/chat/fetch_unseen_count_response.dart';
import 'package:voiceclub_partner/domain/repository/chat_repository.dart';

class FetchUnseenCountUsecase
    implements
        UseCase<
          DataState<FetchUnseenCountResponseModel>,
          FetchUnseenCountParams
        > {
  final ChatRepository _chatRepository;

  FetchUnseenCountUsecase(this._chatRepository);

  @override
  Future<DataState<FetchUnseenCountResponseModel>> call(
    FetchUnseenCountParams params,
  ) {
    return _chatRepository.fetchUnseenCount(category: params.categoryCode.name);
  }
}

class FetchUnseenCountParams extends Equatable {
  final CategoryCode categoryCode;

  const FetchUnseenCountParams({required this.categoryCode});

  @override
  List<Object> get props => [categoryCode];
}
