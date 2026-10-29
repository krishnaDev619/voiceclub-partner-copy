import 'package:equatable/equatable.dart';
import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/data/models/file/upload_file_response.dart';
import 'package:voiceclub_partner/domain/repository/chat_repository.dart';

class GetCallRecordingUseCase
    implements UseCase<DataState<FileResponseModel>, Params> {
  final ChatRepository _chatRepository;

  GetCallRecordingUseCase(this._chatRepository);

  @override
  Future<DataState<FileResponseModel>> call(Params params) {
    return _chatRepository.getCallRecording(callId: params.callId);
  }
}

class Params extends Equatable {
  final int callId;

  const Params({required this.callId});

  @override
  List<Object> get props => [callId];
}
