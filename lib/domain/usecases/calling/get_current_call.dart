import 'package:equatable/equatable.dart';
import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/data/models/calling/call_model.dart';
import 'package:voiceclub_partner/domain/repository/calling_repository.dart';

class GetCurrentCallUsecase implements UseCase<DataState<CallModel>, Params> {
  final CallingRepository _callingRepository;
  GetCurrentCallUsecase(this._callingRepository);

  @override
  Future<DataState<CallModel>> call(Params params) {
    return _callingRepository.getCurrentCall(params.channelId);
  }
}

class Params extends Equatable {
  final String channelId;

  const Params({required this.channelId});

  @override
  List<Object> get props => [channelId];
}
