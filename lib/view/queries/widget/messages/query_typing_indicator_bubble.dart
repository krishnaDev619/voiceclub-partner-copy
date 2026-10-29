import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Left-aligned “other party is typing” bubble matching [QueryTextMessage] (received).
class QueryTypingIndicatorBubble extends StatefulWidget {
  const QueryTypingIndicatorBubble({super.key});

  @override
  State<QueryTypingIndicatorBubble> createState() =>
      _QueryTypingIndicatorBubbleState();
}

class _QueryTypingIndicatorBubbleState extends State<QueryTypingIndicatorBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IntrinsicWidth(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 14.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(12.0),
            topRight: Radius.circular(12.0),
            bottomLeft: Radius.circular(4.0),
            bottomRight: Radius.circular(12.0),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) {
                final phase = (_controller.value + i * 0.22) % 1.0;
                final opacity =
                    0.35 + 0.55 * (0.5 + 0.5 * math.sin(phase * 2 * math.pi));
                return Padding(
                  padding: EdgeInsets.only(right: i < 2 ? 5 : 0),
                  child: Opacity(
                    opacity: opacity.clamp(0.35, 1.0),
                    child: Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade600,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                );
              }),
            );
          },
        ),
      ),
    );
  }
}
