import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/data/models/account/get_criteria_users_response.dart';
import 'package:voiceclub_partner/domain/repository/account_repository.dart';

class SearchCriteriaUsersUseCase
    implements UseCase<DataState<GetCriteriaUsersResponseModel>, Params> {
  final AccountRepository _accountRepository;

  SearchCriteriaUsersUseCase(this._accountRepository);

  @override
  Future<DataState<GetCriteriaUsersResponseModel>> call(Params params) {
    return _accountRepository.getCriteriaUsers(
      cutoffFlag: params.cutoffFlag,
      page: params.page,
      pageSize: params.pageSize,
      searchQuery: params.searchQuery,
    );
  }
}

class Params {
  final int cutoffFlag;
  final int page, pageSize;
  final String searchQuery;

  const Params({
    required this.cutoffFlag,
    required this.page,
    required this.pageSize,
    required this.searchQuery,
  });
}
