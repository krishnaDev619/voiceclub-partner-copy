import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/core/services/formatter.dart';
import 'package:voiceclub_partner/core/services/milestone_rewards_service.dart';
import 'package:voiceclub_partner/data/models/rewards/gifts.dart';
import 'package:voiceclub_partner/view/milestone/controllers/milestone_rewards_controller.dart';
import 'package:voiceclub_partner/view/milestone/widgets/milestone_gift_popup.dart';
import 'package:voiceclub_partner/view/profile/widgets/claimed_gift_dialog.dart';
import 'package:voiceclub_partner/view/profile/widgets/gift_selection_bottom_sheet.dart';
import 'package:voiceclub_partner/view/profile/widgets/pending_gift_dialog.dart';
import 'package:voiceclub_partner/view/widgets/gradient_text.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';

class YearlyRewardsSection extends StatefulWidget {
  final int currentYearlyEarning;

  const YearlyRewardsSection({super.key, required this.currentYearlyEarning});

  @override
  State<YearlyRewardsSection> createState() => _YearlyRewardsSectionState();
}

class _YearlyRewardsSectionState extends State<YearlyRewardsSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _progressAnimation;
  final _scrollController = ScrollController();
  final _rewardsController = Get.find<MilestoneRewardsController>();

  @override
  void initState() {
    super.initState();
    _fetchAndShowReward();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    _progressAnimation = IntTween(
      begin: 0,
      end: widget.currentYearlyEarning,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _controller.forward();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) super.setState(fn);
  }

  void _fetchAndShowReward() async {
    await _rewardsController.fetchGifts();
    await Future.delayed(const Duration(seconds: 4));
    RewardGift? nearestGift = getNearestCompletedGift();

    if (nearestGift == null) return; // No reward unlocked yet

    // Check if the gift is already claimed with approved status
    final claimedGift = _rewardsController.gifts.value.claimedGifts
        ?.firstWhereOrNull((element) => element.giftId == nearestGift.id);

    if (claimedGift != null && claimedGift.status == GiftClaimStatus.APPROVED) {
      // Check if we've already shown the claimed gift dialog
      bool hasShownClaimedDialog =
          await MilestoneRewardsService.isClaimedGiftDialogShown(
            nearestGift.id ?? 0,
          );

      if (!hasShownClaimedDialog) {
        HapticFeedback.vibrate();
        await Get.dialog(
          ClaimedGiftDialog(gift: claimedGift, rewardGift: nearestGift),
        );
        await MilestoneRewardsService.markClaimedGiftDialogAsShown(
          nearestGift.id ?? 0,
        );
      }
    } else {
      // If not claimed, check if milestone popup should be shown
      bool hasSeen = await MilestoneRewardsService.isRewardShown(
        nearestGift.id ?? 0,
      );

      if (!hasSeen) {
        HapticFeedback.vibrate();
        await Get.dialog(
          MilestoneGiftPopup(
            assetPath: nearestGift.imagePath ?? '',
            gift: nearestGift.title ?? '',
            isYearly: true,
          ),
        );
        await MilestoneRewardsService.markRewardAsShown(nearestGift.id ?? 0);
      }
    }

    // Handle gift claiming based on type
    if (_rewardsController.gifts.value.claimedGifts?.any(
          (e) => e.giftId == nearestGift.id,
        ) ==
        false) {
      if (nearestGift.type == GiftType.GIFT) {
        // Show gift selection bottom sheet for physical gifts
        Get.bottomSheet(
          GiftSelectionBottomSheet(gift: nearestGift),
          isDismissible: false,
          enableDrag: false,
        );
      } else if (nearestGift.type == GiftType.CASH) {
        // Automatically claim cash gifts
        _rewardsController.claimGift(
          giftId: nearestGift.id!,
          type: GiftType.CASH.name,
          address: '',
          amount: nearestGift.cashAmount?.toInt() ?? 0,
        );
      }
    }
  }

  RewardGift? getNearestCompletedGift() {
    RewardGift? nearestGift;

    for (var gift in _rewardsController.gifts.value.gifts ?? []) {
      if (widget.currentYearlyEarning >= gift.targetEarnings) {
        nearestGift = gift;
      } else {
        break; // Stop loop once earnings are below target
      }
    }

    return nearestGift;
  }

  /// If currentYearlyEarning is more than 300000, slowly scroll to the bottom
  void _scrollToBottom() {
    if (widget.currentYearlyEarning > 300000) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(seconds: 3),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
          child: AnimatedBuilder(
            animation: _progressAnimation,
            builder: (_, _) {
              return GradientText(
                LocaleKeys.liveThisYearEarnings.trParams({
                  'amount': Formatter.formatIndianCurrency(
                    _progressAnimation.value,
                  ),
                }),
                gradient: Gradients.primaryGradient(),
                style: const TextStyle(fontWeight: Weight.bold),
              );
            },
          ),
        ),
        Obx(
          () =>
              _rewardsController.gifts.value.gifts?.isNotEmpty ?? false
                  ? Expanded(
                    child: ScrollConfiguration(
                      behavior: NoSplashScrollBehaviour(),
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: SizedBox(
                            width: 320.0,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                _buildCurvedPath(),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0,
                                  ),
                                  child: Column(
                                    children: [
                                      Container(
                                        margin: const EdgeInsets.only(
                                          top: 12.0,
                                        ),
                                        padding: const EdgeInsets.all(8.0),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: Gradients.primaryGradient(),
                                        ),
                                        child: const Icon(
                                          Icons.star_rounded,
                                          color: Colors.white,
                                          size: 54.0,
                                        ),
                                      ),
                                      const SizedBox(height: 90),
                                      for (
                                        int i = 0;
                                        i <
                                            (_rewardsController
                                                    .gifts
                                                    .value
                                                    .gifts
                                                    ?.length ??
                                                0);
                                        i++
                                      ) ...[
                                        giftWidget(
                                          index: i,
                                          gift:
                                              _rewardsController
                                                  .gifts
                                                  .value
                                                  .gifts?[i] ??
                                              RewardGift(),
                                        ),
                                        const SizedBox(height: 50.0),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                  : SizedBox(
                    child: Center(
                      child: Text(LocaleKeys.liveNoGiftsAvailable.tr),
                    ),
                  ),
        ),
      ],
    );
  }

  Widget giftWidget({required int index, required RewardGift gift}) {
    final giftClaimed = _rewardsController.gifts.value.claimedGifts
        ?.firstWhereOrNull((element) => element.giftId == gift.id);
    final isPending = giftClaimed?.status == GiftClaimStatus.PENDING;
    final isClaimed = giftClaimed?.status == GiftClaimStatus.APPROVED;
    return Align(
      alignment: index % 2 == 0 ? Alignment.centerLeft : Alignment.centerRight,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Visibility(
            visible: index % 2 != 0,
            child: Row(
              children: [
                AnimatedBuilder(
                  animation: _progressAnimation,
                  builder: (_, _) {
                    final isCompleted =
                        _progressAnimation.value >= (gift.targetEarnings ?? 0);
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GradientText(
                          gift.title ?? '',
                          gradient:
                              isCompleted
                                  ? Gradients.primaryGradient()
                                  : Gradients.textGrey(),
                          style: const TextStyle(fontWeight: Weight.bold),
                        ),
                        GradientText(
                          LocaleKeys.liveTargetAmount.trParams({
                            'amount': Formatter.formatIndianCurrency(
                              gift.targetEarnings,
                            ),
                          }),
                          gradient:
                              isCompleted
                                  ? Gradients.primaryGradient()
                                  : Gradients.textGrey(),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(width: 20.0),
              ],
            ),
          ),
          Align(
            alignment:
                index % 2 == 0 ? Alignment.centerLeft : Alignment.centerRight,
            child: AnimatedBuilder(
              animation: _progressAnimation,
              builder: (_, _) {
                final isCompleted =
                    _progressAnimation.value >= (gift.targetEarnings ?? 0);
                return GestureDetector(
                  onTap: () {
                    if (isPending) {
                      Get.dialog(
                        PendingGiftDialog(
                          claimedAt: giftClaimed?.claimedAt ?? '',
                        ),
                      );
                    } else if (isClaimed) {
                      Get.dialog(
                        ClaimedGiftDialog(gift: giftClaimed!, rewardGift: gift),
                      );
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: GradientBoxBorder(
                        gradient:
                            isCompleted
                                ? isPending
                                    ? Gradients.textYellow()
                                    : Gradients.primaryGradient()
                                : Gradients.borderGrey(),
                        width: 10.0,
                      ),
                    ),
                    padding: const EdgeInsets.all(1.0),
                    child: FastCachedImage(
                      url: gift.imagePath ?? '',
                      width: 48.0,
                      height: 48.0,
                      fit: BoxFit.fill,
                    ),
                  ),
                );
              },
            ),
          ),
          Visibility(
            visible: index % 2 == 0,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(width: 20.0),
                AnimatedBuilder(
                  animation: _progressAnimation,
                  builder: (_, _) {
                    final isCompleted =
                        _progressAnimation.value >= (gift.targetEarnings ?? 0);
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GradientText(
                          gift.title ?? '',
                          gradient:
                              isCompleted
                                  ? Gradients.primaryGradient()
                                  : Gradients.textGrey(),
                          style: const TextStyle(fontWeight: Weight.bold),
                        ),
                        GradientText(
                          LocaleKeys.liveTargetAmount.trParams({
                            'amount': Formatter.formatIndianCurrency(
                              gift.targetEarnings,
                            ),
                          }),
                          gradient:
                              isCompleted
                                  ? Gradients.primaryGradient()
                                  : Gradients.textGrey(),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// **Draws the Curved Progress Path Dynamically**
  Widget _buildCurvedPath() {
    return AnimatedBuilder(
      animation: _progressAnimation,
      builder: (context, _) {
        return CustomPaint(
          size: const Size(237, 852),
          painter: RPSCustomPainter(currentEarning: _progressAnimation.value),
        );
      },
    );
  }
}

class RPSCustomPainter extends CustomPainter {
  final int currentEarning;

  RPSCustomPainter({required this.currentEarning});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paintStroke =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = size.width * 0.055
          ..strokeCap = StrokeCap.round;

    // Full Path (Gray Background)
    Path fullPath = _createFullPath();
    paintStroke.color = const Color(0xFFDFDFDF);
    canvas.drawPath(fullPath, paintStroke);

    // Progress Path (Gradient Line)
    Path progressPath = _calculateProgressPath(fullPath, currentEarning);
    // Get the progress metric
    // PathMetric pathMetric = progressPath.computeMetrics().first;
    // double progressLength = pathMetric.length;

    // // Extract position using getTangentForOffset()
    // Tangent? tangent = pathMetric.getTangentForOffset(progressLength);
    // if (tangent != null) {
    //   onProgressChanged(tangent.position);
    // }
    // Create a LinearGradient Shader
    Rect bounds = fullPath.getBounds(); // Get path bounds
    Paint gradientPaint =
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [Color(0xFFFF7777), Color(0xFFFF9B6D)],
          ).createShader(bounds) // Apply gradient
          ..style = PaintingStyle.stroke
          ..strokeWidth = size.width * 0.055
          ..strokeCap = StrokeCap.round;
    canvas.drawPath(progressPath, gradientPaint);
  }

  // ✅ Creates the full curved path
  Path _createFullPath() {
    Path path = Path();
    path.moveTo(118.5, 0);
    path.lineTo(118.5, 41);
    path.cubicTo(118.5, 58.1208, 104.621, 72, 87.5, 72);
    path.lineTo(54.5, 72);
    path.lineTo(38, 72);
    path.cubicTo(20.8792, 72, 7, 85.8792, 7, 103);
    path.lineTo(7, 161);
    path.cubicTo(7, 178.121, 20.8792, 192, 38, 192);
    path.lineTo(49.5, 192);
    path.lineTo(199.5, 192);
    path.cubicTo(216.621, 192, 230.5, 205.879, 230.5, 223);
    path.lineTo(230.5, 281);
    path.cubicTo(230.5, 298.121, 216.621, 312, 199.5, 312);
    path.lineTo(118.75, 312);
    path.lineTo(38, 312);
    path.cubicTo(20.8792, 312, 7, 325.879, 7, 343);
    path.lineTo(7, 401);
    path.cubicTo(7, 418.121, 20.8792, 432, 38, 432);
    path.lineTo(118.75, 432);
    path.lineTo(199.5, 432);
    path.cubicTo(216.621, 432, 230.5, 445.879, 230.5, 463);
    path.lineTo(230.5, 521);
    path.cubicTo(230.5, 538.121, 216.621, 552, 199.5, 552);
    path.lineTo(118.75, 552);
    path.lineTo(38, 552);
    path.cubicTo(20.8792, 552, 7, 565.879, 7, 583);
    path.lineTo(7, 641);
    path.cubicTo(7, 658.121, 20.8792, 672, 38, 672);
    path.lineTo(118.75, 672);
    path.lineTo(199.5, 672);
    path.cubicTo(216.621, 672, 230.5, 685.879, 230.5, 703);
    path.lineTo(230.5, 761);
    path.cubicTo(230.5, 778.121, 216.621, 792, 199.5, 792);
    path.lineTo(74.5, 792);
    path.lineTo(38, 792);
    path.cubicTo(20.8792, 792, 7, 805.879, 7, 823);
    path.lineTo(7, 852);
    return path;
  }

  // ✅ Calculates progress dynamically based on earnings
  Path _calculateProgressPath(Path fullPath, int earnings) {
    double progressFactor = _getProgressFactor(earnings);
    return fullPath.computeMetrics().first.extractPath(
      0,
      progressFactor * fullPath.computeMetrics().first.length,
    );
  }

  // ✅ Determines how far along the path we should go
  double _getProgressFactor(int earnings) {
    if (earnings < 50000) {
      return earnings / 50000 * 0.10;
    } else if (earnings < 200000) {
      return 0.10 + ((earnings - 50000) / 150000) * 0.15;
    } else if (earnings < 300000) {
      return 0.25 + ((earnings - 200000) / 100000) * 0.15;
    } else if (earnings < 500000) {
      return 0.40 + ((earnings - 300000) / 200000) * 0.15;
    } else if (earnings < 800000) {
      return 0.55 + ((earnings - 500000) / 300000) * 0.15;
    } else if (earnings < 1000000) {
      return 0.70 + ((earnings - 800000) / 200000) * 0.15;
    } else if (earnings < 1500000) {
      return 0.85 + ((earnings - 1000000) / 500000) * 0.15;
    } else {
      return 1.0; // Full progress
    }
  }

  @override
  bool shouldRepaint(covariant RPSCustomPainter oldDelegate) {
    return oldDelegate.currentEarning != currentEarning;
  }
}
