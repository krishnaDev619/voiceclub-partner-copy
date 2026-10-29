import 'package:get/get.dart';
import 'package:voiceclub_partner/core/injection_container.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/data/models/tier/get_weekly_online_duration_response.dart';
import 'package:voiceclub_partner/domain/usecases/tier/get_weekly_online_duration.dart';

class TierController extends GetxController {
  final isLoading = false.obs;
  final weeklyOnlineDuration = GetWeeklyOnlineDurationResponseModel().obs;

  @override
  void onInit() {
    fetchData();
    super.onInit();
  }

  Future<void> fetchData() async {
    try {
      isLoading(true);
      update();
      final weeklyOnlineDurationResponse =
          await sl<GetWeeklyOnlineDurationUsecase>().call(NoParams());
      if (weeklyOnlineDurationResponse.data != null &&
          weeklyOnlineDurationResponse.error == null) {
        weeklyOnlineDuration.value = weeklyOnlineDurationResponse.data!;
      }
    } catch (_) {
    } finally {
      isLoading(false);
      update();
    }
  }
}
