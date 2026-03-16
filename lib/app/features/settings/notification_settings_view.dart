import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:muslimdaily/app/core/utils/style/k_color.dart';
import 'package:muslimdaily/app/features/settings/notification_settings_controller.dart';
import 'package:muslimdaily/app/features/settings/widgets/notification_sections.dart';
import 'view/notification_test_view.dart';

class NotificationSettingsView extends StatelessWidget {
  const NotificationSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NotificationSettingsController());
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(MediaQuery.sizeOf(context).width > 600 ? 70 : 50),
          child: AppBar(
            leading: CupertinoNavigationBarBackButton(
              color: isDark ? Colors.white : Colors.black,
              onPressed: () => Navigator.of(context).pop(),
            ),
            centerTitle: true,
            title: Text(
              'إعدادات التنبيهات',
              style: GoogleFonts.cairo(
                color: Colors.green,
                fontWeight: FontWeight.bold,
                fontSize: MediaQuery.sizeOf(context).width > 600 ? 12.sp : 18.sp,
              ),
            ),
          ),
        ),
        body: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ListView(
                children: [
                  SizedBox(height: MediaQuery.of(context).padding.top + 10),

                  // 🕋 الأجزاء المقسمة
                  AdhanSection(controller: controller),
                  FeaturesSection(controller: controller),
                  AzkarSection(controller: controller),
                  SalatFrequencySection(controller: controller),
                  RemindersSection(controller: controller),

                  // Test Button
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
                        foregroundColor: isDark ? Colors.white : Colors.black87,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const NotificationTestView()),
                      ),
                      icon: const Icon(Icons.build_circle_outlined),
                      label: Text('اختبار التنبيهات (للمطورين)', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
            
            // Save Floating Button
            Positioned(
              bottom: 24,
              left: 24,
              right: 24,
              child: Obx(() => AnimatedOpacity(
                opacity: controller.hasChanges.value ? 1.0 : 0.5,
                duration: const Duration(milliseconds: 300),
                child: SizedBox(
                  height: 56,
                  child: FloatingActionButton.extended(
                    onPressed: (controller.hasChanges.value && !controller.isLoading.value) ? controller.saveAll : null,
                    backgroundColor: KColors.primaryColor,
                    elevation: controller.hasChanges.value ? 8 : 0,
                    label: controller.isLoading.value
                        ? const SizedBox(
                            height: 20, width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                          )
                        : Text('حفظ التغييرات', style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    icon: controller.isLoading.value ? null : const Icon(Icons.save_rounded, color: Colors.white),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              )),
            ),
          ],
        ),
      ),
    );
  }
}
