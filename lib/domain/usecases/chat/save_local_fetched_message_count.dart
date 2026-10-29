import 'package:equatable/equatable.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/domain/repository/chat_repository.dart';

class SaveLocalFetchedMessageCountUsecase
    implements UseCase<void, SaveLocalFetchedMessageCountParams> {
  final ChatRepository _chatRepository;

  SaveLocalFetchedMessageCountUsecase(this._chatRepository);

  @override
  Future<void> call(SaveLocalFetchedMessageCountParams params) async {
    return _chatRepository.saveLocalFetchedMessageCount(
      chatGroupId: params.chatGroupId,
      count: params.count,
    );
  }
}

class SaveLocalFetchedMessageCountParams extends Equatable {
  final int chatGroupId;
  final int count;

  const SaveLocalFetchedMessageCountParams({
    required this.chatGroupId,
    required this.count,
  });

  @override
  List<Object> get props => [chatGroupId, count];
}
