import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';

class ChatLockedTimeBar extends StatelessWidget {
  final bool hasMargin;
  final bool isBottomSheet;

  const ChatLockedTimeBar({
    super.key,
    this.hasMargin = true,
    this.isBottomSheet = true,
  });

  Stream<int> countdownStream() {
    return Stream.periodic(const Duration(seconds: 1), (i) {
      final now = DateTime.now();
      final tomorrow = DateTime(now.year, now.month, now.day + 1);
      final midnight = DateTime(tomorrow.year, tomorrow.month, tomorrow.day);
      final difference = midnight.difference(now);

      return difference.inSeconds;
    }).takeWhile((seconds) => seconds > 0);
  }

  String formatTime(int seconds) {
    final hours = (seconds ~/ 3600);
    final minutes = ((seconds % 3600) ~/ 60);
    final remainingSeconds = seconds % 60;

    final formattedHours = hours.toString().padLeft(2, '0');
    final formattedMinutes = minutes.toString().padLeft(2, '0');
    final formattedSeconds = remainingSeconds.toString().padLeft(2, '0');

    return '$formattedHours:$formattedMinutes:$formattedSeconds';
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: countdownStream(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final remainingSeconds = snapshot.data ?? 0;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Visibility(
              visible: isBottomSheet,
              child: Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: GestureDetector(
                    onTap: () {
                      Get.back();
                    },
                    child: const Icon(Icons.close, color: Colors.white),
                  ),
                ),
              ),
            ),
            Container(
              height: isBottomSheet ? 72.0 : null,
              alignment: Alignment.center,
              margin: EdgeInsets.all(hasMargin ? 8.0 : 0.0),
              padding: const EdgeInsets.symmetric(
                vertical: 12.0,
                horizontal: 8.0,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F7F7),
                boxShadow: const [
                  BoxShadow(color: Color(0x1A000000), blurRadius: 10.0),
                ],
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.lock, color: Color(0xFF787878), size: 20.0),
                  const SizedBox(width: 8.0),
                  Text(
                    (remainingSeconds > 0)
                        ? '${formatTime(remainingSeconds)} left to chat again'
                        : 'Limit refreshed. Reload to unlock.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: FontSize.L,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
