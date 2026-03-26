import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:muslimdaily/app/features/settings/notification_settings_controller.dart';
import 'package:muslimdaily/app/features/settings/widgets/settings_widgets.dart';
import 'package:muslimdaily/app/core/extensions/context_extension.dart';

class AdhanSection extends StatelessWidget {
  final NotificationSettingsController controller;
  const AdhanSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return SettingsSection(
      title: 'الصلوات',
      children: [
        Obx(() => SettingsSwitchTile(
          title: 'تنبيهات الأذان',
          subtitle: 'تفعيل إشعارات الأذان لكل الصلوات',
          icon: Icons.mosque_outlined,
          iconColor: Colors.amber[700]!,
          value: controller.isAdhanEnabled.value,
          onChanged: (val) => controller.updateChange(controller.isAdhanEnabled, val),
        )),
        const SettingsDivider(),
        Obx(() => SettingsSwitchTile(
          title: 'شاشة الأذان المنبثقة',
          subtitle: 'عرض شاشة كاملة عند الأذان',
          icon: Icons.fullscreen,
          iconColor: Colors.teal[600]!,
          value: controller.isAdhanOverlayEnabled.value,
          onChanged: (val) => controller.updateChange(controller.isAdhanOverlayEnabled, val),
        )),
        const SettingsDivider(),
        Obx(() => SettingsSwitchTile(
          title: 'الاهتزاز مع الأذان',
          subtitle: 'تفعيل الاهتزاز عند وقت الصلاة',
          icon: Icons.vibration,
          iconColor: Colors.purple[400]!,
          value: controller.isAdhanVibrationEnabled.value,
          onChanged: (val) => controller.updateChange(controller.isAdhanVibrationEnabled, val),
        )),
        const SettingsDivider(),
        Obx(() => SettingsSwitchTile(
          title: 'تنبيهات قبل الصلاة',
          subtitle: 'تنبيه قبل الأذان بـ 15 دقيقة',
          icon: Icons.access_time,
          iconColor: Colors.orange[800]!,
          value: controller.isPrePrayerReminderEnabled.value,
          onChanged: (val) => controller.updateChange(controller.isPrePrayerReminderEnabled, val),
        )),
        const SettingsDivider(),
        Obx(() => SettingsSwitchTile(
          title: 'تنبيهات الإقامة',
          subtitle: 'تنبيه بإقامة الصلاة بعد 15 دقيقة',
          icon: Icons.timer,
          iconColor: Colors.blue[600]!,
          value: controller.isIqamahReminderEnabled.value,
          onChanged: (val) => controller.updateChange(controller.isIqamahReminderEnabled, val),
        )),
        const SettingsDivider(),
        Obx(() => SettingsSwitchTile(
          title: 'تنبيه الشروق',
          subtitle: 'تنبيه عند موعد شروق الشمس',
          icon: Icons.wb_twilight,
          iconColor: Colors.amber[600]!,
          value: controller.isSunriseReminderEnabled.value,
          onChanged: (val) => controller.updateChange(controller.isSunriseReminderEnabled, val),
        )),
        Obx(() {
          if (controller.isSunriseReminderEnabled.value) {
            return Column(
              children: [
                const SettingsDivider(),
                SettingsSwitchTile(
                  title: 'صوت الشروق مستمر',
                  subtitle: 'تكرار صوت الشروق حتى تقوم بإيقافه',
                  icon: Icons.loop_outlined,
                  iconColor: Colors.amber[800]!,
                  value: controller.isContinuousShuruqEnabled.value,
                  onChanged: (val) => controller.updateChange(controller.isContinuousShuruqEnabled, val),
                ),
              ],
            );
          }
          return const SizedBox.shrink();
        }),
        const SettingsDivider(),
        Obx(() => SettingsSwitchTile(
          title: 'أذكار بعد الصلاة',
          subtitle: 'تذكير بقراءة الأذكار بعد الصلاة',
          icon: Icons.task_alt,
          iconColor: Colors.teal[700]!,
          value: controller.isPostPrayerReminderEnabled.value,
          onChanged: (val) => controller.updateChange(controller.isPostPrayerReminderEnabled, val),
        )),
        Obx(() {
          if (controller.isPostPrayerReminderEnabled.value) {
            return SettingsSliderTile(
              title: 'التنبيه بعد:',
              value: controller.postReminderMinutes.value.toDouble(),
              label: '${controller.postReminderMinutes.value} دقيقة',
              activeColor: Colors.teal,
              onChanged: (val) => controller.updateChange(controller.postReminderMinutes, val.toInt()),
            );
          }
          return const SizedBox.shrink();
        }),
      ],
    );
  }
}

