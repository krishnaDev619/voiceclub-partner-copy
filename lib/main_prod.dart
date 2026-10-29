import 'package:flutter/widgets.dart';
import 'package:voiceclub_partner/core/config/app_config.dart';
import 'package:voiceclub_partner/main.dart' as app;

/// Entry point for the Production flavor.
///
/// Run with:
/// ```bash
/// flutter run --flavor prod -t lib/main_prod.dart
/// ```
///
/// Build with:
/// ```bash
/// flutter build apk --flavor prod -t lib/main_prod.dart
/// ```
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppConfig.initialize(Environment.prod);
  app.main();
}
