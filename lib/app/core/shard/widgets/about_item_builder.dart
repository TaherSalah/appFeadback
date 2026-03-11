import 'package:flutter_svg/flutter_svg.dart';
import 'package:muslimdaily/app/core/utils/style/k_color.dart';
import 'package:muslimdaily/app/core/utils/style/responsive_util.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../features/aboutView/RateService.dart';
import '../../services/system_control_service.dart';
import '../exports/all_exports.dart';

class AboutItemBuilder extends StatefulWidget {
  const AboutItemBuilder({super.key});

  @override
  State<AboutItemBuilder> createState() => _AboutItemBuilderState();
}

class _AboutItemBuilderState extends State<AboutItemBuilder> {
  Map<String, String> supportLinks = {};

  @override
  void initState() {
    super.initState();
    _loadSupportLinks();
  }

  Future<void> _loadSupportLinks() async {
    final links = await SystemControlService().getSupportLinks();
    if (mounted) {
      setState(() {
        supportLinks = links;
      });
    }
  }

  Future<void> _launchURL(String? url) async {
    if (url == null || url.isEmpty) return;
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Default links if not set by admin
    final linkPlayStore = supportLinks['link_playstore'] ??
        'https://play.google.com/store/apps/details?id=com.rafiq.muslimdaily';
    const linkAppGallery =
        'https://appgallery.huawei.com/app/C114956477'; // Not yet in panel
    final linkAppStore = supportLinks['link_appstore'] ??
        'https://apps.apple.com/us/app/%D8%B1%D9%81%D9%8A%D9%82-%D8%A7%D9%84%D9%85%D8%B3%D9%84%D9%85-%D8%A7%D9%84%D9%8A%D9%88%D9%85%D9%8A/id6749927338';

    final linkFacebook = supportLinks['link_facebook'] ??
        'https://www.facebook.com/taher.salah.7927';
    final linkWhatsapp =
        supportLinks['link_whatsapp'] ?? 'https://wa.me/+201094529752';

    void shareGooglePlay() {
      final msg = '''
📱✨ تطبيق *رَفِيقُ المُسْلِمِ اليَوْمِيّ* — القرآن والأذكار اليومية في مكان واحد! ✨📱

قم بتحميل التطبيق الآن من Google Play:
➡️ $linkPlayStore

🌟 استمتع بقراءة الأذكار والأحاديث اليومية بسهولة وراحة.
''';
      Share.share(msg, subject: 'رَفِيقُ المُسْلِمِ اليَوْمِيّ');
    }

    void shareAppGallery() {
      const msg = '''
📱✨ تطبيق *رَفِيقُ المُسْلِمِ اليَوْمِيّ* — القرآن والأذكار اليومية في مكان واحد! ✨📱

قم بتحميل التطبيق الآن من Huawei AppGallery:
➡️ $linkAppGallery

🌟 استمتع بقراءة الأذكار والأحاديث اليومية بسهولة وراحة.
''';
      Share.share(msg, subject: 'رَفِيقُ المُسْلِمِ اليَوْمِيّ');
    }

    void shareAppStore() {
      final msg = '''
📱✨ تطبيق *رَفِيقُ المُسْلِمِ اليَوْمِيّ* — القرآن والأذكار اليومية في مكان واحد! ✨📱

قم بتحميل التطبيق الآن من App Store:
➡️ $linkAppStore

🌟 استمتع بقراءة الأذكار والأحاديث اليومية بسهولة وراحة.
''';
      Share.share(msg, subject: 'رَفِيقُ المُسْلِمِ اليَوْمِيّ');
    }

    final con = Provider.of<AzkarProvider>(context);
    final bool isTablate = context.isTablet;
    final isDark = context.isDark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        children: [
          // Hero Header Section
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 40.h),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: isDark
                    ? [const Color(0xFF1B5E20), const Color(0xFF0D2311)]
                    : [const Color(0xFFE8F5E9), const Color(0xFFC8E6C9)],
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(50),
                bottomRight: Radius.circular(50),
              ),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Image.asset(
                    azkaryLogo,
                    height: 90.h,
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  "رَفِيقُ المُسْلِمِ اليَوْمِيُ",
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.bold,
                    fontSize: isTablate ? 12.sp : 18.sp,
                    color: isDark ? Colors.white : Colors.green.shade900,
                  ),
                ),
                Text(
                  "إصدار 2.1.0",
                  style: GoogleFonts.cairo(
                    fontSize: 12.sp,
                    color: isDark ? Colors.white70 : Colors.green.shade700,
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                // About App Card
                _buildInfoCard(
                  context,
                  title: AppString.KAppAbout,
                  icon: Icons.info_outline_rounded,
                  content: AppString.KAboutText,
                  isDark: isDark,
                  isTablate: isTablate,
                ),
                SizedBox(height: 16.h),

                // Sadka Jariya Card
                _buildInfoCard(
                  context,
                  title: AppString.KSadka,
                  icon: Icons.volunteer_activism_outlined,
                  content: AppString.KAboutText2,
                  isDark: isDark,
                  isTablate: isTablate,
                  cardColor: Colors.amber.withOpacity(0.1),
                  iconColor: Colors.amber.shade800,
                ),
                // SizedBox(height: 24.h),
                //
                // // Support Section
                // _buildSectionTitle(
                //     "ادعم المشروع", Icons.favorite_rounded, Colors.redAccent),
                // SizedBox(height: 12.h),
                // _buildActionButton(
                //   context,
                //   title: "ادعم استمرار وتطوير التطبيق",
                //   icon: Icons.card_giftcard_rounded,
                //   color: Colors.redAccent,
                //   onTap: () =>
                //       Navigator.pushNamed(context, '/supportDeveloper'),
                // ),
                SizedBox(height: 24.h),

                // Contact Section
                _buildSectionTitle(AppString.KContact,
                    Icons.alternate_email_rounded, Colors.blue),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    Expanded(
                      child: _buildSocialButton(
                        context,
                        title: "فيسبوك",
                        icon: facebook,
                        isSvg: false,
                        color: const Color(0xFF1877F2),
                        onTap: () => _launchURL(linkFacebook),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: _buildSocialButton(
                        context,
                        title: "واتساب",
                        icon: whatsApp,
                        isSvg: false,
                        color: const Color(0xFF25D366),
                        onTap: () => _launchURL(linkWhatsapp),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24.h),
                _buildSectionTitle(
                    "قيم التطبيق", Icons.star_rate_outlined, Colors.green),
                SizedBox(height: 24.h),

                _buildActionButton(
                  context,

                  title: "قيّم التطبيق على المتجر",
                  icon: Icons.star_rounded,
                  // color: Colors.amber.shade700,
                  color: KColors.primaryColor,
                  onTap: () =>
                      context.read<RateService>().askForReview(context),
                ),
                SizedBox(height: 25.h),
                // Share Section

                _buildSectionTitle(
                    "شارك الثواب", Icons.share_rounded, Colors.purple),
                SizedBox(height: 12.h),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildStoreIcon(googlePlay, shareGooglePlay),
                    _buildStoreIcon(huaweiGallary, shareAppGallery),
                    _buildStoreIcon(appleStore, shareAppStore),
                  ],
                ),
                // SizedBox(height: 10.h),

                // Rights Section
                Divider(color: isDark ? Colors.white10 : Colors.grey.shade300),
                // SizedBox(height: 10.h),
                _buildSectionTitle(AppString.KDevlop,
                    Icons.developer_mode_outlined, Colors.red),

                SizedBox(height: 8.h),
                Image.asset(
                  "assets/images/perLogo.png",
                  height: 80,
                ),
                SizedBox(height: 8.h),
                Text(
                  AppString.KAppRights,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cairo(
                    fontSize: isTablate ? 8.5.sp : 10.sp,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, Color color) {
    final bool isTap = context.isTablet;
    return Row(
      children: [
        Icon(icon, size: 20.sp, color: color),
        SizedBox(width: 8.w),
        Text(
          title,
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
            fontSize: isTap ? 10.sp : 14.sp,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required String content,
    required bool isDark,
    required bool isTablate,
    Color? cardColor,
    Color? iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor ?? (isDark ? const Color(0xFF1E293B) : Colors.white),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor ?? KColors.primaryColor, size: 22.sp),
              SizedBox(width: 10.w),
              Text(
                title,
                style: GoogleFonts.cairo(
                  fontWeight: FontWeight.bold,
                  fontSize: isTablate ? 10.sp : 15.sp,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            content,
            textAlign: TextAlign.justify,
            style: GoogleFonts.cairo(
              fontSize: isTablate ? 9.sp : 13.sp,
              height: 1.6,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final bool isTap = context.isTablet;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon(icon, color: Colors.white, size: 22),
            // SizedBox(width: 12.w),
            Text(
              title,
              style: GoogleFonts.cairo(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: isTap ? 10.sp : 14.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialButton(
    BuildContext context, {
    required String title,
    required String icon,
    required bool isSvg,
    required Color color,
    required VoidCallback onTap,
  }) {
    final bool isTap = ResponsiveUtil.isTablet(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            isSvg
                ? SvgPicture.asset(icon, height: 20, color: color)
                : Image.asset(icon, height: 20),
            SizedBox(width: 8.w),
            Text(
              title,
              style: GoogleFonts.cairo(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: isTap ? 9.sp : 12.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoreIcon(String icon, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
              ),
            ],
          ),
          child: Image.asset(icon, height: 29),
        ),
      ),
    );
  }
}
