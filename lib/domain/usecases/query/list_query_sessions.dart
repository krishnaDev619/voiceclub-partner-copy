import 'package:equatable/equatable.dart';
import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/data/models/query/list_query_sessions_response.dart';
import 'package:voiceclub_partner/domain/repository/query_repository.dart';

class ListQuerySessionsUseCase
    implements
        UseCase<DataState<ListQuerySessionsResponse>, ListQuerySessionsParams> {
  final QueryRepository _queryRepository;

  ListQuerySessionsUseCase(this._queryRepository);

  @override
  Future<DataState<ListQuerySessionsResponse>> call(
    ListQuerySessionsParams params,
  ) async {
    return _queryRepository.listQuerySessions(
      page: params.page,
      pageSize: params.pageSize,
    );
  }
}

class ListQuerySessionsParams extends Equatable {
  final int page;
  final int pageSize;

  const ListQuerySessionsParams({required this.page, required this.pageSize});

  @override
  List<Object> get props => [page, pageSize];
}
