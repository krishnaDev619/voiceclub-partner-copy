import 'package:equatable/equatable.dart';
import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/domain/repository/calling_repository.dart';

class EndCallUsecase implements UseCase<DataState<void>, Params> {
  final CallingRepository _callingRepository;
  EndCallUsecase(this._callingRepository);

  @override
  Future<DataState<void>> call(Params params) {
    return _callingRepository.endCall(
      params.channelId,
      params.callRejected,
      params.endedByID,
      params.declineReason,
    );
  }
}

class Params extends Equatable {
  final String channelId;
  final bool callRejected;
  final int endedByID;
  final String declineReason;

  const Params({
    required this.channelId,
    required this.callRejected,
    required this.endedByID,
    required this.declineReason,
  });

  @override
  List<Object> get props => [channelId, callRejected, endedByID, declineReason];
}
