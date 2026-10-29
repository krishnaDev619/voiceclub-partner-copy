import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/data/models/blocking/get_blocked_users_response.dart';

abstract class BlockingRepository {
  Future<DataState<void>> blockUser(int accountId, String reason);

  Future<DataState<void>> reportUser(int accountId, String reason);

  Future<DataState<GetBlockedUsersResponseModel>> getBlockedUsers(
    int page,
    int pageSize,
  );
}
