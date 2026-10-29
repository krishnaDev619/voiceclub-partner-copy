import 'package:equatable/equatable.dart';
import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/data/models/blocking/get_blocked_users_response.dart';
import 'package:voiceclub_partner/domain/repository/blocking_repository.dart';

class GetBlockedUsersUseCase
    implements UseCase<DataState<GetBlockedUsersResponseModel>, Params> {
  final BlockingRepository _blockingRepository;
  GetBlockedUsersUseCase(this._blockingRepository);

  @override
  Future<DataState<GetBlockedUsersResponseModel>> call(Params params) {
    return _blockingRepository.getBlockedUsers(params.page, params.pageSize);
  }
}

class Params extends Equatable {
  final int page, pageSize;
  const Params({required this.page, required this.pageSize});

  @override
  List<Object> get props => [page, pageSize];
}
