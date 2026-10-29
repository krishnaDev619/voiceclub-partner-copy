import 'package:shared_preferences/shared_preferences.dart';
import 'package:voiceclub_partner/core/services/logger.dart';

class BroadcastMessageService {
  static const String _broadcastKey = "broadcast_group_ids";

  /// Saves the broadcast group IDs with the current timestamp in SharedPreferences.
  static Future<void> saveBroadcast(List<int> groupIds) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final Map<String, int> broadcasts = await _getStoredBroadcasts();

      final currentTime = DateTime.now().millisecondsSinceEpoch;
      for (final id in groupIds) {
        broadcasts[id.toString()] = currentTime;
      }

      // Save the updated broadcasts back to SharedPreferences.
      await prefs.setString(
        _broadcastKey,
        broadcasts.entries.map((e) => "${e.key}:${e.value}").join(","),
      );
    } catch (e) {
      Logger.logMessage(
        "Error saving broadcast: $e",
        name: "BroadcastMessageService",
      );
    }
  }

  /// Fetches the list of group IDs broadcasted to today and removes entries older than 6 hours.
  static Future<List<int>> fetchTodayBroadcastedGroupIds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final Map<String, int> broadcasts = await _getStoredBroadcasts();

      final now = DateTime.now();
      final cutoffTime =
          now.subtract(const Duration(hours: 6)).millisecondsSinceEpoch;

      // Filter the IDs based on the cutoff time.
      final validBroadcasts = <String, int>{};
      final todayGroupIds = <int>[];

      broadcasts.forEach((key, timestamp) {
        if (timestamp > cutoffTime) {
          validBroadcasts[key] = timestamp;

          // Check if it belongs to today.
          final broadcastDate = DateTime.fromMillisecondsSinceEpoch(timestamp);
          if (_isSameDay(broadcastDate, now)) {
            todayGroupIds.add(int.parse(key));
          }
        }
      });

      // Save the cleaned-up broadcasts back to SharedPreferences.
      await prefs.setString(
        _broadcastKey,
        validBroadcasts.entries.map((e) => "${e.key}:${e.value}").join(","),
      );

      return todayGroupIds;
    } catch (e) {
      Logger.logMessage(
        "Error fetching broadcast: $e",
        name: "BroadcastMessageService",
      );
      return [];
    }
  }

  /// Clears all saved broadcasts (optional utility function).
  static Future<void> clearBroadcasts() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_broadcastKey);
  }

  /// Helper to get stored broadcasts as a Map.
  static Future<Map<String, int>> _getStoredBroadcasts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final broadcastString = prefs.getString(_broadcastKey) ?? "";

      final Map<String, int> broadcasts = {};
      if (broadcastString.isNotEmpty) {
        final entries = broadcastString.split(",");
        for (final entry in entries) {
          final parts = entry.split(":");
          if (parts.length == 2) {
            final id = parts[0];
            final timestamp = int.tryParse(parts[1]) ?? 0;
            if (timestamp > 0) {
              broadcasts[id] = timestamp;
            }
          }
        }
      }
      return broadcasts;
    } catch (e) {
      Logger.logMessage(
        "Error getting stored broadcasts: $e",
        name: "BroadcastMessageService",
      );
      return {};
    }
  }

  /// Helper to check if two dates are on the same day.
  static bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}
