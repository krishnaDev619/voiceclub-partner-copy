import 'package:equatable/equatable.dart';
import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/data/models/calling/place_call_response.dart';
import 'package:voiceclub_partner/domain/repository/calling_repository.dart';

class PlaceCallUsecase
    implements UseCase<DataState<PlaceCallResponseModel>, Params> {
  final CallingRepository _callingRepository;
  PlaceCallUsecase(this._callingRepository);

  @override
  Future<DataState<PlaceCallResponseModel>> call(Params params) {
    return _callingRepository.placeCall(demandUid: params.demandUid);
  }
}

class Params extends Equatable {
  final int demandUid;

  const Params({required this.demandUid});

  @override
  List<Object> get props => [demandUid];
}
