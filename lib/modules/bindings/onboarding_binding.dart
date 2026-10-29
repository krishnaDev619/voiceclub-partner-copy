import 'package:get/get.dart';
import 'package:voiceclub_partner/data/models/data.dart';
import 'package:voiceclub_partner/data/models/metrics/get_probation_details_response.dart';
import 'package:voiceclub_partner/modules/controller/probation_controller.dart';
import 'package:voiceclub_partner/modules/controller/probation_course_controller.dart';
import 'package:voiceclub_partner/modules/controller/user_controller.dart';
import 'package:voiceclub_partner/view/onboarding/controller/onboarding_progress_controller.dart';

class OnboardingBinding extends Bindings {
  final DataModel userDataModel;
  final GetProbationDetailsResponseModel initProbationData;

  OnboardingBinding({
    required this.userDataModel,
    required this.initProbationData,
  });

  @override
  void dependencies() {
    Get.put(
      UserController(
        initUserDataModel: userDataModel,
        initPartnerStatus: initProbationData.stage!,
        initProbationData: initProbationData,
      ),
      permanent: true,
    );
    Get.put(
      ProbationController(initProbationData: initProbationData),
      permanent: true,
    );
    Get.put(ProbationCourseController(), permanent: true);
    Get.put(OnboardingProgressController(), permanent: true);
  }
}
