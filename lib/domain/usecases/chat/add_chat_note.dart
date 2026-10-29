import 'package:equatable/equatable.dart';
import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/domain/repository/chat_repository.dart';

class AddChatNoteUseCase implements UseCase<DataState, Params> {
  final ChatRepository _chatRepository;

  AddChatNoteUseCase(this._chatRepository);

  @override
  Future<DataState> call(Params params) async {
    return _chatRepository.addChatNote(
      accountId: params.accountId,
      age: params.age,
      relationship: params.relationship,
      profession: params.profession,
      noteRequest: params.noteRequest,
    );
  }
}

class Params extends Equatable {
  final int accountId;
  final int age;
  final String profession;
  final String relationship;
  final Map<String, dynamic> noteRequest;

  const Params({
    required this.accountId,
    required this.age,
    required this.profession,
    required this.relationship,
    required this.noteRequest,
  });

  @override
  List<Object> get props => [accountId];
}
