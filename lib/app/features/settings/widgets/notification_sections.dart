import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:muslimdaily/app/features/settings/notification_settings_controller.dart';
import 'package:muslimdaily/app/features/settings/widgets/settings_widgets.dart';
import 'package:muslimdaily/app/core/extensions/context_extension.dart';
import 'package:muslimdaily/app/core/utils/style/k_helper.dart';
import 'package:muslimdaily/app/core/utils/style/k_color.dart';

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
        // const SettingsDivider(),
        // Obx(() => SettingsSwitchTile(
        //   title: 'شاشة الأذان المنبثقة',
        //   subtitle: 'عرض شاشة كاملة عند الأذان',
        //   icon: Icons.fullscreen,
        //   iconColor: Colors.teal[600]!,
        //   value: controller.isAdhanOverlayEnabled.value,
        //   onChanged: (val) => controller.updateChange(controller.isAdhanOverlayEnabled, val),
        // )),
        const SettingsDivider(),
        Obx(() {
          if (controller.isAdhanEnabled.value) {
            return Column(
              children: [
                SettingsSwitchTile(
                  title: 'الأذان كاملاً',
                  subtitle: 'تشغيل الأذان كاملاً أو الاكتفاء بأول 30 ثانية',
                  icon: Icons.record_voice_over,
                  iconColor: Colors.deepOrange[400]!,
                  value: controller.isFullAdhanEnabled.value,
                  onChanged: (val) => controller.updateChange(controller.isFullAdhanEnabled, val),
                ),
                const SettingsDivider(),
              ],
            );
          }
          return const SizedBox.shrink();
        }),
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
      title: 'التحكم في الإشعارات',
      children: [
        Obx(() => SettingsSwitchTile(
          title: 'الوضع الصامت ليلاً',
          subtitle: 'إسكات الإشعارات (ما عدا الأذان) خلال ساعات محددة',
          icon: Icons.brightness_2_outlined,
          iconColor: Colors.deepPurple[400]!,
          value: controller.isNightSilentModeEnabled.value,
          onChanged: (val) => controller.updateChange(controller.isNightSilentModeEnabled, val),
        )),
        Obx(() {
          if (controller.isNightSilentModeEnabled.value) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Row(
                    children: [
                      _buildTimePickerCard(
                        context,
                        title: 'يبدأ من',
                        hour: controller.nightSilentStartHour.value,
                        minute: controller.nightSilentStartMinute.value,
                        icon: Icons.nights_stay_rounded,
                        color: Colors.deepPurple,
                        onTap: () async {
                          final time = await KHelper.pickTime(context);
                          controller.updateChange(controller.nightSilentStartHour, time.hour);
                          controller.updateChange(controller.nightSilentStartMinute, time.minute);
                        },
                      ),
                      const SizedBox(width: 16),
                      _buildTimePickerCard(
                        context,
                        title: 'ينتهي عند',
                        hour: controller.nightSilentEndHour.value,
                        minute: controller.nightSilentEndMinute.value,
                        icon: Icons.wb_sunny_rounded,
                        color: Colors.greenAccent[700]!,
                        onTap: () async {
                          final time = await KHelper.pickTime(context);
                          controller.updateChange(controller.nightSilentEndHour, time.hour);
                          controller.updateChange(controller.nightSilentEndMinute, time.minute);
                        },
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _buildDayPicker(context, controller),
                ),
                Obx(() {
                  int startH = controller.nightSilentStartHour.value;
                  int startM = controller.nightSilentStartMinute.value;
                  int endH = controller.nightSilentEndHour.value;
                  int endM = controller.nightSilentEndMinute.value;
                  
                  int startTotal = startH * 60 + startM;
                  int endTotal = endH * 60 + endM;
                  int diff = endTotal - startTotal;
                  if (diff < 0) diff += 1440; // Handles crossing midnight
                  
                  int h = diff ~/ 60;
                  int m = diff % 60;
                  
                  String durationText = '';
                  if (h > 0) durationText += '$h ساعة';
                  if (m > 0) {
                    if (durationText.isNotEmpty) durationText += ' و ';
                    durationText += '$m دقيقة';
                  }
                  if (durationText.isEmpty) durationText = '0 دقيقة';

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Center(
                      child: Text(
                        'مدة الصمت للاشعارات: $durationText',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 12,
                          color: context.isDark ? Colors.white60 : Colors.black45,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                }),
              ],
            );
          }
          return const SizedBox.shrink();
        }),
        const SettingsDivider(),
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

  Widget _buildTimePickerCard(
    BuildContext context, {
    required String title,
    required int hour,
    required int minute,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    bool isDark = context.isDark;
    
    int displayHour = hour == 0 ? 12 : (hour <= 12 ? hour : hour - 12);
    String timeStr = '${displayHour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
    String period = hour < 12 ? 'صباحاً' : 'مساءً';

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withOpacity(0.03) : color.withOpacity(0.05),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark ? color.withOpacity(0.4) : color.withOpacity(0.15),
              width: 1.5,
            ),
            boxShadow: isDark ? [] : [
              BoxShadow(
                color: color.withOpacity(0.08),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 18, color: color),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 12,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                timeStr,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                  color: isDark ? Colors.white : color,
                  shadows: [
                    Shadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
              ),
              Text(
                period,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDayPicker(BuildContext context, NotificationSettingsController controller) {
    final weekDays = [7, 1, 2, 3, 4, 5, 6]; // Sun to Sat
    final labels = ['أحد', 'اثنين', 'ثلاثاء', 'أربعاء', 'خميس', 'جمعة', 'سبت'];
    bool isDark = context.isDark;

    return Obx(() {
      final selectedCount = controller.nightSilentDays.length;
      String summary = '';
      if (selectedCount == 7) {
        summary = 'نشط طوال الأسبوع';
      } else if (selectedCount == 0) {
        summary = 'معطل تماماً';
      } else {
        final allDays = [7, 1, 2, 3, 4, 5, 6];
        final labelsFull = ['الأحد', 'الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت'];
        final exemptDays = <String>[];
        for (int i = 0; i < 7; i++) {
          if (!controller.nightSilentDays.contains(allDays[i])) {
            exemptDays.add(labelsFull[i]);
          }
        }
        
        if (exemptDays.length <= 2) {
          summary = 'مستثنى من: ${exemptDays.join('، ')}';
        } else {
          summary = 'نشط في $selectedCount أيام';
        }
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'أيام التكرار',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
              ),
              Text(
                summary,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 11,
                  color: KColors.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(weekDays.length, (index) {
          int day = weekDays[index];
          bool isSelected = controller.nightSilentDays.contains(day);
          
          return GestureDetector(
            onTap: () {
              if (isSelected) {
                if (controller.nightSilentDays.length > 1) {
                  controller.nightSilentDays.remove(day);
                  controller.updateChange(controller.nightSilentDays, null);
                }
              } else {
                controller.nightSilentDays.add(day);
                controller.updateChange(controller.nightSilentDays, null);
              }
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: isSelected 
                      ? KColors.primaryColor 
                      : (isDark ? Colors.white.withOpacity(0.05) : Colors.grey[100]),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? Colors.transparent : (isDark ? Colors.white12 : Colors.grey[300]!),
                      width: 1,
                    ),
                    boxShadow: isSelected ? [
                      BoxShadow(
                        color: KColors.primaryColor.withOpacity(0.2),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      )
                    ] : [],
                  ),
                  child: Center(
                    child: Text(
                      labels[index][0],
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black54),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  labels[index].substring(0, labels[index].length > 2 ? 2 : labels[index].length),
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 9,
                    color: isSelected ? KColors.primaryColor : (isDark ? Colors.white38 : Colors.grey),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    ]);
    });
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
      title: 'تذكيرات إضافية (متابعة الأوراد)',
      children: [

        Obx(() => SettingsSwitchTile(
          title: 'تتبع ورد القرآن',
          subtitle: 'تذكيرك مساءً إذا لم تقرأ القرآن خلال اليوم',
          icon: Icons.menu_book,
          iconColor: Colors.brown[400]!,
          value: controller.isQuranTrackingEnabled.value,
          onChanged: (val) => controller.updateChange(controller.isQuranTrackingEnabled, val),
        )),
        const SettingsDivider(),
        Obx(() => SettingsSwitchTile(
          title: 'تتبع أذكار الصباح',
          subtitle: 'تذكيرك قبل الظهر في حال نسيت قراءة أذكار الصباح',
          icon: Icons.wb_sunny_outlined,
          iconColor: Colors.orange[400]!,
          value: controller.isSabahTrackingEnabled.value,
          onChanged: (val) => controller.updateChange(controller.isSabahTrackingEnabled, val),
        )),
        const SettingsDivider(),
        Obx(() => SettingsSwitchTile(
          title: 'تتبع أذكار المساء',
          subtitle: 'تذكيرك ليلاً في حال نسيت قراءة أذكار المساء',
          icon: Icons.nights_stay_outlined,
          iconColor: Colors.indigo[400]!,
          value: controller.isMassaTrackingEnabled.value,
          onChanged: (val) => controller.updateChange(controller.isMassaTrackingEnabled, val),
        )),
        const SettingsDivider(),
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
        const SettingsDivider(),
        Obx(() => SettingsSwitchTile(
          title: 'الدعاء بين الأذان والإقامة',
          subtitle: 'تذكير بالدعاء في هذا الوقت المبارك',
          icon: Icons.message_outlined,
          iconColor: Colors.cyan[600]!,
          value: controller.isBetweenAdhanIqamahEnabled.value,
          onChanged: (val) => controller.updateChange(controller.isBetweenAdhanIqamahEnabled, val),
        )),
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
               Text(
                'دقيقة',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 10,
                  height: 1.0,
                  color:isSelected? Colors.white:Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
