import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:voiceclub_partner/view/chat/widgets/bottom_sheet/semi_circular_progress_indicator.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';
import 'package:get/get.dart';

class UnlockChatBottomSheet extends StatefulWidget {
  final int timeLeftToUnlockInSeconds;
  final int totalSecondsToUnlock;
  final int minutes;

  const UnlockChatBottomSheet({
    super.key,
    required this.minutes,
    required this.timeLeftToUnlockInSeconds,
    required this.totalSecondsToUnlock,
  });

  @override
  State<UnlockChatBottomSheet> createState() => _UnlockChatBottomSheetState();
}

class _UnlockChatBottomSheetState extends State<UnlockChatBottomSheet> {
  String convertToPercentageString(double value) {
    final percentage = (value * 100).toInt();
    return '$percentage';
  }

  @override
  Widget build(BuildContext context) {
    final progress =
        0.8 +
        (0.2 *
            ((widget.totalSecondsToUnlock - widget.timeLeftToUnlockInSeconds) /
                widget.totalSecondsToUnlock));
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.0),
              topRight: Radius.circular(20.0),
            ),
            gradient: LinearGradient(
              begin: Alignment.centerRight,
              end: Alignment.centerLeft,
              colors: [Color(0xFF1E4B6B), Color(0xFF172937)],
              stops: [0.3484, 1.0],
              transform: GradientRotation(213.98),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 48.0, 16.0, 24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        SemiCircularProgressIndicator(
                          progress: progress,
                          width: 280.0,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 20.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              RichText(
                                text: TextSpan(
                                  text: convertToPercentageString(progress),
                                  style: TextStyle(
                                    fontFamily: GoogleFonts.mulish().fontFamily,
                                    fontSize: 42.0, // Original font size
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  children: const <TextSpan>[
                                    TextSpan(
                                      text: '%', // Percent symbol
                                      style: TextStyle(
                                        fontSize: 28.0, // Font size for "%"
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16.0),
                              RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  text:
                                      "Talk for ${widget.minutes} more minutes to unlock ",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18.0,
                                    fontFamily: GoogleFonts.mulish().fontFamily,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: LocaleKeys.liveChat.tr,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 32.0,
                ),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20.0),
                    topRight: Radius.circular(20.0),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 24.0,
                          backgroundColor: Color(0xFF172937),
                          child: Icon(
                            Icons.phone_rounded,
                            size: 28.0,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 12.0),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'First Call Placed',
                              style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4.0),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.check_circle_outline_rounded,
                                  size: 18.0,
                                  color: Colors.green,
                                ),
                                SizedBox(width: 4.0),
                                Text(
                                  'You placed your first call',
                                  style: TextStyle(fontSize: 12.0),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.only(left: 16.0),
                      child: SizedBox(
                        height: 36.0,
                        child: VerticalDivider(
                          color: Color(0xFFA9A9A9),
                          thickness: 1.5,
                        ),
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircleAvatar(
                          radius: 24.0,
                          backgroundColor: Color(0xFFD9D9D9),
                          child: Icon(
                            Icons.message,
                            size: 28.0,
                            color: Color(0xFF787878),
                          ),
                        ),
                        const SizedBox(width: 12.0),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Chat',
                              style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4.0),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.watch_later_outlined,
                                  size: 18.0,
                                  color: Colors.orange,
                                ),
                                const SizedBox(width: 4.0),
                                Text(
                                  'Talk for ${widget.minutes} more minutes to unlock chat',
                                  style: const TextStyle(fontSize: 12.0),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
