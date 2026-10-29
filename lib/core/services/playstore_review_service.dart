import 'package:get/get.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:voiceclub_partner/view/partner_profile/widgets/review_voiceclub_alert.dart';

class PlayStoreReviewService {
  static const String _prefsKey = 'reviewCount';
  static const String _prefsStoreKey = 'wentToStore';

  static Future<void> showPlayStoreReviewDialog() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final wentToStore = prefs.getBool(_prefsStoreKey);
      if (!(wentToStore ?? false)) {
        final count = prefs.getInt(_prefsKey);
        if (count != null) {
          if (count <= 4) {
            _showDialog();
            prefs.setInt(_prefsKey, count + 1);
          }
        } else {
          _showDialog();
          prefs.setInt(_prefsKey, 1);
        }
      }
    } catch (_) {}
  }

  static Future<void> _showDialog() async {
    final prefs = await SharedPreferences.getInstance();
    final result = await Get.dialog<bool?>(const ReviewVoiceClubAlert());
    if (result ?? false) {
      prefs.setBool(_prefsStoreKey, true);
      final inAppReview = InAppReview.instance;
      if (await inAppReview.isAvailable()) {
        inAppReview.requestReview();
      } else {
        inAppReview.openStoreListing();
      }
    } else {
      prefs.setBool(_prefsStoreKey, false);
    }
  }
}
