import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:voiceclub_partner/core/services/logger.dart';

class ReverseCallService {
  static const String _failedCallsKey = "failed_calls";

  /// Increment the failed call count for a specific demandAccountId.
  static Future<void> incrementFailedCall(int demandAccountId) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Get the current failed calls map
      final failedCallsMap = Map<String, int>.from(
        prefs.getString(_failedCallsKey)?.parseJson() ?? {},
      );

      // Increment the count for the given demandAccountId
      failedCallsMap[demandAccountId.toString()] =
          (failedCallsMap[demandAccountId.toString()] ?? 0) + 1;

      // Save the updated map back to SharedPreferences
      await prefs.setString(_failedCallsKey, failedCallsMap.toJson());
    } catch (e) {
      Logger.logMessage(
        "Error incrementing failed call count: $e",
        name: "ReverseCallService",
      );
    }
  }

  /// Get the number of failed calls for a specific demandAccountId.
  static Future<int> getFailedCalls(int demandAccountId) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Get the current failed calls map
      final failedCallsMap = Map<String, int>.from(
        prefs.getString(_failedCallsKey)?.parseJson() ?? {},
      );

      // Return the failed call count for the given demandAccountId, or 0 if it doesn't exist
      return failedCallsMap[demandAccountId.toString()] ?? 0;
    } catch (e) {
      Logger.logMessage(
        "Error fetching failed call count: $e",
        name: "ReverseCallService",
      );
      return 0; // Return 0 in case of an error
    }
  }

  /// Reset the failed call count for a specific demandAccountId.
  static Future<void> resetFailedCalls(int demandAccountId) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Get the current failed calls map
      final failedCallsMap = Map<String, int>.from(
        prefs.getString(_failedCallsKey)?.parseJson() ?? {},
      );

      // Remove the entry for the given demandAccountId
      failedCallsMap.remove(demandAccountId.toString());

      // Save the updated map back to SharedPreferences
      await prefs.setString(_failedCallsKey, failedCallsMap.toJson());
    } catch (e) {
      Logger.logMessage(
        "Error resetting failed call count: $e",
        name: "ReverseCallService",
      );
    }
  }

  /// Clear all failed call data from SharedPreferences.
  static Future<void> clearAllFailedCalls() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_failedCallsKey);
    } catch (e) {
      Logger.logMessage(
        "Error clearing all failed call data: $e",
        name: "ReverseCallService",
      );
    }
  }
}

extension JsonParsing on String {
  /// Parse a JSON string into a Map.
  Map<String, dynamic> parseJson() {
    try {
      return jsonDecode(this) as Map<String, dynamic>;
    } catch (e) {
      Logger.logMessage("Error parsing JSON: $e", name: "ReverseCallService");
      return {};
    }
  }
}

extension MapToJson on Map<String, dynamic> {
  /// Convert a Map into a JSON string.
  String toJson() {
    try {
      return jsonEncode(this);
    } catch (e) {
      Logger.logMessage(
        "Error converting map to JSON: $e",
        name: "ReverseCallService",
      );
      return "{}";
    }
  }
}
