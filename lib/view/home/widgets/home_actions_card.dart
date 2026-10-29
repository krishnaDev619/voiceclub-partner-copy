import 'package:flutter/material.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';

class HomeActionCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final int? pendingCount;
  final bool? isCardExpandable;
  final bool? isCardExpanded;
  final VoidCallback? onTap;

  const HomeActionCard({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.pendingCount,
    this.isCardExpandable,
    this.isCardExpanded,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              isCardExpandable == true && isCardExpanded == true
                  ? BorderRadius.vertical(top: Radius.circular(10))
                  : BorderRadius.circular(10),
          boxShadow:
              isCardExpandable == true
                  ? null
                  : const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4.0,
                      spreadRadius: 0.4,
                    ),
                  ],
        ),
        margin: EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0),
        padding:
            icon != null
                ? const EdgeInsets.all(10.0)
                : const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: HomeActionCardContent(
          title: title,
          icon: icon,
          pendingCount: pendingCount,
          isCardExpandable: isCardExpandable,
          isCardExpanded: isCardExpanded,
        ),
      ),
    );
  }
}

class HomeActionCardContent extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final int? pendingCount;
  final bool? isCardExpandable;
  final bool? isCardExpanded;

  const HomeActionCardContent({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.pendingCount,
    this.isCardExpandable,
    this.isCardExpanded,
  });

  @override
  Widget build(BuildContext context) {
    final isFeedbackPending = pendingCount != null && pendingCount! > 0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            if (icon != null)
              Container(
                decoration: BoxDecoration(
                  color: Color(0xFFFFF0F0),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                padding: EdgeInsets.all(12.0),
                child: Icon(
                  icon,
                  size: 26.0,
                  color: ApplicationColors.primaryRed,
                ),
              ),
            const SizedBox(width: 8.0),
            Text(title, style: TextStyles.h4),
          ],
        ),
        Container(
          height: 20.0,
          width: 20.0,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color:
                pendingCount != null && pendingCount! > 0
                    ? Colors.red
                    : Color.fromRGBO(238, 100, 100, 0.12),
          ),
          child:
              isFeedbackPending
                  ? Center(child: Text("$pendingCount", style: TextStyles.h3))
                  : Icon(
                    isCardExpandable == true
                        ? isCardExpanded == true
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down
                        : Icons.arrow_forward_ios,
                    size: isCardExpandable == true ? 16.0 : 10.0,
                    color: Color.fromRGBO(238, 100, 100, 1),
                  ),
        ),
      ],
    );
  }
}
