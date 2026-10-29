import 'package:equatable/equatable.dart';
import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/data/models/query/get_query_session_response.dart';
import 'package:voiceclub_partner/domain/repository/query_repository.dart';

class GetQuerySessionUseCase
    implements
        UseCase<DataState<GetQuerySessionResponse>, GetQuerySessionParams> {
  final QueryRepository _queryRepository;

  GetQuerySessionUseCase(this._queryRepository);

  @override
  Future<DataState<GetQuerySessionResponse>> call(
    GetQuerySessionParams params,
  ) async {
    return _queryRepository.getQuerySession(sessionId: params.sessionId);
  }
}

class GetQuerySessionParams extends Equatable {
  final String sessionId;

  const GetQuerySessionParams({required this.sessionId});

  @override
  List<Object> get props => [sessionId];
}
