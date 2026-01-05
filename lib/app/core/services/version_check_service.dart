import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';

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
          .maybeSingle();

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
      builder: (context) => WillPopScope(
        onWillPop: () async => !isMandatory,
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Row(
              children: [
                const Icon(Icons.system_update, color: Colors.green),
                const SizedBox(width: 10),
                Text(
                  'تحديث جديد متاح',
                  style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'إصدار جديد ($versionName) متاح للتحميل الآن.',
                  style: GoogleFonts.cairo(),
                ),
                if (releaseNotes != null && releaseNotes.isNotEmpty) ...[
                  const SizedBox(height: 15),
                  Text(
                    'ما الجديد:',
                    style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  Text(
                    releaseNotes,
                    style: GoogleFonts.cairo(fontSize: 12, color: Colors.grey[700]),
                  ),
                ],
                if (isMandatory) ...[
                  const SizedBox(height: 15),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'هذا التحديث إجباري لضمان عمل التطبيق بشكل صحيح.',
                            style: GoogleFonts.cairo(fontSize: 11, color: Colors.red[900]),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
            actions: [
              if (!isMandatory)
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'لاحقاً',
                    style: GoogleFonts.cairo(color: Colors.grey),
                  ),
                ),
              ElevatedButton(
                onPressed: () => _launchURL(updateUrl),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text(
                  'تحديث الآن',
                  style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
