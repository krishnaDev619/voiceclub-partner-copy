import 'package:flutter/foundation.dart';
import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/services/logger.dart';
import 'package:voiceclub_partner/domain/usecases/chat/get_chat_attachment_url.dart';

/// Resolves private/signed file URLs into public URLs.
///
/// Add a method per module (chat attachments today, other file types later).
/// Successful lookups are cached by filename so the same file is not fetched twice.
class SignedUrlService {
  final GetChatAttachmentUrlUseCase _getChatAttachmentUrlUseCase;

  final Map<String, Future<String>> _cache = {};

  SignedUrlService(this._getChatAttachmentUrlUseCase);

  /// Returns a public URL for a chat attachment.
  ///
  /// [signedUrl] can be a full URL (`https://amazon.in/239883982739.mp4`)
  /// or any path whose last segment is the filename. Local file paths
  /// (`/…` or `file://`) are returned as-is.
  Future<String> getChatAttachmentUrl(String signedUrl) {
    if (!_shouldResolve(signedUrl)) return Future.value(signedUrl);

    final filename = extractFilename(signedUrl);
    if (filename == null || filename.isEmpty) return Future.value(signedUrl);

    final cached = _cache[filename];
    if (cached != null) return cached;

    late final Future<String> future;
    future = () async {
      try {
        return await _fetchChatAttachmentUrl(filename);
      } catch (error) {
        if (identical(_cache[filename], future)) {
          _cache.remove(filename);
        }
        Logger.logMessage(
          'Failed to resolve chat attachment url for $filename: $error',
          name: 'SignedUrlService',
        );
        return signedUrl;
      }
    }();
    _cache[filename] = future;
    return future;
  }

  Future<String> _fetchChatAttachmentUrl(String filename) async {
    final result = await _getChatAttachmentUrlUseCase.call(
      GetChatAttachmentUrlParams(filename: filename),
    );

    final url = result.data?.url;
    if (result is DataSuccess && url != null && url.isNotEmpty) {
      return url;
    }

    throw StateError(
      result.errorMessage.isNotEmpty
          ? result.errorMessage
          : 'Empty chat attachment url',
    );
  }

  /// Last path segment, ignoring query params.
  /// `amazon.in/239883982739.mp4` → `239883982739.mp4`
  @visibleForTesting
  static String? extractFilename(String url) {
    final trimmed = url.trim();
    if (trimmed.isEmpty) return null;

    final uri = Uri.tryParse(trimmed);
    if (uri == null) return null;

    if (uri.pathSegments.isNotEmpty) {
      return uri.pathSegments.last;
    }

    final path = uri.path;
    if (path.isEmpty) return null;
    return path.split('/').last;
  }

  static bool _shouldResolve(String url) {
    final trimmed = url.trim();
    if (trimmed.isEmpty) return false;

    final lower = trimmed.toLowerCase();
    if (lower.startsWith('file://')) return false;
    // Absolute local paths (just-sent attachments) should not hit the API.
    if (trimmed.startsWith('/')) return false;
    return true;
  }
}
