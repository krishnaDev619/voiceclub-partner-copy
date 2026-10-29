import 'package:flutter/widgets.dart';
import 'package:voiceclub_partner/core/config/app_config.dart';
import 'package:voiceclub_partner/main.dart' as app;

/// Entry point for the Development flavor.
///
/// Run with:
/// ```bash
/// flutter run --flavor dev -t lib/main_dev.dart
/// ```
///
/// Build with:
/// ```bash
/// flutter build apk --flavor dev -t lib/main_dev.dart
/// ```
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppConfig.initialize(Environment.dev);
  app.main();
}
