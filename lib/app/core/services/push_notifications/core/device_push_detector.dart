import 'dart:io';

import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/entities/notification_token.dart';
import 'push_notification_logger.dart';

/// نتيجة فحص خدمة الـ Push على الجهاز
class DevicePushCapability {
  /// الـ Provider المتاح على الجهاز
  final PushProvider provider;

  /// هل الجهاز iOS؟
  final bool isIos;

  /// هل الجهاز Huawei بدون GMS؟
  final bool isHmsOnly;

  /// هل الجهاز Android بـ GMS؟
  final bool isGmsAvailable;

  const DevicePushCapability({
    required this.provider,
    required this.isIos,
    required this.isHmsOnly,
    required this.isGmsAvailable,
  });

  @override
  String toString() {
    return 'DevicePushCapability(provider: ${provider.name}, '
        'isIos: $isIos, isHmsOnly: $isHmsOnly, isGmsAvailable: $isGmsAvailable)';
  }
}

/// الكلاس المسؤول عن اكتشاف خدمة الـ Push المناسبة للجهاز
///
/// ### كيف يعمل؟
///
/// ```
/// Start
///   ↓
/// iOS? ──YES──→ Use FCM (APNs via Firebase)
///   ↓ NO
/// Android?
///   ↓
/// Check GMS (GoogleApiAvailability) ──AVAILABLE──→ Use FCM
///   ↓ NOT AVAILABLE
/// Check HMS (HmsApiAvailability) ──AVAILABLE──→ Use HMS
///   ↓ NOT AVAILABLE
/// No push service → PushProvider.none
/// ```
///
/// ### مصادر الفحص
/// - لـ GMS: `com.google.android.gms:play-services-base` عبر MethodChannel
/// - لـ HMS: `com.huawei.hms:base` عبر MethodChannel
///
/// ### Caching
/// يُخزّن النتيجة في SharedPreferences لتجنب إعادة الفحص عند كل launch
class DevicePushDetector {
  static const String _cacheKey = 'push_provider_detected';
  static const String _channelName =
      'com.rafiq.muslimdaily/push_detector';

  static final MethodChannel _channel = const MethodChannel(_channelName);

  final SharedPreferences _prefs;
  final PushNotificationLogger _logger;

  DevicePushDetector(this._prefs, this._logger);

  /// ذاكرة مؤقتة في الـ RAM (لتجنب قراءة SharedPreferences مراراً)
  DevicePushCapability? _cachedCapability;

  // ─────────────────────────────────────────────────────────────────
  // Public API
  // ─────────────────────────────────────────────────────────────────

  /// الكشف عن خدمة الـ Push المناسبة للجهاز الحالي
  ///
  /// يتحقق من الـ cache أولاً، إذا لم يجد يجري الفحص الكامل
  Future<DevicePushCapability> detectCapability() async {
    // 1. استخدام الـ RAM cache إذا متوفر (أسرع)
    if (_cachedCapability != null) {
      _logger.d('🔍 Using RAM-cached push capability: $_cachedCapability');
      return _cachedCapability!;
    }

    // 2. استخدام SharedPreferences cache (يبقى بعد إغلاق التطبيق)
    final cached = _prefs.getString(_cacheKey);
    if (cached != null) {
      final capability = _fromCacheString(cached);
      _cachedCapability = capability;
      _logger.d('🔍 Using SharedPreferences-cached push capability: $capability');
      return capability;
    }

    // 3. فحص الجهاز فعلياً
    final capability = await _detectFresh();
    _cachedCapability = capability;

    // 4. حفظ في SharedPreferences
    await _prefs.setString(_cacheKey, _toCacheString(capability));

    _logger.i('🔍 Detected push capability: $capability');
    return capability;
  }

  /// إعادة تعيين الـ cache وإجراء فحص جديد
  ///
  /// يُستخدم عند تثبيت تحديث GMS أو HMS على الجهاز
  Future<DevicePushCapability> refreshCapability() async {
    _cachedCapability = null;
    await _prefs.remove(_cacheKey);
    return detectCapability();
  }

  // ─────────────────────────────────────────────────────────────────
  // Private Detection Logic
  // ─────────────────────────────────────────────────────────────────

