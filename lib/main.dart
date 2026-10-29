import 'dart:async';
import 'dart:io';

import 'package:app_links/app_links.dart';
import 'package:dio/dio.dart';
import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_facebook_app_links/flutter_facebook_app_links.dart';
import 'package:get/get.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shorebird_code_push/shorebird_code_push.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:voiceclub_partner/core/constants/custom_timeago.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/constants/string_constants.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/core/injection_container.dart';
import 'package:voiceclub_partner/features/onboarding/core/injection_container.dart'
    as onboarding;
import 'package:voiceclub_partner/core/routes.dart';
import 'package:voiceclub_partner/core/services/analytics_service.dart';
import 'package:voiceclub_partner/core/services/app_info_service.dart';
import 'package:voiceclub_partner/core/services/token_service.dart';
import 'package:voiceclub_partner/core/services/logger.dart';
import 'package:voiceclub_partner/core/services/logging_interceptor.dart';
import 'package:voiceclub_partner/core/services/notification_service.dart';
import 'package:voiceclub_partner/core/services/theme_provider.dart';
import 'package:voiceclub_partner/data/models/chat/chat_group.dart';
import 'package:voiceclub_partner/data/models/chat/chat_message.dart';
import 'package:voiceclub_partner/data/models/chat/chat_pricing.dart';
import 'package:voiceclub_partner/data/models/chat/member.dart';
import 'package:voiceclub_partner/data/models/notifications/user_data.dart';
import 'package:voiceclub_partner/core/localizations/locale_code.dart';
import 'package:voiceclub_partner/core/services/ui_localization_service.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/app_translations.dart';
import 'package:voiceclub_partner/modules/controller/deeplink_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Pass all uncaught "fatal" errors from the framework to Crashlytics
  FlutterError.onError = (errorDetails) {
    if (errorDetails.toString().toLowerCase().contains(
      "no host specified in uri",
    )) {
      Logger.logMessage(
        "$errorDetails",
        name: "FlutterError no host",
        isCritical: true,
      );
      return;
    } else {
      Logger.logMessage(
        "$errorDetails",
        name: "FlutterError",
        isCritical: true,
      );
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
    }
  };
  // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
  PlatformDispatcher.instance.onError = (error, stack) {
    if (error.toString().toLowerCase().contains("no host specified in uri")) {
      Logger.logMessage(
        "$error",
        name: "PlatformDispatcher no host",
        isCritical: true,
      );
      return false;
    } else {
      Logger.logMessage("$error", name: "PlatformDispatcher", isCritical: true);
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    }
  };

  // Initialize notification service before other services
  await NotificationService.initNotificationService();

  // Request notification permissions
  final notificationPermission =
      await NotificationService.requestNotificationPermissions();
  if (!notificationPermission) {
    Logger.logMessage("Notification permissions not granted", isCritical: true);
  }

  // Hive
  // Get the directory for storing Hive files with version-specific path
  final appDocumentDirectory = await getApplicationDocumentsDirectory();

  final appInfo = await AppInfoService().getAppInfo();
  final patchVersion = await ShorebirdUpdater().readCurrentPatch();

  final newPath =
      'hive_db_v${appInfo.version?.replaceAll('.', '_')}_${patchVersion?.number}';

  final hiveDirectoryPath = path.join(appDocumentDirectory.path, newPath);

  // Delete previous Hive directories
  await _deletePreviousHiveDirectory(appDocumentDirectory.path, newPath);

  await Hive.initFlutter(hiveDirectoryPath);

  Hive.registerAdapter(CategoryCodeAdapter());
  Hive.registerAdapter(ChatTypeAdapter());
  Hive.registerAdapter(ChatTierAdapter());
  Hive.registerAdapter(ChatGroupAdapter());
  Hive.registerAdapter(ChatMessageAdapter());
  Hive.registerAdapter(ChatPricingAdapter());
  Hive.registerAdapter(ChatMemberAdapter());
  Hive.registerAdapter(UserDataModelAdapter());
  Hive.registerAdapter(AccountTypeAdapter());

  await Hive.openBox<List>(StringConstants.chatGroupsBoxName);
  await Hive.openBox<int>(StringConstants.messageCountBoxName);
  await Hive.openBox<int>(StringConstants.fetchedMessageCountBoxName);
  await Hive.openBox<double>(StringConstants.scrollPostionBoxName);

  await initializeDependencies();
  await onboarding.initializeDependencies();
  await sl<TokenService>().restoreSession();
  sl<Dio>().interceptors.add(LoggingInterceptor());
  await sl<UiLocalizationService>().initialize();
  final deepLinkController = Get.put(DeeplinkController());
  await initializeSingular(deepLinkController);
  _initFBDeferredDeeplinks(deepLinkController);
  initAppLinks(deepLinkController: deepLinkController);
  NotificationService.getInitialNotificationAction();

  await FastCachedImageConfig.init();
  SystemChrome.setSystemUIOverlayStyle(systemOverlayStyle);

  timeago.setLocaleMessages('en', CustomTimeagoMessages());

  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

