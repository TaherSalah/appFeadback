import 'package:equatable/equatable.dart';

/// نوع الإشعار — يستخدم لتحديد الشاشة التي يجب فتحها
enum NotificationType {
  /// إشعار عام (رسالة ترويجية أو خبر)
  general,

  /// إشعار مجتمع
  community,

  /// إشعار وظيفة جديدة في المجتمع
  communityPost,

  /// إشعار تعليق على المنشور
  communityComment,

  /// إشعار خيرية
  charity,

  /// إشعار تحديث
  appUpdate,

  /// إشعار ختمة
  khatmah,

  /// نوع مجهول — لم يُعرَّف في التطبيق بعد
  unknown,
}

/// الكيان الأساسي الذي يمثّل إشعاراً مستلماً من أي مصدر (FCM أو HMS)
///
/// هذه الـ entity هي الواجهة الموحّدة التي يتعامل معها باقي التطبيق
/// بغض النظر عن مصدر الإشعار.
class NotificationPayload extends Equatable {
  /// معرّف فريد للإشعار
  final String id;

  /// عنوان الإشعار
  final String? title;

  /// جسم نص الإشعار
  final String? body;

  /// نوع الإشعار لتحديد التنقل
  final NotificationType type;

  /// البيانات الإضافية المرسلة مع الإشعار (data payload)
  final Map<String, dynamic> data;

  /// رابط الصورة إن وُجد
  final String? imageUrl;

  /// وقت استلام الإشعار
  final DateTime receivedAt;

  /// هل التطبيق كان في الـ Foreground عند استلام الإشعار؟
  final bool isForeground;

  const NotificationPayload({
    required this.id,
    required this.type,
    required this.data,
    required this.receivedAt,
    this.title,
    this.body,
    this.imageUrl,
    this.isForeground = true,
  });

  /// تحويل map البيانات القادمة من FCM/HMS إلى NotificationPayload
  factory NotificationPayload.fromDataMap({
    required String id,
    required Map<String, dynamic> data,
    String? title,
    String? body,
    String? imageUrl,
    bool isForeground = true,
  }) {
    return NotificationPayload(
      id: id,
      title: title,
      body: body,
      imageUrl: imageUrl,
      type: _parseType(data['type'] as String?),
      data: data,
      receivedAt: DateTime.now(),
      isForeground: isForeground,
    );
  }

  /// تحويل نص الـ type القادم من الـ Backend إلى enum
  static NotificationType _parseType(String? typeStr) {
    switch (typeStr) {
      case 'general':
        return NotificationType.general;
      case 'community':
        return NotificationType.community;
      case 'community_post':
        return NotificationType.communityPost;
      case 'community_comment':
        return NotificationType.communityComment;
      case 'charity':
        return NotificationType.charity;
      case 'app_update':
        return NotificationType.appUpdate;
      case 'khatmah':
        return NotificationType.khatmah;
      default:
        return NotificationType.unknown;
    }
  }

  /// استخراج معرّف الـ Route المستهدف من data payload
  String? get targetId => data['target_id'] as String?;

  /// استخراج مسار الـ Route من data payload
  String? get routePath => data['route'] as String?;

  NotificationPayload copyWith({
    String? id,
    String? title,
    String? body,
    NotificationType? type,
    Map<String, dynamic>? data,
    String? imageUrl,
    DateTime? receivedAt,
    bool? isForeground,
  }) {
    return NotificationPayload(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      data: data ?? this.data,
      imageUrl: imageUrl ?? this.imageUrl,
      receivedAt: receivedAt ?? this.receivedAt,
      isForeground: isForeground ?? this.isForeground,
    );
  }

  @override
  List<Object?> get props => [id, title, body, type, data, imageUrl, receivedAt, isForeground];

  @override
  String toString() {
    return 'NotificationPayload(id: $id, title: $title, type: $type, isForeground: $isForeground)';
  }
}
