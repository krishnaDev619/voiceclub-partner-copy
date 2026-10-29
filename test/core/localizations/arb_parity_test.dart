import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:voiceclub_partner/core/localizations/arb_refresh.dart';

const _languageCodes = [
  'hi',
  'ta',
  'te',
  'kn',
  'ml',
  'mr',
  'bn',
  'pa',
  'or',
  'gu',
  'ur',
  'bho',
];

Map<String, dynamic> _loadArb(String code) {
  final file = File('assets/i18n/$code.arb');
  expect(file.existsSync(), isTrue, reason: 'missing ${file.path}');
  return jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
}

void main() {
  test('every bundled language ARB has the same keys as English', () {
    final english = parseArb(_loadArb('en'));
    final englishKeys = english.translations.keys.toSet();

    expect(englishKeys, isNotEmpty);
    expect(english.journey, isNotEmpty);
    expect(english.introAudio, isNotEmpty);

    for (final code in _languageCodes) {
      final raw = _loadArb(code);
      final parsed = parseArb(raw);

      expect(raw['@@locale'], code);
      expect(
        parsed.translations.keys.toSet(),
        englishKeys,
        reason: '$code translation keys must match en.arb',
      );
      expect(parsed.journey, isNotEmpty, reason: '$code Journey');
      expect(parsed.introAudio, isNotEmpty, reason: '$code IntroAudio');
    }
  });

  test('languages.json lists every bundled language ARB', () {
    final file = File('assets/i18n/languages.json');
    final json = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
    final languages =
        (json['languages'] as List<dynamic>)
            .whereType<Map<String, dynamic>>()
            .toList();
    final codes = languages.map((item) => item['code'] as String).toSet();

    expect(codes, _languageCodes.toSet());
    for (final language in languages) {
      final code = language['code'] as String;
      expect(language['arb_url'], contains('$code.arb'));
      expect(File('assets/i18n/$code.arb').existsSync(), isTrue);
    }
  });
}
