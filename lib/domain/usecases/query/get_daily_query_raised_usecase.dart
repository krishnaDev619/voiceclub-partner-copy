import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/data/models/query/get_daily_query_raised_count_response.dart';
import 'package:voiceclub_partner/domain/repository/query_repository.dart';

class GetDailyQueryRaisedCountUseCase
    implements UseCase<DataState<GetDailyQueryRaisedCountResponse>, NoParams> {
  final QueryRepository _queryRepository;

  GetDailyQueryRaisedCountUseCase(this._queryRepository);

  @override
  Future<DataState<GetDailyQueryRaisedCountResponse>> call(
    NoParams params,
  ) async {
    return _queryRepository.getDailyQueryRaisedCount();
  }
}
