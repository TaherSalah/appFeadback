import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muslimdaily/app/core/cubit/centralized_cubit.dart';
import 'package:muslimdaily/app/core/utils/style/k_color.dart';

import 'package:muslimdaily/app/features/settings/notification_settings_view.dart';
import 'package:muslimdaily/app/features/settings/location_settings_view.dart';
import 'package:muslimdaily/app/features/settings/feedback_view.dart';
import 'package:muslimdaily/app/features/settings/feedback_history_view.dart';
import '../mainView/controllar/MainController.dart';
import '../user_guide/presentation/user_guide_list_screen.dart';

import '../../core/utils/style/app_theme_colors.dart';

import 'package:showcaseview/showcaseview.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  final GlobalKey _userGuideKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _checkFirstLaunch();
  }

  Future<void> _checkFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    final bool hasShownShowcase = prefs.getBool('showcase_settings') ?? false;

    if (!hasShownShowcase) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ShowCaseWidget.of(context).startShowCase([_userGuideKey]);
        prefs.setBool('showcase_settings', true);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: ShowCaseWidget(
        builder: (context) => Scaffold(
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(
                MediaQuery.sizeOf(context).width > 600 ? 80 : 50),
            child: AppBar(
              leading: Navigator.canPop(context)
                  ? IconButton(
                      icon: const Icon(Icons.arrow_back_ios),
                      color: isDark ? Colors.white : Colors.black,
                      onPressed: () => Navigator.of(context).pop(),
                    )
                  : null,
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
                          _buildDivider(isDark),
                          // تعديل التاريخ الهجري
                          ListTile(
                            leading: _buildIconContainer(
                              Icons.calendar_month_outlined,
                              Colors.deepOrange,
                            ),
                            title: Text(
                              'تعديل التاريخ الهجري',
                              style: GoogleFonts.cairo(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            subtitle: Text(
                              'تقديم أو تأخير التاريخ الهجري',
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
                              child: DropdownButton<int>(
                                value: MainController().hijriAdjustment,
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
                                onChanged: (int? newValue) {
                                  if (newValue != null) {
                                    MainController()
                                        .setHijriAdjustment(newValue);
                                    (context as Element).markNeedsBuild();
                                  }
                                },
                                items: List.generate(5, (index) {
                                  final val = index - 2;
                                  String label = val == 0
                                      ? 'تلقائي'
                                      : (val > 0 ? '+$val يوم' : '$val يوم');
                                  return DropdownMenuItem(
                                    alignment: AlignmentGeometry.centerRight,
                                    value: val,
                                    child: Text(label),
                                  );
                                }),
                              ),
                            ),
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
                                    color:
                                        isDark ? Colors.white : Colors.black87,
                                    fontSize: 12,
                                  ),
                                  onChanged: (ThemeMode? newValue) {
                                    if (newValue != null) {
                                      cubit.setThemeMode(newValue);
                                    }
                                  },
                                  items: const [
                                    DropdownMenuItem(
                                      alignment: AlignmentGeometry.centerRight,
                                      value: ThemeMode.system,
                                      child: Text('تلقائي'),
                                    ),
                                    DropdownMenuItem(
                                      alignment: AlignmentGeometry.centerRight,
                                      value: ThemeMode.light,
                                      child: Text('فاتح ☀️'),
                                    ),
                                    DropdownMenuItem(
                                      alignment: AlignmentGeometry.centerRight,
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
                                    overlayColor: const Color(0xFFD4AF37)
                                        .withOpacity(0.2),
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
                                      color: isDark
                                          ? Colors.white
                                          : Colors.black87,
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
                                      color: isDark
                                          ? Colors.white
                                          : Colors.black87,
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
                          Showcase(
                            key: _userGuideKey,
                            description:
                                'هل تحتاج لمساعدة؟ دليل المستخدم يشرح لك كل ميزة بالتفصيل',
                            child: _buildListTile(
                              context,
                              icon: Icons.help_outline_rounded,
                              title: 'دليل المستخدم',
                              subtitle: 'شرح كل ميزة وكيفية استخدامها',
                              iconColor: Colors.deepPurple[400]!,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const UserGuideListScreen(),
                                  ),
                                );
                              },
                            ),
                          ),
                          _buildDivider(isDark),
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
                          _buildDivider(isDark),
                          _buildListTile(
                            context,
                            icon: Icons.feedback_outlined,
                            title: 'الشكاوى والاقتراحات',
                            subtitle: 'أرسل لنا ملاحظاتك واقتراحاتك',
                            iconColor: Colors.orange[600]!,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const FeedbackView(),
                                ),
                              );
                            },
                          ),
                          _buildDivider(isDark),
                          _buildListTile(
                            context,
                            icon: Icons.history,
                            title: 'سجل الشكاوى',
                            subtitle: 'تابع حالة شكاويك السابقة',
                            iconColor: Colors.blue[600]!,
                            onTap: () {
                              _showEmailDialog(context);
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
      ),
    );
  }

  void _showEmailDialog(BuildContext context) {
    final controller = TextEditingController();
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: Dialog(
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          backgroundColor: Colors.transparent,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // جسم الديالوج
              Container(
                padding: const EdgeInsets.fromLTRB(20, 45, 20, 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: isDark
                        ? [const Color(0xFF0F172A), const Color(0xFF1E293B)]
                        : [const Color(0xFFE3F2FD), const Color(0xFFBBDEFB)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // العنوان
                    Text(
                      'عرض سجل الشكاوى',
                      style: GoogleFonts.cairo(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF0D47A1),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // النص التوضيحي
                    Text(
                      'أدخل البريد الإلكتروني الذي استخدمته عند إرسال الشكوى لمتابعة حالتها.',
                      style: GoogleFonts.cairo(
                        fontSize: 12.sp,
                        height: 1.4,
                        color: isDark ? Colors.white70 : Colors.blue.shade900,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20.h),

                    // حقل البريد الإلكتروني
                    TextField(
                      controller: controller,
                      style: GoogleFonts.cairo(
                          color: isDark ? Colors.white : Colors.black),
                      decoration: InputDecoration(
                        labelText: 'البريد الإلكتروني',
                        labelStyle: GoogleFonts.cairo(),
                        hintText: "example@mail.com",
                        hintStyle: TextStyle(
                            color: isDark ? Colors.grey : Colors.grey[600]),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15)),
                        filled: true,
                        fillColor: isDark
                            ? Colors.white12
                            : Colors.white.withOpacity(0.6),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    SizedBox(height: 24.h),

                    // الأزرار
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.of(dialogContext).pop();
                            },
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: isDark
                                    ? Colors.grey.shade400
                                    : Colors.blue.shade300,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 11),
                            ),
                            child: Text(
                              'إلغاء',
                              style: GoogleFonts.cairo(
                                fontSize: 13.sp,
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF0D47A1),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              final email = controller.text.trim();
                              if (email.isNotEmpty && email.contains('@')) {
                                Navigator.pop(dialogContext);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        FeedbackHistoryView(userEmail: email),
                                  ),
                                );
                              }
                            },
                            icon: const Icon(Icons.manage_search_rounded,
                                size: 18),
                            label: Text(
                              'عرض',
                              style: GoogleFonts.cairo(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1976D2),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 11),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // الأيقونة الدائرية أعلى الديالوج
              Positioned(
                top: -35,
                left: 0,
                right: 0,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1976D2), Color(0xFF64B5F6)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF1976D2).withOpacity(0.5),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.manage_history_rounded,
                        size: 38,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
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
          // color: isDark ? const Color(0xFFD4AF37) : const Color(0xFFB8860B),
          color: isDark ? KColors.primaryColor : const Color(0xFFB8860B),
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
