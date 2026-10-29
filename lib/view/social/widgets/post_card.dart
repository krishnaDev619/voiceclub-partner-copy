import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/core/injection_container.dart';
import 'package:voiceclub_partner/core/services/alert_service.dart';
import 'package:voiceclub_partner/core/services/analytics_service.dart';
import 'package:voiceclub_partner/data/models/calling/get_reverse_calling_stats_reponse.dart';
import 'package:voiceclub_partner/data/models/chat/member.dart';
import 'package:voiceclub_partner/data/models/social/post_model.dart';
import 'package:voiceclub_partner/domain/usecases/calling/get_reverse_calling_stats.dart';
import 'package:voiceclub_partner/domain/usecases/social/react_post.dart';
import 'package:voiceclub_partner/domain/usecases/social/unreact_post.dart';
import 'package:voiceclub_partner/view/chat/widgets/outgoing_call_dialog.dart';
import 'package:voiceclub_partner/view/social/controllers/comments_controller.dart';
import 'package:voiceclub_partner/view/social/controllers/explore_controller.dart';
import 'package:voiceclub_partner/view/social/widgets/comments_sheet.dart';
import 'package:voiceclub_partner/view/social/widgets/post_audio_player.dart';
import 'package:voiceclub_partner/view/social/widgets/post_video_player.dart';
import 'package:voiceclub_partner/view/social/widgets/reaction_picker.dart';
import 'package:voiceclub_partner/view/social/widgets/reactions_bottom_sheet.dart';
import 'package:voiceclub_partner/view/widgets/custom_profile_picture.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';

class PostCard extends StatefulWidget {
  final PostModel post;
  final bool isViewPost;

  const PostCard({super.key, required this.post, this.isViewPost = false});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _heartAnimationController;
  OverlayEntry? _reactionPickerOverlay;
  final GlobalKey _reactionButtonKey = GlobalKey();
  late Future<GetReverseCallingStatsResponseModel?> _reverseCallAllowedFuture;

