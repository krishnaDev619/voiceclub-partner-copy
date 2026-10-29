import 'package:equatable/equatable.dart';
import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/data/models/chat/chat_group.dart';
import 'package:voiceclub_partner/domain/repository/chat_repository.dart';

class GetChatGroupByAccountIdUsecase
    implements UseCase<DataState<ChatGroup>, GetChatGroupByAccountIdParams> {
  final ChatRepository _chatRepository;

  GetChatGroupByAccountIdUsecase(this._chatRepository);

  @override
  Future<DataState<ChatGroup>> call(GetChatGroupByAccountIdParams params) {
    return _chatRepository.getChatGroupByAccountId(accountId: params.accountId);
  }
}

class GetChatGroupByAccountIdParams extends Equatable {
  final int accountId;

  const GetChatGroupByAccountIdParams({required this.accountId});

  @override
  List<Object> get props => [accountId];
}
