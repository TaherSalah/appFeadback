import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:muslimdaily/app/core/extensions/context_extension.dart';
import 'package:muslimdaily/app/features/settings/feedback_view.dart';
import 'package:muslimdaily/app/features/settings/location_settings_view.dart';
import 'package:muslimdaily/app/features/settings/notification_settings_view.dart';
import '../azanView/widget/AdhanStatusBanner.dart';
import '../userGuide/presentation/user_guide_list_screen.dart';
import 'settings_controller.dart';
import 'widgets/settings_email_dialog.dart';
import 'widgets/settings_font_size_slider.dart';
import 'widgets/settings_widgets.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
Get.put(SettingsController(context));
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(
            context.isTab ? 80 : 50,
          ),
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
                 style: TextStyle(
                          fontFamily: "cairo",
                color: Colors.green,
                fontWeight: FontWeight.bold,
                fontSize: context.isTab ? 12.sp : 18.sp,
              ),
            ),
          ),
        ),
        body: GetBuilder<SettingsController>(
          builder: (controller) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ListView(
                children: [
                  SizedBox(height: MediaQuery.of(context).padding.top + 10),
                  const AdhanStatusBanner(),

                  // 🔔 قسم التنبيهات والموقع
                  SettingsSection(
                    title: 'عام',
                    children: [
                      SettingsListTile(
                        icon: Icons.notifications_active_outlined,
                        title: 'إعدادات الإشعارات',
                        subtitle: 'الأذان، الأذكار، الصلاة على النبي',
                        iconColor: Colors.amber[700]!,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const NotificationSettingsView(),
                          ),
                        ),
                      ),
                      const SettingsDivider(),
                      SettingsListTile(
                        icon: Icons.location_on_outlined,
                        title: 'إعدادات الموقع',
                        subtitle: 'تحديد الدولة والمدينة لمواقيت الصلاة',
                        iconColor: Colors.green[600]!,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LocationSettingsView(),
                          ),
                        ),
                      ),
                      const SettingsDivider(),
                      SettingsDropdownTile<int>(
                        icon: Icons.calendar_month_outlined,
                        title: 'تعديل التاريخ الهجري',
                        subtitle: 'تقديم أو تأخير التاريخ الهجري',
                        iconColor: Colors.deepOrange,
                        value: controller.hijriAdjustment,
                        onChanged: (newValue) {
                          if (newValue != null) {
                            controller.setHijriAdjustment(newValue);
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
                    ],
                  ),

                  // 🎨 قسم المظهر
                  SettingsSection(
                    title: 'المظهر والخطوط',
                    children: [
                      SettingsDropdownTile<ThemeMode>(
                        icon: Icons.palette_outlined,
                        title: 'مظهر التطبيق',
                        subtitle: controller.getThemeName(controller.currentTheme),
                        iconColor: Colors.purple[400]!,
                        value: controller.currentTheme,
                        onChanged: (newValue) {
                          if (newValue != null) {
                            controller.setThemeMode(newValue);
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
                      const SettingsDivider(),
                      SettingsFontSizeSlider(
                        title: 'حجم خط الأذكار',
                        value: controller.azkarFontSize,
                        activeColor: const Color(0xFFD4AF37),
                        icon: Icons.format_size,
                        iconColor: Colors.blue[400]!,
                        previewText: "«لا حولَ ولا قوةَ إلا بالله.ِ»",
                        onChanged: (value) => controller.setAzkarFontSize(value),
                      ),
                      const SettingsDivider(),
                      SettingsFontSizeSlider(
                        title: 'حجم خط الحديث',
                        value: controller.hadithFontSize,
                        activeColor: Colors.teal,
                        icon: Icons.menu_book,
                        iconColor: Colors.teal[400]!,
                        previewText:
                            "«مَنْ يُرِدِ اللَّهُ بِهِ خَيْرًا يُفَقِّهْهُ فِي الدِّينِ»",
                        onChanged: (value) => controller.setHadithFontSize(value),
                      ),
                    ],
                  ),

                  // ℹ️ حول التطبيق
                  SettingsSection(
                    title: 'أخرى',
                    children: [
                      SettingsListTile(
                        icon: Icons.help_outline_rounded,
                        title: 'دليل المستخدم',
                        subtitle: 'شرح كل ميزة وكيفية استخدامها',
                        iconColor: Colors.deepPurple[400]!,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const UserGuideListScreen(),
                          ),
                        ),
                      ),
                      const SettingsDivider(),
                      SettingsListTile(
                        icon: Icons.info_outline,
                        title: 'حول التطبيق',
                        subtitle: 'معلومات عن التطبيق',
                        iconColor: Colors.teal[400]!,
                        onTap: () => Navigator.pushNamed(context, '/about'),
                      ),
                      const SettingsDivider(),
                      SettingsListTile(
                        icon: Icons.feedback_outlined,
                        title: 'الشكاوى والاقتراحات',
                        subtitle: 'أرسل لنا ملاحظاتك واقتراحاتك',
                        iconColor: Colors.orange[600]!,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const FeedbackView(),
                          ),
                        ),
                      ),
                      const SettingsDivider(),
                      SettingsListTile(
                        icon: Icons.history,
                        title: 'سجل الشكاوى',
                        subtitle: 'تابع حالة شكاويك السابقة',
                        iconColor: Colors.blue[600]!,
                        onTap: () => showDialog(
                          context: context,
                          builder: (context) => const SettingsEmailDialog(),
                        ),
                      ),
                      const SettingsDivider(),
                      SettingsListTile(
                        icon: Icons.telegram_rounded,
                        title: 'قناة التلجرام',
                        subtitle: 'انضم لمجتمع رفيق المسلم اليومي على تلجرام',
                        iconColor: const Color(0xFF229ED9),
                        onTap: () => _showTelegramDialog(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _showTelegramDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "انضم إلينا على تلجرام",
          textAlign: TextAlign.center,
             style: TextStyle(
                          fontFamily: "cairo",fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.asset(
                "assets/images/telegram_qr.png",
                width: 250.w,
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              "اشترك في القناة لتصلك آخر التحديثات والميزات الجديدة فور صدورها.",
              textAlign: TextAlign.center,
                 style: TextStyle(
                          fontFamily: "cairo",fontSize: 14.sp),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("إغلاق",    style: TextStyle(
                          fontFamily: "cairo",color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF229ED9),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Get.find<SettingsController>().launchTelegram(),
            child: const Text(
              "انضم الآن",
                 style: TextStyle(
                          fontFamily: "cairo",color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
