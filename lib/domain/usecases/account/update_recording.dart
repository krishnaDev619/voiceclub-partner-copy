import 'package:equatable/equatable.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/domain/repository/account_repository.dart';

class UpdateRecordingUsecase implements UseCase<DataState<void>, Params> {
  final AccountRepository _accountRepository;
  UpdateRecordingUsecase(this._accountRepository);

  @override
  Future<DataState<void>> call(Params params) {
    return _accountRepository.updateRecording(
      url: params.url,
      type: params.recordingAudioType.type,
      language: params.language,
      status: params.status,
      reason: params.reason,
    );
  }
}

class Params extends Equatable {
  final String url;
  final RecordingAudioType recordingAudioType;
  final String language;
  final String status;
  final String? reason;

  const Params({
    required this.url,
    required this.recordingAudioType,
    required this.language,
    required this.status,
    this.reason,
  });

  @override
  List<Object> get props => [url, recordingAudioType, language, status];
}
