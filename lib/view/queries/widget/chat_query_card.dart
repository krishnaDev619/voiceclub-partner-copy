import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';

class ChatQueryCard extends StatelessWidget {
  final String title;
  final DateTime date;
  final QuerySessionStatus status;
  final int kamMessageCount;
  final VoidCallback? onTap;

  const ChatQueryCard({
    super.key,
    required this.title,
    required this.date,
    required this.status,
    required this.kamMessageCount,
    this.onTap,
  });

  String _getOrdinalSuffix(int day) {
    if (day >= 11 && day <= 13) {
      return 'th';
    }
    switch (day % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }

  String _formatDate(DateTime date) {
    final day = date.day;
    final ordinalSuffix = _getOrdinalSuffix(day);
    final month = DateFormat('MMM').format(date);
    final year = date.year;
    return '$day$ordinalSuffix $month $year';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (kamMessageCount > 0) ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                        ),
                        if (kamMessageCount > 0) ...[
                          const SizedBox(width: 6.0),
                          Container(
                            padding: const EdgeInsets.all(4.0),
                            decoration: BoxDecoration(
                              color: Colors.red.shade100,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              kamMessageCount.toString(),
                              style: TextStyle(
                                fontSize: 8.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ] else
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                  const SizedBox(height: 6.0),
                  Text(
                    _formatDate(date),
                    style: const TextStyle(
                      fontSize: 13.0,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF999999),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              status.toQuerySessionStatusName(),
              style: TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.w500,
                color: status.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
