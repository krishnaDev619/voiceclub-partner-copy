import 'package:equatable/equatable.dart';
import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/domain/repository/blocking_repository.dart';

class ReportUserUsecase implements UseCase<DataState<void>, Params> {
  final BlockingRepository _blockingRepository;
  ReportUserUsecase(this._blockingRepository);

  @override
  Future<DataState<void>> call(Params params) {
    return _blockingRepository.reportUser(params.accountId, params.reason);
  }
}

class Params extends Equatable {
  final int accountId;
  final String reason;
  const Params({required this.accountId, required this.reason});

  @override
  List<Object> get props => [accountId, reason];
}
