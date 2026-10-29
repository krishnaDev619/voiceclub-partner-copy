import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/data/models/account/get_reverse_calls_reseponse.dart';
import 'package:voiceclub_partner/domain/repository/account_repository.dart';

class GetReverseCallsUseCase
    implements UseCase<DataState<GetReverseCallsResponse>, Params> {
  final AccountRepository _accountRepository;

  GetReverseCallsUseCase(this._accountRepository);

  @override
  Future<DataState<GetReverseCallsResponse>> call(Params params) {
    return _accountRepository.getReverseCalls(
      page: params.page,
      pageSize: params.pageSize,
    );
  }
}

class Params {
  final int page, pageSize;

  const Params({required this.page, required this.pageSize});
}
