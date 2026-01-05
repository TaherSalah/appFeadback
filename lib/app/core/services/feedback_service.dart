import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' as p;

/// خدمة إرسال الشكاوى والاقتراحات إلى Supabase
class FeedbackService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// إرسال شكوى أو اقتراح
  ///
  /// [name] اسم المستخدم (مطلوب)
  /// [email] البريد الإلكتروني (مطلوب)
  /// [category] التصنيف (مشكلة، تحديث، اقتراح، إلخ)
  /// [description] وصف الشكوى أو الاقتراح (مطلوب)
  /// [images] قائمة الصور الاختيارية
  /// [phone] رقم الهاتف الاختياري
  /// [rating] التقييم بالنجوم (1-5)
  Future<void> submitFeedback({
    required String name,
    required String email,
    required String category,
    required String description,
    List<File>? images,
    String? phone,
    int? rating,
  }) async {
    try {
      List<String> imageUrls = [];

      // 1. رفع الصور إلى Storage إذا كانت موجودة
      if (images != null && images.isNotEmpty) {
        for (var image in images) {
          final fileName =
              '${DateTime.now().millisecondsSinceEpoch}_${p.basename(image.path)}';
          final path = 'uploads/$fileName';

          // رفع الصورة
          await _supabase.storage.from('feedback_images').upload(path, image);

          // الحصول على رابط الصورة العام
          final String publicUrl =
              _supabase.storage.from('feedback_images').getPublicUrl(path);

          imageUrls.add(publicUrl);
        }
      }

      // 2. جمع معلومات الجهاز تلقائياً
      final deviceInfo = await _getDeviceInfo();

      // 3. إدراج البيانات في قاعدة البيانات
      await _supabase.from('feedback').insert({
        'name': name,
        'email': email,
        'category': category,
        'description': description,
        'image_urls': imageUrls,
        'device_info': deviceInfo,
        'phone': phone,
        'rating': rating ?? 5, // افتراضي 5 نجوم إذا لم يحدد
        'status': 'جديد', // الحالة الافتراضية
        'fcm_token': null, // No longer using OneSignal
      });
    } catch (e) {
      // إعادة رمي الخطأ ليتم التعامل معه في واجهة المستخدم
      rethrow;
    }
  }

  /// جلب سجل الشكاوى الخاص بمستخدم معين بناءً على البريد الإلكتروني
  Future<List<Map<String, dynamic>>> getUserFeedback(String email) async {
    try {
      final response = await _supabase
          .from('feedback')
          .select('*')
          .eq('email', email)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      rethrow;
    }
  }

  /// جمع معلومات الجهاز للمساعدة في تتبع المشاكل
  Future<Map<String, dynamic>> _getDeviceInfo() async {
    final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();

    Map<String, dynamic> info = {
      'app_version': packageInfo.version,
      'build_number': packageInfo.buildNumber,
    };

    if (Platform.isAndroid) {
      final androidInfo = await deviceInfoPlugin.androidInfo;
      info.addAll({
        'os': 'Android',
        'os_version': androidInfo.version.release,
        'model': androidInfo.model,
        'manufacturer': androidInfo.manufacturer,
      });
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfoPlugin.iosInfo;
      info.addAll({
        'os': 'iOS',
        'os_version': iosInfo.systemVersion,
        'model': iosInfo.utsname.machine,
        'name': iosInfo.name,
      });
    }

    return info;
  }
}
