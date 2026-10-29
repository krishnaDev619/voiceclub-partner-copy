import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/core/constants/asset_constants.dart';
import 'package:voiceclub_partner/data/models/chat/chat_theme.dart';
import 'package:voiceclub_partner/view/widgets/custom_button.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';

class DemoChangeThemeBottomSheet extends StatefulWidget {
  final ChatTheme currentTheme;
  final ValueChanged<ChatTheme> onThemeSelected;
  final List<ChatTheme> themes;
  const DemoChangeThemeBottomSheet({
    super.key,
    required this.currentTheme,
    required this.onThemeSelected,
    required this.themes,
  });

  @override
  State<DemoChangeThemeBottomSheet> createState() =>
      _DemoChangeThemeBottomSheetState();
}

class _DemoChangeThemeBottomSheetState
    extends State<DemoChangeThemeBottomSheet> {
  late ChatTheme selectedTheme;

  @override
  void initState() {
    super.initState();
    selectedTheme = widget.currentTheme;
  }

  void selectTheme(ChatTheme theme) {
    setState(() {
      selectedTheme = theme;
    });
    widget.onThemeSelected(theme);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () {
              Get.back();
            },
            child: const CircleAvatar(
              radius: 22.0,
              backgroundColor: Colors.black26,
              child: Padding(
                padding: EdgeInsets.all(4.0),
                child: Icon(Icons.close, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 6.0),
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.0),
                topRight: Radius.circular(16.0),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  LocaleKeys.demoThemes.tr,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children:
                      widget.themes
                          .where(
                            (element) =>
                                element.isFree ||
                                selectedTheme.id == element.id,
                          )
                          .map((theme) {
                            return ThemeCard(
                              theme: theme,
                              isSelected: selectedTheme == theme,
                              onTap: () => selectTheme(theme),
                            );
                          })
                          .toList(),
                ),
                const SizedBox(height: 16),
                CustomButton(
                  text: LocaleKeys.demoApplyTheme.tr,
                  enabled: selectedTheme != widget.currentTheme,
                  onTap: () {
                    if (selectedTheme != widget.currentTheme) {
                      Get.back<ChatTheme>(result: selectedTheme);
                    }
                  },
                  color: selectedTheme.primaryColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ThemeCard extends StatelessWidget {
  final ChatTheme theme;
  final bool isSelected;
  final VoidCallback onTap;

  const ThemeCard({
    super.key,
    required this.theme,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final width = (Get.width - 84.0) / 3;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(1.0),
            decoration: BoxDecoration(
              border: Border.all(
                color: isSelected ? theme.primaryColor : Colors.transparent,
                width: 2,
              ),
              color: theme == defaultTheme ? const Color(0xFFFFF6F6) : null,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Container(
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Image.asset(
                theme.assetPath ?? AssetConstants.chatBackground,
                width: width,
                height: width * 1.62,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: width,
            padding: const EdgeInsets.symmetric(horizontal: 2.0),
            child: Text(
              theme.displayName ?? "",
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
