import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';

class CustomTab extends StatelessWidget {
  const CustomTab({
    super.key,
    required this.label,
    required this.selected,
    this.selectedBackgroundColor,
    this.unselectedBackgroundColor = Colors.transparent,
    this.selectedContentColor = Colors.white,
    this.unselectedContentColor,
    this.iconData,
    this.borderColor,
    required this.hasBorder,
    this.padding = const EdgeInsets.symmetric(vertical: 8.0),
    this.trailing,
  });

  final String label;
  final bool selected;
  final Color? selectedBackgroundColor;
  final Color? unselectedBackgroundColor;
  final Color? selectedContentColor;
  final Color? unselectedContentColor;
  final IconData? iconData;
  final Color? borderColor;
  final bool hasBorder;
  final EdgeInsets padding;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      constraints: BoxConstraints(minWidth: Get.width / 6),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color:
            selected
                ? (selectedBackgroundColor ?? Get.theme.primaryColor)
                : (unselectedBackgroundColor ?? Get.theme.primaryColor),
        border:
            hasBorder
                ? Border.all(color: borderColor ?? Get.theme.primaryColor)
                : null,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          iconData != null
              ? Padding(
                padding: const EdgeInsets.only(right: 4.0),
                child: Icon(
                  iconData,
                  size: 18.0,
                  color:
                      selected ? selectedContentColor : unselectedContentColor,
                ),
              )
              : const SizedBox.shrink(),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: GoogleFonts.mulish().fontFamily,
              fontSize: FontSize.M,
              fontWeight: FontWeight.bold,
              color: selected ? selectedContentColor : unselectedContentColor,
            ),
          ),
          trailing ?? const SizedBox.shrink(),
        ],
      ),
    );
  }
}
