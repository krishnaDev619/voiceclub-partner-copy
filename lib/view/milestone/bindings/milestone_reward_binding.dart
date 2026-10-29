import 'package:get/get.dart';
import 'package:voiceclub_partner/view/milestone/controllers/milestone_rewards_controller.dart';

class MilestoneRewardsBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(MilestoneRewardsController());
  }
}
