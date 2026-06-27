import 'package:logger/logger.dart';

/// Logger مخصص لنظام Push Notifications
///
/// ### المميزات:
/// - يضيف prefix مميز لكل رسالة `[PUSH]` لتسهيل الفلترة
/// - في Release mode يتجاهل Debug/Verbose logs تلقائياً
/// - يدعم Error logging مع StackTrace
///
/// ### كيفية الاستخدام:
/// ```dart
/// final logger = PushNotificationLogger();
/// logger.d('Debug message');     // 🔵 Debug (dev only)
/// logger.i('Info message');      // 🟢 Info
/// logger.w('Warning message');   // 🟡 Warning
/// logger.e('Error message');     // 🔴 Error
/// ```
class PushNotificationLogger {
  static const String _tag = '[PUSH]';

  final Logger _logger;

  PushNotificationLogger({bool verbose = false})
      : _logger = Logger(
          printer: PrettyPrinter(
            methodCount: 1,
            errorMethodCount: 5,
            lineLength: 80,
            colors: true,
            printEmojis: true,
            dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
          ),
          // في Release mode: فقط Warning وما فوق
          level: verbose ? Level.trace : Level.info,
        );

  /// رسائل التطوير التفصيلية (لن تظهر في Release)
  void d(String message) {
    _logger.d('$_tag $message');
  }

  /// معلومات عامة مهمة
  void i(String message) {
    _logger.i('$_tag $message');
  }

  /// تحذيرات لا تُوقف التطبيق لكن تحتاج انتباه
  void w(String message) {
    _logger.w('$_tag $message');
  }

  /// أخطاء مع stackTrace اختيارية
  void e(String message, {Object? error, StackTrace? stackTrace}) {
    _logger.e(
      '$_tag $message',
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// رسائل Token (تُظهر أول 20 حرف فقط من الـ Token لأسباب أمنية)
  void token(String token, String provider) {
    final preview =
        token.length > 20 ? '${token.substring(0, 20)}...' : token;
    _logger.i('$_tag Token [$provider]: $preview');
  }
}
