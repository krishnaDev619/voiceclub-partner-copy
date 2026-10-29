import 'package:get/get.dart';
import 'package:voiceclub_partner/core/injection_container.dart';
import 'package:voiceclub_partner/data/models/account/reverse_call_user.dart';
import 'package:voiceclub_partner/domain/usecases/account/get_reverse_calls.dart';
import 'package:voiceclub_partner/modules/controller/rewards_controller.dart';

class ReverseCallListController extends GetxController {
  final totalPages = 1.obs;
  final totalItems = 0.obs;
  final isLoading = true.obs;
  final reverseCallsList = <ReverseCallUser>{}.obs;
  final isRewardsLoading = false.obs;

  @override
  void onInit() {
    fetchReverseCalls(page: 1);
    Get.find<RewardsController>().fetchRewardsStats();
    super.onInit();
  }

  Future<void> fetchReverseCalls({required int page}) async {
    try {
      isLoading(true);
      if (page == 1) {
        reverseCallsList.clear();
        totalPages.value = 1;
        totalItems.value = 0;
      }
      update();
      if (page <= totalPages.value) {
        var response = await sl<GetReverseCallsUseCase>().call(
          Params(page: page, pageSize: 25),
        );

        if (response.data != null && response.error == null) {
          totalItems.value = response.data?.totalItems ?? 0;
          reverseCallsList.addAll(response.data?.users ?? []);
          totalPages.value = response.data?.totalPages ?? 1;
        }
      }
    } catch (_) {
    } finally {
      isLoading(false);
    }
  }
}
