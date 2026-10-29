import 'package:get/get.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/injection_container.dart';
import 'package:voiceclub_partner/data/models/account/conversion_user.dart';
import 'package:voiceclub_partner/domain/usecases/account/get_criteria_users.dart';
import 'package:voiceclub_partner/domain/usecases/account/search_criteria_users.dart'
    as search;
import 'package:voiceclub_partner/modules/controller/rewards_controller.dart';

class UserConversionController extends GetxController {
  final bool isConverted;
  UserConversionController({required this.isConverted});

  final criteriaUsersList = <ConversionUser>{}.obs;
  final cutoff = 0.obs;
  final conversionStatus = ConversionStatus.Completed.obs;
  final totalPages = 1.obs;
  final totalItems = 0.obs;
  final isLoading = true.obs;
  final isRewardsLoading = false.obs;

  @override
  void onInit() {
    conversionStatus.value =
        isConverted ? ConversionStatus.Completed : ConversionStatus.Pending;
    getCriteriaUsers(page: 1);
    Get.find<RewardsController>().fetchRewardsStats();
    super.onInit();
  }

  Future<void> getCriteriaUsers({required int page, String query = ''}) async {
    try {
      isLoading(true);
      if (page == 1) {
        criteriaUsersList.clear();
        totalPages.value = 1;
        totalItems.value = 0;
      }
      update();
      if (page <= totalPages.value) {
        final getCriteriaUsersUseCase = sl<GetCriteriaUsersUseCase>();
        final searchCriteriaUsersUseCase =
            sl<search.SearchCriteriaUsersUseCase>();
        var response =
            query.isNotEmpty
                ? await searchCriteriaUsersUseCase.call(
                  search.Params(
                    searchQuery: query,
                    cutoffFlag:
                        conversionStatus.value == ConversionStatus.Pending
                            ? 0
                            : 1,
                    page: page,
                    pageSize: 25,
                  ),
                )
                : await getCriteriaUsersUseCase.call(
                  Params(
                    cutoffFlag:
                        conversionStatus.value == ConversionStatus.Pending
                            ? 0
                            : 1,
                    page: page,
                    pageSize: 25,
                  ),
                );
        if (response.data != null && response.error == null) {
          totalItems.value = response.data?.totalItems ?? 0;
          criteriaUsersList.addAll(response.data?.users ?? []);
          cutoff.value = response.data?.cutoff ?? 0;
          totalPages.value = response.data?.totalPages ?? 1;
        }
      }
    } catch (_) {
    } finally {
      isLoading(false);
      update();
      Get.context?.loaderOverlay.hide();
    }
  }

  void changeTab(ConversionStatus status) {
    if (status != conversionStatus.value) {
      conversionStatus.value = status;
      update();
      getCriteriaUsers(page: 1);
    }
  }
}
