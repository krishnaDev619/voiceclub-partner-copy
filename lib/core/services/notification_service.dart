import 'dart:convert';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/core/config/app_config.dart';
import 'package:voiceclub_partner/core/isolate_injection.dart';
import 'package:voiceclub_partner/core/services/auth_service.dart';
import 'package:voiceclub_partner/core/services/logger.dart';
import 'package:voiceclub_partner/domain/usecases/ringing/set_ring_isolate.dart';
import 'package:voiceclub_partner/modules/controller/chat_overview_controller.dart';
import 'package:voiceclub_partner/modules/controller/deeplink_controller.dart';

class NotificationService {
  static Future<void> initNotificationService() async {
    await initializeLocalNotifications(debug: kDebugMode);
    await startListeningNotificationEvents();
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    // Add foreground message handling
    FirebaseMessaging.onMessage.listen(_onMessageReceived);
    FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenedApp);
  }

  static Future<bool> requestNotificationPermissions() async {
    try {
      // Request FCM permissions
      final settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        await FirebaseMessaging.instance.setAutoInitEnabled(true);
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  static Future<void> initializeLocalNotifications({
    required bool debug,
  }) async {
    await AwesomeNotifications().initialize(null, [
      NotificationChannel(
        channelKey: '1',
        channelName: 'Calling Notification',
        soundSource: 'resource://raw/rozana_ringtone',
        channelDescription: 'Incoming Call',
        playSound: true,
        locked: true,
        importance: NotificationImportance.Max,
        defaultPrivacy: NotificationPrivacy.Private,
        enableVibration: true,
        enableLights: true,
        criticalAlerts: true,
      ),
      NotificationChannel(
        channelKey: '2',
        channelName: 'Notificaton',
        soundSource: 'resource://raw/rozana_notification',
        channelDescription: 'Missed Call',
        playSound: true,
        importance: NotificationImportance.High,
        defaultPrivacy: NotificationPrivacy.Private,
        enableVibration: true,
        enableLights: true,
      ),
      NotificationChannel(
        channelKey: '3',
        channelName: 'Chat Notificaton',
        soundSource: 'resource://raw/chat_notification',
        channelDescription: 'Chat',
        playSound: true,
        importance: NotificationImportance.High,
        defaultPrivacy: NotificationPrivacy.Private,
        enableVibration: true,
        enableLights: true,
      ),
      NotificationChannel(
        channelKey: 'basic_channel',
        channelName: 'Default',
        channelDescription: 'Default',
        playSound: false,
        importance: NotificationImportance.High,
        defaultPrivacy: NotificationPrivacy.Private,
        enableLights: true,
      ),
    ], debug: debug);
  }

  static Future<void> startListeningNotificationEvents() async {
    await AwesomeNotifications().setListeners(
      onActionReceivedMethod: onActionReceivedMethod,
      onNotificationDisplayedMethod: onNotificationDisplayedMethod,
      onNotificationCreatedMethod: onNotificationCreatedMethod,
    );
  }

  static Future<void> showInternalNotification({
    int? notificationId,
    required String title,
    required String body,
    Map<String, String?>? payload,
    String? channelKey,
  }) async {
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: notificationId ?? 0,
        channelKey: channelKey ?? "basic_channel",
        title: title,
        body: body,
        autoDismissible: true,
        duration: const Duration(seconds: 5),
        payload: payload,
      ),
    );
  }

  ///  *********************************************
  ///     LOCAL NOTIFICATION EVENTS
  ///  *********************************************

  static Future<void> getInitialNotificationAction() async {
    Map<String, dynamic>? payload;
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      IsolateLogger.logMessage(
        'NotificationService: Initial FCM message: ${initialMessage.toMap()}',
      );
      payload = initialMessage.data;
    }
    if (initialMessage == null) {
      ReceivedAction? receivedAction = await AwesomeNotifications()
          .getInitialNotificationAction(removeFromActionEvents: true);
      if (receivedAction != null) {
        IsolateLogger.logMessage(
          'NotificationService: Received action: ${receivedAction.toMap()}',
        );
        payload = receivedAction.payload;
      }
    }
    try {
      if (payload != null) {
        // Handling incoming call
        if (payload.containsKey('deeplink')) {
          final deepLinkController = Get.find<DeeplinkController>();
          final deepLink = Uri.parse(payload['deeplink'] ?? '');
          deepLinkController.updateDeeplink(deepLink);
        } else if (payload.containsKey('content')) {
          final content = payload['content'] ?? '';
          final contentMap = jsonDecode(content) as Map<String, dynamic>;
          if (contentMap.containsKey('deeplink')) {
            final deepLinkController = Get.find<DeeplinkController>();
            final deepLink = Uri.parse(contentMap['deeplink'] ?? '');
            deepLinkController.updateDeeplink(deepLink);
          }
        }
      }
    } catch (e) {
      IsolateLogger.logSoftError(
        'Failed to process initial notification action',
        StackTrace.current,
      );
    }
    return;
  }

  @pragma('vm:entry-point')
  static Future<void> onNotificationDisplayedMethod(
    ReceivedNotification notification,
  ) async {
    try {
      if (notification.createdLifeCycle == NotificationLifeCycle.Foreground) {
        // Handling incoming call
        if (notification.payload?.containsKey('deeplink') ?? false) {
          if ((notification.payload?['deeplink'] ?? '').contains('chat')) {
            final chatOverviewController = Get.find<ChatOverviewController>();
            Future.delayed(const Duration(seconds: 1), () {
              chatOverviewController.fetchChats(page: 1);
            });
          }
        }
      }
    } catch (_) {}
  }

  @pragma('vm:entry-point')
  static Future<void> onNotificationCreatedMethod(
    ReceivedNotification notification,
  ) async {}

  /// This will get called when user taps on notification while in foreground
  @pragma('vm:entry-point')
  static Future<void> onActionReceivedMethod(
    ReceivedAction receivedAction,
  ) async {
    try {
      IsolateLogger.logMessage(
        "NotificationService: onActionReceivedMethod: ${receivedAction.toMap()}",
      );

      // Handling incoming call
      if (receivedAction.payload?.containsKey('deeplink') ?? false) {
        if ((receivedAction.payload?['deeplink'] ?? '').contains('chat')) {
          final chatOverviewController = Get.find<ChatOverviewController>();
          Future.delayed(const Duration(milliseconds: 500), () {
            chatOverviewController.fetchChats(page: 1);
          });
        }
      }
      if (receivedAction.payload?.containsKey('deeplink') ?? false) {
        final deepLinkController = Get.find<DeeplinkController>();
        final deepLink = Uri.parse(receivedAction.payload?['deeplink'] ?? '');
        deepLinkController.updateDeeplink(deepLink);
      } else if (receivedAction.payload?.containsKey('content') ?? false) {
        final content = receivedAction.payload?['content'] ?? '';
        final contentMap = jsonDecode(content) as Map<String, dynamic>;
        if (contentMap.containsKey('deeplink')) {
          final deepLinkController = Get.find<DeeplinkController>();
          final deepLink = Uri.parse(contentMap['deeplink'] ?? '');
          deepLinkController.updateDeeplink(deepLink);
        }
      }
    } catch (_) {}
  }

  static Future<void> _onMessageReceived(RemoteMessage message) async {
    try {
      if (message.notification?.title?.isNotEmpty ?? false) {
        showInternalNotification(
          title: message.notification?.title ?? '',
          body: message.notification?.body ?? '',
          payload: message.data.map(
            (key, value) => MapEntry(key, value.toString()),
          ),
          channelKey: message.notification?.android?.channelId,
        );
      }
    } catch (_) {}
  }

  static Future<void> _onMessageOpenedApp(RemoteMessage message) async {
    try {
      IsolateLogger.logMessage(
        "NotificationService: onMessageOpenedApp: ${message.toMap()}",
      );
      final payload = message.data;
      // Handling incoming call
      if (payload.containsKey('deeplink')) {
        if ((payload['deeplink'] ?? '').contains('chat')) {
          final chatOverviewController = Get.find<ChatOverviewController>();
          Future.delayed(const Duration(milliseconds: 500), () {
            chatOverviewController.fetchChats(page: 1);
          });
        }
      }
      if (payload.containsKey('deeplink')) {
        final deepLinkController = Get.find<DeeplinkController>();
        final deepLink = Uri.parse(payload['deeplink'] ?? '');
        deepLinkController.updateDeeplink(deepLink);
      }
    } catch (_) {}
  }
}

