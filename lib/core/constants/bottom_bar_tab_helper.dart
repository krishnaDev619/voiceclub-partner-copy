import 'package:get/get.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/modules/controller/user_controller.dart';

class BottomBarTabHelper {
  static List<BottomBarTabType> getVisibleTabs() {
    final userController = Get.find<UserController>();
    final currentStatus = userController.partnerStatus.value;
    final currentStage = userController.currentStage;

    if (currentStatus == PartnerCurrentStatus.NEW_LIVE ||
        currentStatus == PartnerCurrentStatus.PROBATION) {
      return BottomBarTabType.values
          .where((tab) => tab != BottomBarTabType.SOCIAL)
          .toList();
    } else if (currentStatus == PartnerCurrentStatus.LIVE ||
        currentStage == TutorialStage.DONE) {
      return BottomBarTabType.values
          .where((tab) => tab != BottomBarTabType.LEARNING)
          .toList();
    }

    return BottomBarTabType.values;
  }
}
