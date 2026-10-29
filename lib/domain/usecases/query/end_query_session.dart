import 'package:equatable/equatable.dart';
import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/domain/repository/query_repository.dart';

class EndQuerySessionUseCase
    implements UseCase<DataState<void>, EndQuerySessionParams> {
  final QueryRepository _queryRepository;

  EndQuerySessionUseCase(this._queryRepository);

  @override
  Future<DataState<void>> call(EndQuerySessionParams params) async {
    return _queryRepository.endQuerySession(sessionId: params.sessionId);
  }
}

class EndQuerySessionParams extends Equatable {
  final String sessionId;

  const EndQuerySessionParams({required this.sessionId});

  @override
  List<Object?> get props => [sessionId];
}
