import 'package:equatable/equatable.dart';
import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/domain/repository/ringing_repository.dart';

class SetRingIsolateUsecase
    implements UseCase<DataState<void>, SetRingIsolateParams> {
  final RingingRepository _ringingRepository;
  SetRingIsolateUsecase(this._ringingRepository);

  @override
  Future<DataState<void>> call(SetRingIsolateParams params) {
    return _ringingRepository.setRing(channelId: params.channelId);
  }
}

class SetRingIsolateParams extends Equatable {
  final String channelId;
  const SetRingIsolateParams({required this.channelId});

  @override
  List<Object> get props => [channelId];
}
