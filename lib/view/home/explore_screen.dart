import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/view/home/widgets/post.dart';
import 'package:voiceclub_partner/view/social/controllers/explore_controller.dart';
import 'package:voiceclub_partner/view/social/widgets/create_post_sheet.dart';
import 'package:voiceclub_partner/view/social/widgets/post_card_shimmer.dart';
import 'package:voiceclub_partner/view/social/widgets/post_status_widget.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  late AppLifecycleListener lifecycleListener;
  final ValueNotifier<bool> _showScrollToTop = ValueNotifier<bool>(false);
  double _maxScrollPosition = 0;

  @override
  void initState() {
    super.initState();
    lifecycleListener = AppLifecycleListener(
      onPause: () => Get.find<ExploreController>().pauseAllPlayers(),
    );
  }

  @override
  void dispose() {
    _showScrollToTop.dispose();
    super.dispose();
  }

  bool onScrollNotification(ScrollNotification scrollNotification) {
    if (scrollNotification.metrics.axis != Axis.vertical) {
      return false;
    }

    if (scrollNotification is ScrollUpdateNotification) {
      final pixels = scrollNotification.metrics.pixels;

      // Reset max scroll position when near the top
      if (pixels < 50) {
        _maxScrollPosition = 0;
      } else {
        _maxScrollPosition =
            _maxScrollPosition < pixels ? pixels : _maxScrollPosition;
      }

      if (_maxScrollPosition > 400 && !_showScrollToTop.value) {
        _showScrollToTop.value = true;
      } else if (_maxScrollPosition <= 400 && _showScrollToTop.value) {
        _showScrollToTop.value = false;
      }
    }

    return false;
  }

  Future<void> _scrollToTop() async {
    final primaryController = PrimaryScrollController.of(context);
    await primaryController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void _showCreatePostSheet() {
    Get.find<ExploreController>().pauseAllPlayers();
    Get.bottomSheet(const CreatePostSheet(), isScrollControlled: true);
  }

  Widget _buildTabSelector(ExploreController controller) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _buildTab(
            text: LocaleKeys.liveAllUsers.tr,
            isSelected: controller.selectedTabIndex.value == 0,
            onTap: () => controller.onTabChanged(0),
          ),
          const SizedBox(width: 12),
          _buildTab(
            text: LocaleKeys.liveMyUsers.tr,
            isSelected: controller.selectedTabIndex.value == 1,
            onTap: () => controller.onTabChanged(1),
          ),
          const SizedBox(width: 12),
          _buildTab(
            text: LocaleKeys.liveMyPosts.tr,
            isSelected: controller.selectedTabIndex.value == 2,
            onTap: () => controller.onTabChanged(2),
          ),
        ],
      ),
    );
  }

  Widget _buildTab({
    required String text,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? ApplicationColors.primaryRed
                  : const Color(0xFFF4F4F4),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[600],
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildPostsList(ExploreController controller) {
    final posts =
        controller.selectedTabIndex.value == 0
            ? controller.forYouPosts
            : controller.selectedTabIndex.value == 1
            ? controller.myUsersPosts
            : controller.yourPosts;
    final hasError =
        controller.selectedTabIndex.value == 0
            ? controller.forYouHasError
            : controller.selectedTabIndex.value == 1
            ? controller.myUsersHasError
            : controller.yourPostsHasError;
    final currentPage =
        controller.selectedTabIndex.value == 0
            ? controller.forYouCurrentPage
            : controller.selectedTabIndex.value == 1
            ? controller.myUsersCurrentPage
            : controller.yourPostsCurrentPage;
    final totalPages =
        controller.selectedTabIndex.value == 0
            ? controller.forYouTotalPages
            : controller.selectedTabIndex.value == 1
            ? controller.myUsersTotalPages
            : controller.yourPostsTotalPages;

    if (controller.isLoading.value && posts.isEmpty) {
      return const SliverFillRemaining(
        child: SingleChildScrollView(
          physics: NeverScrollableScrollPhysics(),
          child: Column(children: [PostCardShimmer(), PostCardShimmer()]),
        ),
      );
    } else if (hasError.value && posts.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(LocaleKeys.liveFailedToLoadPosts.tr),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: controller.refreshPosts,
                child: Text(LocaleKeys.liveRetry.tr),
              ),
            ],
          ),
        ),
      );
    } else if (posts.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.camera_enhance_rounded,
                size: 100,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                LocaleKeys.liveNoPostsYet.tr,
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (index >= posts.length) {
            if (currentPage.value < totalPages.value) {
              controller.loadMorePosts();
              return const Center(child: PostCardShimmer());
            }
            return null;
          }

          final post = posts[index];
          return Post(post: post);
        },
        childCount:
            posts.length + (currentPage.value < totalPages.value ? 1 : 0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ExploreController>();
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Obx(
            () => SafeArea(
              child: NotificationListener<ScrollNotification>(
                onNotification: onScrollNotification,
                child: NestedScrollView(
                  headerSliverBuilder: (context, innerBoxIsScrolled) {
                    return [
                      SliverPersistentHeader(
                        floating: true,
                        delegate: _SliverAppBarDelegate(
                          _buildTabSelector(controller),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: Obx(
                          () =>
                              controller.showPostStatus.value
                                  ? PostStatusWidget(
                                    key: ValueKey(
                                      'post_status_${controller.currentPostId.value}',
                                    ),
                                    postId: controller.currentPostId.value,
                                  )
                                  : const SizedBox.shrink(),
                        ),
                      ),
                    ];
                  },
                  body: RefreshIndicator(
                    onRefresh: () async {
                      controller.refreshPost();
                    },
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: CustomScrollView(
                        key: ValueKey(controller.selectedTabIndex.value),
                        slivers: [_buildPostsList(controller)],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          ValueListenableBuilder<bool>(
            valueListenable: _showScrollToTop,
            builder: (context, showButton, child) {
              if (!showButton) return const SizedBox.shrink();
              return Positioned(
                top: 54,
                left: 0,
                right: 0,
                child: Center(
                  child: AnimatedOpacity(
                    opacity: showButton ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: Container(
                      decoration: BoxDecoration(
                        color: ApplicationColors.primaryRed,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _scrollToTop,
                          borderRadius: BorderRadius.circular(20),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.keyboard_arrow_up_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Back to top',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton(
                onPressed: _showCreatePostSheet,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  backgroundColor: ApplicationColors.primaryRed,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add, color: Colors.white, size: 18),
                    SizedBox(width: 6),
                    Text(
                      'Post',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _SliverAppBarDelegate(this.child);

  @override
  double get minExtent => 56.0;
  @override
  double get maxExtent => 56.0;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return SizedBox.expand(child: Container(color: Colors.white, child: child));
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return true;
  }
}
