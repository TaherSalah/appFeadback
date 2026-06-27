import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart' show Color;

import 'push_notification_logger.dart';

/// مُدير Notification Channels الخاصة بالـ Push Notifications
///
/// تعمل **جنباً إلى جنب** مع [NotificationManager] الموجود —
/// لا تُعيد التهيئة بل تُضيف القنوات عبر [AwesomeNotifications().setChannel].
///
/// ### قنوات الـ Push:
/// | المفتاح | الوصف | الأهمية |
/// |---------|-------|---------|
/// | push_general_channel | إشعارات عامة | High |
/// | push_community_channel | إشعارات المقرأة القرآنية | Default |
/// | push_silent_channel | تحديثات صامتة | Low |
class NotificationChannelsManager {
  static const String generalChannelKey = 'push_general_channel';
  static const String communityChannelKey = 'push_community_channel';
  static const String silentChannelKey = 'push_silent_channel';

  static const _green = Color(0xFF178B74);

  // ─────────────────────────────────────────────────────────────────
  //  Create Push Channels
  // ─────────────────────────────────────────────────────────────────

  /// إضافة قنوات الـ Push إلى awesome_notifications
  ///
  /// يستخدم [setChannel] لإضافة القنوات بدون إعادة تهيئة كاملة،
  /// لتجنب التعارض مع القنوات الموجودة في [NotificationManager].
  static Future<void> createPushChannels() async {
    final logger = PushNotificationLogger();

    try {
      await Future.wait([
        _createGeneralChannel(),
        _createCommunityChannel(),
        _createSilentChannel(),
      ]);
      logger.i('✅ Push notification channels created');
    } catch (e) {
      logger.e('Failed to create push channels', error: e);
    }
  }

  // ─────────────────────────────────────────────────────────────────
  //  Channel Definitions
  // ─────────────────────────────────────────────────────────────────

  static Future<void> _createGeneralChannel() async {
    await AwesomeNotifications().setChannel(
      NotificationChannel(
        channelKey: generalChannelKey,
        channelName: 'الإشعارات العامة',
        channelDescription: 'الإشعارات الواردة من رفيق المسلم',
        importance: NotificationImportance.High,
        defaultColor: _green,
        ledColor: _green,
        playSound: true,
        enableVibration: true,
        enableLights: true,
      ),
    );
  }

  static Future<void> _createCommunityChannel() async {
    await AwesomeNotifications().setChannel(
      NotificationChannel(
        channelKey: communityChannelKey,
        channelName: 'المقرأة القرآنية',
        channelDescription: 'إشعارات المقرأة القرآنية والتعليقات والتفاعل',
        importance: NotificationImportance.Default,
        defaultColor: _green,
        ledColor: _green,
        playSound: true,
        enableVibration: true,
        enableLights: true,
      ),
    );
  }

  static Future<void> _createSilentChannel() async {
    await AwesomeNotifications().setChannel(
      NotificationChannel(
        channelKey: silentChannelKey,
        channelName: 'تحديثات صامتة',
        channelDescription: 'تحديثات بيانات في الخلفية بدون صوت',
        importance: NotificationImportance.Low,
        playSound: false,
        enableVibration: false,
        enableLights: false,
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  //  Helper: اختيار Channel المناسب لكل نوع إشعار
  // ─────────────────────────────────────────────────────────────────

  /// يُعيد مفتاح الـ Channel المناسب لنوع الإشعار
  static String getChannelForType(String notificationType) {
    switch (notificationType) {
      case 'community':
      case 'communityPost':
      case 'communityComment':
        return communityChannelKey;
      case 'dataUpdate':
        return silentChannelKey;
      default:
        return generalChannelKey;
    }
  }
}
