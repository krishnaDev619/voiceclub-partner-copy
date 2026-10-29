import 'package:dio/dio.dart';
import 'package:flutter/services.dart';

/// Downloads the body of an ARB file from the URL the languages API returned.
abstract class ArbFileClient {
  Future<String> read(String url);
}

/// Maps a mock CDN url (`https://mock.local/i18n/<file>.arb`) to a bundled
/// asset. A real client will replace this with an HTTP GET of [url].
class MockArbFileClient implements ArbFileClient {
  MockArbFileClient({Future<String> Function(String assetPath)? loadAsset})
    : _loadAsset = loadAsset ?? rootBundle.loadString;

  final Future<String> Function(String assetPath) _loadAsset;

  @override
  Future<String> read(String url) {
    final fileName = Uri.parse(url).pathSegments.last;
    return _loadAsset('assets/i18n/$fileName');
  }
}

/// GETs [url] as text. Mock CDN hosts still resolve to bundled ARB assets.
class HttpArbFileClient implements ArbFileClient {
  HttpArbFileClient(
    this._dio, {
    Future<String> Function(String assetPath)? loadAsset,
  }) : _loadAsset = loadAsset ?? rootBundle.loadString;

  final Dio _dio;
  final Future<String> Function(String assetPath) _loadAsset;

  @override
  Future<String> read(String url) async {
    final uri = Uri.parse(url);
    if (uri.host == 'mock.local') {
      return _loadAsset('assets/i18n/${uri.pathSegments.last}');
    }
    final response = await _dio.getUri<String>(
      uri,
      options: Options(responseType: ResponseType.plain),
    );
    return response.data ?? '';
  }
}