  @override
  void initState() {
    super.initState();
    _heartAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _reverseCallAllowedFuture = _getReverseCallAllowed();
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  // Get reverse call allowed only if the post is of demand and isViewPost is true
  Future<GetReverseCallingStatsResponseModel?> _getReverseCallAllowed() async {
    if (widget.post.user?.role == AccountType.DEMAND &&
        (widget.isViewPost ||
            Get.find<ExploreController>().selectedTabIndex.value == 1)) {
      try {
        var response = await sl<GetReverseCallingStatsUsecase>().call(
          GetReverseCallingStatsParams(
            demandAccountId: widget.post.accountId ?? 0,
          ),
        );
        if (response.data != null && response.error == null) {
          return response.data;
        }
      } catch (_) {
        // Error will be handled by FutureBuilder
      }
    }
    return null;
  }

  void _openReverseCallDialog(
    GetReverseCallingStatsResponseModel? reverseCallingStatsResponse,
  ) async {
    try {
      if (widget.post.accountId != null &&
          reverseCallingStatsResponse != null) {
        HapticFeedback.vibrate();
        Get.dialog(
          OutgoingCallDialog(
            reverseCallingStatsResponse: reverseCallingStatsResponse,
            demandPeer: ChatMember(
              accountId: widget.post.accountId ?? 0,
              user: widget.post.user,
            ),
            screenName: 'PostCard',
          ),
        );
      }
    } catch (_) {
      AlertService.showSnackBar(
        snackBarType: SnackBarType.Error,
        title: LocaleKeys.liveCallFailed.tr,
        subtitle: LocaleKeys.livePleaseTryAgainLater.tr,
      );
    }
  }

  void _showComments() {
    if (Get.isRegistered<CommentsController>(tag: widget.post.id) == false) {
      Get.find<ExploreController>().pauseAllPlayers();
      showModalBottomSheet(
        context: context,
        builder: (context) => CommentsSheet(post: widget.post),
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        enableDrag: true,
        isDismissible: true,
        useSafeArea: true,
        constraints: BoxConstraints(maxHeight: Get.height * 0.9),
      ).then((_) {
        if (Get.isRegistered<CommentsController>(tag: widget.post.id)) {
          Get.delete<CommentsController>(tag: widget.post.id);
        }
      });
    }
  }

  void _handleReaction() async {
    try {
      if (widget.post.id == null) return;

      if (widget.post.hasReaction) {
        // Remove reaction
        setState(() {
          widget.post.removeReaction();
        });

        sl<UnReactPostUsecase>().call(
          UnReactPostParams(postId: widget.post.id!),
        );
        sl<AnalyticsService>().trackEvent(
          "unlikePostPartner",
          eventProperties: widget.post.eventProperties,
        );
      } else {
        // Add default reaction (LIKE)
        _addReaction(ReactionType.HEART);
      }
    } catch (_) {}
  }

  void _addReaction(ReactionType reactionType) async {
    HapticFeedback.mediumImpact();
    try {
      if (widget.post.id == null) return;

      setState(() {
        widget.post.reactToPost(reactionType);
      });

      sl<ReactPostUsecase>().call(
        ReactPostParams(
          postId: widget.post.id!,
          reactionType: reactionType.toApiString,
        ),
      );
      sl<AnalyticsService>().trackEvent(
        "likePostPartner",
        eventProperties: {
          ...widget.post.eventProperties,
          "reactionType": reactionType.name,
        },
      );
      _removeReactionPicker();
    } catch (_) {}
  }

  void _showReactionPicker() {
    HapticFeedback.mediumImpact();
    if (_reactionPickerOverlay != null) return;

    final RenderBox? renderBox =
        _reactionButtonKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    // Calculate position to show picker above the reaction button
    final pickerWidth = 300.0; // Approximate width of reaction picker
    final pickerHeight = 60.0; // Approximate height of reaction picker

    // Center the picker horizontally relative to the button
    final left = (position.dx + size.width / 2) - (pickerWidth / 2);
    // Position above the button with some padding
    final top = position.dy - pickerHeight - 10;

    // Ensure picker stays within screen bounds
    final screenWidth = Get.width;
    final adjustedLeft = left.clamp(10.0, screenWidth - pickerWidth - 10);
    final adjustedTop = top < 100 ? position.dy + size.height + 10 : top;

    _reactionPickerOverlay = OverlayEntry(
      builder:
          (context) => NotificationListener<ScrollNotification>(
            onNotification: (scrollNotification) {
              // Close overlay when user scrolls
              _removeReactionPicker();
              return false;
            },
            child: GestureDetector(
              onTap: () {
                // Close overlay when user taps outside
                _removeReactionPicker();
              },
              behavior: HitTestBehavior.translucent,
              child: Stack(
                children: [
                  // Full screen barrier to detect outside clicks
                  Container(
                    width: Get.width,
                    height: Get.height,
                    color: Colors.transparent,
                  ),
                  // Positioned reaction picker
                  Positioned(
                    left: adjustedLeft,
                    top: adjustedTop,
                    child: GestureDetector(
                      onTap: () {
                        // Prevent the overlay from closing when tapping on the picker itself
                      },
                      child: Material(
                        color: Colors.transparent,
                        child: ReactionPicker(
                          currentReaction: widget.post.myReaction,
                          onReactionSelected: (reactionType) {
                            _addReaction(reactionType);
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );

    Overlay.of(context).insert(_reactionPickerOverlay!);
  }

  void _removeReactionPicker() {
    _reactionPickerOverlay?.remove();
    _reactionPickerOverlay = null;
  }

  Widget _getReactionIcon(ReactionType reactionType) {
    return Text(reactionType.emoji, style: TextStyle(fontSize: 20));
  }

  void _handleDoubleTap() {
    if (!widget.post.hasReaction) {
      _addReaction(ReactionType.HEART);
      _heartAnimationController.forward(from: 0).then((_) {
        _heartAnimationController.reverse();
      });
    }
  }

  @override
  void dispose() {
    _heartAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      elevation: 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      CustomProfilePicture(
                        avatarURL: widget.post.user?.avatar,
                        name: widget.post.user?.name ?? 'Anonymous',
                        radius: 16,
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                widget.post.user?.name ?? 'Anonymous',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                              widget.post.user?.tagWidget ??
                                  const SizedBox.shrink(),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.post.timeAgo,
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (widget.post.user?.role == AccountType.DEMAND &&
                    (widget.isViewPost ||
                        Get.find<ExploreController>().selectedTabIndex.value ==
                            1))
                  FutureBuilder<GetReverseCallingStatsResponseModel?>(
                    future: _reverseCallAllowedFuture,
                    builder: (context, snapshot) {
                      if (snapshot.data?.isCallAllowed == true) {
                        return GestureDetector(
                          onTap: () {
                            _openReverseCallDialog(snapshot.data);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Get.theme.primaryColor),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            margin: const EdgeInsets.only(right: 8),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.call,
                                  color: Get.theme.primaryColor,
                                  size: 18.0,
                                ),
                                const SizedBox(width: 4.0),
                                Text(
                                  'Call',
                                  style: TextStyle(
                                    fontSize: FontSize.xL,
                                    fontWeight: FontWeight.bold,
                                    color: Get.theme.primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                SizedBox(
                  width: 20,
                  child: PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert_rounded, size: 20),
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    itemBuilder:
                        (context) => [
                          PopupMenuItem<String>(
                            value: 'report',
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.report_outlined,
                                  color: Colors.red[400],
                                  size: 18,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Report Post',
                                  style: TextStyle(
                                    color: Colors.red[400],
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                    onSelected: (value) {
                      if (value == 'report') {
                        HapticFeedback.vibrate();
                        sl<AnalyticsService>().trackEvent(
                          "reportPostPartner",
                          eventProperties: widget.post.eventProperties,
                        );
                        Get.back();
                        AlertService.showSnackBar(
                          snackBarType: SnackBarType.Warning,
                          title: LocaleKeys.liveReportPost.tr,
                          subtitle: LocaleKeys.livePostReportedSuccessfully.tr,
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onDoubleTap: _handleDoubleTap,
            child: _buildMediaContent(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      key: _reactionButtonKey,
                      onTap: _handleReaction,
                      onLongPress: _showReactionPicker,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        child: Row(
                          children: [
                            widget.post.hasReaction
                                ? _getReactionIcon(widget.post.myReaction!)
                                : const Icon(Icons.favorite_border),
                            const SizedBox(width: 4),
                          ],
                        ),
                      ),
                    ),
                    if (widget.post.reactionCounts?.totalReactions != null &&
                        widget.post.reactionCounts!.totalReactions! > 0)
                      GestureDetector(
                        onTap: () {
                          if (widget.post.id != null) {
                            Get.bottomSheet(
                              ReactionsBottomSheet(post: widget.post),
                              isScrollControlled: true,
                            );
                          }
                        },
                        child: Text(
                          '${widget.post.reactionCounts?.totalReactions}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.mode_comment_outlined),
                      visualDensity: VisualDensity.compact,
                      onPressed: _showComments,
                    ),
                    if (widget.post.totalCommentCount != null &&
                        widget.post.totalCommentCount! > 0)
                      Text(
                        '${widget.post.totalCommentCount}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                  ],
                ),
                if (widget.post.mostRelevantComment != null &&
                    widget.post.mostRelevantComment?.commentType ==
                        CommentType.TEXT)
                  GestureDetector(
                    onTap: _showComments,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 6, top: 4),
                      child: RichText(
                        text: TextSpan(
                          style: DefaultTextStyle.of(context).style,
                          children: [
                            TextSpan(
                              text:
                                  '${widget.post.mostRelevantComment?.user?.name ?? 'Anonymous'} ',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(
                              text:
                                  widget.post.mostRelevantComment!.textContent,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaContent() {
    return Container(
      width: Get.width,
      height: Get.width,
      color: widget.post.backgroundColor,
      child: Stack(
        alignment: Alignment.center,
        children: [
          _buildMediaContentByType(),
          ScaleTransition(
            scale: Tween<double>(begin: 0.8, end: 1.0).animate(
              CurvedAnimation(
                parent: _heartAnimationController,
                curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
              ),
            ),
            child: FadeTransition(
              opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                CurvedAnimation(
                  parent: _heartAnimationController,
                  curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
                ),
              ),
              child: const Icon(Icons.favorite, color: Colors.white, size: 80),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaContentByType() {
    switch (widget.post.postType) {
      case PostMediaType.IMAGE:
        if (widget.post.textOverlay?.isNotEmpty ?? false) {
          return _buildImageWithTextContent();
        }
        return _buildImageContent();
      case PostMediaType.AUDIO:
        return _buildAudioContent();
      case PostMediaType.TEXT:
        return _buildTextContent();
      case PostMediaType.VIDEO:
        return _buildVideoContent();
      case null:
        return const SizedBox.shrink();
    }
  }

  Widget _buildImageContent() {
    if ((widget.post.mediaUrl?.isEmpty ?? true)) {
      return const Center(
        child: Text(
          'No image available',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return FastCachedImage(
      url: widget.post.mediaUrl ?? '',
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.cover,
      errorBuilder:
          (context, url, error) => const Center(
            child: Text(
              'This image is not available',
              style: TextStyle(color: Colors.white),
            ),
          ),
    );
  }

  Widget _buildImageWithTextContent() {
    final textStyle = widget.post.getTextStyle();
    return Container(
      width: Get.width,
      height: Get.width,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: widget.post.backgroundColor,
        image: DecorationImage(
          image: FastCachedImageProvider(widget.post.mediaUrl ?? ''),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black.withValues(alpha: 0.7),
            BlendMode.darken,
          ),
        ),
      ),
      child: Text(
        widget.post.textOverlay ?? '',
        style: textStyle.copyWith(color: widget.post.backgroundColor),
        textAlign: TextAlign.center,
        maxLines: 10,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildAudioContent() {
    if ((widget.post.mediaUrl?.isEmpty ?? true)) {
      return const Center(
        child: Text(
          'No audio available',
          style: TextStyle(color: Colors.white),
        ),
      );
    }
    return PostAudioPlayer(
      audioUrl: widget.post.mediaUrl ?? '',
      width: Get.width * 0.8,
      height: 60,
      backgroundColor: Colors.transparent,
      textColor: widget.post.backgroundColor,
    );
  }

  Widget _buildVideoContent() {
    if ((widget.post.mediaUrl?.isEmpty ?? true)) {
      return const Center(
        child: Text(
          'No video available',
          style: TextStyle(color: Colors.white),
        ),
      );
    }
    return PostVideoPlayer(
      videoUrl: widget.post.mediaUrl ?? '',
      thumbnailUrl: widget.post.thumbnailUrl,
      width: Get.width,
      height: Get.width,
      backgroundColor: widget.post.backgroundColor,
      autoPlay: true,
      avatarUrl: widget.post.avatarUrl ?? '',
    );
  }

  Widget _buildTextContent() {
    final textStyle = widget.post.getTextStyle();
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        widget.post.textOverlay ?? '',
        style: textStyle,
        textAlign: TextAlign.center,
        maxLines: 10,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