void _initFBDeferredDeeplinks(DeeplinkController deepLinkController) async {
  try {
    final initFBResponse = await FlutterFacebookAppLinks.initFBLinks();
    String deepLinkUrl = initFBResponse.toString();
    if (deepLinkUrl.isNotEmpty) {
      deepLinkController.updateDeeplink(
        Uri.parse(deepLinkUrl),
        source: 'facebook',
      );
    }
  } catch (_) {}
}

Future<void> initializeSingular(DeeplinkController deepLinkController) async {
  await sl<AnalyticsService>().initSingularSDK(
    onDeepLink:
        (link, {required isDeferred, passthrough}) =>
            deepLinkController.updateDeeplink(
              link,
              source: 'singular',
              isDeferred: isDeferred,
              passthrough: passthrough,
            ),
  );
}

void initAppLinks({required DeeplinkController deepLinkController}) {
  final appLinks = AppLinks();

  appLinks.getInitialLink().then((value) {
    if (value != null) {
      Logger.logMessage(
        "App Links getInitialLink() called with: ${value.toString()}",
      );
      deepLinkController.updateDeeplink(value, source: 'appLinksInitial');
    }
  });

  appLinks.uriLinkStream.listen((value) {
    Logger.logMessage(
      "App Links uriLinkStream called with: ${value.toString()}",
    );
    deepLinkController.updateDeeplink(value, source: 'appLinksStream');
  });
}

Future<void> _deletePreviousHiveDirectory(
  String appDocumentPath,
  String newPath,
) async {
  try {
    final directory = Directory(appDocumentPath);
    final List<FileSystemEntity> entities = directory.listSync();

    for (var entity in entities) {
      if (entity is Directory &&
          entity.path.contains('hive_db') &&
          !entity.path.contains(newPath)) {
        await entity.delete(recursive: true);
      }
    }
  } catch (e) {
    Logger.logMessage(
      'Error deleting old Hive directory: $e',
      isCritical: true,
    );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  // The navigator key is necessary to navigate using static methods
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    return GlobalLoaderOverlay(
      overlayColor: Colors.white60.withValues(alpha: 0.3),
      overlayWidgetBuilder:
          (_) => Center(
            child: SizedBox(
              height: 32.0,
              width: 32.0,
              child: CircularProgressIndicator(
                color: themeProvider.currentTheme.primaryColor,
              ),
            ),
          ),
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'VoiceClub Partner',
        theme: themeProvider.currentTheme,
        onGenerateRoute: RouteGenerator.generateRoute,
        initialRoute: RouteGenerator.defaultRoute,
        // Keep layout LTR even for RTL locales like Urdu (`ur`).
        // GetX otherwise flips the whole tree via rtlLanguages.
        textDirection: TextDirection.ltr,
        locale: sl<UiLocalizationService>().currentLocale,
        fallbackLocale: bundledFallbackLocale,
        translationsKeys: AppTranslation.translationsKeys,
      ),
    );
  }
}
