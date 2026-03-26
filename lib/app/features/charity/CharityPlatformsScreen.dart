import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:muslimdaily/app/core/extensions/context_extension.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/utils/style/k_helper.dart';

class CharityPlatform {
  final String name;
  final String description;
  final String url;
  final String emoji;
  final String country;

  const CharityPlatform({
    required this.name,
    required this.description,
    required this.url,
    required this.emoji,
    required this.country,
  });
}

class CharityPlatformsScreen extends StatelessWidget {
  const CharityPlatformsScreen({super.key});

  static const List<CharityPlatform> _platforms = [
    CharityPlatform(
      name: 'مؤسسة مصر الخير',
      description: 'من أكبر المؤسسات الخيرية في مصر، تعمل في مجالات الصحة والتعليم والتنمية',
      url: 'https://www.egyptianfoodbank.org',
      emoji: '🇪🇬',
      country: 'مصر',
    ),
    CharityPlatform(
      name: 'بنك الطعام المصري',
      description: 'يوفر الطعام للأسر الفقيرة والمحتاجة في جميع أنحاء مصر',
      url: 'https://www.egyptianfoodbank.com',
      emoji: '🍲',
      country: 'مصر',
    ),
    CharityPlatform(
      name: 'رسالة',
      description: 'جمعية خيرية شاملة تقدم الدعم في التعليم والصحة والكفالة',
      url: 'https://www.resala.org',
      emoji: '💝',
      country: 'مصر',
    ),
    CharityPlatform(
      name: 'جمعية البر الخيرية',
      description: 'من أكبر الجمعيات الخيرية في السعودية، تعمل في الكفالة والإغاثة',
      url: 'https://www.albirr.org',
      emoji: '🇸🇦',
      country: 'السعودية',
    ),
    CharityPlatform(
      name: 'الهلال الأحمر السعودي',
      description: 'يقدم المساعدات الطبية والإغاثية في السعودية والعالم',
      url: 'https://www.srca.org.sa',
      emoji: '🌙',
      country: 'السعودية',
    ),
    CharityPlatform(
      name: 'الهلال الأحمر الإماراتي',
      description: 'يقدم المساعدات الإنسانية والإغاثية في العالم',
      url: 'https://www.rcuae.ae',
      emoji: '🇦🇪',
      country: 'الإمارات',
    ),
    CharityPlatform(
      name: 'بيت الزكاة الكويتي',
      description: 'يجمع ويوزع الزكاة والصدقات على المستحقين',
      url: 'https://www.zakathouse.org.kw',
      emoji: '🇰🇼',
      country: 'الكويت',
    ),
    CharityPlatform(
      name: 'الإغاثة الإسلامية',
      description: 'منظمة دولية تعمل في الإغاثة والتنمية في أكثر من 40 دولة',
      url: 'https://www.islamic-relief.org',
      emoji: '🌍',
      country: 'دولية',
    ),
    CharityPlatform(
      name: 'قطر الخيرية',
      description: 'تعمل في مجالات التنمية والإغاثة محلياً ودولياً',
      url: 'https://www.qcharity.org',
      emoji: '🇶🇦',
      country: 'قطر',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor:
            isDark ? const Color(0xFF1A1F36) : const Color(0xFFF5F7FA),
        appBar: AppBar(
          title: Text(
            'منصات التبرع الموثوقة 🌐',
               style: TextStyle(
                          fontFamily: "cairo",
              fontWeight: FontWeight.bold,
              fontSize: 20.sp,
            ),
          ),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
        body: ListView.builder(
          padding: EdgeInsets.all(16.w),
          itemCount: _platforms.length,
          itemBuilder: (context, index) {
            return _buildPlatformCard(_platforms[index], isDark);
          },
        ),
      ),
    );
  }

  Widget _buildPlatformCard(CharityPlatform platform, bool isDark) {
    return Builder(
      builder: (context) => InkWell(
        onTap: () => _launchUrl(platform.url, context),
        borderRadius: BorderRadius.circular(20.r),
        child: Container(
          margin: EdgeInsets.only(bottom: 16.h),
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF2D3748) : Colors.white,
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
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
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
                      ),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      platform.emoji,
                      style: TextStyle(fontSize: 28.sp),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          platform.name,
                             style: TextStyle(
                          fontFamily: "cairo",
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF3B82F6).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(
                            platform.country,
                               style: TextStyle(
                          fontFamily: "cairo",
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF3B82F6),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Text(
                platform.description,
                   style: TextStyle(
                          fontFamily: "cairo",
                  fontSize: 13.sp,
                  color: Colors.grey[600],
                  height: 1.6,
                ),
              ),
              SizedBox(height: 12.h),
              Row(
                children: [
                  Icon(
                    Icons.open_in_new,
                    size: 16.sp,
                    color: const Color(0xFF3B82F6),
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    'زيارة الموقع',
                       style: TextStyle(
                          fontFamily: "cairo",
                      fontSize: 13.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF3B82F6),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _launchUrl(String urlString, BuildContext context) async {
    final uri = Uri.parse(urlString);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        KHelper.showError(message:  'تعذر فتح الرابط',);

      }
    }
  }
}
