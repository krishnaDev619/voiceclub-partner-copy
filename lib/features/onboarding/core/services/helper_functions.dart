import 'dart:typed_data';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:voiceclub_partner/core/services/logger.dart';

class HelperFunctions {
  static Future<Uint8List> fetchUrlAsBytes(String url) async {
    try {
      final file = await DefaultCacheManager().getSingleFile(url);
      return file.readAsBytesSync();
    } catch (e) {
      Logger.logError("Unexpected error fetching file: $e, URL: $url");
      throw Exception("Failed to fetch file: $e");
    }
  }
}
