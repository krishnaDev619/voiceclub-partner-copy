import 'package:get/get.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/data/models/chat/chat_filter.dart';
import 'package:voiceclub_partner/modules/controller/broadcast_controller.dart';

class BroadcastBinding extends Bindings {
  final ChatFilter broadcastFilter;

  BroadcastBinding({required this.broadcastFilter});

  @override
  void dependencies() {
    Get.put(
      BroadcastController(
        broadcastFilter: broadcastFilter,
        categoryCode: CategoryCode.GOSSIP,
      ),
    );
  }
}
