import 'package:equatable/equatable.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/data/models/chat/chat_group.dart';
import 'package:voiceclub_partner/domain/repository/chat_repository.dart';

class SaveChatGroupsToDatabaseUsecase
    implements UseCase<void, SaveChatGroupsToDatabaseParams> {
  final ChatRepository _chatRepository;

  SaveChatGroupsToDatabaseUsecase(this._chatRepository);

  @override
  Future<void> call(SaveChatGroupsToDatabaseParams params) async {
    return _chatRepository.saveChatGroupsToDatabase(
      chatGroups: params.chatGroups,
      filter: params.filter,
    );
  }
}

class SaveChatGroupsToDatabaseParams extends Equatable {
  final List<ChatGroup> chatGroups;
  final ChatTabFilter filter;

  const SaveChatGroupsToDatabaseParams({
    required this.chatGroups,
    required this.filter,
  });

  @override
  List<Object> get props => [chatGroups, filter];
}
