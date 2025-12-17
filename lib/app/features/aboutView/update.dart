import 'dart:io';
import 'package:dio/dio.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/shard/exports/all_exports.dart';

// ═══════════════════════════════════════════════════════════════════════════
// 1️⃣ MODEL - نموذج بيانات التحديث
// ═══════════════════════════════════════════════════════════════════════════

class AppUpdateModel {
  final String latestVersion; // آخر إصدار متاح
  final String minRequiredVersion; // أقل إصدار مطلوب (للتحديث الإجباري)
  final bool forceUpdate; // هل التحديث إجباري؟
  final String updateMessage; // رسالة التحديث
  final String updateMessageEn; // رسالة التحديث بالإنجليزية
  final Map<String, String> downloadLinks; // روابط التحميل حسب المنصة
  final List<String> features; // الميزات الجديدة
  final bool isActive; // هل التحديث مفعّل؟

  AppUpdateModel({
    required this.latestVersion,
    required this.minRequiredVersion,
    required this.forceUpdate,
    required this.updateMessage,
    required this.updateMessageEn,
    required this.downloadLinks,
    required this.features,
    this.isActive = true,
  });

  factory AppUpdateModel.fromJson(Map<String, dynamic> json) {
    return AppUpdateModel(
      latestVersion: json['latestVersion'] ?? '1.0.0',
      minRequiredVersion: json['minRequiredVersion'] ?? '1.0.0',
      forceUpdate: json['forceUpdate'] ?? false,
      updateMessage: json['updateMessage'] ?? '',
      updateMessageEn: json['updateMessageEn'] ?? '',
      downloadLinks: Map<String, String>.from(json['downloadLinks'] ?? {}),
      features: List<String>.from(json['features'] ?? []),
      isActive: json['isActive'] ?? true,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 2️⃣ SERVICE - خدمة فحص التحديثات
// ═══════════════════════════════════════════════════════════════════════════

class UpdateService {
  final Dio _dio = Dio();

  // 🔗 غيّر هذا الرابط لـ API الخاص بك
  static const String UPDATE_API_URL =
      'https://raw.githubusercontent.com/TaherSalah/update_app/refs/heads/master/update.json';

  /// فحص التحديثات من السيرفر
  // Future<AppUpdateModel?> checkForUpdate() async {
  //   try {
  //     final response = await _dio.get(UPDATE_API_URL);
  //
  //     if (response.statusCode == 200) {
  //       print("response.statusCode ${response.statusCode}");
  //       print("response.statusCode ${response.data}");
  //       return AppUpdateModel.fromJson(response.data);
  //     }
  //   } catch (e) {
  //     print('❌ Error checking for updates: $e');
  //   }
  //   return null;
  // }

  Future<AppUpdateModel?> checkForUpdate() async {
    try {
      final response = await _dio.get(UPDATE_API_URL);

      if (response.statusCode == 200) {
        print("response.statusCode ${response.statusCode}");
        print("response.statusCode ${response.data}");
        // لو response.data String → حوله ل JSON
        final Map<String, dynamic> jsonData =
            response.data is String ? jsonDecode(response.data) : response.data;

        return AppUpdateModel.fromJson(jsonData);
      }
    } catch (e) {
      print('❌ Error checking for updates: $e');
    }
    return null;
  }

  /// مقارنة الإصدارات
  bool isUpdateRequired(String currentVersion, String requiredVersion) {
    return _compareVersions(currentVersion, requiredVersion) < 0;
  }

  bool isUpdateAvailable(String currentVersion, String latestVersion) {
    return _compareVersions(currentVersion, latestVersion) < 0;
  }

  /// مقارنة رقمين إصدار (1.2.3 vs 1.2.4)
  int _compareVersions(String v1, String v2) {
    List<int> v1Parts = v1.split('.').map(int.parse).toList();
    List<int> v2Parts = v2.split('.').map(int.parse).toList();

    for (int i = 0; i < 3; i++) {
      int part1 = i < v1Parts.length ? v1Parts[i] : 0;
      int part2 = i < v2Parts.length ? v2Parts[i] : 0;

      if (part1 < part2) return -1;
      if (part1 > part2) return 1;
    }
    return 0;
  }

  /// الحصول على الإصدار الحالي من التطبيق
  Future<String> getCurrentVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version;
  }

  /// الحصول على المنصة الحالية
  String getCurrentPlatform() {
    if (Platform.isAndroid) return 'android';
    if (Platform.isIOS) return 'ios';
    // للهواوي، عادة بيكون android برضه لكن ممكن تعمل فحص إضافي
    return 'android';
  }

  /// فتح رابط التحديث
  Future<void> openUpdateLink(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 3️⃣ WIDGET - مربع حوار التحديث
// ═══════════════════════════════════════════════════════════════════════════

class UpdateDialog extends StatelessWidget {
  final AppUpdateModel updateInfo;
  final bool isForced;
  final VoidCallback onUpdate;
  final VoidCallback? onSkip;
  final bool isArabic;

  const UpdateDialog({
    super.key,
    required this.updateInfo,
    required this.isForced,
    required this.onUpdate,
    this.onSkip,
    this.isArabic = true,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !isForced,
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(
              isForced ? Icons.warning_amber_rounded : Icons.system_update,
              color: isForced ? Colors.red : Colors.blue,
              size: 32,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                isForced
                    ? (isArabic ? 'تحديث مطلوب' : 'Update Required')
                    : (isArabic ? 'تحديث متاح' : 'Update Available'),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isArabic
                    ? updateInfo.updateMessage
                    : updateInfo.updateMessageEn,
                style: const TextStyle(fontSize: 16),
              ),
              if (updateInfo.features.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  isArabic ? 'الميزات الجديدة:' : 'New Features:',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                ...updateInfo.features.map(
                  (feature) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('• ', style: TextStyle(fontSize: 16)),
                        Expanded(child: Text(feature)),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline,
                        color: Colors.blue, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      isArabic
                          ? 'الإصدار الجديد: ${updateInfo.latestVersion}'
                          : 'New Version: ${updateInfo.latestVersion}',
                      style: const TextStyle(color: Colors.blue),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          if (!isForced)
            TextButton(
              onPressed: onSkip,
              child: Text(isArabic ? 'لاحقاً' : 'Later'),
            ),
          ElevatedButton(
            onPressed: onUpdate,
            style: ElevatedButton.styleFrom(
              backgroundColor: isForced ? Colors.red : Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                isArabic ? 'تحديث الآن' : 'Update Now',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 4️⃣ MIDDLEWARE - صفحة التحقق من التحديث
// ═══════════════════════════════════════════════════════════════════════════

class UpdateCheckScreen extends StatefulWidget {
  final Widget child; // الصفحة الرئيسية للتطبيق
  final bool isArabic;

  const UpdateCheckScreen({
    super.key,
    required this.child,
    this.isArabic = true,
  });

  @override
  State<UpdateCheckScreen> createState() => _UpdateCheckScreenState();
}

class _UpdateCheckScreenState extends State<UpdateCheckScreen> {
  final UpdateService _updateService = UpdateService();
  bool _isChecking = true;
  bool _showApp = false;

  @override
  void initState() {
    super.initState();
    _checkForUpdates();
  }

  Future<void> _checkForUpdates() async {
    try {
      // الحصول على معلومات التحديث
      final updateInfo = await _updateService.checkForUpdate();

      if (updateInfo == null || !updateInfo.isActive) {
        setState(() {
          _showApp = true;
          _isChecking = false;
        });
        return;
      }

      // الحصول على الإصدار الحالي
      final currentVersion = await _updateService.getCurrentVersion();

      // التحقق من الحاجة للتحديث
      final isForced = _updateService.isUpdateRequired(
        currentVersion,
        updateInfo.minRequiredVersion,
      );

      final hasUpdate = _updateService.isUpdateAvailable(
        currentVersion,
        updateInfo.latestVersion,
      );

      setState(() => _isChecking = false);

      if (hasUpdate && mounted) {
        _showUpdateDialog(updateInfo, isForced);
      } else {
        setState(() => _showApp = true);
      }
    } catch (e) {
      print('❌ Error in update check: $e');
      setState(() {
        _showApp = true;
        _isChecking = false;
      });
    }
  }

  void _showUpdateDialog(AppUpdateModel updateInfo, bool isForced) {
    showDialog(
      context: context,
      barrierDismissible: !isForced,
      builder: (context) => UpdateDialog(
        updateInfo: updateInfo,
        isForced: isForced,
        isArabic: widget.isArabic,
        onUpdate: () {
          final platform = _updateService.getCurrentPlatform();
          final link = updateInfo.downloadLinks[platform] ?? '';
          if (link.isNotEmpty) {
            _updateService.openUpdateLink(link);
          }
          if (!isForced) {
            Navigator.of(context).pop();
            setState(() => _showApp = true);
          }
        },
        onSkip: !isForced
            ? () {
                Navigator.of(context).pop();
                setState(() => _showApp = true);
              }
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    return _showApp ? widget.child : const SizedBox.shrink();
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 5️⃣ INTEGRATION - التكامل مع main.dart
// ═══════════════════════════════════════════════════════════════════════════

// في ملف main.dart، غيّر runApp إلى:

/*
void main() async {
  // ... كل الكود الموجود عندك ...

  runApp(
    BlocProvider<CentralizedCubit>(
      create: (context) => CentralizedCubit(sharedPreferences: Di.sharedPreferences)
        ..localization(),
      child: BlocBuilder<CentralizedCubit, CentralizedState>(
        builder: (context, state) {
          return UpdateCheckScreen(
            isArabic: state.locale?.languageCode == 'ar',
            child: const MashkahApp(),
          );
        },
      ),
    ),
  );
}
*/
