import 'package:equatable/equatable.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/data/models/chat/chat_group.dart';
import 'package:voiceclub_partner/domain/repository/chat_repository.dart';

class GetChatGroupsFromDatabaseUsecase
    implements UseCase<List<ChatGroup>, GetChatGroupsFromDatabaseParams> {
  final ChatRepository _chatRepository;

  GetChatGroupsFromDatabaseUsecase(this._chatRepository);

  @override
  Future<List<ChatGroup>> call(GetChatGroupsFromDatabaseParams params) async {
    return _chatRepository.getChatGroupsFromDatabase(filter: params.filter);
  }
}

class GetChatGroupsFromDatabaseParams extends Equatable {
  final ChatTabFilter filter;

  const GetChatGroupsFromDatabaseParams({required this.filter});

  @override
  List<Object> get props => [filter];
}
