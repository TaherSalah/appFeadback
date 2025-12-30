import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muslimdaily/app/core/cubit/centralized_cubit.dart';
import 'package:muslimdaily/app/features/messaView/azkar_massa.dart';
import 'package:muslimdaily/app/features/settings/notification_settings_view.dart';
import 'package:muslimdaily/app/features/settings/location_settings_view.dart';

import '../../core/utils/style/app_theme_colors.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        // extendBodyBehindAppBar: true,
        // appBar: AppBar(
        //   title: Text(
        //     'الإعدادات',
        //     style: GoogleFonts.cairo(
        //       fontSize: 20,
        //       fontWeight: FontWeight.bold,
        //       color: isDark ? Colors.white : Colors.black87,
        //     ),
        //   ),
        //   centerTitle: true,
        //   backgroundColor: Colors.transparent,
        //   elevation: 0,
        //   leading: BackButton(color: isDark ? Colors.white : Colors.black87),
        // ),
        appBar: PreferredSize(
          preferredSize:
              Size.fromHeight(MediaQuery.sizeOf(context).width > 600 ? 80 : 50),
          child: AppBar(
            leading: CupertinoNavigationBarBackButton(
              color: isDark ? Colors.white : Colors.black,
            ),
            // actions: [
            //   IconButton(
            //     onPressed: () => Navigator.push(
            //       context,
            //       MaterialPageRoute(
            //         builder: (context) => CreateKhatmahScreen(),
            //       ),
            //     ),
            //     icon: const Icon(Icons.add),
            //   )
            // ],
            centerTitle: true,
            title: Text(
              "الإعدادات",
              style: GoogleFonts.cairo(
                color: Colors.green,
                fontWeight: FontWeight.bold,
                fontSize:
                    MediaQuery.sizeOf(context).width > 600 ? 12.sp : 18.sp,
              ),
            ),
          ),
        ),

        body: Container(
          // decoration: BoxDecoration(
          //   gradient: LinearGradient(
          //     begin: Alignment.topCenter,
          //     end: Alignment.bottomCenter,
          //     colors: isDark
          //         ? [
          //             const Color(0xFF0F172A),
          //             const Color(0xFF1E293B),
          //             const Color(0xFF0F172A)
          //           ]
          //         : [
          //             const Color(0xFFF8F9FA),
          //             const Color(0xFFE9ECEF),
          //             const Color(0xFFF8F9FA)
          //           ],
          //   ),
          // ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: BlocBuilder<CentralizedCubit, CentralizedState>(
              builder: (context, state) {
                final cubit = CentralizedCubit.get(context);
                final currentTheme = cubit.themeMode();
                final currentFontSize = cubit.azkarFontSize();

                return ListView(
                  children: [
                    SizedBox(height: MediaQuery.of(context).padding.top + 10),

                    // 🔔 قسم التنبيهات والموقع
                    _buildSectionHeader(context, 'عام'),
                    _buildSettingsCard(
                      context,
                      children: [
                        _buildListTile(
                          context,
                          icon: Icons.notifications_active_outlined,
                          title: 'إعدادات الإشعارات',
                          subtitle: 'الأذان، الأذكار، الصلاة على النبي',
                          iconColor: Colors.amber[700]!,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const NotificationSettingsView(),
                              ),
                            );
                          },
                        ),
                        _buildDivider(isDark),
                        _buildListTile(
                          context,
                          icon: Icons.location_on_outlined,
                          title: 'إعدادات الموقع',
                          subtitle: 'تحديد الدولة والمدينة لمواقيت الصلاة',
                          iconColor: Colors.green[600]!,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const LocationSettingsView(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // 🎨 قسم المظهر
                    _buildSectionHeader(context, 'المظهر والخطوط'),
                    _buildSettingsCard(
                      context,
                      children: [
                        // الثيم
                        ListTile(
                          leading: _buildIconContainer(
                            Icons.palette_outlined,
                            Colors.purple[400]!,
                          ),
                          title: Text(
                            'مظهر التطبيق',
                            style: GoogleFonts.cairo(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          subtitle: Text(
                            _getThemeName(currentTheme),
                            style: GoogleFonts.cairo(
                                fontSize: 12, color: Colors.grey),
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white.withOpacity(0.1)
                                  : Colors.grey.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isDark
                                    ? Colors.white12
                                    : Colors.grey.shade300,
                              ),
                            ),
                            child: Directionality(
                              textDirection: TextDirection.rtl,
                              child: DropdownButton<ThemeMode>(
                                value: currentTheme,
                                icon: const Icon(Icons.keyboard_arrow_down,
                                    size: 18),
                                underline: const SizedBox(),
                                isDense: true,
                                dropdownColor: isDark
                                    ? const Color(0xFF1E293B)
                                    : Colors.white,
                                style: GoogleFonts.cairo(
                                  color: isDark ? Colors.white : Colors.black87,
                                  fontSize: 12,
                                ),
                                onChanged: (ThemeMode? newValue) {
                                  if (newValue != null) {
                                    cubit.setThemeMode(newValue);
                                  }
                                },
                                items: const [
                                  DropdownMenuItem(
                                    value: ThemeMode.system,
                                    child: Text('تلقائي'),
                                  ),
                                  DropdownMenuItem(
                                    value: ThemeMode.light,
                                    child: Text('فاتح ☀️'),
                                  ),
                                  DropdownMenuItem(
                                    value: ThemeMode.dark,
                                    child: Text('داكن 🌙'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        _buildDivider(isDark),

                        // حجم الخط
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  _buildIconContainer(
                                      Icons.format_size, Colors.blue[400]!),
                                  const SizedBox(width: 16),
                                  Text(
                                    'حجم خط الأذكار',
                                    style: GoogleFonts.cairo(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: isDark
                                          ? Colors.white
                                          : Colors.black87,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    '${currentFontSize.round()}',
                                    style: GoogleFonts.cairo(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: isDark
                                          ? Colors.white
                                          : Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  activeTrackColor: const Color(0xFFD4AF37),
                                  inactiveTrackColor: isDark
                                      ? Colors.white24
                                      : Colors.grey.shade300,
                                  thumbColor: const Color(0xFFD4AF37),
                                  overlayColor:
                                      const Color(0xFFD4AF37).withOpacity(0.2),
                                ),
                                child: Slider(
                                  value: currentFontSize,
                                  min: 14.0,
                                  max: 40.0,
                                  divisions: 13,
                                  onChanged: (double value) {
                                    cubit.setAzkarFontSize(value);
                                  },
                                ),
                              ),
                              // معاينة
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? Colors.black.withOpacity(0.2)
                                      : Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isDark
                                        ? Colors.white10
                                        : Colors.grey.shade200,
                                  ),
                                ),
                                child: Text(
                                  "«لا حولَ ولا قوةَ إلا بالله.ِ»",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: "me",
                                    fontSize: currentFontSize,
                                    color:
                                        isDark ? Colors.white : Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        _buildDivider(isDark),

                        // حجم خط الحديث
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  _buildIconContainer(
                                      Icons.menu_book, Colors.teal[400]!),
                                  const SizedBox(width: 16),
                                  Text(
                                    'حجم خط الحديث',
                                    style: GoogleFonts.cairo(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: isDark
                                          ? Colors.white
                                          : Colors.black87,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    '${cubit.hadithFontSize().round()}',
                                    style: GoogleFonts.cairo(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: isDark
                                          ? Colors.white
                                          : Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  activeTrackColor: Colors.teal,
                                  inactiveTrackColor: isDark
                                      ? Colors.white24
                                      : Colors.grey.shade300,
                                  thumbColor: Colors.teal,
                                  overlayColor: Colors.teal.withOpacity(0.2),
                                ),
                                child: Slider(
                                  value: cubit.hadithFontSize(),
                                  min: 14.0,
                                  max: 40.0,
                                  divisions: 13,
                                  onChanged: (double value) {
                                    cubit.setHadithFontSize(value);
                                  },
                                ),
                              ),
                              // معاينة
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? Colors.black.withOpacity(0.2)
                                      : Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isDark
                                        ? Colors.white10
                                        : Colors.grey.shade200,
                                  ),
                                ),
                                child: Text(
                                  "«مَنْ يُرِدِ اللَّهُ بِهِ خَيْرًا يُفَقِّهْهُ فِي الدِّينِ»",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: "me",
                                    fontSize: cubit.hadithFontSize(),
                                    color:
                                        isDark ? Colors.white : Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // ℹ️ حول التطبيق
                    _buildSectionHeader(context, 'أخرى'),
                    _buildSettingsCard(
                      context,
                      children: [
                        _buildListTile(
                          context,
                          icon: Icons.info_outline,
                          title: 'حول التطبيق',
                          subtitle: 'الإصدار 2.0.0',
                          iconColor: Colors.teal[400]!,
                          onTap: () {
                            Navigator.pushNamed(context, '/about');
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 40),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, right: 8.0),
      child: Text(
        title,
        style: GoogleFonts.cairo(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: isDark ? const Color(0xFFD4AF37) : const Color(0xFFB8860B),
        ),
      ),
    );
  }

  Widget _buildSettingsCard(BuildContext context,
      {required List<Widget> children}) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        // color: isDark ? const Color(0xFF1E293B).withOpacity(0.6) : Colors.white,
        color: AppThemeColors.cardBackgroundColor(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Column(
            children: children,
          ),
        ),
      ),
    );
  }

  Widget _buildListTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              _buildIconContainer(icon, iconColor),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.cairo(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: GoogleFonts.cairo(
                          fontSize: 11,
                          color: Colors.grey,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: isDark ? Colors.white30 : Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconContainer(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: color, size: 22),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Divider(
      height: 1,
      thickness: 1,
      color: isDark
          ? Colors.white.withOpacity(0.05)
          : Colors.grey.withOpacity(0.1),
      indent: 60,
    );
  }

  String _getThemeName(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'تلقائي (حسب النظام)';
      case ThemeMode.light:
        return 'فاتح ☀️';
      case ThemeMode.dark:
        return 'داكن 🌙';
    }
  }
}
