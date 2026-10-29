import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/core/constants/asset_constants.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/core/services/formatter.dart';
import 'package:voiceclub_partner/modules/controller/achievements_controller.dart';
import 'package:voiceclub_partner/modules/controller/wallet_controller.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';

class AchievementsSection extends StatelessWidget {
  const AchievementsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AchievementsController(), permanent: true);
    final walletController = Get.find<WalletController>();

    return Obx(() {
      if (controller.isLoading.value) {
        return const SizedBox.shrink();
      }

      final showAny =
          controller.shouldShowYearlyNext.value ||
          controller.shouldShowLifetimeNext.value;

      if (!showAny) return const SizedBox.shrink();

      final cards = <Widget>[];

      if (controller.shouldShowYearlyNext.value) {
        final nextTarget = _getNextTargetFromGifts(controller);
        final remaining = (nextTarget - controller.yearlyEarning.value).clamp(
          0,
          nextTarget,
        );
        final image = _getNextGiftImage(controller);
        cards.add(
          _CouponCard(
            leading:
                image != null
                    ? FastCachedImage(url: image, width: 48, height: 48)
                    : Image.asset(AssetConstants.money, height: 48, width: 48),
            title: LocaleKeys.homeYearlyReward.tr,
            subtitle: LocaleKeys.homeAmountLeft.tr,
            amountText: Formatter.formatIndianCurrency(remaining),
            iconBackgroundColor: const Color(0xFFF0F8FF),
            onTap: () {
              walletController.fetchAndShowMiletoneEarnings(
                selectedTabIndex: 0,
                isFromHomeScreen: true,
              );
            },
          ),
        );
      }

      if (controller.shouldShowLifetimeNext.value) {
        final next = _getNextLifetimeTarget(controller);
        final remaining = (next - controller.lifetimeEarning.value).clamp(
          0,
          next,
        );
        cards.add(
          _CouponCard(
            leading: Image.asset(AssetConstants.money, height: 48, width: 48),
            title: LocaleKeys.homeLifetimeReward.tr,
            subtitle: LocaleKeys.homeAmountLeft.tr,
            amountText: Formatter.formatIndianCurrency(remaining),
            iconBackgroundColor: const Color(0xFFF8F0FF),
            onTap: () {
              walletController.fetchAndShowMiletoneEarnings(
                selectedTabIndex: 1,
                isFromHomeScreen: true,
              );
            },
          ),
        );
      }

      return Container(
        height: 120,
        width: Get.width,
        padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            spacing: 10,
            children:
                cards.map((card) {
                  return card;
                }).toList(),
          ),
        ),
      );
    });
  }

  int _getNextTargetFromGifts(AchievementsController controller) {
    final list = controller.gifts.value.gifts ?? [];
    for (final g in list) {
      final target = (g.targetEarnings ?? 0).toInt();
      if (controller.yearlyEarning.value < target) return target;
    }
    return controller.yearlyEarning.value;
  }

  String? _getNextGiftImage(AchievementsController controller) {
    final list = controller.gifts.value.gifts ?? [];
    for (final g in list) {
      final target = (g.targetEarnings ?? 0).toInt();
      if (controller.yearlyEarning.value < target) return g.imagePath;
    }
    return null;
  }

  int _getNextLifetimeTarget(AchievementsController controller) {
    for (final gift in LifetimeRewardGift.values) {
      if (controller.lifetimeEarning.value < gift.targetEarnings) {
        return gift.targetEarnings;
      }
    }
    return controller.lifetimeEarning.value;
  }
}

class DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = const Color(0xFFE5E5E5)
          ..strokeWidth = 1.0
          ..style = PaintingStyle.stroke;

    const dashWidth = 4.0;
    const dashSpace = 3.0;
    double startY = 0.0;

    while (startY < size.height) {
      canvas.drawLine(Offset(0, startY), Offset(0, startY + dashWidth), paint);
      startY += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class CouponCardClipper extends CustomClipper<Path> {
  final double notchRadius;
  final double
  dashLinePosition; // Position where the dashed line is (from left edge)

  CouponCardClipper({this.notchRadius = 6.0, this.dashLinePosition = 104.0});

  @override
  Path getClip(Size size) {
    final path = Path();
    final notchX = dashLinePosition; // X position of the dashed line

    // Start from top-left with radius
    path.moveTo(20, 0);

    // Top edge to the notch area
    path.lineTo(notchX - notchRadius, 0);

    // Top notch (semicircle going upward/outward)
    path.arcToPoint(
      Offset(notchX + notchRadius, 0),
      radius: Radius.circular(notchRadius),
      clockwise: false, // This makes it go outward (up)
    );

    // Continue top edge to top-right corner
    path.lineTo(size.width - 20, 0);
    path.arcToPoint(Offset(size.width, 20), radius: const Radius.circular(20));

    // Right edge
    path.lineTo(size.width, size.height - 20);
    path.arcToPoint(
      Offset(size.width - 20, size.height),
      radius: const Radius.circular(20),
    );

    // Bottom edge to the notch area
    path.lineTo(notchX + notchRadius, size.height);

    // Bottom notch (semicircle going downward/outward)
    path.arcToPoint(
      Offset(notchX - notchRadius, size.height),
      radius: Radius.circular(notchRadius),
      clockwise: false, // This makes it go outward (down)
    );

    // Continue bottom edge to bottom-left corner
    path.lineTo(20, size.height);
    path.arcToPoint(
      Offset(0, size.height - 20),
      radius: const Radius.circular(20),
    );

    // Left edge
    path.lineTo(0, 20);
    path.arcToPoint(Offset(20, 0), radius: const Radius.circular(20));

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CouponCardClipper oldClipper) {
    return oldClipper.notchRadius != notchRadius ||
        oldClipper.dashLinePosition != dashLinePosition;
  }
}

class _CouponCard extends StatelessWidget {
  final Widget leading;
  final String title;
  final String subtitle;
  final String? amountText;
  final VoidCallback? onTap;
  final Color? iconBackgroundColor;

  const _CouponCard({
    required this.leading,
    required this.title,
    required this.subtitle,
    required this.amountText,
    this.onTap,
    this.iconBackgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth > 600 ? 280.0 : screenWidth * 0.60;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 104,
        width: cardWidth,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: const Color(0x0F000000),
              blurRadius: 16,
              offset: const Offset(0, 4),
              spreadRadius: 0,
            ),
            BoxShadow(
              color: const Color(0x08000000),
              blurRadius: 4,
              offset: const Offset(0, 2),
              spreadRadius: 0,
            ),
          ],
        ),
        child: ClipPath(
          clipper: CouponCardClipper(notchRadius: 12.0, dashLinePosition: 84.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFFF0F0F0), width: 1),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  // Icon Container
                  Container(
                    decoration: BoxDecoration(
                      color: iconBackgroundColor ?? const Color(0xFFF8F9FF),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFEEEEEE),
                        width: 1,
                      ),
                    ),
                    padding: const EdgeInsets.all(10),
                    child: Center(
                      child: SizedBox(width: 30, height: 30, child: leading),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Dashed separator line
                  SizedBox(
                    width: 1,
                    height: 60,
                    child: CustomPaint(painter: DashedLinePainter()),
                  ),
                  const SizedBox(width: 16),
                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: FontSize.xXL,
                            fontWeight: Weight.heavy,
                            color: ApplicationColors.black,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: FontSize.M,
                            fontWeight: Weight.normal,
                            color: ApplicationColors.textGrey,
                            letterSpacing: 0.1,
                          ),
                        ),
                        if (amountText != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            amountText!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: FontSize.L,
                              color: ApplicationColors.primaryRed,
                              fontWeight: Weight.heavy,
                              letterSpacing: 0.1,
                            ),
                          ),
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
    );
  }
}

class JoiningBonusCardData {
  final String imagePath;
  final String title;
  final String subtitle;

  JoiningBonusCardData(this.imagePath, this.title, this.subtitle);
}
