import 'package:flutter_test/flutter_test.dart';
import 'package:voiceclub_partner/data/models/localization/ui_language.dart';
import 'package:voiceclub_partner/features/onboarding/core/constants/enums.dart';
import 'package:voiceclub_partner/features/onboarding/views/onboarding/widgets/choose_language_question.dart';

void main() {
  group('resolveLockedSpeakingLanguage', () {
    test('keeps English UI unlocked so two languages can be chosen', () {
      const english = UiLanguage(
        code: 'en',
        name: 'English',
        appLanguage: 'English',
      );

      expect(
        resolveLockedSpeakingLanguage(selectedUiLanguage: english),
        isNull,
      );
    });

    test('locks Hindi when Hindi is the selected UI language', () {
      const hindi = UiLanguage(
        code: 'hi',
        name: 'हिन्दी',
        appLanguage: 'Hindi',
      );

      expect(
        resolveLockedSpeakingLanguage(selectedUiLanguage: hindi),
        Language.Hindi,
      );
    });

    test('locks Tamil when Tamil is the selected UI language', () {
      const tamil = UiLanguage(code: 'ta', name: 'தமிழ்', appLanguage: 'Tamil');

      expect(
        resolveLockedSpeakingLanguage(selectedUiLanguage: tamil),
        Language.Tamil,
      );
    });

    test('prefers a deeplink language over the selected UI language', () {
      const hindi = UiLanguage(
        code: 'hi',
        name: 'हिन्दी',
        appLanguage: 'Hindi',
      );

      expect(
        resolveLockedSpeakingLanguage(
          deeplinkLanguage: Language.Telugu,
          selectedUiLanguage: hindi,
        ),
        Language.Telugu,
      );
    });
  });
}
