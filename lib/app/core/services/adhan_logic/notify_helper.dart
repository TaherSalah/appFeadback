import 'dart:developer' show log;

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart' show Colors;
import 'package:shared_preferences/shared_preferences.dart';

import 'prayers_notifications_controller.dart';

class NotifyHelper {
  static bool _initialized = false;

  // Note: For now using standard sound paths from almasjid.
  // In rafuiqElmuslim, we can load from SharedPreferences.
  static Future<String> get audioPath async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('adhan_path') ?? 'resource://raw/aqsa_athan';
  }

  static Future<String> get audioFajirPath async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('adhan_path_fajir') ??
        'resource://raw/aqsa_fajir_athan';
  }

  static const String _permissionFlagKey = 'notifications_permission_granted';
  static const String _notificationSetupSeenKey = 'notification_setup_seen';

  static Future<bool> get isAllowed async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_permissionFlagKey) ?? false;
  }

  static Future<bool> get hasSeenNotificationSetup async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_notificationSetupSeenKey) ?? false;
  }

  static Future<void> markNotificationSetupAsSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationSetupSeenKey, true);
    log('Marked notification setup as seen', name: 'NotifyHelper');
  }

  Future<String> customSound(
      Map<String, String?> payload, int reminderId) async {
    String? soundType = payload['sound_type'];

    switch (soundType) {
      case 'nothing':
      case 'silent':
        return 'resource://raw/silence';
      case 'bell':
        return 'resource://raw/notification';
      case 'sound':
        return reminderId == 0 ? await audioFajirPath : await audioPath;
      default:
        return 'resource://raw/notification';
    }
  }

  Future<void> scheduledNotification({
    required int reminderId,
    required String title,
    required String summary,
    required String body,
    required bool isRepeats,
    DateTime? time,
    Map<String, String?>? payload,
    int? soundIndex,
  }) async {
    payload ??= {'sound_type': 'bell'};

    if (!_initialized) {
      initAwesomeNotifications();
    }
    String localTimeZone =
        await AwesomeNotifications().getLocalTimeZoneIdentifier();

    String channelKey = _getChannelKey(payload['sound_type']);

    try {
      final aPath = await audioPath;
      log('audioPath: $aPath', name: 'NotifyHelper');
      log('sound_type: ${payload['sound_type']}', name: 'NotifyHelper');
      log('channelKey: $channelKey', name: 'NotifyHelper');

      AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: reminderId,
          groupKey: 'prayers_notifications_ak$reminderId',
          channelKey: channelKey,
          actionType: ActionType.Default,
          title: title,
          summary: summary,
          body: body,
          payload: payload,
          customSound: await customSound(payload, reminderId),
          wakeUpScreen: true,
          badge: 0,
        ),
        schedule: time != null
            ? NotificationCalendar.fromDate(
                date: time,
                repeats: isRepeats,
                allowWhileIdle: true,
                preciseAlarm: true)
            : NotificationInterval(
                interval: const Duration(minutes: 2),
                timeZone: localTimeZone,
                repeats: false),
      );
      log('Notification successfully scheduled', name: 'NotifyHelper');
    } catch (e) {
      log('Error scheduling notification: $e', name: 'NotifyHelper');
    }
  }

  String _getChannelKey(String? soundType) {
    switch (soundType) {
      case 'sound':
        return 'prayers_notifications_channel_ak';
      case 'bell':
      case 'nothing':
      case 'silent':
      default:
        return 'prayers_notifications_channel_ak_notification';
    }
  }

  static void initAwesomeNotifications() {
    // Initialization is now handled centrally by NotificationManager
    _initialized = true;
    log('Awesome Notifications Initialization handled by NotificationManager',
        name: 'NotifyHelper');
  }

  Future<void> notificationBadgeListener() async {
    await AwesomeNotifications().getGlobalBadgeCounter().then((_) async {
      await AwesomeNotifications().setGlobalBadgeCounter(0);
    });
  }

  Future<void> cancelNotification(int notificationId) async {
    log('Notification ID $notificationId was cancelled', name: 'NotifyHelper');
    return AwesomeNotifications().cancelSchedule(notificationId);
  }

  Future<void> requistPermissions() async {
    if (!_initialized) {
      initAwesomeNotifications();
    }
    await AwesomeNotifications()
        .isNotificationAllowed()
        .then((isAllowed) async {
      if (!isAllowed) {
        try {
          await AwesomeNotifications().requestPermissionToSendNotifications();
          log('Notification permission requested', name: 'NotifyHelper');
        } catch (e) {
          log('Failed to request notification permission: $e',
              name: 'NotifyHelper');
        }
      }
    });
  }

  void setNotificationsListeners() {
    AwesomeNotifications().setListeners(
        onActionReceivedMethod: onActionReceivedMethod,
        onNotificationCreatedMethod: onNotificationCreatedMethod,
        onNotificationDisplayedMethod: onNotificationDisplayedMethod,
        onDismissActionReceivedMethod: onDismissActionReceivedMethod);
  }

  @pragma('vm:entry-point')
  static Future<void> onNotificationCreatedMethod(
      ReceivedNotification receivedNotification) async {
    log('Notification Created: ${receivedNotification.title}',
        name: 'NotifyHelper');
  }

  @pragma('vm:entry-point')
  static Future<void> onNotificationDisplayedMethod(
      ReceivedNotification receivedNotification) async {
    log('notificationDisplayed: ${receivedNotification.body}',
        name: 'NotifyHelper');
  }

  @pragma('vm:entry-point')
  static Future<void> onDismissActionReceivedMethod(
      ReceivedAction receivedAction) async {
    log('Notification Dismessed: ${receivedAction.body}', name: 'NotifyHelper');
  }

  @pragma('vm:entry-point')
  static Future<void> onActionReceivedMethod(
      ReceivedAction receivedAction) async {
    log('Received Action: ${receivedAction.body} Received Action ID: ${receivedAction.id}',
        name: 'NotifyHelper');
    // Here we can call PrayersNotificationsCtrl.instance.onNotificationActionReceived
    try {
      PrayersNotificationsCtrl.instance
          .onNotificationActionReceived(receivedAction);
    } catch (_) {}
  }
}
