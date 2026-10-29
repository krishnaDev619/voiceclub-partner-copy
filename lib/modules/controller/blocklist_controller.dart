import 'package:get/get.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:voiceclub_partner/core/injection_container.dart';
import 'package:voiceclub_partner/data/models/blocking/get_blocked_users_response.dart';
import 'package:voiceclub_partner/domain/usecases/blocking/block_user.dart'
    as block_user_use_case;
import 'package:voiceclub_partner/domain/usecases/blocking/get_blocked_users.dart';

class BlockListController extends GetxController {
  var blockedUsers = <BlockedUsers>{}.obs;
  final _getBlockedUsersUseCase = sl<GetBlockedUsersUseCase>();
  final _blockUserUseCase = sl<block_user_use_case.BlockUserUsecase>();
  final currentPage = 1.obs;
  final totalPages = 1.obs;
  final totalBlockedUsers = 0.obs;

  Future<void> fetchBlocklistData() async {
    try {
      Get.context?.loaderOverlay.show();
      var response = await _getBlockedUsersUseCase.call(
        Params(page: currentPage.value, pageSize: 20),
      );
      if (response.data == null) return;
      totalPages.value = response.data?.totalPages ?? 1;
      blockedUsers.addAll(response.data!.blockedUsers?.reversed.toList() ?? []);
      totalBlockedUsers(response.data?.totalItems ?? 0);
      update();
    } catch (_) {
    } finally {
      Get.context?.loaderOverlay.hide();
    }
  }

  Future<void> blockUser({
    required int accountId,
    required String reason,
  }) async {
    try {
      Get.context?.loaderOverlay.show();
      await _blockUserUseCase.call(
        block_user_use_case.Params(accountId: accountId, reason: reason),
      );
    } catch (_) {
    } finally {
      Get.context?.loaderOverlay.hide();
    }
  }
}
