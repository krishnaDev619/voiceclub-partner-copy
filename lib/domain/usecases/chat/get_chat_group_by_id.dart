import 'package:equatable/equatable.dart';
import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/data/models/chat/chat_group.dart';
import 'package:voiceclub_partner/domain/repository/chat_repository.dart';

class GetChatGroupByIdUsecase implements UseCase<DataState<ChatGroup>, Params> {
  final ChatRepository _chatRepository;

  GetChatGroupByIdUsecase(this._chatRepository);

  @override
  Future<DataState<ChatGroup>> call(Params params) {
    return _chatRepository.getChatGroupById(groupId: params.groupId);
  }
}

class Params extends Equatable {
  final int groupId;

  const Params({required this.groupId});

  @override
  List<Object> get props => [groupId];
}
