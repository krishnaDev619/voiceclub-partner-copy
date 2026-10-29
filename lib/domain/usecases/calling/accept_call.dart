import 'package:equatable/equatable.dart';
import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/data/models/calling/accept_call_response.dart';
import 'package:voiceclub_partner/domain/repository/calling_repository.dart';

class AcceptCallUsecase
    implements UseCase<DataState<AcceptCallResponseModel>, Params> {
  final CallingRepository _callingRepository;
  AcceptCallUsecase(this._callingRepository);

  @override
  Future<DataState<AcceptCallResponseModel>> call(Params params) {
    return _callingRepository.acceptCall(params.channelId);
  }
}

class Params extends Equatable {
  final String channelId;
  const Params({required this.channelId});

  @override
  List<Object> get props => [channelId];
}
