import 'package:flutter/widgets.dart';

/// Locale used when no language has been chosen yet. Strings for this locale
/// are compiled into the app so the UI still has text offline.
const Locale bundledFallbackLocale = Locale('en', 'US');

/// Turns an API language code into a [Locale] without assuming which
/// languages exist. `en`, `hi`, and `en_US` are all handled the same way.
Locale localeFromCode(String code) {
  final parts =
      code.replaceAll('-', '_').split('_').where((part) {
        return part.isNotEmpty;
      }).toList();
  if (parts.isEmpty) return bundledFallbackLocale;
  if (parts.length == 1) return Locale(parts.first);
  return Locale(parts.first, parts[1]);
}

/// Key GetX uses when looking up translations for [code].
String translationKeyFor(String code) => localeFromCode(code).toString();
