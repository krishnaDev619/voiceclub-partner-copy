import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';

class LanguageWidget extends StatelessWidget {
  final bool isSelected;
  final String language;
  final String? localeAsset;
  final VoidCallback onTap;
  final String? subtitle;

  const LanguageWidget({
    super.key,
    required this.isSelected,
    required this.language,
    this.localeAsset,
    required this.onTap,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color:
              isSelected
                  ? Get.theme.primaryColor.withValues(alpha: 0.2)
                  : const Color(0xFFF5F5F5),
        ),
        child: Column(
          children: [
            Row(
              children: [
                RadioGroup(
                  onChanged: (value) {
                    if (value != null) {
                      onTap();
                    }
                  },
                  groupValue: isSelected ? language : null,
                  child: Radio<String>(value: language),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              language,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: FontSize.xXL),
                            ),
                          ),
                          const SizedBox(width: 6.0),
                          Visibility(
                            visible: subtitle != null,
                            replacement: const SizedBox.shrink(),
                            child: Flexible(
                              child: Text(
                                subtitle ?? "",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: FontSize.xXL),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if ((localeAsset ?? '').isNotEmpty)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _LanguageIcon(source: localeAsset!, selected: isSelected),
                  const SizedBox(width: 10.0),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _LanguageIcon extends StatelessWidget {
  const _LanguageIcon({required this.source, required this.selected});

  final String source;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final colorFilter =
        selected
            ? null
            : const ColorFilter.mode(Color(0xFF9A9A9A), BlendMode.srcIn);
    final picture =
        source.startsWith('http://') || source.startsWith('https://')
            ? SvgPicture.network(source, colorFilter: colorFilter)
            : SvgPicture.asset(source, colorFilter: colorFilter);
    return picture;
  }
}