@pragma('vm:entry-point')
Future<void> initializeBackgroundNotifications() async {
  try {
    await AwesomeNotifications().initialize(null, [
      NotificationChannel(
        channelKey: '1',
        channelName: 'Calling Notification',
        soundSource: 'resource://raw/rozana_ringtone',
        channelDescription: 'Incoming Call',
        playSound: true,
        locked: true,
        importance: NotificationImportance.Max,
        defaultPrivacy: NotificationPrivacy.Private,
        enableVibration: true,
      ),
      NotificationChannel(
        channelKey: '4', // For game call notification
        channelName: 'Game Call Notification',
        soundSource: 'resource://raw/rozana_ringtone',
        channelDescription: 'Game Call',
        playSound: true,
        locked: true,
        importance: NotificationImportance.Max,
        defaultPrivacy: NotificationPrivacy.Private,
        enableVibration: true,
      ),
    ], debug: false);
  } catch (_) {}
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    // Initialize Firebase if not already initialized
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp();
    }

    // Initialize AppConfig for background isolate (loads dotenv)
    // This MUST be called before accessing any config values
    await AppConfig.initializeForBackground();

    // Log the message for debugging
    IsolateLogger.logMessage(
      "Handling a background message: ${message.messageId}",
    );
    IsolateLogger.logMessage("Message data: ${message.data}");

    // Extract data from message
    final data = message.data;
    final content =
        data.containsKey("content")
            ? jsonDecode(data["content"]) as Map<String, dynamic>
            : <String, dynamic>{};
    final payload =
        (content.containsKey('payload'))
            ? (content["payload"] as Map<String, dynamic>?) ?? {}
            : <String, dynamic>{};

    // Extract required fields with null safety
    String? callerName, channelId;
    if (payload.containsKey("name")) {
      callerName = payload["name"] as String?;
    }
    if (payload.containsKey("channelName")) {
      channelId = payload["channelName"] as String?;
    }

    // Validate required data
    if ((callerName?.isEmpty ?? true) || (channelId?.isEmpty ?? true)) {
      if (message.data.containsKey("dismissByChannel")) {
        final channelKey = message.data["dismissByChannel"] as String?;
        if (channelKey?.isNotEmpty ?? false) {
          await AwesomeNotifications().cancelNotificationsByChannelKey(
            channelKey!,
          );
        }
      }
      return;
    }

    // Initialize notifications
    await initializeBackgroundNotifications();

    // Check if notifications are allowed without requesting permissions
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      IsolateLogger.logMessage("Notifications not allowed");
      return;
    }

    // Cancel any existing notifications to prevent duplicates
    await AwesomeNotifications().cancelNotificationsByChannelKey("1");
    var result = false;

    // Create the notification with proper configuration
    result = await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 1,
        channelKey: '1',
        title: 'Incoming Call',
        body: '$callerName is calling...',
        category: NotificationCategory.Call,
        fullScreenIntent: true,
        wakeUpScreen: true,
        autoDismissible: false,
        criticalAlert: true,
        duration: const Duration(seconds: 45),
        payload: {'screen': 'call'},
      ),
      actionButtons: [
        NotificationActionButton(
          key: 'ANSWER',
          label: 'Answer',
          actionType: ActionType.Default,
          color: Colors.green,
        ),
      ],
    );

    IsolateLogger.logMessage('Logging createNotificationResult $result');

    // Initialize isolate dependencies and handle ring state
    if (!isolate.isRegistered<SetRingIsolateUsecase>()) {
      await initializeIsolateDependencies();
    }
    final isLoggedIn = await isolate<IsolateAuthService>().isLoggedIn();

    if (isLoggedIn) {
      try {
        IsolateLogger.logMessage(
          "Calling the api for the background/killed state notification alert",
        );
        final response = await isolate<SetRingIsolateUsecase>().call(
          SetRingIsolateParams(channelId: channelId ?? ""),
        );
        if (response.error != null) {
          IsolateLogger.logSoftError(
            "Failed to Set Ring Isolate for $channelId: ${response.error}",
            StackTrace.current,
          );
        } else {
          IsolateLogger.logMessage(
            "Successfully Set Ring Isolate for $channelId",
          );
        }
      } catch (e) {
        IsolateLogger.logSoftError(
          "Error setting ring state: $e",
          StackTrace.current,
        );
      }
    } else {
      IsolateLogger.logMessage(
        "User not logged in, skipping ring state update",
      );
    }
  } catch (e, stackTrace) {
    IsolateLogger.logSoftError(
      'Error in _firebaseMessagingBackgroundHandler: $e',
      stackTrace,
    );
  }
}
