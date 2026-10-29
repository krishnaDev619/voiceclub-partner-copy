import 'package:equatable/equatable.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/domain/repository/chat_repository.dart';

class GetLocalFetchedMessageCountUsecase
    implements UseCase<int?, GetLocalFetchedMessageCountParams> {
  final ChatRepository _chatRepository;

  GetLocalFetchedMessageCountUsecase(this._chatRepository);

  @override
  Future<int?> call(GetLocalFetchedMessageCountParams params) async {
    return _chatRepository.getLocalFetchedMessageCount(
      chatGroupId: params.chatGroupId,
    );
  }
}

class GetLocalFetchedMessageCountParams extends Equatable {
  final int chatGroupId;

  const GetLocalFetchedMessageCountParams({required this.chatGroupId});

  @override
  List<Object> get props => [chatGroupId];
}
