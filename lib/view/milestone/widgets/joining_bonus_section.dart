import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/core/injection_container.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/core/services/milestone_rewards_service.dart';
import 'package:voiceclub_partner/domain/usecases/wallet/get_payout_count.dart';
import 'package:voiceclub_partner/view/milestone/certificate_screen.dart';
import 'package:voiceclub_partner/view/milestone/widgets/milestone_gift_popup.dart';
import 'package:voiceclub_partner/view/widgets/gradient_linear_progress_indicator.dart';
import 'package:voiceclub_partner/view/widgets/gradient_text.dart';

class JoiningBonusSection extends StatefulWidget {
  const JoiningBonusSection({super.key});

  @override
  State<JoiningBonusSection> createState() => _JoiningBonusSectionState();
}

class _JoiningBonusSectionState extends State<JoiningBonusSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _progressAnimation;

  int currentPayoutCount = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    fetchPayoutCount();
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) super.setState(fn);
  }

  Future<void> fetchPayoutCount() async {
    try {
      final response = await sl<GetPayoutCountUseCase>().call(NoParams());
      if (response.data != null && response.error == null) {
        currentPayoutCount = response.data?.payoutCount ?? 0;

        _progressAnimation = IntTween(
          begin: 0,
          end: currentPayoutCount,
        ).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
        );

        _controller.forward();

        setState(() {
          isLoading = false;
        });

        WidgetsBinding.instance.addPostFrameCallback((_) {
          checkAndShowCongratsDialog();
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  double progressValue(int payoutCount) {
    // Progress based on payout count, max 5 payouts for bonuses
    if (payoutCount < 2) {
      return 0.05; // Minimum progress to show some visual feedback
    } else if (payoutCount < 3) {
      return 0.25; // 25% progress for 2nd payout
    } else if (payoutCount < 4) {
      return 0.5; // 50% progress for 3rd payout
    } else if (payoutCount >= 4) {
      return 0.10; // 75% progress for 4th payout
    } else {
      return 0.10;
    }
  }

  void checkAndShowCongratsDialog() async {
    await Future.delayed(const Duration(seconds: 4));
    JoiningBonus? nearestBonus = getNearestCompletedBonus();

    if (nearestBonus == null) return; // No bonus unlocked yet

    bool hasSeen = await MilestoneRewardsService.isLifetimeRewardShown(
      nearestBonus.payoutNumber,
    );

    if (!hasSeen) {
      HapticFeedback.vibrate();
      Get.dialog(
        MilestoneGiftPopup(
          assetPath: nearestBonus.imagePath,
          gift: nearestBonus.bonusTitle,
        ),
      );
      await MilestoneRewardsService.markLifetimeRewardAsShown(
        nearestBonus.payoutNumber,
      );
    }
  }

  JoiningBonus? getNearestCompletedBonus() {
    JoiningBonus? nearestBonus;

    for (var bonus in JoiningBonus.values) {
      if (bonus.isUnlocked(currentPayoutCount)) {
        nearestBonus = bonus;
      } else {
        break; // Stop loop once bonus is not unlocked
      }
    }

    return nearestBonus;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

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
                          i < JoiningBonus.values.length;
                          i++
                        ) ...[
                          AnimatedBuilder(
                            animation: _progressAnimation,
                            builder: (_, _) {
                              final bonus = JoiningBonus.values[i];
                              final isUnlocked = bonus.isUnlocked(
                                _progressAnimation.value,
                              );

                              return Container(
                                padding: const EdgeInsets.all(4.0),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(0xFFE0E0E0),
                                  gradient:
                                      isUnlocked
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
                          if (i != JoiningBonus.values.length - 1)
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
                            "Payout Count: ${_progressAnimation.value}",
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
                    for (final bonus in JoiningBonus.values)
                      _buildBonusCard(bonus),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBonusCard(JoiningBonus bonus) {
    return AnimatedBuilder(
      animation: _progressAnimation,
      builder: (_, _) {
        final isUnlocked = bonus.isUnlocked(_progressAnimation.value);

        return GestureDetector(
          onTap: () {
            if (bonus == JoiningBonus.certificate && isUnlocked) {
              Get.to(() => const CertificateScreen());
            }
          },
          child: Container(
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
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.asset(
                    bonus.imagePath,
                    height: 96.0,
                    width: 96.0,
                  ),
                ),
                const SizedBox(width: 8.0),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: GradientText(
                          bonus.bonusTitle,
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
                          bonus.description,
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
                if (bonus == JoiningBonus.certificate)
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 16.0,
                    color: Colors.grey,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
