import 'dart:convert';
import 'dart:io';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/injection_container.dart';
import 'package:voiceclub_partner/core/services/alert_service.dart';
import 'package:voiceclub_partner/core/services/analytics_service.dart';
import 'package:voiceclub_partner/domain/usecases/notifications/add_notification.dart';
import 'package:voiceclub_partner/domain/usecases/stories/upload_story_audio_file.dart'
    as upload_story_audio_file;
import 'package:voiceclub_partner/view/logs/logs_controller.dart';

class NotifyDemandService {
  NotifyDemandService() {
    _initPrefs();
  }

  final _addNotificationUseCase = sl<AddNotificationUsecase>();
  SharedPreferences? _prefs;
  static const String _prefsKeyNormal = 'notification_info_normal';
  static const String _prefsKeyAudio = 'notification_info_audio';

  Future<void> sendNotificationToDemand({
    required int logId,
    required int demandUid,
    required bool isAudio,
    String path = '',
    required String userName,
    required String screenName,
  }) async {
    if (isAudio) {
      if (await isAllowedToSendAudioNotification(demandUserId: demandUid)) {
        try {
          String url = await uploadAudio(path);
          if (url.isNotEmpty) {
            await _addNotificationUseCase.call(
              Params(uid: demandUid, isAudio: true, audioUrl: url),
            );
          } else {
            AlertService.showSnackBar(
              snackBarType: SnackBarType.Warning,
              title: "Oops",
              subtitle: "There was an error. Please try again!",
            );
          }
          addOrUpdateAudioNotification(demandUserId: demandUid);
          final controller = PlayerController();
          await controller.preparePlayer(path: path);
          String duration = (controller.maxDuration ~/ 1000).toString().padLeft(
            2,
            '0',
          );
          sl<AnalyticsService>().trackEvent(
            "audioNotifySuccess",
            eventProperties: {
              "demandName": userName,
              "demandId": demandUid.toString(),
              "audioLength": duration,
            },
          );
          Get.back();
          AlertService.showSnackBar(
            snackBarType: SnackBarType.Success,
            title: "Success",
            subtitle: "Audio notification sent successfully!",
          );
        } catch (_) {
          AlertService.showSnackBar(
            snackBarType: SnackBarType.Warning,
            title: "Oops",
            subtitle: "There was an error. Please try again!",
          );
        }
        if (Get.isRegistered<LogsController>()) {
          Get.find<LogsController>().fetchLogs();
        }
      }
    } else {
      if (await isAllowedToSendNormalNotification(demandUserId: demandUid)) {
        try {
          await _addNotificationUseCase.call(
            Params(uid: demandUid, isAudio: false, audioUrl: ''),
          );
          addOrUpdateNormalNotification(demandUserId: demandUid);
          sl<AnalyticsService>().trackEvent(
            "notifyUser",
            eventProperties: {
              "demandName": userName,
              "demandId": demandUid.toString(),
              "screenName": screenName,
            },
          );
          AlertService.showSnackBar(
            snackBarType: SnackBarType.Success,
            title: "Success",
            subtitle: "Call notification sent successfully!",
          );
        } catch (_) {
          AlertService.showSnackBar(
            snackBarType: SnackBarType.Warning,
            title: "Oops",
            subtitle: "There was an error. Please try again!",
          );
        }
        if (Get.isRegistered<LogsController>()) {
          Get.find<LogsController>().fetchLogs();
        }
      }
    }
  }

  Future<String> uploadAudio(String audioFilePath) async {
    String url = '';
    try {
      final uploadStoryAudioFile =
          sl<upload_story_audio_file.UploadStoryAudioFileUsecase>();
      File audioFile = File(audioFilePath);
      final response = await uploadStoryAudioFile.call(
        upload_story_audio_file.Params(recordingFile: audioFile),
      );
      url = response.data?.url ?? '';
    } catch (_) {}
    return url;
  }

  Future<void> _initPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // Function to add or update a list of normal notifications sent to demand users
  Future<void> addOrUpdateNormalNotification({
    required int demandUserId,
  }) async {
    final notifications = await getNormalNotifications();

    final now = DateTime.now();
    final existingNotificationIndex = notifications.indexWhere(
      (n) => n.demandUserId == demandUserId,
    );

    if (existingNotificationIndex != -1) {
      // Update the existing notification
      notifications[existingNotificationIndex] = NotificationInfo(
        type: NotificationType.normal,
        demandUserId: demandUserId,
        count:
            (notifications[existingNotificationIndex].count >= 3)
                ? 1
                : notifications[existingNotificationIndex].count + 1,
        timestamp: now,
      );
    } else {
      // Add a new notification
      notifications.add(
        NotificationInfo(
          type: NotificationType.normal,
          demandUserId: demandUserId,
          count: 1,
          timestamp: now,
        ),
      );
    }

    await _saveNotifications(_prefsKeyNormal, notifications);
  }

