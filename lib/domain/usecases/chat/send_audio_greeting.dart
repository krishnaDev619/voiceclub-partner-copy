import 'package:equatable/equatable.dart';
import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/domain/repository/chat_repository.dart';

class SendAudioGreetingUsecase implements UseCase<DataState<void>, Params> {
  final ChatRepository _chatRepository;

  SendAudioGreetingUsecase(this._chatRepository);

  @override
  Future<DataState<void>> call(Params params) {
    return _chatRepository.sendAudioGreeting(accountId: params.accountId);
  }
}

class Params extends Equatable {
  final int accountId;

  const Params({required this.accountId});

  @override
  List<Object> get props => [accountId];
}