class FeaturesSection extends StatelessWidget {
  final NotificationSettingsController controller;
  const FeaturesSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return SettingsSection(
      title: 'مميزات إضافية',
      children: [
        Obx(() => SettingsSwitchTile(
          title: 'زر إيقاف الصوت',
          subtitle: 'إضافة زر "إيقاف" في التنبيه لكتمة بسرعة',
          icon: Icons.volume_off_outlined,
          iconColor: Colors.red[400]!,
          value: controller.isMuteActionEnabled.value,
          onChanged: (val) => controller.updateChange(controller.isMuteActionEnabled, val),
        )),
        const SettingsDivider(),
        Obx(() => SettingsSwitchTile(
          title: 'وضع الصمت التلقائي',
          subtitle: 'تحويل الهاتف للصامت تلقائياً بعد الأذان',
          icon: Icons.do_not_disturb_on_outlined,
          iconColor: Colors.indigo[600]!,
          value: controller.isAutoSilentEnabled.value,
          onChanged: (val) => controller.updateChange(controller.isAutoSilentEnabled, val),
        )),
        Obx(() {
          if (controller.isAutoSilentEnabled.value) {
            return SettingsSliderTile(
              title: 'مدة الصمت:',
              value: controller.autoSilentDuration.value.toDouble(),
              min: 5,
              max: 60,
              divisions: 11,
              label: '${controller.autoSilentDuration.value} دقيقة',
              activeColor: Colors.indigo,
              onChanged: (val) => controller.updateChange(controller.autoSilentDuration, val.toInt()),
            );
          }
          return const SizedBox.shrink();
        }),
      ],
    );
  }
}

class AzkarSection extends StatelessWidget {
  final NotificationSettingsController controller;
  const AzkarSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return SettingsSection(
      title: 'الأذكار اليومية',
      children: [
        Obx(() => SettingsSwitchTile(
          title: 'أذكار الصباح',
          subtitle: 'تنبيه يومي الساعة 9:00 ص',
          icon: Icons.wb_sunny_outlined,
          iconColor: Colors.orange[400]!,
          value: controller.isAzkarSabahEnabled.value,
          onChanged: (val) => controller.updateChange(controller.isAzkarSabahEnabled, val),
        )),
        const SettingsDivider(),
        Obx(() => SettingsSwitchTile(
          title: 'أذكار المساء',
          subtitle: 'تنبيه يومي الساعة 6:00 م',
          icon: Icons.nights_stay_outlined,
          iconColor: Colors.indigo[400]!,
          value: controller.isAzkarMassaEnabled.value,
          onChanged: (val) => controller.updateChange(controller.isAzkarMassaEnabled, val),
        )),
        const SettingsDivider(),
        Obx(() => SettingsSwitchTile(
          title: 'أذكار النوم',
          subtitle: 'تنبيه يومي الساعة 10:00 م',
          icon: Icons.bed_outlined,
          iconColor: Colors.purple[400]!,
          value: controller.isAzkarSleepEnabled.value,
          onChanged: (val) => controller.updateChange(controller.isAzkarSleepEnabled, val),
        )),
        const SettingsDivider(),
        Obx(() => SettingsSwitchTile(
          title: 'قيام الليل',
          subtitle: 'تنبيه قبل الفجر',
          icon: Icons.star_border,
          iconColor: Colors.blue[300]!,
          value: controller.isQiyamEnabled.value,
          onChanged: (val) => controller.updateChange(controller.isQiyamEnabled, val),
        )),
      ],
    );
  }
}

class SalatFrequencySection extends StatelessWidget {
  final NotificationSettingsController controller;
  const SalatFrequencySection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    bool isDark = context.isDark;
    return SettingsSection(
      title: 'الصلاة على النبي ﷺ',
      children: [
        Obx(() => SettingsSwitchTile(
          title: 'تفعيل التذكير',
          subtitle: 'تنبيهات متكررة للصلاة على النبي',
          icon: Icons.volunteer_activism_outlined,
          iconColor: Colors.green[500]!,
          value: controller.isSalatAlaNabiEnabled.value,
          onChanged: (val) => controller.updateChange(controller.isSalatAlaNabiEnabled, val),
        )),
        Obx(() {
          if (controller.isSalatAlaNabiEnabled.value) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SettingsDivider(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Text(
                    'تكرار التذكير كل:',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                ),
                SizedBox(
                  height: 80,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: [1, 5, 10, 15, 20, 30, 45, 60].map((mins) =>
                      FrequencyChip(
                        minutes: mins,
                        isSelected: controller.salatFrequency.value == mins,
                        onTap: () => controller.updateChange(controller.salatFrequency, mins),
                      )
                    ).toList(),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            );
          }
          return const SizedBox.shrink();
        }),
      ],
    );
  }
}

