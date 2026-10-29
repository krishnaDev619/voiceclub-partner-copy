import 'package:equatable/equatable.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/data/models/calling/call_state_model.dart';
import 'package:voiceclub_partner/domain/repository/calling_repository.dart';

class FetchCallStateStreamUsecase
    implements UseCase<Stream<CallStateModel?>?, FetchCallStateStreamParams> {
  final CallingRepository _callingRepository;

  FetchCallStateStreamUsecase(this._callingRepository);

  @override
  Future<Stream<CallStateModel?>?> call(
    FetchCallStateStreamParams params,
  ) async {
    return _callingRepository.fetchCallStateStream(channelId: params.channelId);
  }
}

class FetchCallStateStreamParams extends Equatable {
  final String channelId;

  const FetchCallStateStreamParams({required this.channelId});

  @override
  List<Object> get props => [channelId];
}
