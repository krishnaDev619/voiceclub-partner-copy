import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';

class ReactionPicker extends StatelessWidget {
  final Function(ReactionType) onReactionSelected;
  final ReactionType? currentReaction;

  const ReactionPicker({
    super.key,
    required this.onReactionSelected,
    this.currentReaction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children:
            ReactionType.values.map((reactionType) {
              final isSelected = currentReaction == reactionType;
              return GestureDetector(
                onTap: () => onReactionSelected(reactionType),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color:
                        isSelected
                            ? Get.theme.primaryColor.withValues(alpha: 0.1)
                            : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: _getReactionEmoji(reactionType, isSelected),
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _getReactionEmoji(ReactionType reactionType, bool isSelected) {
    return Text(
      reactionType.emoji,
      style: TextStyle(fontSize: isSelected ? 28 : 24),
    );
  }
}
