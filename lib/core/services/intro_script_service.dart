import 'dart:math';
import 'package:get/get.dart';
import 'package:voiceclub_partner/core/injection_container.dart';
import 'package:voiceclub_partner/core/services/logger.dart';
import 'package:voiceclub_partner/core/services/ui_localization_service.dart';
import 'package:voiceclub_partner/modules/controller/user_controller.dart';

class IntroScriptService {
  final UserController _userController = Get.find<UserController>();

  /// True only when every required talk language has its own intro variants.
  /// If primary or secondary is missing variants, both languages use the old UI.
  Future<bool> allRequiredLanguagesHaveIntroVariants() async {
    final userDetails = _userController.userDetails.value;
    final primary = userDetails.primaryLanguage;
    if (!await _hasIntroVariantsFor(primary)) {
      return false;
    }
    final secondary = userDetails.secondaryLanguage;
    final needsSecondary =
        (secondary?.isNotEmpty ?? false) && secondary != primary;
    if (needsSecondary && !await _hasIntroVariantsFor(secondary)) {
      return false;
    }
    return true;
  }

  Future<bool> _hasIntroVariantsFor(String? language) async {
    final value = language?.trim();
    if (value == null || value.isEmpty) {
      return false;
    }
    try {
      final script = await sl<UiLocalizationService>().introAudioFor(value);
      return script?.variants?.isNotEmpty == true;
    } catch (e) {
      Logger.logMessage(
        "Intro variant check failed for $value: $e",
        name: "IntroScriptService",
      );
      return false;
    }
  }

  /// Picks a random intro script for [audioLanguage] and fills `{name}`
  /// and `{city}`. Falls back to the app language script when that
  /// language has no intro lines.
  ///
  /// Returns the primary line, the secondary line, and the sample audio URL.
  Future<(String, String, String)?> generateIntroAudioText({
    required String audioLanguage,
    required String cityName,
  }) async {
    try {
      final localization = sl<UiLocalizationService>();
      var scriptModel = await localization.introAudioFor(audioLanguage);
      if (scriptModel?.variants?.isNotEmpty != true) {
        scriptModel = localization.introAudio;
      }
      final variants = scriptModel?.variants;
      if (variants == null || variants.isEmpty) {
        return null;
      }

      final userName = _userController.userDetails.value.user?.name ?? "User";
      final userFirstName = userName.split(" ").first;
      final selectedVariant = variants[Random().nextInt(variants.length)];

      final primaryText = _replacePlaceholders(
        selectedVariant.primaryVariant ?? '',
        name: userFirstName,
        city: cityName,
      );
      final secondaryText = _replacePlaceholders(
        selectedVariant.secondaryVariant ?? '',
        name: userFirstName,
        city: cityName,
      );

      Logger.logMessage(
        "Generated primary text: $primaryText && secondary text: $secondaryText",
        name: "IntroScriptService",
      );

      return (primaryText, secondaryText, selectedVariant.audioUrl ?? "");
    } catch (e) {
      Logger.logMessage(
        "Error generating intro audio text: $e",
        name: "IntroScriptService",
        isCritical: true,
      );
      return null;
    }
  }

  String _replacePlaceholders(
    String variantText, {
    required String name,
    required String city,
  }) {
    return variantText
        .replaceAll('{name}', name)
        .replaceAll('{city}', city)
        .trim();
  }
}
