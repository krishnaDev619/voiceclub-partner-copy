import 'package:equatable/equatable.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/domain/repository/chat_repository.dart';

class DeleteChatGroupsFromDatabaseUsecase
    implements UseCase<void, DeleteChatGroupsFromDatabaseParams> {
  final ChatRepository _chatRepository;

  DeleteChatGroupsFromDatabaseUsecase(this._chatRepository);

  @override
  Future<void> call(DeleteChatGroupsFromDatabaseParams params) async {
    return _chatRepository.deleteChatGroupsFromDatabase(filter: params.filter);
  }
}

class DeleteChatGroupsFromDatabaseParams extends Equatable {
  final ChatTabFilter filter;

  const DeleteChatGroupsFromDatabaseParams({required this.filter});

  @override
  List<Object> get props => [filter];
}