  // Function to fetch the list of normal notifications sent to demand users
  Future<List<NotificationInfo>> getNormalNotifications() async {
    return await _getNotifications(_prefsKeyNormal);
  }

  // Function to add or update a list of audio notifications sent to demand users
  Future<void> addOrUpdateAudioNotification({required int demandUserId}) async {
    final notifications = await getAudioNotifications();

    final now = DateTime.now();
    final existingNotificationIndex = notifications.indexWhere(
      (n) => n.demandUserId == demandUserId,
    );

    if (existingNotificationIndex != -1) {
      // Update the existing notification
      notifications[existingNotificationIndex] = NotificationInfo(
        type: NotificationType.audio,
        demandUserId: demandUserId,
        count: 1,
        timestamp: now,
      );
    } else {
      // Add a new notification
      notifications.add(
        NotificationInfo(
          type: NotificationType.audio,
          demandUserId: demandUserId,
          count: 1,
          timestamp: now,
        ),
      );
    }

    await _saveNotifications(_prefsKeyAudio, notifications);
  }

  // Function to fetch the list of audio notifications sent to demand users
  Future<List<NotificationInfo>> getAudioNotifications() async {
    return await _getNotifications(_prefsKeyAudio);
  }

  // Function to check if a supply user is allowed to send an audio notification to a demand user
  Future<bool> isAllowedToSendAudioNotification({
    required int demandUserId,
  }) async {
    final notifications = await getAudioNotifications();

    final now = DateTime.now();
    final notification = notifications.firstWhereOrNull(
      (n) => n.demandUserId == demandUserId,
    );

    if (notification == null ||
        now.difference(notification.timestamp).inHours >= 6) {
      // No audio notification sent within the last 6 hours
      // or no previous audio notification exists
      return true;
    }
    return false;
  }

  // Function to check if a supply user is allowed to send a normal notification to a demand user
  Future<bool> isAllowedToSendNormalNotification({
    required int demandUserId,
  }) async {
    if (await isAllowedToSendAudioNotification(demandUserId: demandUserId)) {
      final notifications = await getNormalNotifications();
      final now = DateTime.now();
      final notification = notifications.firstWhereOrNull(
        (n) => n.demandUserId == demandUserId,
      );

      if ((notification?.count ?? 0) < 3 ||
          now.difference(notification?.timestamp ?? now).inHours >= 6) {
        return true;
      }
    }
    return false;
  }

  // Find the notification with the matching demandUserId
  Future<NotificationInfo?> getNotificationInfo({
    required String prefsKey,
    required int demandUserId,
  }) async {
    final notifications = await _getNotifications(prefsKey);
    final notification = notifications.firstWhereOrNull(
      (n) => n.demandUserId == demandUserId,
    );

    return notification;
  }

  // Helper function to get notifications from SharedPreferences
  Future<List<NotificationInfo>> _getNotifications(String prefsKey) async {
    final notificationInfoStrings = _prefs?.getStringList(prefsKey) ?? [];
    return notificationInfoStrings
        .map((json) => NotificationInfo.fromJson(json))
        .toList();
  }

  // Helper function to save notifications to SharedPreferences
  Future<void> _saveNotifications(
    String prefsKey,
    List<NotificationInfo> notifications,
  ) async {
    final notificationInfoStrings =
        notifications.map((n) => jsonEncode(n.toJson())).toList();
    await _prefs?.setStringList(prefsKey, notificationInfoStrings);
  }

  Future<void> deleteNotificationInfo({required int demandUserId}) async {
    await _deleteNotificationInfo(_prefsKeyNormal, demandUserId);
    await _deleteNotificationInfo(_prefsKeyAudio, demandUserId);
    if (Get.isRegistered<LogsController>()) {
      Get.find<LogsController>().fetchLogs(logType: LogType.Missed);
    }
  }

  Future<void> _deleteNotificationInfo(
    String prefsKey,
    int demandUserId,
  ) async {
    final notifications = await _getNotifications(prefsKey);
    final notificationIndex = notifications.indexWhere(
      (n) => n.demandUserId == demandUserId,
    );

    if (notificationIndex != -1) {
      // Remove the notification if it exists
      notifications.removeAt(notificationIndex);
      await _saveNotifications(prefsKey, notifications);
    }
  }
}

// Data class to store notification information
class NotificationInfo {
  final NotificationType type;
  final DateTime timestamp;
  final int demandUserId;
  final int count;

  NotificationInfo({
    required this.type,
    required this.count,
    required this.demandUserId,
    required this.timestamp,
  });

  factory NotificationInfo.fromJson(String json) {
    final Map<String, dynamic> data = jsonDecode(json);
    return NotificationInfo(
      demandUserId: data['uid'],
      count: data['count'],
      type: NotificationType.values[data['type']],
      timestamp: DateTime.fromMillisecondsSinceEpoch(data['timestamp']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': demandUserId,
      'count': count,
      'type': type.index,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }
}
