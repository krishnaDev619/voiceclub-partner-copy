import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/core/services/formatter.dart';
import 'package:voiceclub_partner/core/services/milestone_rewards_service.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';
import 'package:voiceclub_partner/view/milestone/widgets/milestone_gift_popup.dart';
import 'package:voiceclub_partner/view/widgets/gradient_linear_progress_indicator.dart';
import 'package:voiceclub_partner/view/widgets/gradient_text.dart';

class LifetimeRewardsSection extends StatefulWidget {
  final int currentLifetimeEarning;

  const LifetimeRewardsSection({
    super.key,
    required this.currentLifetimeEarning,
  });

  @override
  State<LifetimeRewardsSection> createState() => _LifetimeRewardsSectionState();
}

class _LifetimeRewardsSectionState extends State<LifetimeRewardsSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    _progressAnimation = IntTween(
      begin: 0,
      end: widget.currentLifetimeEarning,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _controller.forward();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkAndShowCongratsDialog();
    });
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) super.setState(fn);
  }

  void checkAndShowCongratsDialog() async {
    await Future.delayed(const Duration(seconds: 4));
    LifetimeRewardGift? nearestGift = getNearestCompletedGift();

    if (nearestGift == null) return; // No reward unlocked yet

    bool hasSeen = await MilestoneRewardsService.isLifetimeRewardShown(
      nearestGift.id,
    );

    if (!hasSeen) {
      HapticFeedback.vibrate();
      Get.dialog(
        MilestoneGiftPopup(
          assetPath: nearestGift.imagePath,
          gift: nearestGift.title,
        ),
      );
      await MilestoneRewardsService.markLifetimeRewardAsShown(nearestGift.id);
    }
  }

  LifetimeRewardGift? getNearestCompletedGift() {
    LifetimeRewardGift? nearestGift;

    for (var gift in LifetimeRewardGift.values) {
      if (widget.currentLifetimeEarning >= gift.targetEarnings) {
        nearestGift = gift;
      } else {
        break; // Stop loop once earnings are below target
      }
    }

    return nearestGift;
  }

  double progressValue(int earnings) {
    if (earnings < 1500000) {
      return 0.05 + (earnings / 1500000 * 0.20);
    } else if (earnings < 2500000) {
      return 0.25 + (earnings - 1500000) / 1000000 * 0.25;
    } else if (earnings < 3500000) {
      return 0.5 + (earnings - 2500000) / 1000000 * 0.25;
    } else if (earnings < 5000000) {
      return 0.75 + (earnings - 3500000) / 1500000 * 0.25;
    } else {
      return 1;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: NoSplashScrollBehaviour(),
      child: SingleChildScrollView(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(width: 16.0),
            SizedBox(
              height: 466.0,
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  SizedBox(
                    width: 16.0,
                    height: 466.0,
                    child: RotatedBox(
                      quarterTurns: -3,
                      child: AnimatedBuilder(
                        animation: _progressAnimation,
                        builder: (_, _) {
                          return GradientLinearProgressIndicator(
                            value: progressValue(_progressAnimation.value),
                            backgroundColor: const Color(0xFFE9E8E8),
                            borderRadius: BorderRadius.circular(12),
                          );
                        },
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 90.0),
                    child: Column(
                      children: [
                        for (
                          int i = 0;
                          i < LifetimeRewardGift.values.length;
                          i++
                        ) ...[
                          AnimatedBuilder(
                            animation: _progressAnimation,
                            builder: (_, _) {
                              return Container(
                                padding: const EdgeInsets.all(4.0),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(0xFFE0E0E0),
                                  gradient:
                                      _progressAnimation.value >=
                                              LifetimeRewardGift
                                                  .values[i]
                                                  .targetEarnings
                                          ? Gradients.primaryGradient()
                                          : null,
                                ),
                                child: const Icon(
                                  Icons.star_rounded,
                                  size: 20.0,
                                  color: Colors.white,
                                ),
                              );
                            },
                          ),
                          if (i != LifetimeRewardGift.values.length - 1)
                            const SizedBox(height: 88.0),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16.0),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 8.0),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: AnimatedBuilder(
                        animation: _progressAnimation,
                        builder: (_, _) {
                          return GradientText(
                            LocaleKeys.liveLifetimeEarnings.trParams({
                              'amount': Formatter.formatIndianCurrency(
                                _progressAnimation.value,
                              ),
                            }),
                            maxLines: 1,
                            gradient: Gradients.primaryGradient(),
                            style: const TextStyle(
                              fontSize: 14.0,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24.0),
                    for (final reward in LifetimeRewardGift.values)
                      _buildRewardCard(reward),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRewardCard(LifetimeRewardGift reward) {
    return AnimatedBuilder(
      animation: _progressAnimation,
      builder: (_, _) {
        bool isUnlocked = _progressAnimation.value >= reward.targetEarnings;
        return Container(
          height: 96.0,
          margin: const EdgeInsets.only(bottom: 24.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: GradientBoxBorder(
              gradient:
                  isUnlocked
                      ? Gradients.primaryGradient()
                      : Gradients.borderGrey(),
            ),
            color: const Color(0xFFFFFEFD),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                reward.imagePath,
                height: 96.0,
                width: 96.0,
              ), // Icon Image
              const SizedBox(width: 8.0),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: GradientText(
                        reward.title,
                        gradient:
                            isUnlocked
                                ? Gradients.textBlack()
                                : Gradients.textGrey(),
                        maxLines: 1,
                        style: const TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF676767),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: GradientText(
                        LocaleKeys.liveTargetAmount.trParams({
                          'amount': Formatter.formatIndianCurrency(
                            reward.targetEarnings,
                          ),
                        }),
                        maxLines: 1,
                        gradient:
                            isUnlocked
                                ? Gradients.textBlack()
                                : Gradients.textGrey(),
                        style: const TextStyle(
                          color: Color(0xFF676767),
                          fontSize: 12.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8.0),
            ],
          ),
        );
      },
    );
  }
}
