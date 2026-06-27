import 'package:package_info_plus/package_info_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../errors/failure.dart';
import '../../core/push_notification_logger.dart';
import '../../domain/entities/notification_token.dart';

/// مصدر البيانات البعيد — يتواصل مع Supabase لحفظ وإدارة Push Tokens
///
/// ### الجدول المستخدم: `push_tokens`
/// (تم إنشاؤه في push_tokens_schema.sql)
///
/// ### العمليات:
/// - upsert: إدخال أو تحديث Token
/// - deactivate: إلغاء تفعيل Token عند تسجيل الخروج
/// - delete: حذف Token نهائياً
class TokenRemoteDataSource {
  final SupabaseClient _supabase;
  final PushNotificationLogger _logger;

  static const String _tableName = 'push_tokens';
  static const String _rpcUpsert = 'upsert_push_token';
  static const String _rpcDeactivate = 'deactivate_push_token';

  TokenRemoteDataSource(this._supabase, this._logger);

  // ─────────────────────────────────────────────────────────────────
  //  Upsert Token
  // ─────────────────────────────────────────────────────────────────

  /// إرسال Token إلى Supabase (إدخال جديد أو تحديث موجود)
  ///
  /// يستخدم الـ RPC Function `upsert_push_token` التي تتجنب التكرار
  Future<void> upsertToken({
    required String userId,
    required NotificationToken token,
  }) async {
    try {
      _logger.i('📤 Sending push token to Supabase...');

      // جلب إصدار التطبيق
      String appVersion = '';
      try {
        final info = await PackageInfo.fromPlatform();
        appVersion = '${info.version}+${info.buildNumber}';
      } catch (_) {
        appVersion = 'unknown';
      }

      // استخدام RPC Function لتجنب conflict errors
      await _supabase.rpc(_rpcUpsert, params: {
        'p_user_id': userId,
        'p_token': token.value,
        'p_provider': token.provider.name,
        'p_platform': token.platform,
        'p_app_version': appVersion,
      });

      _logger.i('✅ Token upserted to Supabase [${token.provider.name}]');
    } on PostgrestException catch (e) {
      _logger.e(
        'Supabase error upserting token: ${e.code} - ${e.message}',
        error: e,
      );
      throw ServerFailure(
        errorMessage: 'Failed to save push token: ${e.message}',
      );
    } catch (e, stack) {
      _logger.e('Unexpected error upserting token', error: e, stackTrace: stack);
      throw ServerFailure(errorMessage: e.toString());
    }
  }

  // ─────────────────────────────────────────────────────────────────
  //  Deactivate Token (Logout)
  // ─────────────────────────────────────────────────────────────────

  /// إلغاء تفعيل Token عند تسجيل الخروج
  ///
  /// لا نحذف الـ Token بل نضع `is_active = false`
  /// لأن الـ Backend قد يحتاج سجل التاريخ
  Future<void> deactivateToken({
    required String userId,
    required String tokenValue,
  }) async {
    try {
      _logger.i('🔕 Deactivating push token in Supabase...');

      await _supabase.rpc(_rpcDeactivate, params: {
        'p_user_id': userId,
        'p_token': tokenValue,
      });

      _logger.i('✅ Token deactivated in Supabase');
    } on PostgrestException catch (e) {
      _logger.e(
        'Supabase error deactivating token: ${e.code} - ${e.message}',
        error: e,
      );
      // لا نرمي Exception هنا — الـ logout يجب أن يكتمل حتى لو فشل هذا
    } catch (e) {
      _logger.e('Unexpected error deactivating token', error: e);
    }
  }

  // ─────────────────────────────────────────────────────────────────
  //  Delete All Tokens for User
  // ─────────────────────────────────────────────────────────────────

  /// حذف جميع tokens لمستخدم معين (للحسابات المحذوفة)
  Future<void> deleteAllTokensForUser(String userId) async {
    try {
      _logger.w('🗑️ Deleting all push tokens for user: $userId');

      await _supabase
          .from(_tableName)
          .delete()
          .eq('user_id', userId);

      _logger.i('✅ All tokens deleted for user');
    } on PostgrestException catch (e) {
      _logger.e('Supabase error deleting tokens: ${e.message}', error: e);
    }
  }

  // ─────────────────────────────────────────────────────────────────
  //  Get Active Tokens for User (للـ Backend Admin)
  // ─────────────────────────────────────────────────────────────────

  /// جلب جميع Tokens النشطة لمستخدم (للـ Admin Dashboard)
  Future<List<Map<String, dynamic>>> getActiveTokensForUser(
    String userId,
  ) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('user_id', userId)
          .eq('is_active', true)
          .order('updated_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      _logger.e('Failed to get tokens for user', error: e);
      return [];
    }
  }
}
