import 'package:get/get.dart';
import 'package:voiceclub_partner/features/onboarding/views/agreement/controllers/agreement_controller.dart';

class AgreementBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(AgreementController());
  }
}
