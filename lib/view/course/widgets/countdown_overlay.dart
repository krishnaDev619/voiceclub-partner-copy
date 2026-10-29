import 'dart:async';

import 'package:flutter/material.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';

class CountdownOverlay extends StatefulWidget {
  final VoidCallback onCountdownComplete;
  final VoidCallback onTap;

  const CountdownOverlay({
    super.key,
    required this.onCountdownComplete,
    required this.onTap,
  });

  @override
  State<CountdownOverlay> createState() => _CountdownOverlayState();
}

class _CountdownOverlayState extends State<CountdownOverlay> {
  Timer? _timer;
  int _remainingSeconds = 5;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          setState(() {
            _remainingSeconds--;
          });
        } else {
          _timer?.cancel();
          widget.onCountdownComplete();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 35.0,
      width: 130.0,
      color: const Color(0xFFb3b3b3),
      child: Stack(
        fit: StackFit.expand,
        children: [
          TweenAnimationBuilder<double>(
            duration: const Duration(seconds: 20),
            curve: Curves.easeInOut,
            tween: Tween<double>(begin: 0, end: 10),
            builder:
                (context, value, _) => LinearProgressIndicator(
                  value: value,
                  backgroundColor: const Color(0xFFb3b3b3),
                  color: Colors.white,
                ),
          ),
          FittedBox(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.play_arrow, color: Colors.black),
                Text(
                  "Next Lesson in $_remainingSeconds ",
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: Weight.heavy,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
