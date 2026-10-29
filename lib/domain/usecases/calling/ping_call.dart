import 'package:equatable/equatable.dart';
import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/domain/repository/calling_repository.dart';

class PingCallUseCase implements UseCase<DataState, Params> {
  final CallingRepository _callingRepository;

  PingCallUseCase(this._callingRepository);

  @override
  Future<DataState> call(Params params) {
    return _callingRepository.pingCall(channelId: params.channelId);
  }
}

class Params extends Equatable {
  final String channelId;

  const Params({required this.channelId});

  @override
  List<Object> get props => [channelId];
}
