import 'package:flutter_test/flutter_test.dart';
import 'package:voiceclub_partner/core/services/deeplink_language.dart';
import 'package:voiceclub_partner/data/models/localization/ui_language.dart';

void main() {
  const languages = [
    UiLanguage(code: 'hi', name: 'हिन्दी', appLanguage: 'Hindi'),
    UiLanguage(code: 'ta', name: 'தமிழ்', appLanguage: 'Tamil'),
    UiLanguage(code: 'kn', name: 'ಕನ್ನಡ', appLanguage: 'Kannada'),
  ];

  test('matches a code, an app language, or a display name from the list', () {
    expect(listedLanguageToken('hi', languages), 'Hindi');
    expect(listedLanguageToken('Hindi', languages), 'Hindi');
    expect(listedLanguageToken('  tamil ', languages), 'Tamil');
    expect(listedLanguageToken('kn', languages), 'Kannada');
    expect(listedLanguageToken('ಕನ್ನಡ', languages), 'Kannada');
  });

  test('ignores a language that is not in the list', () {
    expect(listedLanguageToken('Bengali', languages), isNull);
    expect(listedLanguageToken('', languages), isNull);
    expect(listedLanguageToken(null, languages), isNull);
  });
}
