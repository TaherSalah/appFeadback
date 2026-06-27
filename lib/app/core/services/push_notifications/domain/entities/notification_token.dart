import 'package:equatable/equatable.dart';

/// نوع الـ Push Provider — يحدد أي خدمة تم استخدامها للحصول على الـ Token
enum PushProvider {
  /// Firebase Cloud Messaging — للأجهزة التي تدعم Google Play Services
  fcm,

  /// Huawei Mobile Services Push Kit — لأجهزة Huawei بدون GMS
  hms,

  /// Apple Push Notification Service — لأجهزة iOS (يُدار عبر FCM)
  apns,

  /// غير محدد — الجهاز لا يدعم أياً من الخدمتين
  none,
}

/// الكيان الذي يمثّل Push Token المسجَّل للجهاز
///
/// يُستخدم لإرسال Token إلى الـ Backend وتخزينه محلياً.
class NotificationToken extends Equatable {
  /// الـ Token الخام
  final String value;

  /// نوع الـ Provider الذي أصدر هذا الـ Token
  final PushProvider provider;

  /// وقت استلام الـ Token أو تحديثه
  final DateTime updatedAt;

  /// نسخة التطبيق عند تسجيل الـ Token (مفيد في الـ Backend)
  final String? appVersion;

  /// Platform: android / ios / huawei
  final String platform;

  const NotificationToken({
    required this.value,
    required this.provider,
    required this.updatedAt,
    required this.platform,
    this.appVersion,
  });

  /// Token فارغ يدل على عدم وجود Token
  static final NotificationToken empty = NotificationToken(
    value: '',
    provider: PushProvider.none,
    updatedAt: DateTime.fromMillisecondsSinceEpoch(0),
    platform: '',
  );

  bool get isEmpty => value.isEmpty;
  bool get isNotEmpty => value.isNotEmpty;

  /// تحويل إلى Map لإرساله للـ Backend (Supabase)
  Map<String, dynamic> toMap() {
    return {
      'token': value,
      'provider': provider.name,
      'platform': platform,
      'app_version': appVersion,
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// إنشاء من Map قادم من Supabase
  factory NotificationToken.fromMap(Map<String, dynamic> map) {
    return NotificationToken(
      value: map['token'] as String? ?? '',
      provider: _parseProvider(map['provider'] as String?),
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : DateTime.now(),
      platform: map['platform'] as String? ?? '',
      appVersion: map['app_version'] as String?,
    );
  }

  static PushProvider _parseProvider(String? str) {
    switch (str) {
      case 'fcm':
        return PushProvider.fcm;
      case 'hms':
        return PushProvider.hms;
      case 'apns':
        return PushProvider.apns;
      default:
        return PushProvider.none;
    }
  }

  NotificationToken copyWith({
    String? value,
    PushProvider? provider,
    DateTime? updatedAt,
    String? platform,
    String? appVersion,
  }) {
    return NotificationToken(
      value: value ?? this.value,
      provider: provider ?? this.provider,
      updatedAt: updatedAt ?? this.updatedAt,
      platform: platform ?? this.platform,
      appVersion: appVersion ?? this.appVersion,
    );
  }

  @override
  List<Object?> get props => [value, provider, updatedAt, platform, appVersion];

  @override
  String toString() {
    return 'NotificationToken(provider: ${provider.name}, platform: $platform, value: ${value.substring(0, value.length.clamp(0, 20))}...)';
  }
}
