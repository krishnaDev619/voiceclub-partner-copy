import 'package:flutter_test/flutter_test.dart';
import 'package:voiceclub_partner/core/localizations/arb_refresh.dart';
import 'package:voiceclub_partner/core/localizations/locale_code.dart';

void main() {
  group('parseArb', () {
    test('keeps sentences and drops metadata keys', () {
      final parsed = parseArb({
        '@@locale': 'xx',
        '@@last_modified': '2026-09-25T06:30:00Z',
        '@searchName': {'description': 'hint'},
        'searchName': 'Search',
      });

      expect(parsed.lastModified, '2026-09-25T06:30:00Z');
      expect(parsed.translations, {'searchName': 'Search'});
    });

    test('reads sentences inside Onboarding, Journey, and Modules', () {
      final parsed = parseArb({
        '@@last_modified': '2026-09-25T07:05:00Z',
        'Onboarding': {
          '_note': 'For editors only',
          'Login': {'loginOrSignup': 'Login or Signup'},
        },
        'Journey': {'_note': 'Empty for now'},
        'Modules': {
          'Home': {'homeTitle': 'Home'},
        },
      });

      expect(parsed.lastModified, '2026-09-25T07:05:00Z');
      expect(parsed.translations, {
        'loginOrSignup': 'Login or Signup',
        'homeTitle': 'Home',
      });
    });

    test('keeps lesson lists out of the sentence map', () {
      final parsed = parseArb({
        'Journey': {
          'Tooltips': {'changeActivityStatus': 'Change your activity status'},
          'Lessons': {
            'stages': [
              {
                'stage': 'S1',
                'lessons': [
                  {
                    'title': 'How to go online?',
                    'lessonUrl': 'https://example.mp4',
                  },
                ],
              },
            ],
          },
        },
      });

      expect(parsed.translations, {
        'changeActivityStatus': 'Change your activity status',
      });
      expect(parsed.journey?['stages'], isA<List<dynamic>>());
      expect(
        (parsed.journey?['stages'] as List).first['lessons'].first['title'],
        'How to go online?',
      );
    });

    test('keeps intro audio scripts out of the sentence map', () {
      final parsed = parseArb({
        'IntroAudio': {
          '_note': 'For editors only',
          'introAudioVideo': 'https://example.com/intro.mp4',
          'defaultSampleAudio': 'https://example.com/sample.mp3',
          'prompt': 'Moderate this audio',
          'variants': [
            {
              'primary_variant': 'Hello {name}',
              'secondary_variant': 'नमस्ते {name}',
              'audio_url': 'https://example.mp3',
            },
          ],
        },
        'Modules': {
          'Home': {'homeTitle': 'Home'},
        },
      });

      expect(parsed.translations, {
        'homeTitle': 'Home',
        'introAudioVideo': 'https://example.com/intro.mp4',
        'defaultSampleAudio': 'https://example.com/sample.mp3',
      });
      expect(parsed.introAudio?['prompt'], 'Moderate this audio');
      expect(parsed.translations.containsKey('prompt'), isFalse);
      expect(
        (parsed.introAudio?['variants'] as List).first['primary_variant'],
        'Hello {name}',
      );
    });
  });

  group('withEnglishBackup', () {
    const english = LoadedArb(
      translations: {'homeTitle': 'Home'},
      journey: {
        'stages': [
          {'stage': 'S1'},
        ],
      },
      introAudio: {'prompt': 'Moderate this audio'},
    );

    test('keeps a complete language file', () {
      const loaded = LoadedArb(
        translations: {'homeTitle': 'होम'},
        journey: {
          'stages': [
            {'stage': 'S1'},
          ],
        },
        introAudio: {'prompt': 'ऑडियो'},
      );

      final merged = withEnglishBackup(loaded: loaded, english: english);

      expect(merged.translations['homeTitle'], 'होम');
      expect(merged.introAudio?['prompt'], 'ऑडियो');
    });

    test('uses English when the load supplied nothing', () {
      final merged = withEnglishBackup(
        loaded: const LoadedArb(),
        english: english,
      );

      expect(merged.translations['homeTitle'], 'Home');
      expect(merged.journey?['stages'], isA<List<dynamic>>());
      expect(merged.introAudio?['prompt'], 'Moderate this audio');
    });

    test('fills only the missing lessons and intro audio', () {
      const loaded = LoadedArb(translations: {'homeTitle': 'होम'});

      final merged = withEnglishBackup(loaded: loaded, english: english);

      expect(merged.translations['homeTitle'], 'होम');
      expect(merged.journey?['stages'], isA<List<dynamic>>());
      expect(merged.introAudio?['prompt'], 'Moderate this audio');
    });
  });

  group('decideArbRefresh', () {
    test('downloads when nothing is saved', () {
      expect(
        decideArbRefresh(
          cachedLastModified: null,
          remoteLastModified: '2026-09-25T06:30:00Z',
          hasCachedTranslations: false,
        ),
        ArbRefreshDecision.download,
      );
    });

    test('uses the saved copy when timestamps match', () {
      expect(
        decideArbRefresh(
          cachedLastModified: '2026-09-25T06:30:00Z',
          remoteLastModified: '2026-09-25T06:30:00Z',
          hasCachedTranslations: true,
        ),
        ArbRefreshDecision.useCache,
      );
    });

    test('downloads when the remote timestamp is newer', () {
      expect(
        decideArbRefresh(
          cachedLastModified: '2026-09-24T12:00:00Z',
          remoteLastModified: '2026-09-25T06:30:00Z',
          hasCachedTranslations: true,
        ),
        ArbRefreshDecision.download,
      );
    });
  });

  group('localeFromCode', () {
    test('parses a short code and a region code the same way', () {
      expect(localeFromCode('hi').toString(), 'hi');
      expect(localeFromCode('en_US').toString(), 'en_US');
      expect(translationKeyFor('ta'), 'ta');
    });
  });
}
