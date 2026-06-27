import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/notification_token.dart';
import '../../core/push_notification_logger.dart';

/// مصدر البيانات المحلي — يحفظ ويسترجع Token من SharedPreferences
///
/// ### الغرض:
/// - تجنب إرسال Token مكرر للـ Backend (يقارن القديم بالجديد)
/// - الاحتفاظ بالـ Token عند فقدان الإنترنت وإعادة الإرسال لاحقاً
/// - تتبع حالة الإرسال للـ Backend (هل أُرسل أم لا؟)
class TokenLocalDataSource {
  static const String _tokenKey = 'push_token_value';
  static const String _providerKey = 'push_token_provider';
  static const String _platformKey = 'push_token_platform';
  static const String _isSentKey = 'push_token_is_sent';
  static const String _updatedAtKey = 'push_token_updated_at';

  final SharedPreferences _prefs;
  final PushNotificationLogger _logger;

  TokenLocalDataSource(this._prefs, this._logger);

  // ─────────────────────────────────────────────────────────────────
  //  Save
  // ─────────────────────────────────────────────────────────────────

  /// حفظ الـ Token محلياً
  Future<void> saveToken(NotificationToken token) async {
    await Future.wait([
      _prefs.setString(_tokenKey, token.value),
      _prefs.setString(_providerKey, token.provider.name),
      _prefs.setString(_platformKey, token.platform),
      _prefs.setString(
          _updatedAtKey, token.updatedAt.toIso8601String()),
      // عند الحفظ، نعيّن isSent = false حتى يُرسَل للـ Backend
      _prefs.setBool(_isSentKey, false),
    ]);

    _logger.d('💾 Token saved locally [${token.provider.name}]');
  }

  /// تحديث حالة الإرسال للـ Backend
  Future<void> markAsSent() async {
    await _prefs.setBool(_isSentKey, true);
    _logger.d('✅ Token marked as sent to backend');
  }

  // ─────────────────────────────────────────────────────────────────
  //  Read
  // ─────────────────────────────────────────────────────────────────

  /// استرجاع الـ Token المحفوظ
  NotificationToken? getSavedToken() {
    final value = _prefs.getString(_tokenKey);
    if (value == null || value.isEmpty) return null;

    final providerStr = _prefs.getString(_providerKey) ?? 'none';
    final platform = _prefs.getString(_platformKey) ?? '';
    final updatedAtStr = _prefs.getString(_updatedAtKey);

    return NotificationToken(
      value: value,
      provider: _parseProvider(providerStr),
      platform: platform,
      updatedAt: updatedAtStr != null
          ? DateTime.tryParse(updatedAtStr) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  /// هل الـ Token تغيّر عن المحفوظ؟
  ///
  /// يُستخدم لتجنب إرسال Token مكرر للـ Backend
  bool hasTokenChanged(String newToken) {
    final saved = _prefs.getString(_tokenKey);
    return saved != newToken;
  }

  /// هل الـ Token أُرسل للـ Backend؟
  bool isTokenSentToBackend() {
    return _prefs.getBool(_isSentKey) ?? false;
  }

  // ─────────────────────────────────────────────────────────────────
  //  Clear
  // ─────────────────────────────────────────────────────────────────

  /// حذف الـ Token المحلي (عند تسجيل الخروج)
  Future<void> clearToken() async {
    await Future.wait([
      _prefs.remove(_tokenKey),
      _prefs.remove(_providerKey),
      _prefs.remove(_platformKey),
      _prefs.remove(_isSentKey),
      _prefs.remove(_updatedAtKey),
    ]);
    _logger.d('🗑️ Local token cleared');
  }

  // ─────────────────────────────────────────────────────────────────
  //  Helpers
  // ─────────────────────────────────────────────────────────────────

  PushProvider _parseProvider(String str) {
    return PushProvider.values.firstWhere(
      (e) => e.name == str,
      orElse: () => PushProvider.none,
    );
  }
}
