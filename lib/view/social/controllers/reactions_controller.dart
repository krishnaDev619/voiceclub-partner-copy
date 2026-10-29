import 'package:get/get.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/injection_container.dart';
import 'package:voiceclub_partner/core/services/logger.dart';
import 'package:voiceclub_partner/data/models/notifications/user_data.dart';
import 'package:voiceclub_partner/domain/usecases/social/get_all_reactions.dart';

class ReactionsController extends GetxController {
  final String postId;

  // Current state
  final users = <UserDataModel>[].obs;
  final isLoading = false.obs;
  final hasError = false.obs;
  final selectedReactionType = ReactionType.LIKE.obs;

  // Available reaction types with their counts
  final reactionCounts = <ReactionType, int>{}.obs;

  ReactionsController({required this.postId});

  @override
  void onInit() {
    super.onInit();
    fetchReactionUsers(selectedReactionType.value);
  }

  void selectReactionType(ReactionType reactionType) {
    if (selectedReactionType.value == reactionType) return;

    selectedReactionType.value = reactionType;
    fetchReactionUsers(reactionType);
  }

  Future<void> fetchReactionUsers(ReactionType reactionType) async {
    try {
      isLoading.value = true;
      hasError.value = false;

      final response = await sl<GetAllReactionsUsecase>().call(
        GetAllReactionsParams(
          postId: postId,
          reaction: reactionType.toApiString,
        ),
      );

      if (response.data != null) {
        users.value = response.data?.users ?? [];
        reactionCounts[reactionType] = users.length;
      } else {
        hasError.value = true;
        users.clear();
        Logger.logMessage(
          'Error fetching ${reactionType.name} reactions: ${response.error}',
        );
      }
    } catch (e) {
      hasError.value = true;
      users.clear();
      Logger.logMessage('Error fetching ${reactionType.name} reactions: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> retry() async {
    await fetchReactionUsers(selectedReactionType.value);
  }
}
