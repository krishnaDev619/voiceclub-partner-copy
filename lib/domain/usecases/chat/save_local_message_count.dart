import 'package:equatable/equatable.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/domain/repository/chat_repository.dart';

class SaveLocalMessageCountUsecase
    implements UseCase<void, SaveLocalMessageCountParams> {
  final ChatRepository _chatRepository;

  SaveLocalMessageCountUsecase(this._chatRepository);

  @override
  Future<void> call(SaveLocalMessageCountParams params) async {
    return _chatRepository.saveLocalMessageCount(
      chatGroupId: params.chatGroupId,
      count: params.count,
    );
  }
}

class SaveLocalMessageCountParams extends Equatable {
  final int chatGroupId;
  final int count;

  const SaveLocalMessageCountParams({
    required this.chatGroupId,
    required this.count,
  });

  @override
  List<Object> get props => [chatGroupId, count];
}
