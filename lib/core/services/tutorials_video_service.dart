import 'package:shared_preferences/shared_preferences.dart';
import 'package:voiceclub_partner/core/services/logger.dart';

class TutorialLessonService {
  static const String _completedLessonKey = 'completedLessonID';

  // Method to store the ongoing lesson ID
  static Future<void> saveCompletedLessonID(int lessonId) async {
    try {
      Logger.logMessage(
        "saveCompletedLessonID() called with $lessonId",
        name: "Tutorial",
      );
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_completedLessonKey, lessonId);
    } catch (e) {
      // Handle the error appropriately, e.g., log it
      // Logger.logError("Error saving ongoingLessonId: $e");
    }
  }

  // Method to retrieve the ongoing lesson ID
  static Future<int?> getCompletedLessonID() async {
    try {
      Logger.logMessage("getCompletedLessonID() called", name: "Tutorial");
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_completedLessonKey);
    } catch (e) {
      // Handle the error appropriately, e.g., log it
      // Logger.logError("Error retrieving ongoingLessonId: $e");
      return null;
    }
  }

  // Method to clear the ongoing lesson ID
  static Future<void> clearOngoingLessonID() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_completedLessonKey);
    } catch (e) {
      // Handle the error appropriately, e.g., log it
      // Logger.logError("Error clearing ongoingLessonId: $e");
    }
  }
}
