import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/data/models/query/get_unseen_kam_query_chat_message_count_response.dart';
import 'package:voiceclub_partner/domain/repository/query_repository.dart';

class GetUnseenKamQueryChatMessageCountUseCase
    implements
        UseCase<
          DataState<GetUnseenKamQueryChatMessageCountResponse>,
          NoParams
        > {
  final QueryRepository _queryRepository;

  GetUnseenKamQueryChatMessageCountUseCase(this._queryRepository);

  @override
  Future<DataState<GetUnseenKamQueryChatMessageCountResponse>> call(
    NoParams params,
  ) async {
    return _queryRepository.getUnseenKamQueryChatMessageCount();
  }
}
