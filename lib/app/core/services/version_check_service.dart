import 'package:flutter/material.dart';
import 'package:muslimdaily/app/core/extensions/context_extension.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../widgets/CustomGradientDialog.dart';

class VersionCheckService {
  final _supabase = Supabase.instance.client;

  static const String _lastIgnoredVersionKey = 'last_ignored_build_number';
  static const String _lastIgnoredTimeKey = 'last_update_ignored_time';

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

      // 3. Check if update is needed
      if (serverBuildNumber > currentBuildNumber) {
        if (isMandatory) {
          // Always show if mandatory
          _showDialog(context, versionName, isMandatory, updateUrl, releaseNotes, serverBuildNumber);
          return;
        }

        // Optional Update - Check Cooldown
        final prefs = await SharedPreferences.getInstance();
        final lastIgnoredBuild = prefs.getInt(_lastIgnoredVersionKey) ?? 0;
        final lastIgnoredTimeStr = prefs.getString(_lastIgnoredTimeKey);

        bool shouldShow = false;

        if (serverBuildNumber > lastIgnoredBuild) {
          // It's a new version compared to what they ignored
          shouldShow = true;
        } else {
          // Same version, check if 24 hours passed
          if (lastIgnoredTimeStr == null) {
            shouldShow = true;
          } else {
            final lastIgnoredTime = DateTime.tryParse(lastIgnoredTimeStr);
            if (lastIgnoredTime == null) {
              shouldShow = true;
            } else {
              final difference = DateTime.now().difference(lastIgnoredTime);
              if (difference.inHours >= 24) {
                shouldShow = true;
              }
            }
          }
        }

        if (shouldShow && context.mounted) {
          _showDialog(context, versionName, isMandatory, updateUrl, releaseNotes, serverBuildNumber);
        }
      }
    } catch (e) {
      debugPrint('Error checking for updates: $e');
    }
  }

  void _showDialog(BuildContext context, String versionName, bool isMandatory, String updateUrl, String? releaseNotes, int serverBuildNumber) {
    _showUpdateDialog(
      context,
      versionName: versionName,
      isMandatory: isMandatory,
      updateUrl: updateUrl,
      releaseNotes: releaseNotes,
      serverBuildNumber: serverBuildNumber,
    );
  }

  void _showUpdateDialog(
    BuildContext context, {
    required String versionName,
    required bool isMandatory,
    required String updateUrl,
    required int serverBuildNumber,
    String? releaseNotes,
  }) {
    showDialog(
      context: context,
      barrierDismissible: !isMandatory,
      builder: (context) {
        final isDark = context.isDark;
        return PopScope(
          canPop: !isMandatory,
          child: CustomGradientDialog(
            title: "تحديث جديد متوفر!",
            message:
                "نسخة جديدة ($versionName) من التطبيق متاحة الآن.\nيرجى التحديث للاستمتاع بأحدث المميزات.",
            icon: Icons.system_update,
            gradientColors: isDark
                ? [const Color(0xFF1E3A8A), const Color(0xFF1E40AF)] // Dark Blue
                : [const Color(0xFF2563EB), const Color(0xFF60A5FA)], // Blue
            isDark: isDark,
            onPrimaryPressed: () => _launchURL(updateUrl),
            primaryButtonText: "تحديث الآن",
            primaryButtonColor: Colors.white.withOpacity(0.2),
            onSecondaryPressed: isMandatory
                ? null
                : () async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setInt(_lastIgnoredVersionKey, serverBuildNumber);
                    await prefs.setString(_lastIgnoredTimeKey, DateTime.now().toIso8601String());
                    if (context.mounted) Navigator.pop(context);
                  },
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
