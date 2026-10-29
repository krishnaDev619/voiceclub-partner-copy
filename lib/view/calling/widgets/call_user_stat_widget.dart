import 'package:flutter/material.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';
import 'package:get/get.dart';

class CallUserStatWidget extends StatelessWidget {
  const CallUserStatWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: _TooltipBubbleClipper(),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15.0),
        ),

        padding: const EdgeInsets.only(top: 20.0, right: 5, left: 5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _StatRow(
              index: 1,
              label: LocaleKeys.live1stCall.tr,
              badge: 'New User',
              isNewUser: true,
              showDivider: true,
            ),
            _StatRow(
              index: 2,
              label: LocaleKeys.live2ndCall.tr,
              badge: 'New User',
              isNewUser: true,
              showDivider: true,
            ),
            _StatRow(
              index: 3,
              label: LocaleKeys.live3rdCall.tr,
              badge: 'New User',
              isNewUser: true,
              showDivider: true,
            ),
            _StatRow(
              index: 4,
              label: LocaleKeys.live4Calls.tr,
              badge: 'Old User',
              isNewUser: false,
              showDivider: false,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final int index;
  final String label;
  final String badge;
  final bool isNewUser;
  final bool showDivider;

  const _StatRow({
    required this.index,
    required this.label,
    required this.badge,
    required this.isNewUser,
    required this.showDivider,
  });

  Color get _circleBackground =>
      isNewUser ? const Color(0xFFDFF2E0) : const Color(0xFFFFE6CF);

  Color get _circleText =>
      isNewUser ? const Color(0xFF3A9E4F) : const Color(0xFFE07A1A);

  Color get _badgeBackground =>
      isNewUser ? const Color(0xFFDFF2E0) : const Color(0xFFFFE6CF);

  Color get _badgeText =>
      isNewUser ? const Color(0xFF2D8A40) : const Color(0xFFD9731A);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
          child: Row(
            children: [
              Container(
                width: 32.0,
                height: 32.0,
                decoration: BoxDecoration(
                  color: _circleBackground,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                alignment: Alignment.center,
                child: Text(
                  '$index',
                  style: TextStyle(
                    color: _circleText,
                    fontWeight: FontWeight.w600,
                    fontSize: 14.0,
                  ),
                ),
              ),
              const SizedBox(width: 7.0),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              ),
              Container(
                width: 80,
                padding: const EdgeInsets.symmetric(
                  horizontal: 7.0,
                  vertical: 5.0,
                ),
                decoration: BoxDecoration(
                  color: _badgeBackground,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Text(
                  badge,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _badgeText,
                    fontWeight: FontWeight.w600,
                    fontSize: 13.0,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
          const Divider(height: 1.0, thickness: 1.0, color: Color(0xFFEEEEEE)),
      ],
    );
  }
}

class _TooltipBubbleClipper extends CustomClipper<Path> {
  static const double _radius = 14.0;
  static const double _arrowWidth = 20.0;
  static const double _arrowHeight = 14.0;

  @override
  Path getClip(Size size) {
    final double arrowLeft = size.width / 4 - _arrowWidth / 2;
    final double arrowRight = size.width / 4 + _arrowWidth / 2;

    final path =
        Path()
          ..moveTo(_radius, _arrowHeight)
          ..lineTo(arrowLeft, _arrowHeight)
          ..lineTo(size.width / 4, 0)
          ..lineTo(arrowRight, _arrowHeight)
          ..lineTo(size.width - _radius, _arrowHeight)
          ..quadraticBezierTo(
            size.width,
            _arrowHeight,
            size.width,
            _arrowHeight + _radius,
          )
          ..lineTo(size.width, size.height - _radius)
          ..quadraticBezierTo(
            size.width,
            size.height,
            size.width - _radius,
            size.height,
          )
          ..lineTo(_radius, size.height)
          ..quadraticBezierTo(0, size.height, 0, size.height - _radius)
          ..lineTo(0, _arrowHeight + _radius)
          ..quadraticBezierTo(0, _arrowHeight, _radius, _arrowHeight)
          ..close();

    return path;
  }

  @override
  bool shouldReclip(_TooltipBubbleClipper oldClipper) => false;
}