  Future<DevicePushCapability> _detectFresh() async {
    // ── iOS ─────────────────────────────────────────────────────────
    if (Platform.isIOS) {
      // TODO: عند الاستعداد لـ iOS:
      //   1. احصل على حساب Apple Developer
      //   2. أضف GoogleService-Info.plist في ios/Runner/
      //   3. غيّر هذا السطر إلى: provider: PushProvider.fcm
      //
      // حالياً: iOS لا يدعم Push Notifications (بدون حساب Apple Developer)
      _logger.w('⚠️ iOS push not configured yet — no Apple Developer account');
      return const DevicePushCapability(
        provider: PushProvider.none,
        isIos: true,
        isHmsOnly: false,
        isGmsAvailable: false,
      );
    }

    // ── Android ─────────────────────────────────────────────────────
    if (Platform.isAndroid) {
      // خطوة 1: فحص Google Play Services
      final gmsAvailable = await _isGmsAvailable();
      if (gmsAvailable) {
        return const DevicePushCapability(
          provider: PushProvider.fcm,
          isIos: false,
          isHmsOnly: false,
          isGmsAvailable: true,
        );
      }

      // خطوة 2: فحص Huawei Mobile Services
      final hmsAvailable = await _isHmsAvailable();
      if (hmsAvailable) {
        return const DevicePushCapability(
          provider: PushProvider.hms,
          isIos: false,
          isHmsOnly: true,
          isGmsAvailable: false,
        );
      }

      // لا توجد خدمة push على الجهاز
      _logger.w('⚠️ No push service available on this device');
      return const DevicePushCapability(
        provider: PushProvider.none,
        isIos: false,
        isHmsOnly: false,
        isGmsAvailable: false,
      );
    }

    // منصات أخرى (غير مدعومة بـ Push)
    return const DevicePushCapability(
      provider: PushProvider.none,
      isIos: false,
      isHmsOnly: false,
      isGmsAvailable: false,
    );
  }

  /// فحص توفر Google Play Services عبر MethodChannel
  ///
  /// نتائج ResultCode من GoogleApiAvailability:
  /// - 0: SUCCESS (GMS متاح)
  /// - 1: SERVICE_MISSING
  /// - 2: SERVICE_VERSION_UPDATE_REQUIRED
  /// - 3: SERVICE_DISABLED
  /// - 9: SERVICE_INVALID
  Future<bool> _isGmsAvailable() async {
    try {
      final int resultCode = await _channel.invokeMethod('checkGmsAvailability');
      final isAvailable = resultCode == 0; // ConnectionResult.SUCCESS
      _logger.d(
          'GMS check result: $resultCode → ${isAvailable ? "AVAILABLE" : "NOT AVAILABLE"}');
      return isAvailable;
    } on PlatformException catch (e) {
      _logger.e('Failed to check GMS: ${e.message}');
      // في حال فشل الفحص، نفترض أن GMS متاح (الحالة الأكثر شيوعاً)
      return Platform.isAndroid;
    } catch (e) {
      _logger.e('Unexpected error checking GMS: $e');
      return false;
    }
  }

  /// فحص توفر Huawei Mobile Services عبر MethodChannel
  Future<bool> _isHmsAvailable() async {
    try {
      final int resultCode = await _channel.invokeMethod('checkHmsAvailability');
      final isAvailable = resultCode == 0; // HuaweiApiAvailability.HMS_CORE_APK_UP_TO_DATE
      _logger.d(
          'HMS check result: $resultCode → ${isAvailable ? "AVAILABLE" : "NOT AVAILABLE"}');
      return isAvailable;
    } on PlatformException catch (e) {
      // PlatformException عادةً تعني أن HMS غير مثبّت أصلاً
      _logger.d('HMS not available (PlatformException): ${e.message}');
      return false;
    } catch (e) {
      _logger.e('Unexpected error checking HMS: $e');
      return false;
    }
  }

  // ─────────────────────────────────────────────────────────────────
  // Cache Serialization
  // ─────────────────────────────────────────────────────────────────

  String _toCacheString(DevicePushCapability cap) {
    return '${cap.provider.name}|${cap.isIos}|${cap.isHmsOnly}|${cap.isGmsAvailable}';
  }

  DevicePushCapability _fromCacheString(String str) {
    try {
      final parts = str.split('|');
      if (parts.length != 4) return _defaultCapability();

      PushProvider provider = PushProvider.values.firstWhere(
        (e) => e.name == parts[0],
        orElse: () => PushProvider.none,
      );

      return DevicePushCapability(
        provider: provider,
        isIos: parts[1] == 'true',
        isHmsOnly: parts[2] == 'true',
        isGmsAvailable: parts[3] == 'true',
      );
    } catch (_) {
      return _defaultCapability();
    }
  }

  DevicePushCapability _defaultCapability() {
    return const DevicePushCapability(
      provider: PushProvider.none,
      isIos: false,
      isHmsOnly: false,
      isGmsAvailable: false,
    );
  }
}
