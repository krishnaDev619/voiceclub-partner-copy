import 'package:equatable/equatable.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/domain/repository/chat_repository.dart';

class FetchLastSeenMessageIdStreamUseCase
    implements UseCase<Stream<String?>, FetchLastSeenMessageIdStreamParams> {
  final ChatRepository _chatRepository;

  FetchLastSeenMessageIdStreamUseCase(this._chatRepository);

  @override
  Future<Stream<String?>> call(
    FetchLastSeenMessageIdStreamParams params,
  ) async {
    return _chatRepository.fetchLastSeenMessageIdStream(
      chatGroupId: params.chatGroupId,
    );
  }
}

class FetchLastSeenMessageIdStreamParams extends Equatable {
  final int chatGroupId;

  const FetchLastSeenMessageIdStreamParams({required this.chatGroupId});

  @override
  List<Object> get props => [chatGroupId];
}
