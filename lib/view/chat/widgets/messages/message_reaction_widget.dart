import 'package:flutter/material.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';

class MessageReactionWidget extends StatelessWidget {
  final String? reaction;
  final Alignment alignment;
  final VoidCallback onReactionTap;

  const MessageReactionWidget({
    super.key,
    required this.reaction,
    required this.alignment,
    required this.onReactionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: reaction?.isNotEmpty ?? false,
      child: GestureDetector(
        onTap: onReactionTap,
        child: Transform.translate(
          offset: const Offset(0.0, -3.0),
          child: UnconstrainedBox(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14.0),
                border: Border.all(color: Colors.grey.shade300, width: 0.5),
              ),
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              alignment: alignment,
              padding: const EdgeInsets.symmetric(
                horizontal: 6.0,
                vertical: 3.0,
              ),
              child: Text(
                reaction ?? "",
                style: const TextStyle(fontSize: FontSize.xL),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
