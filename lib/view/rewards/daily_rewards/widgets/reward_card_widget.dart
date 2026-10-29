import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';
import 'package:voiceclub_partner/view/tutorial/demo/widgets/core/disabled_widget.dart';

class RewardCardWidget extends StatelessWidget {
  final String title;
  final String progress;
  final String remaining;
  final String imagePath;
  final VoidCallback? onTap;
  final bool isCompleted;

  const RewardCardWidget({
    super.key,
    required this.title,
    required this.progress,
    required this.remaining,
    required this.imagePath,
    this.onTap,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.only(left: 8.0, top: 8.0, right: 8.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 6.0,
              spreadRadius: 2.0,
              offset: const Offset(2, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Left Side: Image
            Disabled(
              disabled: onTap == null && !isCompleted,
              opacity: 0.75,
              child: Image.asset(
                imagePath,
                width: 100.0,
                height: 100.0,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12.0),
            // Middle: Text Section
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    progress,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color:
                          isCompleted
                              ? Colors.green
                              : onTap == null
                              ? Colors.amber
                              : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    isCompleted ? LocaleKeys.liveCompleted.tr : remaining,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.0,
                      color: isCompleted ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
            ),
            // Right Side: Arrow Icon
            if (onTap != null)
              const CircleAvatar(
                backgroundColor: Color(0xFFFFF2F2),
                radius: 12.0,
                child: Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14.0,
                  color: Color(0xFF263238),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
