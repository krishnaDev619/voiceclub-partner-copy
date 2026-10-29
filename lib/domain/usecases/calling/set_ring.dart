import 'package:equatable/equatable.dart';
import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/domain/repository/calling_repository.dart';

class SetRingUsecase implements UseCase<DataState<void>, Params> {
  final CallingRepository _callingRepository;
  SetRingUsecase(this._callingRepository);

  @override
  Future<DataState<void>> call(Params params) {
    return _callingRepository.setRing(params.channelId);
  }
}

class Params extends Equatable {
  final String channelId;
  const Params({required this.channelId});

  @override
  List<Object> get props => [channelId];
}
