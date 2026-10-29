import 'package:equatable/equatable.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/data/models/get_logs_grouped_response.dart';
import 'package:voiceclub_partner/domain/repository/calling_repository.dart';

class GetLogsGroupedUsecase
    implements UseCase<DataState<GetLogsGroupedResponseModel>, Params> {
  final CallingRepository _callingRepository;
  GetLogsGroupedUsecase(this._callingRepository);

  @override
  Future<DataState<GetLogsGroupedResponseModel>> call(Params params) {
    return _callingRepository.getLogsGrouped(
      period: params.overviewFilter.stringValue,
      type: params.logType.name,
      page: params.page,
      pageSize: params.pageSize,
    );
  }
}

class Params extends Equatable {
  final OverviewFilter overviewFilter;
  final LogType logType;
  final int page, pageSize;

  const Params({
    required this.overviewFilter,
    required this.logType,
    required this.page,
    required this.pageSize,
  });

  @override
  List<Object> get props => [overviewFilter, logType, page, pageSize];
}
