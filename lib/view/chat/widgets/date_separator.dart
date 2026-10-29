import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateSeparator extends StatelessWidget {
  final DateTime date;
  final bool? isQueryChat;
  final double? bottomPadding;

  const DateSeparator(
    this.date, {
    super.key,
    this.isQueryChat,
    this.bottomPadding,
  });

  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  String formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    if (isSameDay(dateTime, today)) {
      return 'Today';
    } else if (isSameDay(dateTime, yesterday)) {
      return 'Yesterday';
    } else if (now.difference(dateTime).inDays < 7) {
      return DateFormat('EEEE').format(dateTime);
    } else if (dateTime.year == now.year) {
      return DateFormat('E, dd MMM').format(dateTime);
    } else {
      return DateFormat('dd MMM yyyy').format(dateTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = formatDateTime(date);

    return Container(
      margin:
          isQueryChat == true
              ? EdgeInsets.only(top: 16.0, bottom: bottomPadding ?? 16.0)
              : null,
      padding:
          isQueryChat == true
              ? const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0)
              : EdgeInsets.only(top: 12.0),
      decoration:
          isQueryChat == true
              ? BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.0),
              )
              : null,
      child: Text(
        formattedDate,
        style: TextStyle(
          fontSize: 12.0,
          fontWeight: FontWeight.bold,
          color: isQueryChat == true ? Color(0xFF989898) : Colors.grey,
        ),
      ),
    );
  }
}
