import 'package:get/get.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/injection_container.dart';
import 'package:voiceclub_partner/core/services/logger.dart';
import 'package:voiceclub_partner/data/models/notifications/user_data.dart';
import 'package:voiceclub_partner/domain/usecases/social/get_post_reactions.dart';

class LikesController extends GetxController {
  final String postId;
  final users = <UserDataModel>[].obs;
  final isLoading = false.obs;
  final hasError = false.obs;
  final hasMore = true.obs;
  final currentPage = 1.obs;

  static const int pageSize = 20;

  LikesController({required this.postId});

  @override
  void onInit() {
    super.onInit();
    fetchInitialLikes();
  }

  Future<void> fetchInitialLikes() async {
    currentPage.value = 1;
    users.clear();
    hasMore.value = true;
    await fetchLikes();
  }

  Future<void> fetchLikes() async {
    if (!hasMore.value || isLoading.value) return;

    try {
      isLoading.value = true;
      hasError.value = false;

      final response = await sl<GetPostReactionsUsecase>().call(
        GetPostReactionsParams(postId: postId),
      );

      if (response.data != null) {
        final reactions = response.data?.reactions;
        final newUsers = reactions?[ReactionType.LIKE] ?? [];

        if (newUsers.isEmpty || newUsers.length < pageSize) {
          hasMore.value = false;
        }

        if (currentPage.value == 1) {
          users.value = newUsers;
        } else {
          users.addAll(newUsers);
        }

        currentPage.value++;
      } else {
        hasError.value = true;
        Logger.logMessage('Error fetching likes: ${response.error}');
      }
    } catch (e) {
      hasError.value = true;
      Logger.logMessage('Error fetching likes: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> retry() async {
    if (users.isEmpty) {
      await fetchInitialLikes();
    } else {
      await fetchLikes();
    }
  }
}
