import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../services/system_control_service.dart';

class SocialBannerWidget extends StatefulWidget {
  const SocialBannerWidget({super.key});

  @override
  State<SocialBannerWidget> createState() => _SocialBannerWidgetState();
}

class _SocialBannerWidgetState extends State<SocialBannerWidget> {
  Map<String, dynamic>? _config;
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  Future<void> _loadConfig() async {
    final config = await SystemControlService().getSocialBannerConfig();
    if (mounted) {
      setState(() {
        _config = config;
        _isVisible = config?['isActive'] == true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVisible || _config == null) return const SizedBox.shrink();

    final title = _config!['title'] ?? 'انضم إلينا';
    final url = _config!['url'] ?? '';
    final platform = _config!['platform'] ?? 'telegram';
    final isTelegram = platform == 'telegram';

    final Color bgColor = isTelegram ? const Color(0xFF229ED9) : const Color(0xFF25D366);
    final IconData icon = isTelegram ? FontAwesomeIcons.telegram : FontAwesomeIcons.whatsapp;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 5),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            if (url.isNotEmpty) {
              final uri = Uri.parse(url);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  bgColor,
                  bgColor.withOpacity(0.8),
                ],
                begin: Alignment.centerRight,
                end: Alignment.centerLeft,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: bgColor.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: FaIcon(
                    icon,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.cairo(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                      ),
                      Text(
                        isTelegram ? 'تابعنا على تليجرام' : 'راسلنا على واتساب',
                        style: GoogleFonts.cairo(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isTelegram ? 'انضم' : 'تواصل',
                    style: GoogleFonts.cairo(
                      color: bgColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
