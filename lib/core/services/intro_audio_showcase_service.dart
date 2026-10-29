import 'package:shared_preferences/shared_preferences.dart';
import 'package:voiceclub_partner/core/services/logger.dart';

class IntroAudioShowcaseService {
  static const String _introAudioShowcaseShownKey =
      'intro_audio_showcase_shown';

  // Method to check if intro audio showcase has been shown
  static Future<bool> hasIntroAudioShowcaseBeenShown() async {
    try {
      Logger.logMessage(
        "hasIntroAudioShowcaseBeenShown() called",
        name: "IntroAudioShowcase",
      );
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_introAudioShowcaseShownKey) ?? false;
    } catch (e) {
      Logger.logMessage(
        "Error checking intro audio showcase status: $e",
        name: "IntroAudioShowcase",
      );
      return false;
    }
  }

  // Method to mark intro audio showcase as shown
  static Future<void> markIntroAudioShowcaseAsShown() async {
    try {
      Logger.logMessage(
        "markIntroAudioShowcaseAsShown() called",
        name: "IntroAudioShowcase",
      );
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_introAudioShowcaseShownKey, true);
    } catch (e) {
      Logger.logMessage(
        "Error marking intro audio showcase as shown: $e",
        name: "IntroAudioShowcase",
      );
    }
  }

  // Method to reset intro audio showcase status (for testing purposes)
  static Future<void> resetIntroAudioShowcaseStatus() async {
    try {
      Logger.logMessage(
        "resetIntroAudioShowcaseStatus() called",
        name: "IntroAudioShowcase",
      );
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_introAudioShowcaseShownKey);
    } catch (e) {
      Logger.logMessage(
        "Error resetting intro audio showcase status: $e",
        name: "IntroAudioShowcase",
      );
    }
  }
}
