import 'package:flutter/material.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';

class DemoHomeActionCard extends StatelessWidget {
  final String title;
  final bool? isCardExpandable;
  final bool? isCardExpanded;
  final VoidCallback? onTap;

  const DemoHomeActionCard({
    super.key,
    required this.title,
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
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: DemoHomeActionCardContent(
          title: title,
          isCardExpandable: isCardExpandable,
          isCardExpanded: isCardExpanded,
        ),
      ),
    );
  }
}

class DemoHomeActionCardContent extends StatelessWidget {
  final String title;
  final bool? isCardExpandable;
  final bool? isCardExpanded;

  const DemoHomeActionCardContent({
    super.key,
    required this.title,
    this.isCardExpandable,
    this.isCardExpanded,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: TextStyles.h4),
        Container(
          height: 20.0,
          width: 20.0,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Color.fromRGBO(238, 100, 100, 0.12),
          ),
          child: Icon(
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
