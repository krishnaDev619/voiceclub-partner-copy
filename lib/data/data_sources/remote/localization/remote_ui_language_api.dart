import 'package:dio/dio.dart';
import 'package:voiceclub_partner/core/services/logger.dart';
import 'package:voiceclub_partner/data/data_sources/remote/localization/ui_language_api.dart';
import 'package:voiceclub_partner/data/data_sources/remote/localization/ui_language_api_service.dart';
import 'package:voiceclub_partner/data/models/localization/ui_language.dart';

/// Reads `/un/secure/localization/languages`. Falls back to [fallback] when the
/// request fails or the payload has no usable languages.
class RemoteUiLanguageApi implements UiLanguageApi {
  RemoteUiLanguageApi(this._service, {UiLanguageApi? fallback})
    : _fallback = fallback;

  final UiLanguageApiService _service;
  final UiLanguageApi? _fallback;

  @override
  Future<List<UiLanguage>> fetchLanguages() async {
    const category = 'GOSSIP';
    final role = 'SUPPLY';
    Logger.logMessage(
      'Fetching UI languages (category=$category, role=$role).',
      name: 'UI_LOCALE',
    );
    try {
      final response = await _service.getLanguages(
        category: category,
        role: role,
      );
      final languages =
          response.data.languages
              .where((language) => language.code.isNotEmpty)
              .toList();
      if (languages.isNotEmpty) {
        Logger.logMessage(
          'UI languages API returned ${languages.length} languages.',
          name: 'UI_LOCALE',
        );
        return languages;
      }
      Logger.logMessage(
        'UI languages API returned an empty list.',
        name: 'UI_LOCALE',
      );
    } on DioException catch (error) {
      Logger.logMessage(
        'UI languages API failed: ${error.requestOptions.uri} '
        'status=${error.response?.statusCode} body=${error.response?.data}',
        name: 'UI_LOCALE',
      );
    } catch (error) {
      Logger.logMessage('UI languages API failed: $error', name: 'UI_LOCALE');
    }
    final fallback = _fallback;
    if (fallback != null) {
      Logger.logMessage(
        'Using bundled UI languages fallback.',
        name: 'UI_LOCALE',
      );
      return fallback.fetchLanguages();
    }
    return const [];
  }
}
