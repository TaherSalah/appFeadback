import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/utils/style/responsive_util.dart';

class SupportDeveloperScreen extends StatelessWidget {
  const SupportDeveloperScreen({super.key});

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'تم نسخ الرقم: $text',
          textAlign: TextAlign.center,
             style: TextStyle(
                          fontFamily: "cairo",),
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isTab = ResponsiveUtil.isTablet(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: const CupertinoNavigationBarBackButton(color: Colors.white),
          title: Text(
            'ادعم المشروع 🤍',
               style: TextStyle(
                          fontFamily: "cairo",
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
        ),
        body: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Hero Section with Gradient
            Container(
              padding: EdgeInsets.fromLTRB(24.w, 80.h, 24.w, 32.h),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: isDark
                      ? [const Color(0xFF1B5E20), const Color(0xFF0D2311)]
                      : [const Color(0xFF2E7D32), const Color(0xFF1B5E20)],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(50),
                  bottomRight: Radius.circular(50),
                ),
              ),
              child: Column(
                children: [
                  const Text('🚀', style: TextStyle(fontSize: 50)),
                  const SizedBox(height: 16),
                  Text(
                    'ساهم في استمرار التطبيق',
                       style: TextStyle(
                          fontFamily: "cairo",
                      fontSize: isTab ? 12.sp : 18.sp,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.green.shade900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'تطبيق رفيق المسلم مجاني تماماً وسيظل كذلك بإذن الله. دعمك يساعدنا على تغطية تكاليف الخوادم وتطوير ميزات جديدة لخدمة المسلمين حول العالم.',
                    textAlign: TextAlign.center,
                       style: TextStyle(
                          fontFamily: "cairo",
                      fontSize: isTab ? 9.sp : 13.sp,
                      color: isDark ? Colors.white70 : Colors.green.shade800,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  // Online Support Section
                  _buildSectionHeader('دعم عبر الإنترنت', Icons.public, isDark),
                  const SizedBox(height: 12),
                  _buildSupportCard(
                    title: 'Buy Me a Coffee',
                    subtitle: 'دعم سريع ومباشر عبر البطاقات البنكية',
                    icon: Icons.coffee,
                    color: const Color(0xFFFFDD00),
                    textColor: Colors.black,
                    onTap: () =>
                        _launchUrl('https://buymeacoffee.com/rafiqMuslimDaily'),
                  ),
                  const SizedBox(height: 12),
                  _buildSupportCard(
                    title: 'PayPal',
                    subtitle: 'تحويل آمن عبر حساب بايبال',
                    icon: Icons.payment,
                    color: const Color(0xFF003087),
                    textColor: Colors.white,
                    onTap: () => _launchUrl('https://paypal.me/tahersalah'),
                  ),

                  const SizedBox(height: 30),

                  // Local Support Section
                  _buildSectionHeader(
                      'دعم محلي (مصر)', Icons.account_balance_wallet, isDark),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: Colors.red.withOpacity(0.3), width: 2),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.phone_android,
                              color: Colors.red),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'فودافون كاش',
                                   style: TextStyle(
                          fontFamily: "cairo",
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                '01094529752',
                                   style: TextStyle(
                          fontFamily: "cairo",
                                  fontSize: 18,
                                  letterSpacing: 1.2,
                                  color: Colors.red.shade700,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy_all, color: Colors.grey),
                          onPressed: () =>
                              _copyToClipboard(context, '01094529752'),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Footer
                  Center(
                    child: Text(
                      'جزاكم الله خيراً على دعمكم الدائم ❤️',
                         style: TextStyle(
                          fontFamily: "cairo",
                        fontSize: 14,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, bool isDark) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.amber.shade700),
        const SizedBox(width: 8),
        Text(
          title,
             style: TextStyle(
                          fontFamily: "cairo",
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white70 : Colors.black54,
          ),
        ),
      ],
    );
  }

  Widget _buildSupportCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: textColor, size: 30),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                       style: TextStyle(
                          fontFamily: "cairo",
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: textColor,
                    ),
                  ),
                  Text(
                    subtitle,
                       style: TextStyle(
                          fontFamily: "cairo",
                      fontSize: 12,
                      color: textColor.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: textColor, size: 16),
          ],
        ),
      ),
    );
  }
}
