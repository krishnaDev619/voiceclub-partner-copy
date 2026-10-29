import 'package:intl/intl.dart';

class Formatter {
  static String calculateDifference(DateTime date) {
    DateTime now = DateTime.now();
    var value =
        DateTime(
          date.year,
          date.month,
          date.day,
        ).difference(DateTime(now.year, now.month, now.day)).inDays;
    return value == -1
        ? "Yesterday"
        : value == 1
        ? "Tomorrow"
        : value == 0
        ? "Today"
        : "";
  }

  static String formattedTime({required int timeInSecond}) {
    int sec = timeInSecond % 60;
    int min = (timeInSecond / 60).floor();
    String minute = min.toString().length <= 1 ? "0$min" : "$min";
    String second = sec.toString().length <= 1 ? "0$sec" : "$sec";
    return "$minute.$second";
  }

  static String formatLargeNumber(int number) {
    if (number < 1000) {
      return number.toString();
    } else if (number < 100000) {
      int result = (number / 1000).round();
      return '${result}k';
    } else if (number < 10000000) {
      int result = (number / 100000).round();
      return '${result}L';
    } else if (number < 1000000000) {
      int result = (number / 10000000).round();
      return '${result}cr';
    }
    // You can continue adding more cases for larger numbers if needed
    return number.toString();
  }

  static String formatStringToLargeNumber(String currentBalance) {
    try {
      // suffix = {' ', 'k', 'L', 'cr'};
      double value = double.parse(currentBalance);

      if (value < 1000) {
        // less than a thousand
        return value.toStringAsFixed(2);
      } else if (value >= 1000 && value < 100000) {
        // thousands
        double result = value / 1000;
        return "${result.toStringAsFixed(2)}k";
      } else if (value >= 100000 && value < 10000000) {
        // lakhs
        double result = value / 100000;
        return "${result.toStringAsFixed(2)}L";
      } else if (value >= 10000000) {
        // crores
        double result = value / 10000000;
        return "${result.toStringAsFixed(2)}cr";
      }
    } catch (_) {
      // Handle parsing errors gracefully
    }
    return "";
  }

  static String formatPrice(num price) {
    if (price >= 10000) {
      final roundedPrice = price ~/ 1000;
      final remainder = (price % 1000) / 100;
      return '${(roundedPrice)}.${remainder.toStringAsFixed(0)}k';
    } else {
      return price.toStringAsFixed(0);
    }
  }

  static String formatLiveCount(num count) {
    if (count >= 1000) {
      final roundedPrice = count ~/ 1000;
      final remainder = (count % 1000) / 100;
      return '${(roundedPrice)}.${remainder.toStringAsFixed(0)}k';
    } else {
      return "$count";
    }
  }

  static String formatNumValue(num? value) {
    if ((value ?? 0) % 1 == 0) {
      // If the number is an integer
      return (value ?? 0).toInt().toString();
    } else {
      // If the number has decimals, format to 2 decimal places
      return (value ?? 0).toStringAsFixed(2);
    }
  }

  static String formatIndianCurrency(num? value) {
    if (value == null) return "₹0"; // Handle null case

    String strValue = value.toStringAsFixed(
      0,
    ); // Convert to string without decimals
    int len = strValue.length;

    if (len <= 3) {
      return "₹$strValue"; // No formatting needed for numbers <= 999
    }

    // Extract last three digits
    String lastThree = strValue.substring(len - 3);
    String remaining = strValue.substring(0, len - 3);

    // Add commas after every two digits in the remaining part
    remaining = remaining.replaceAllMapped(
      RegExp(r'(\d{1,2})(?=(\d{2})+$)'),
      (Match m) => '${m[1]},',
    );

    return "₹$remaining,$lastThree";
  }

  /// This function will format date like this 21 Feb 2025
  static String getFormattedDate(String date) {
    // Parse the input date string
    DateTime? dateTime = DateTime.tryParse(date);

    // Format the date
    if (dateTime != null) {
      return DateFormat("dd MMM yyyy").format(dateTime);
    }

    return "";
  }

  static String getFormattedDateTime(String date) {
    // Parse the input date string
    DateTime? dateTime = DateTime.tryParse(date);

    // Format the date
    if (dateTime != null) {
      return DateFormat("dd/MMM/yyyy - hh:mm a").format(dateTime);
    }

    return "";
  }
}