class RemindersSection extends StatelessWidget {
  final NotificationSettingsController controller;
  const RemindersSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return SettingsSection(
      title: 'تذكيرات إضافية',
      children: [
        Obx(() => SettingsSwitchTile(
          title: 'تذكير صيام الاثنين والخميس',
          subtitle: 'تذكير مساء الأحد والأربعاء',
          icon: Icons.date_range,
          iconColor: Colors.deepPurple[400]!,
          value: controller.isFastingReminderEnabled.value,
          onChanged: (val) => controller.updateChange(controller.isFastingReminderEnabled, val),
        )),
        const SettingsDivider(),
        Obx(() => SettingsSwitchTile(
          title: 'سنن الجمعة',
          subtitle: 'سورة الكهف وساعة الاستجابة',
          icon: Icons.calendar_today,
          iconColor: Colors.teal[600]!,
          value: controller.isFridayRemindersEnabled.value,
          onChanged: (val) => controller.updateChange(controller.isFridayRemindersEnabled, val),
        )),
        const SettingsDivider(),
        Obx(() => SettingsSwitchTile(
          title: 'ورد القرآن اليومي',
          subtitle: 'تذكير يومي بقراءة الورد',
          icon: Icons.menu_book,
          iconColor: Colors.brown[400]!,
          value: controller.isDailyQuranReminderEnabled.value,
          onChanged: (val) => controller.updateChange(controller.isDailyQuranReminderEnabled, val),
        )),
        const SettingsDivider(),
        Obx(() => SettingsSwitchTile(
          title: 'تذكير الأيام البيض',
          subtitle: 'تذكير بأيام 13 و14 و15 من كل شهر هجري',
          icon: Icons.calendar_month_outlined,
          iconColor: Colors.blueAccent[400]!,
          value: controller.isWhiteDaysReminderEnabled.value,
          onChanged: (val) => controller.updateChange(controller.isWhiteDaysReminderEnabled, val),
        )),
        const SettingsDivider(),
        Obx(() => SettingsSwitchTile(
          title: 'المناسبات الإسلامية',
          subtitle: 'تذكير بعرفة، عاشوراء، رمضان والأعياد',
          icon: Icons.auto_awesome,
          iconColor: Colors.amber[600]!,
          value: controller.isReligiousOccasionsEnabled.value,
          onChanged: (val) => controller.updateChange(controller.isReligiousOccasionsEnabled, val),
        )),
        const SettingsDivider(),
        Obx(() => SettingsSwitchTile(
          title: 'سورة الملك',
          subtitle: 'تذكير بقراءة سورة الملك قبل النوم',
          icon: Icons.nightlight_round,
          iconColor: Colors.indigo[400]!,
          value: controller.isMulkReminderEnabled.value,
          onChanged: (val) => controller.updateChange(controller.isMulkReminderEnabled, val),
        )),
        const SettingsDivider(),
        Obx(() => SettingsSwitchTile(
          title: 'صلاة الضحى',
          subtitle: 'تذكير بصلاة الأوابين',
          icon: Icons.wb_sunny_outlined,
          iconColor: Colors.orange[400]!,
          value: controller.isDuhaReminderEnabled.value,
          onChanged: (val) => controller.updateChange(controller.isDuhaReminderEnabled, val),
        )),
        const SettingsDivider(),
        Obx(() => SettingsSwitchTile(
          title: 'سنة اليوم',
          subtitle: 'إشعار يومي بسنة من السنن المهجورة',
          icon: Icons.lightbulb_outline,
          iconColor: Colors.lightBlue[400]!,
          value: controller.isSunnahReminderEnabled.value,
          onChanged: (val) => controller.updateChange(controller.isSunnahReminderEnabled, val),
        )),
        // const SettingsDivider(),
        // Obx(() => SettingsSwitchTile(
        //   title: 'الدعاء بين الأذان والإقامة',
        //   subtitle: 'تذكير بالدعاء في هذا الوقت المبارك',
        //   icon: Icons.message_outlined,
        //   iconColor: Colors.cyan[600]!,
        //   value: controller.isBetweenAdhanIqamahEnabled.value,
        //   onChanged: (val) => controller.updateChange(controller.isBetweenAdhanIqamahEnabled, val),
        // )),
      ],
    );
  }
}

class FrequencyChip extends StatelessWidget {
  final int minutes;
  final bool isSelected;
  final VoidCallback onTap;

  const FrequencyChip({
    super.key,
    required this.minutes,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    bool isDark = context.isDark;
    final primaryColor = isSelected ? const Color(0xFF178B74) : (isDark ? const Color(0xFF1E293B) : Colors.white);

    return Padding(
      padding: const EdgeInsets.only(left: 10.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 75,
          decoration: BoxDecoration(
            color: primaryColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? Colors.transparent : (isDark ? Colors.white12 : Colors.grey.shade200),
            ),
            boxShadow: isSelected
                ? [BoxShadow(color: const Color(0xFF178B74).withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))]
                : [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.1 : 0.03), blurRadius: 4, offset: const Offset(0, 2))],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$minutes',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  height: 1.0,
                  color: isSelected ? Colors.white : (isDark ? Colors.white : Colors.black87),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'دقيقة',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 10,
                  height: 1.0,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
