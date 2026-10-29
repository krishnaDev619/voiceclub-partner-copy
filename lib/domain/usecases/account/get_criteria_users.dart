import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/data/models/account/get_criteria_users_response.dart';
import 'package:voiceclub_partner/domain/repository/account_repository.dart';

class GetCriteriaUsersUseCase
    implements UseCase<DataState<GetCriteriaUsersResponseModel>, Params> {
  final AccountRepository _accountRepository;

  GetCriteriaUsersUseCase(this._accountRepository);

  @override
  Future<DataState<GetCriteriaUsersResponseModel>> call(Params params) {
    return _accountRepository.getCriteriaUsers(
      cutoffFlag: params.cutoffFlag,
      page: params.page,
      pageSize: params.pageSize,
    );
  }
}

class Params {
  final int cutoffFlag;
  final int page, pageSize;

  const Params({
    required this.cutoffFlag,
    required this.page,
    required this.pageSize,
  });
}
