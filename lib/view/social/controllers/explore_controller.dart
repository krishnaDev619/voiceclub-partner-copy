import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/core/injection_container.dart';
import 'package:voiceclub_partner/core/services/analytics_service.dart';
import 'package:voiceclub_partner/core/services/logger.dart';
import 'package:voiceclub_partner/data/models/social/post_model.dart';
import 'package:voiceclub_partner/domain/usecases/social/list_my_posts.dart';
import 'package:voiceclub_partner/domain/usecases/social/list_my_user_posts.dart';
import 'package:voiceclub_partner/domain/usecases/social/list_posts.dart';

class ExploreController extends GetxController {
  final forYouPosts = <PostModel>[].obs;
  final yourPosts = <PostModel>[].obs;
  final myUsersPosts = <PostModel>[].obs;
  final isLoading = false.obs;
  final selectedTabIndex = 0.obs;

  // For You tab pagination
  final forYouTotalPages = 1.obs;
  final forYouCurrentPage = 1.obs;
  final forYouHasError = false.obs;

  // Your Posts tab pagination
  final yourPostsTotalPages = 1.obs;
  final yourPostsCurrentPage = 1.obs;
  final yourPostsHasError = false.obs;

  // My Users tab pagination
  final myUsersTotalPages = 1.obs;
  final myUsersCurrentPage = 1.obs;
  final myUsersHasError = false.obs;

  final showPostStatus = false.obs;
  final currentPostId = ''.obs;

  @override
  void onInit() {
    fetchInitialForYouPosts();
    super.onInit();
  }

  void onTabChanged(int index) {
    if (selectedTabIndex.value == index) return;
    pauseAllPlayers();
    selectedTabIndex.value = index;
    if (index == 0) {
      fetchInitialForYouPosts();
    } else if (index == 1) {
      fetchInitialMyUsersPosts();
    } else {
      fetchInitialYourPosts();
    }
    sl<AnalyticsService>().trackEvent(
      "exploreTabChangedPartner",
      eventProperties: {
        "tab":
            index == 0
                ? "For You"
                : index == 1
                ? "My Users"
                : "Your Posts",
      },
    );
  }

  Future<void> fetchInitialForYouPosts() async {
    forYouCurrentPage.value = 1;
    forYouTotalPages.value = 1;
    forYouPosts.clear();
    await fetchForYouPosts(page: 1);
  }

  Future<void> fetchInitialYourPosts() async {
    yourPostsCurrentPage.value = 1;
    yourPostsTotalPages.value = 1;
    yourPosts.clear();
    await fetchYourPosts(page: 1);
  }

  Future<void> fetchInitialMyUsersPosts() async {
    myUsersCurrentPage.value = 1;
    myUsersTotalPages.value = 1;
    myUsersPosts.clear();
    await fetchMyUsersPosts(page: 1);
  }

  Future<void> refreshPost() async {
    if (selectedTabIndex.value == 0) {
      await fetchInitialForYouPosts();
    } else if (selectedTabIndex.value == 1) {
      await fetchInitialMyUsersPosts();
    } else {
      await fetchInitialYourPosts();
    }
  }

  Future<void> fetchForYouPosts({required int page}) async {
    if (page == 1) {
      isLoading(true);
      forYouPosts.clear();
    }

    if (page <= forYouTotalPages.value) {
      try {
        forYouHasError(false);
        final response = await sl<ListPostsUsecase>().call(
          ListPostsParams(page: page, pageSize: 20),
        );

        if (response.data != null) {
          forYouTotalPages.value = response.data?.totalPages ?? 1;
          final newPosts = response.data?.posts ?? [];
          forYouPosts.addAll(newPosts);
          forYouCurrentPage.value = page;
        } else if (response.error != null) {
          forYouHasError(true);
        }
      } catch (e) {
        forYouHasError(true);
        Logger.logMessage('Error fetching for you posts: ${e.toString()}');
      } finally {
        isLoading(false);
      }
    }
  }

