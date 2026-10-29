import 'package:voiceclub_partner/core/services/app_preferences.dart';

class VideoService {
  final AppPreferences _preferences;

  VideoService(this._preferences);

  Future<void> setMeetingOneVideoSeen() async {
    await _preferences.setBool(AppPreferences.meetingOneVideoKey, true);
  }

  Future<bool> getMeetingOneVideoSeen() async {
    return await _preferences.getBool(AppPreferences.meetingOneVideoKey) ??
        false;
  }

  Future<void> setTestimonialVideoSeen() async {
    await _preferences.setBool(AppPreferences.testimonialVideoKey, true);
  }

  Future<bool> getTestimonialVideoSeen() async {
    return await _preferences.getBool(AppPreferences.testimonialVideoKey) ??
        false;
  }

  Future<void> setAgreementVideoSeen() async {
    await _preferences.setBool(AppPreferences.agreementVideoKey, true);
  }

  Future<bool> getAgreementVideoSeen() async {
    return await _preferences.getBool(AppPreferences.agreementVideoKey) ??
        false;
  }
}
