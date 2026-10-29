import 'package:get/get.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/injection_container.dart';
import 'package:voiceclub_partner/core/services/ui_localization_service.dart';
import 'package:voiceclub_partner/modules/controller/user_controller.dart';

class JourneyEligibilityController extends GetxController {
  UserController get _userController => Get.find<UserController>();

  bool get hasLegacyJourneyConfig {
    final stages = sl<UiLocalizationService>().journey?.stages;
    return stages != null && stages.isNotEmpty;
  }

  bool get shouldShowLegacyTutorial {
    final userController = _userController;
    final userDetails = userController.userDetails.value;

    if (userDetails.onboardingStageTutorialCompleted ?? false) {
      return false;
    }

    if (userController.currentStage == TutorialStage.DONE ||
        userController.partnerStatus.value == PartnerCurrentStatus.LIVE) {
      return false;
    }

    return hasLegacyJourneyConfig;
  }
}
