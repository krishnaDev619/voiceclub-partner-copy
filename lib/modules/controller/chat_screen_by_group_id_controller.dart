import 'package:get/get.dart';
import 'package:voiceclub_partner/data/models/chat/chat_group.dart';
import 'package:voiceclub_partner/domain/usecases/chat/get_chat_group_by_id.dart';

class ChatScreenByGroupIdController extends GetxController {
  final GetChatGroupByIdUsecase getChatGroupByIdUsecase;
  final int groupId;

  ChatScreenByGroupIdController({
    required this.getChatGroupByIdUsecase,
    required this.groupId,
  });

  final isLoading = true.obs;
  final isError = false.obs;
  final chatGroup = const ChatGroup().obs;

  @override
  void onInit() {
    _fetchChatGroup();
    super.onInit();
  }

  Future<void> _fetchChatGroup() async {
    try {
      isLoading(true);
      isError(false);
      final response = await getChatGroupByIdUsecase.call(
        Params(groupId: groupId),
      );

      if (response.error == null && response.data != null) {
        chatGroup.value = response.data!;
      } else {
        isError(true);
      }
    } catch (e) {
      isError(true);
    } finally {
      isLoading(false);
      update();
    }
  }
}
