import 'package:flutter/material.dart';
import 'package:muslimdaily/app/core/extensions/context_extension.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../widgets/CustomGradientDialog.dart';

class VersionCheckService {
  final _supabase = Supabase.instance.client;

  Future<void> checkForUpdates(BuildContext context) async {
    try {
      // 1. Get current app info
      final packageInfo = await PackageInfo.fromPlatform();
      final currentBuildNumber = int.tryParse(packageInfo.buildNumber) ?? 0;

      // 2. Fetch latest update from Supabase
      final response = await _supabase
          .from('app_updates')
          .select('*')
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle()
          .timeout(const Duration(seconds: 3));

      if (response == null) return;

      final serverBuildNumber = response['version_code'] as int;
      final isMandatory = response['is_mandatory'] as bool;
      final updateUrl = response['update_url'] as String;
      final versionName = response['version_name'] as String;
      final releaseNotes = response['release_notes'] as String?;

      // 3. Compare versions
      if (serverBuildNumber > currentBuildNumber) {
        if (context.mounted) {
          _showUpdateDialog(
            context,
            versionName: versionName,
            isMandatory: isMandatory,
            updateUrl: updateUrl,
            releaseNotes: releaseNotes,
          );
        }
      }
    } catch (e) {
      debugPrint('Error checking for updates: $e');
    }
  }

  void _showUpdateDialog(
    BuildContext context, {
    required String versionName,
    required bool isMandatory,
    required String updateUrl,
    String? releaseNotes,
  }) {
    showDialog(
      context: context,
      barrierDismissible: !isMandatory,
      builder: (context) {
        final isDark = context.isDark;
        return WillPopScope(
          onWillPop: () async => !isMandatory,
          child: CustomGradientDialog(
            title: "تحديث جديد متوفر!",
            message:
                "نسخة جديدة ($versionName) من التطبيق متاحة الآن.\nيرجى التحديث للاستمتاع بأحدث المميزات.",
            icon: Icons.system_update,
            gradientColors: isDark
                ? [
                    const Color(0xFF1E3A8A),
                    const Color(0xFF1E40AF)
                  ] // Dark Blue
                : [const Color(0xFF2563EB), const Color(0xFF60A5FA)], // Blue
            isDark: isDark,
            onPrimaryPressed: () => _launchURL(updateUrl),
            primaryButtonText: "تحديث الآن",
            primaryButtonColor: Colors.white.withOpacity(0.2),
            onSecondaryPressed:
                isMandatory ? null : () => Navigator.pop(context),
            secondaryButtonText: isMandatory ? null : "لاحقاً",
            infoText: isMandatory
                ? "هذا التحديث إجباري لضمان عمل التطبيق بشكل صحيح."
                : (releaseNotes != null && releaseNotes.isNotEmpty)
                    ? releaseNotes
                    : "تحسينات عامة وإصلاحات للأخطاء.",
            titleColor: Colors.white,
            messageColor: Colors.white.withOpacity(0.9),
            iconColor: Colors.white,
          ),
        );
      },
    );
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
