import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';
import 'package:get/get.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final bool showBackButton;
  final Color backgroundColor;
  final Color titleColor;
  final double titleFontSize;
  final double elevation;
  final Widget? action;
  final bool? centerTitle;

  const CustomAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.showBackButton = true,
    this.backgroundColor = Colors.white,
    this.titleColor = Colors.black,
    this.titleFontSize = 24.0,
    this.elevation = 0.0,
    this.action,
    this.centerTitle,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: elevation,
      leadingWidth: 40.0,
      leading: showBackButton ? const BackButton(color: Colors.black) : null,
      automaticallyImplyLeading: showBackButton,
      backgroundColor: backgroundColor,
      centerTitle: centerTitle,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: backgroundColor,
        statusBarIconBrightness: Brightness.dark,
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                title.isEmpty ? " " : title,
                style: TextStyle(
                  fontSize: titleFontSize,
                  fontWeight: FontWeight.bold,
                  color: titleColor,
                ),
              ),
            ),
          ),
          Visibility(
            visible: subtitle != null,
            replacement: const SizedBox.shrink(),
            child: Text(
              subtitle ?? "",
              style: TextStyle(
                fontSize: FontSize.M,
                color: titleColor.withValues(alpha: 0.7),
              ),
            ),
          ),
        ],
      ),
      actions: action != null ? [action!] : null,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class SliverAppBarCustom extends StatelessWidget {
  const SliverAppBarCustom({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      title: Text(LocaleKeys.liveExplore.tr),
      centerTitle: false,
      backgroundColor: Colors.white,
      elevation: 0.0,
    );
  }
}
