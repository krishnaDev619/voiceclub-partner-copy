import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:voiceclub_partner/data/data_sources/remote/localization/ui_language_api.dart';
import 'package:voiceclub_partner/data/models/localization/ui_language.dart';

/// Reads the combined languages payload from a local JSON asset.
class MockUiLanguageApi implements UiLanguageApi {
  MockUiLanguageApi({AssetBundle? bundle}) : _bundle = bundle ?? rootBundle;

  final AssetBundle _bundle;

  static const _languagesAsset = 'assets/i18n/languages.json';

  @override
  Future<List<UiLanguage>> fetchLanguages() async {
    final raw = await _bundle.loadString(_languagesAsset);
    final json = jsonDecode(raw) as Map<String, dynamic>;
    return UiLanguagesResponse.fromJson(
      json,
    ).languages.where((language) => language.code.isNotEmpty).toList();
  }
}