  Future<void> fetchYourPosts({required int page}) async {
    if (page == 1) {
      isLoading(true);
      yourPosts.clear();
    }

    if (page <= yourPostsTotalPages.value) {
      try {
        yourPostsHasError(false);
        final response = await sl<ListMyPostsUsecase>().call(
          ListMyPostsParams(page: page, pageSize: 20),
        );

        if (response.data != null) {
          yourPostsTotalPages.value = response.data?.totalPages ?? 1;
          final newPosts = response.data?.posts ?? [];
          yourPosts.addAll(newPosts);
          yourPostsCurrentPage.value = page;
        } else if (response.error != null) {
          yourPostsHasError(true);
        }
      } catch (e) {
        yourPostsHasError(true);
        Logger.logMessage('Error fetching your posts: ${e.toString()}');
      } finally {
        isLoading(false);
      }
    }
  }

  Future<void> fetchMyUsersPosts({required int page}) async {
    if (page == 1) {
      isLoading(true);
      myUsersPosts.clear();
    }

    if (page <= myUsersTotalPages.value) {
      try {
        myUsersHasError(false);
        final response = await sl<ListMyUserPostsUsecase>().call(
          ListMyUserPostsParams(page: page, pageSize: 20),
        );

        if (response.data != null) {
          myUsersTotalPages.value = response.data?.totalPages ?? 1;
          final newPosts = response.data?.posts ?? [];
          myUsersPosts.addAll(newPosts);
          myUsersCurrentPage.value = page;
        } else if (response.error != null) {
          myUsersHasError(true);
        }
      } catch (e) {
        myUsersHasError(true);
        Logger.logMessage('Error fetching my users posts: ${e.toString()}');
      } finally {
        isLoading(false);
      }
    }
  }

  Future<void> loadMorePosts() async {
    Logger.logMessage('Loading more posts');
    if (isLoading.value) return;
    Logger.logMessage('Selected tab index: ${selectedTabIndex.value}');

    if (selectedTabIndex.value == 0 &&
        forYouCurrentPage.value < forYouTotalPages.value) {
      await fetchForYouPosts(page: forYouCurrentPage.value + 1);
    } else if (selectedTabIndex.value == 1 &&
        myUsersCurrentPage.value < myUsersTotalPages.value) {
      await fetchMyUsersPosts(page: myUsersCurrentPage.value + 1);
    } else if (selectedTabIndex.value == 2 &&
        yourPostsCurrentPage.value < yourPostsTotalPages.value) {
      await fetchYourPosts(page: yourPostsCurrentPage.value + 1);
    }
  }

  Future<void> refreshPosts() async {
    if (selectedTabIndex.value == 0) {
      await fetchInitialForYouPosts();
    } else if (selectedTabIndex.value == 1) {
      await fetchInitialMyUsersPosts();
    } else {
      await fetchInitialYourPosts();
    }
  }

  // Audio Control
  RxMap<String, PlayerController> playerControllersMap =
      <String, PlayerController>{}.obs;

  //The path of current player which is being played
  var currentPlayerPath = "".obs;

  void addPlayerController({
    required String playerKey,
    required PlayerController playerController,
  }) {
    playerControllersMap[playerKey] = playerController;
  }

  /// Call this method everytime when you want to play or pause the player
  void stopAndStartPlayer(String playerKey) {
    if (playerKey == currentPlayerPath.value) {
      final playerController = playerControllersMap[playerKey];
      if (playerController!.playerState.isPlaying) {
        playerController.pausePlayer();
      } else {
        playerController.startPlayer();
      }
      return;
    }

    for (var controller in playerControllersMap.values) {
      controller.pausePlayer();
    }

    final playerController = playerControllersMap[playerKey];
    playerController?.startPlayer();
    currentPlayerPath.value = playerController?.playerKey ?? "";
  }

  Future<void> pauseAllPlayers() async {
    try {
      for (var controller in playerControllersMap.values) {
        await controller.pausePlayer();
      }
    } catch (_) {}
  }

  void showPostStatusWidget(String postId) {
    currentPostId.value = postId;
    showPostStatus.value = true;
  }

  void hidePostStatus() {
    showPostStatus.value = false;
    currentPostId.value = '';
  }
}
