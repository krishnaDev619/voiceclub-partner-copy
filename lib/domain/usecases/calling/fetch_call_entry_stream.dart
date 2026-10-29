import 'package:equatable/equatable.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/data/models/calling/call_entry_model.dart';
import 'package:voiceclub_partner/domain/repository/calling_repository.dart';

class FetchCallEntryStreamUsecase
    implements UseCase<Stream<CallEntryModel?>?, FetchCallEntryStreamParams> {
  final CallingRepository _callingRepository;

  FetchCallEntryStreamUsecase(this._callingRepository);

  @override
  Future<Stream<CallEntryModel?>?> call(
    FetchCallEntryStreamParams params,
  ) async {
    return _callingRepository.fetchCallEntryStream(accountId: params.accountId);
  }
}

class FetchCallEntryStreamParams extends Equatable {
  final String accountId;

  const FetchCallEntryStreamParams({required this.accountId});

  @override
  List<Object> get props => [accountId];
}
