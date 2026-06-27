import 'package:flutter/material.dart';

import '../domain/entities/notification_payload.dart';
import 'push_notification_logger.dart';

/// مُدير التنقل للإشعارات — Deep Linking
///
/// ### المسؤولية:
/// استلام [NotificationPayload] وتحديد الشاشة التي يجب فتحها
/// بناءً على [NotificationType].
///
/// ### كيف يعمل:
/// ```
/// User taps notification
///      ↓
/// NotificationCubit receives payload
///      ↓
/// NotificationNavigator.navigate(payload)
///      ↓
/// يُحدد الـ Route المناسب → يفتح الشاشة
/// ```
///
/// ### إضافة Route جديد:
/// أضف حالة جديدة في [navigate] مع الـ route المطلوب.
class NotificationNavigator {
  final GlobalKey<NavigatorState> navigatorKey;
  final PushNotificationLogger _logger;

  NotificationNavigator({
    required this.navigatorKey,
    PushNotificationLogger? logger,
  }) : _logger = logger ?? PushNotificationLogger();

  // ─────────────────────────────────────────────────────────────────
  //  Main Navigation
  // ─────────────────────────────────────────────────────────────────

  /// تنفيذ التنقل بناءً على نوع الإشعار
  ///
  /// يُستدعى من [NotificationCubit] عند الضغط على إشعار
  void navigate(NotificationPayload payload) {
    _logger.i(
      '🧭 Navigating for notification: type=${payload.type.name}, '
      'targetId=${payload.targetId}, route=${payload.routePath}',
    );

    // أولاً: إذا كان هناك route صريح في الـ payload — استخدمه مباشرة
    if (payload.routePath != null && payload.routePath!.isNotEmpty) {
      _navigateToPath(payload.routePath!, arguments: payload.data);
      return;
    }

    // ثانياً: التنقل بناءً على نوع الإشعار
    switch (payload.type) {
      case NotificationType.community:
        _navigateToCommunity(payload);
        break;

      case NotificationType.communityPost:
        _navigateToCommunityPost(payload);
        break;

      case NotificationType.communityComment:
        _navigateToCommunityPost(payload);
        break;

      case NotificationType.charity:
        _navigateToCharity(payload);
        break;

      case NotificationType.khatmah:
        _navigateToKhatmah(payload);
        break;

      case NotificationType.appUpdate:
        _navigateToAppUpdate(payload);
        break;

      case NotificationType.general:
        _navigateToMain();
        break;

      case NotificationType.unknown:
        _logger.w('Unknown notification type — navigating to main');
        _navigateToMain();
        break;
    }
  }

  // ─────────────────────────────────────────────────────────────────
  //  Specific Routes
  // ─────────────────────────────────────────────────────────────────

  void _navigateToCommunity(NotificationPayload payload) {
    final communityId = payload.targetId;
    if (communityId != null && communityId.isNotEmpty) {
      _navigateToPath(
        '/communities/details',
        arguments: {'communityId': communityId},
      );
    } else {
      _navigateToPath('/communities');
    }
  }

  void _navigateToCommunityPost(NotificationPayload payload) {
    final postId = payload.targetId ?? payload.data['post_id'] as String?;
    final communityId = payload.data['community_id'] as String?;

    if (postId != null) {
      _navigateToPath(
        '/communities/post',
        arguments: {
          'postId': postId,
          'communityId': communityId,
        },
      );
    } else {
      _navigateToCommunity(payload);
    }
  }

  void _navigateToCharity(NotificationPayload payload) {
    _navigateToPath('/charity');
  }

  void _navigateToKhatmah(NotificationPayload payload) {
    _navigateToPath('/khatmah');
  }

  void _navigateToAppUpdate(NotificationPayload payload) {
    // فتح صفحة الإعدادات أو متجر التطبيقات
    _navigateToPath('/settings/update');
  }

  void _navigateToMain() {
    _navigateToPath('/');
  }

  // ─────────────────────────────────────────────────────────────────
  //  Core Navigation Method
  // ─────────────────────────────────────────────────────────────────

  void _navigateToPath(String path, {Object? arguments}) {
    final context = navigatorKey.currentContext;
    if (context == null) {
      _logger.w('Cannot navigate — no context available (app might be starting up)');
      return;
    }

    final navigator = navigatorKey.currentState;
    if (navigator == null) {
      _logger.w('Cannot navigate — navigator state is null');
      return;
    }

    try {
      _logger.i('🧭 Navigating to: $path');

      // استخدام pushNamedAndRemoveUntil للتأكد من تنظيف الـ Stack
      navigator.pushNamedAndRemoveUntil(
        path,
        (route) => route.isFirst, // احتفظ بأول صفحة في الـ Stack
        arguments: arguments,
      );
    } catch (e) {
      _logger.e('Navigation failed to $path', error: e);
      // محاولة fallback للـ main
      try {
        navigator.pushNamedAndRemoveUntil('/', (route) => false);
      } catch (_) {}
    }
  }

  // ─────────────────────────────────────────────────────────────────
  //  Pending Navigation (للـ Terminated State)
  // ─────────────────────────────────────────────────────────────────

  NotificationPayload? _pendingNavigation;

  /// حفظ الإشعار للتنقل لاحقاً (عندما لا يكون الـ Navigator جاهزاً)
  ///
  /// يُستخدم عند فتح التطبيق من Terminated state
  void setPendingNavigation(NotificationPayload payload) {
    _pendingNavigation = payload;
    _logger.d('📌 Pending navigation saved for: ${payload.type.name}');
  }

  /// تنفيذ التنقل المعلّق إذا وُجد
  ///
  /// يُستدعى بعد بناء الـ Widget tree باستخدام addPostFrameCallback
  void executePendingNavigation() {
    if (_pendingNavigation != null) {
      final payload = _pendingNavigation!;
      _pendingNavigation = null;
      _logger.i('📌 Executing pending navigation');

      // تأخير بسيط للتأكد من جاهزية الـ Navigator
      Future.delayed(const Duration(milliseconds: 500), () {
        navigate(payload);
      });
    }
  }
}
