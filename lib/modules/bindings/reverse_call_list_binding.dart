import 'package:get/get.dart';
import 'package:voiceclub_partner/modules/controller/reverse_call_list_controller.dart';

class ReverseCallListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ReverseCallListController());
  }
}
