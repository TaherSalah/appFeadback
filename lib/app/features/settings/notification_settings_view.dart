import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muslimdaily/app/core/services/settings_service.dart';
import 'package:muslimdaily/app/core/services/notification_manager.dart';
import 'package:muslimdaily/app/core/utils/style/k_color.dart';
import 'package:muslimdaily/app/core/utils/style/k_helper.dart';
import 'package:muslimdaily/app/core/utils/style/app_theme_colors.dart';

import '../azanView/view/AdhanDiagnosticScreen.dart';
import 'view/notification_test_view.dart';

class NotificationSettingsView extends StatefulWidget {
  const NotificationSettingsView({super.key});

  @override
  State<NotificationSettingsView> createState() =>
      _NotificationSettingsViewState();
}

class _NotificationSettingsViewState extends State<NotificationSettingsView> {
  final SettingsService _settings = SettingsService();

  // Local state for UI
  late bool isAdhanEnabled;
  late bool isAdhanVibrationEnabled;
  late bool isAdhanOverlayEnabled;
  late bool isPrePrayerReminderEnabled;
  late bool isIqamahReminderEnabled;
  late bool isSunriseReminderEnabled;
  late bool isContinuousShuruqEnabled;
  late bool isPostPrayerReminderEnabled;
  late int postReminderMinutes;
  late bool isAzkarSabahEnabled;
  late bool isAzkarMassaEnabled;
  late bool isAzkarSleepEnabled;
  late bool isQiyamEnabled;
  late bool isSalatAlaNabiEnabled;
  late int salatFrequency;

  // New Reminders
  late bool isFastingReminderEnabled;
  late bool isFridayRemindersEnabled;
  late bool isDailyQuranReminderEnabled;
  late bool isWhiteDaysReminderEnabled;
  late bool isReligiousOccasionsEnabled;
  late bool isMulkReminderEnabled;
  late bool isDuhaReminderEnabled;
  late bool isSunnahReminderEnabled;
  late bool isBetweenAdhanIqamahEnabled;
  late bool isMuteActionEnabled;
  late bool isStopActionEnabled;
  late bool isAutoSilentEnabled;
  late int autoSilentDuration;

  bool _hasChanges = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentSettings();
  }

  void _loadCurrentSettings() {
    setState(() {
      isAdhanEnabled = _settings.isAdhanEnabled;
      isAdhanVibrationEnabled = _settings.isAdhanVibrationEnabled;
      isAdhanOverlayEnabled = _settings.isAdhanOverlayEnabled;
      isPrePrayerReminderEnabled = _settings.isPrePrayerReminderEnabled;
      isIqamahReminderEnabled = _settings.isIqamahReminderEnabled;
      isSunriseReminderEnabled = _settings.isSunriseReminderEnabled;
      isContinuousShuruqEnabled = _settings.isContinuousShuruqEnabled;
      isPostPrayerReminderEnabled = _settings.isPostPrayerReminderEnabled;
      postReminderMinutes = _settings.postReminderMinutes;
      isAzkarSabahEnabled = _settings.isAzkarSabahEnabled;
      isAzkarMassaEnabled = _settings.isAzkarMassaEnabled;
      isAzkarSleepEnabled = _settings.isAzkarSleepEnabled;
      isQiyamEnabled = _settings.isQiyamEnabled;
      isSalatAlaNabiEnabled = _settings.isSalatAlaNabiEnabled;
      salatFrequency = _settings.getSalatAlaNabiMinutes();

      // New Reminders
      isFastingReminderEnabled = _settings.isFastingReminderEnabled;
      isFridayRemindersEnabled = _settings.isFridayRemindersEnabled;
      isDailyQuranReminderEnabled = _settings.isDailyQuranReminderEnabled;
      isWhiteDaysReminderEnabled = _settings.isWhiteDaysReminderEnabled;
      isReligiousOccasionsEnabled = _settings.isReligiousOccasionsEnabled;
      isMulkReminderEnabled = _settings.isMulkReminderEnabled;
      isDuhaReminderEnabled = _settings.isDuhaReminderEnabled;
      isSunnahReminderEnabled = _settings.isSunnahReminderEnabled;
      isBetweenAdhanIqamahEnabled = _settings.isBetweenAdhanIqamahEnabled;
      isMuteActionEnabled = _settings.isMuteActionEnabled;
      isStopActionEnabled = _settings.isStopActionEnabled;
      isAutoSilentEnabled = _settings.isAutoSilentEnabled;
      autoSilentDuration = _settings.autoSilentDuration;

      _hasChanges = false;
    });
  }

  Future<void> _saveAll() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);
    try {
      await _settings.setAdhanEnabled(isAdhanEnabled);
      await _settings.setAdhanVibrationEnabled(isAdhanVibrationEnabled);
      await _settings.setAdhanOverlayEnabled(isAdhanOverlayEnabled);
      await _settings.setPrePrayerReminderEnabled(isPrePrayerReminderEnabled);
      await _settings.setIqamahReminderEnabled(isIqamahReminderEnabled);
      await _settings.setSunriseReminderEnabled(isSunriseReminderEnabled);
      await _settings.setContinuousShuruqEnabled(isContinuousShuruqEnabled);
      await _settings.setPostPrayerReminderEnabled(isPostPrayerReminderEnabled);
      await _settings.setPostReminderMinutes(postReminderMinutes);
      await _settings.setAzkarSabahEnabled(isAzkarSabahEnabled);
      await _settings.setAzkarMassaEnabled(isAzkarMassaEnabled);
      await _settings.setAzkarSleepEnabled(isAzkarSleepEnabled);
      await _settings.setQiyamEnabled(isQiyamEnabled);
      await _settings.setSalatAlaNabiEnabled(isSalatAlaNabiEnabled);
      await _settings.setSalatAlaNabiMinutes(salatFrequency);

      // New Reminders
      await _settings.setFastingReminderEnabled(isFastingReminderEnabled);
      await _settings.setFridayRemindersEnabled(isFridayRemindersEnabled);
      await _settings.setDailyQuranReminderEnabled(isDailyQuranReminderEnabled);
      await _settings.setWhiteDaysReminderEnabled(isWhiteDaysReminderEnabled);
      await _settings.setReligiousOccasionsEnabled(isReligiousOccasionsEnabled);
      await _settings.setMulkReminderEnabled(isMulkReminderEnabled);
      await _settings.setDuhaReminderEnabled(isDuhaReminderEnabled);
      await _settings.setSunnahReminderEnabled(isSunnahReminderEnabled);
      await _settings.setBetweenAdhanIqamahEnabled(isBetweenAdhanIqamahEnabled);
      await _settings.setMuteActionEnabled(isMuteActionEnabled);
      await _settings.setStopActionEnabled(isStopActionEnabled);
      await _settings.setAutoSilentEnabled(isAutoSilentEnabled);
      await _settings.setAutoSilentDuration(autoSilentDuration);

      // Trigger notification rescheduling
      await NotificationManager().rescheduleAll();

      KHelper.showSuccess(message: 'تم حفظ الإعدادات وتحديث التنبيهات بنجاح');
      setState(() => _hasChanges = false);
    } catch (e) {
      KHelper.showError(message: 'حدث خطأ أثناء حفظ الإعدادات');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        // extendBodyBehindAppBar: true,
        // appBar: AppBar(
        //   title: Text(
        //     'إعدادات التنبيهات',
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
              Size.fromHeight(MediaQuery.sizeOf(context).width > 600 ? 70 : 50),
          child: AppBar(
            leading: CupertinoNavigationBarBackButton(
              color: isDark ? Colors.white : Colors.black,
            ),
            centerTitle: true,
            title: Text(
              'إعدادات التنبيهات',
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
          child: Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ListView(
                    children: [
                      SizedBox(height: MediaQuery.of(context).padding.top),

                      // 🛠️ حل المشاكل
                      _buildSettingsCard(
                        context,
                        children: [
                          _buildListTile(
                            context,
                            title: 'حل مشاكل الأذان والتنبيهات',
                            subtitle:
                                'إذا كان الأذان لا يعمل أو يتوقف، اضغط هنا',
                            icon: Icons.build_circle_outlined,
                            iconColor: Colors.redAccent,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const AdhanDiagnosticScreen(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // 🕋 الأذان
                      _buildSectionHeader(context, 'الصلوات'),
                      _buildSettingsCard(
                        context,
                        children: [
                          _buildSwitchTile(
                            context,
                            title: 'تنبيهات الأذان',
                            subtitle: 'تفعيل إشعارات الأذان لكل الصلوات',
                            icon: Icons.mosque_outlined,
                            iconColor: Colors.amber[700]!,
                            value: isAdhanEnabled,
                            onChanged: (val) {
                              setState(() {
                                isAdhanEnabled = val;
                                _hasChanges = true;
                              });
                            },
                          ),
                          _buildDivider(isDark),
                          _buildSwitchTile(
                            context,
                            title: 'شاشة الأذان المنبثقة',
                            subtitle: 'عرض شاشة كاملة عند الأذان',
                            icon: Icons.fullscreen,
                            iconColor: Colors.teal[600]!,
                            value: isAdhanOverlayEnabled,
                            onChanged: (val) {
                              setState(() {
                                isAdhanOverlayEnabled = val;
                                _hasChanges = true;
                              });
                            },
                          ),
                          _buildDivider(isDark),
                          _buildSwitchTile(
                            context,
                            title: 'الاهتزاز مع الأذان',
                            subtitle: 'تفعيل الاهتزاز عند وقت الصلاة',
                            icon: Icons.vibration,
                            iconColor: Colors.purple[400]!,
                            value: isAdhanVibrationEnabled,
                            onChanged: (val) {
                              setState(() {
                                isAdhanVibrationEnabled = val;
                                _hasChanges = true;
                              });
                            },
                          ),
                          _buildDivider(isDark),
                          _buildSwitchTile(
                            context,
                            title: 'تنبيهات قبل الصلاة',
                            subtitle: 'تنبيه قبل الأذان بـ 15 دقيقة',
                            icon: Icons.access_time,
                            iconColor: Colors.orange[800]!,
                            value: isPrePrayerReminderEnabled,
                            onChanged: (val) {
                              setState(() {
                                isPrePrayerReminderEnabled = val;
                                _hasChanges = true;
                              });
                            },
                          ),
                          _buildDivider(isDark),
                          _buildSwitchTile(
                            context,
                            title: 'تنبيهات الإقامة',
                            subtitle: 'تنبيه بإقامة الصلاة بعد 15 دقيقة',
                            icon: Icons.timer,
                            iconColor: Colors.blue[600]!,
                            value: isIqamahReminderEnabled,
                            onChanged: (val) {
                              setState(() {
                                isIqamahReminderEnabled = val;
                                _hasChanges = true;
                              });
                            },
                          ),
                          _buildDivider(isDark),
                          _buildSwitchTile(
                            context,
                            title: 'تنبيه الشروق',
                            subtitle: 'تنبيه عند موعد شروق الشمس',
                            icon: Icons.wb_twilight,
                            iconColor: Colors.amber[600]!,
                            value: isSunriseReminderEnabled,
                            onChanged: (val) {
                              setState(() {
                                isSunriseReminderEnabled = val;
                                _hasChanges = true;
                              });
                            },
                          ),
                          if (isSunriseReminderEnabled) ...[
                            _buildDivider(isDark),
                            _buildSwitchTile(
                              context,
                              title: 'صوت الشروق مستمر',
                              subtitle: 'تكرار صوت الشروق حتى تقوم بإيقافه',
                              icon: Icons.loop_outlined,
                              iconColor: Colors.amber[800]!,
                              value: isContinuousShuruqEnabled,
                              onChanged: (val) {
                                setState(() {
                                  isContinuousShuruqEnabled = val;
                                  _hasChanges = true;
                                });
                              },
                            ),
                          ],
                          _buildDivider(isDark),
                          _buildSwitchTile(
                            context,
                            title: 'أذكار بعد الصلاة',
                            subtitle: 'تذكير بقراءة الأذكار بعد الصلاة',
                            icon: Icons.task_alt,
                            iconColor: Colors.teal[700]!,
                            value: isPostPrayerReminderEnabled,
                            onChanged: (val) {
                              setState(() {
                                isPostPrayerReminderEnabled = val;
                                _hasChanges = true;
                              });
                            },
                          ),
                          if (isPostPrayerReminderEnabled) ...[
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 8),
                              child: Row(
                                children: [
                                  Text(
                                    'التنبيه بعد:',
                                    style: GoogleFonts.cairo(
                                      fontSize: 12,
                                      color: isDark
                                          ? Colors.white70
                                          : Colors.black54,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Slider(
                                      value: postReminderMinutes.toDouble(),
                                      min: 5,
                                      max: 30,
                                      divisions: 5,
                                      label: '$postReminderMinutes دقيقة',
                                      activeColor: Colors.teal,
                                      onChanged: (val) {
                                        setState(() {
                                          postReminderMinutes = val.toInt();
                                          _hasChanges = true;
                                        });
                                      },
                                    ),
                                  ),
                                  Text(
                                    '$postReminderMinutes دقيقة',
                                    style: GoogleFonts.cairo(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: isDark
                                          ? Colors.white
                                          : Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),

                      const SizedBox(height: 24),

                      // ✨ مميزات حصرية
                      _buildSectionHeader(context, 'مميزات إضافية '),
                      _buildSettingsCard(
                        context,
                        children: [
                          _buildSwitchTile(
                            context,
                            title: 'زر إيقاف الصوت',
                            subtitle: 'إضافة زر "إيقاف" في التنبيه لكتمة بسرعة',
                            icon: Icons.volume_off_outlined,
                            iconColor: Colors.red[400]!,
                            value: isMuteActionEnabled,
                            onChanged: (val) {
                              setState(() {
                                isMuteActionEnabled = val;
                                _hasChanges = true;
                              });
                            },
                          ),
                          _buildDivider(isDark),
                          _buildSwitchTile(
                            context,
                            title: 'وضع الصمت التلقائي',
                            subtitle: 'تحويل الهاتف للصامت تلقائياً بعد الأذان',
                            icon: Icons.do_not_disturb_on_outlined,
                            iconColor: Colors.indigo[600]!,
                            value: isAutoSilentEnabled,
                            onChanged: (val) {
                              setState(() {
                                isAutoSilentEnabled = val;
                                _hasChanges = true;
                              });
                            },
                          ),
                          if (isAutoSilentEnabled) ...[
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 8),
                              child: Row(
                                children: [
                                  Text(
                                    'مدة الصمت:',
                                    style: GoogleFonts.cairo(
                                      fontSize: 12,
                                      color: isDark
                                          ? Colors.white70
                                          : Colors.black54,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Slider(
                                      value: autoSilentDuration.toDouble(),
                                      min: 5,
                                      max: 60,
                                      divisions: 11,
                                      label: '$autoSilentDuration دقيقة',
                                      activeColor: Colors.indigo,
                                      onChanged: (val) {
                                        setState(() {
                                          autoSilentDuration = val.toInt();
                                          _hasChanges = true;
                                        });
                                      },
                                    ),
                                  ),
                                  Text(
                                    '$autoSilentDuration دقيقة',
                                    style: GoogleFonts.cairo(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: isDark
                                          ? Colors.white
                                          : Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),

                      const SizedBox(height: 24),

                      // 📿 الأذكار
                      _buildSectionHeader(context, 'الأذكار اليومية'),
                      _buildSettingsCard(
                        context,
                        children: [
                          _buildSwitchTile(
                            context,
                            title: 'أذكار الصباح',
                            subtitle: 'تنبيه يومي الساعة 9:00 ص',
                            icon: Icons.wb_sunny_outlined,
                            iconColor: Colors.orange[400]!,
                            value: isAzkarSabahEnabled,
                            onChanged: (val) {
                              setState(() {
                                isAzkarSabahEnabled = val;
                                _hasChanges = true;
                              });
                            },
                          ),
                          _buildDivider(isDark),
                          _buildSwitchTile(
                            context,
                            title: 'أذكار المساء',
                            subtitle: 'تنبيه يومي الساعة 6:00 م',
                            icon: Icons.nights_stay_outlined,
                            iconColor: Colors.indigo[400]!,
                            value: isAzkarMassaEnabled,
                            onChanged: (val) {
                              setState(() {
                                isAzkarMassaEnabled = val;
                                _hasChanges = true;
                              });
                            },
                          ),
                          _buildDivider(isDark),
                          _buildSwitchTile(
                            context,
                            title: 'أذكار النوم',
                            subtitle: 'تنبيه يومي الساعة 10:00 م',
                            icon: Icons.bed_outlined,
                            iconColor: Colors.purple[400]!,
                            value: isAzkarSleepEnabled,
                            onChanged: (val) {
                              setState(() {
                                isAzkarSleepEnabled = val;
                                _hasChanges = true;
                              });
                            },
                          ),
                          _buildDivider(isDark),
                          _buildSwitchTile(
                            context,
                            title: 'قيام الليل',
                            subtitle: 'تنبيه قبل الفجر',
                            icon: Icons.star_border,
                            iconColor: Colors.blue[300]!,
                            value: isQiyamEnabled,
                            onChanged: (val) {
                              setState(() {
                                isQiyamEnabled = val;
                                _hasChanges = true;
                              });
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // 🕌 الصلاة على النبي
                      _buildSectionHeader(context, 'الصلاة على النبي ﷺ'),
                      _buildSettingsCard(
                        context,
                        children: [
                          _buildSwitchTile(
                            context,
                            title: 'تفعيل التذكير',
                            subtitle: 'تنبيهات متكررة للصلاة على النبي',
                            icon: Icons.volunteer_activism_outlined,
                            iconColor: Colors.green[500]!,
                            value: isSalatAlaNabiEnabled,
                            onChanged: (val) {
                              setState(() {
                                isSalatAlaNabiEnabled = val;
                                _hasChanges = true;
                              });
                            },
                          ),
                          if (isSalatAlaNabiEnabled) ...[
                            _buildDivider(isDark),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'تكرار التذكير كل:',
                                    style: GoogleFonts.cairo(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: isDark
                                          ? Colors.white70
                                          : Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  SizedBox(
                                    height: 80,
                                    child: ListView(
                                      scrollDirection: Axis.horizontal,
                                      children: [
                                        _buildFrequencyChip(1),
                                        _buildFrequencyChip(5),
                                        _buildFrequencyChip(10),
                                        _buildFrequencyChip(15),
                                        _buildFrequencyChip(20),
                                        _buildFrequencyChip(30),
                                        _buildFrequencyChip(45),
                                        _buildFrequencyChip(60),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),

                      const SizedBox(height: 24),

                      // 🌟 تذكيرات إضافية
                      _buildSectionHeader(context, 'تذكيرات إضافية'),
                      _buildSettingsCard(
                        context,
                        children: [
                          _buildSwitchTile(
                            context,
                            title: 'تذكير صيام الاثنين والخميس',
                            subtitle: 'تذكير مساء الأحد والأربعاء',
                            icon: Icons.date_range,
                            iconColor: Colors.deepPurple[400]!,
                            value: isFastingReminderEnabled,
                            onChanged: (val) {
                              setState(() {
                                isFastingReminderEnabled = val;
                                _hasChanges = true;
                              });
                            },
                          ),
                          _buildDivider(isDark),
                          _buildSwitchTile(
                            context,
                            title: 'سنن الجمعة',
                            subtitle: 'سورة الكهف وساعة الاستجابة',
                            icon: Icons.calendar_today,
                            iconColor: Colors.teal[600]!,
                            value: isFridayRemindersEnabled,
                            onChanged: (val) {
                              setState(() {
                                isFridayRemindersEnabled = val;
                                _hasChanges = true;
                              });
                            },
                          ),
                          _buildDivider(isDark),
                          _buildSwitchTile(
                            context,
                            title: 'ورد القرآن اليومي',
                            subtitle: 'تذكير يومي بقراءة الورد',
                            icon: Icons.menu_book,
                            iconColor: Colors.brown[400]!,
                            value: isDailyQuranReminderEnabled,
                            onChanged: (val) {
                              setState(() {
                                isDailyQuranReminderEnabled = val;
                                _hasChanges = true;
                              });
                            },
                          ),
                          _buildDivider(isDark),
                          _buildSwitchTile(
                            context,
                            title: 'تذكير الأيام البيض',
                            subtitle: 'تذكير بأيام 13 و14 و15 من كل شهر هجري',
                            icon: Icons.calendar_month_outlined,
                            iconColor: Colors.blueAccent[400]!,
                            value: isWhiteDaysReminderEnabled,
                            onChanged: (val) {
                              setState(() {
                                isWhiteDaysReminderEnabled = val;
                                _hasChanges = true;
                              });
                            },
                          ),
                          _buildDivider(isDark),
                          _buildSwitchTile(
                            context,
                            title: 'المناسبات الإسلامية',
                            subtitle: 'تذكير بعرفة، عاشوراء، رمضان والأعياد',
                            icon: Icons.auto_awesome,
                            iconColor: Colors.amber[600]!,
                            value: isReligiousOccasionsEnabled,
                            onChanged: (val) {
                              setState(() {
                                isReligiousOccasionsEnabled = val;
                                _hasChanges = true;
                              });
                            },
                          ),
                          _buildDivider(isDark),
                          _buildSwitchTile(
                            context,
                            title: 'سورة الملك',
                            subtitle: 'تذكير بقراءة سورة الملك قبل النوم',
                            icon: Icons.nightlight_round,
                            iconColor: Colors.indigo[400]!,
                            value: isMulkReminderEnabled,
                            onChanged: (val) {
                              setState(() {
                                isMulkReminderEnabled = val;
                                _hasChanges = true;
                              });
                            },
                          ),
                          _buildDivider(isDark),
                          _buildSwitchTile(
                            context,
                            title: 'صلاة الضحى',
                            subtitle: 'تذكير بصلاة الأوابين',
                            icon: Icons.wb_sunny_outlined,
                            iconColor: Colors.orange[400]!,
                            value: isDuhaReminderEnabled,
                            onChanged: (val) {
                              setState(() {
                                isDuhaReminderEnabled = val;
                                _hasChanges = true;
                              });
                            },
                          ),
                          _buildDivider(isDark),
                          _buildSwitchTile(
                            context,
                            title: 'سنة اليوم',
                            subtitle: 'إشعار يومي بسنة من السنن المهجورة',
                            icon: Icons.lightbulb_outline,
                            iconColor: Colors.lightBlue[400]!,
                            value: isSunnahReminderEnabled,
                            onChanged: (val) {
                              setState(() {
                                isSunnahReminderEnabled = val;
                                _hasChanges = true;
                              });
                            },
                          ),
                          _buildDivider(isDark),
                          _buildSwitchTile(
                            context,
                            title: 'الدعاء بين الأذان والإقامة',
                            subtitle: 'تذكير بالدعاء في هذا الوقت المبارك',
                            icon: Icons.message_outlined,
                            iconColor: Colors.cyan[600]!,
                            value: isBetweenAdhanIqamahEnabled,
                            onChanged: (val) {
                              setState(() {
                                isBetweenAdhanIqamahEnabled = val;
                                _hasChanges = true;
                              });
                            },
                          ),
                        ],
                      ),

                      // ✨ مميزات إضافية (Premium)
                      const SizedBox(height: 75),
                      // _buildSectionHeader(context, 'مميزات إضافية'),
                      // _buildSettingsCard(
                      //   context,
                      //   children: [
                      //     _buildSwitchTile(
                      //       context,
                      //       title: 'زر إيقاف الصوت',
                      //       subtitle: 'إظهار زر الإيقاف في التنبيهات',
                      //       icon: Icons.notifications_off_outlined,
                      //       iconColor: Colors.red[400]!,
                      //       value: isStopActionEnabled,
                      //       onChanged: (val) {
                      //         setState(() {
                      //           isStopActionEnabled = val;
                      //           isMuteActionEnabled = val; // Link them together
                      //           _hasChanges = true;
                      //         });
                      //       },
                      //     ),
                      //     _buildDivider(isDark),
                      //     _buildSwitchTile(
                      //       context,
                      //       title: 'وضع الصمت التلقائي',
                      //       subtitle: 'تحويل الهاتف للوضع الصامت بعد الأذان',
                      //       icon: Icons.do_not_disturb_on_outlined,
                      //       iconColor: Colors.indigo[400]!,
                      //       value: isAutoSilentEnabled,
                      //       onChanged: (val) {
                      //         setState(() {
                      //           isAutoSilentEnabled = val;
                      //           _hasChanges = true;
                      //         });
                      //       },
                      //     ),
                      //     if (isAutoSilentEnabled) ...[
                      //       _buildDivider(isDark),
                      //       Padding(
                      //         padding: const EdgeInsets.symmetric(
                      //             horizontal: 16, vertical: 8),
                      //         child: Row(
                      //           children: [
                      //             Icon(Icons.timer_outlined,
                      //                 size: 20, color: Colors.indigo[400]),
                      //             const SizedBox(width: 8),
                      //             Text(
                      //               'مدة الصمت: $autoSilentDuration دقيقة',
                      //               style: GoogleFonts.cairo(
                      //                 fontSize: 14,
                      //                 color: isDark
                      //                     ? Colors.white70
                      //                     : Colors.black54,
                      //               ),
                      //             ),
                      //             Expanded(
                      //               child: Slider(
                      //                 value: autoSilentDuration.toDouble(),
                      //                 min: 5,
                      //                 max: 60,
                      //                 divisions: 11,
                      //                 activeColor: Colors.indigo[400],
                      //                 onChanged: (val) {
                      //                   setState(() {
                      //                     autoSilentDuration = val.toInt();
                      //                     _hasChanges = true;
                      //                   });
                      //                 },
                      //               ),
                      //             ),
                      //           ],
                      //         ),
                      //       ),
                      //     ],
                      //   ],
                      // ),
                      //
                      // const SizedBox(height: 75),

                      // Test Button
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  isDark ? Colors.grey[800] : Colors.grey[200],
                              foregroundColor:
                                  isDark ? Colors.white : Colors.black87,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const NotificationTestView(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.build_circle_outlined),
                            label: Text(
                              'اختبار التنبيهات (للمطورين)',
                              style: GoogleFonts.cairo(
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),

                      // Diagnostic Button
                      // Padding(
                      //   padding: const EdgeInsets.only(bottom: 100),
                      //   child: SizedBox(
                      //     width: double.infinity,
                      //     child: ElevatedButton.icon(
                      //       style: ElevatedButton.styleFrom(
                      //         backgroundColor:
                      //             isDark ? Colors.teal[900] : Colors.teal[50],
                      //         foregroundColor:
                      //             isDark ? Colors.tealAccent : Colors.teal[800],
                      //         padding: const EdgeInsets.symmetric(vertical: 12),
                      //         shape: RoundedRectangleBorder(
                      //           borderRadius: BorderRadius.circular(12),
                      //         ),
                      //         elevation: 0,
                      //       ),
                      //       onPressed: () {
                      //         Navigator.push(
                      //           context,
                      //           MaterialPageRoute(
                      //             builder: (context) =>
                      //                 const AdhanDiagnosticScreen(),
                      //           ),
                      //         );
                      //       },
                      //       icon: const Icon(Icons.medical_services_outlined),
                      //       label: Text(
                      //         'تشخيص مشاكل الأذان',
                      //         style: GoogleFonts.cairo(
                      //             fontWeight: FontWeight.bold),
                      //       ),
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: AnimatedOpacity(
          opacity: _hasChanges ? 1.0 : 0.5,
          duration: const Duration(milliseconds: 300),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            width: double.infinity,
            height: 56,
            child: FloatingActionButton.extended(
              onPressed: (_hasChanges && !_isLoading) ? _saveAll : null,
              // backgroundColor: const Color(0xFFD4AF37),
              backgroundColor: KColors.primaryColor,
              elevation: (_hasChanges && !_isLoading) ? 8 : 0,
              label: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      'حفظ التغييرات',
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
              icon: _isLoading
                  ? null
                  : const Icon(Icons.save_rounded, color: Colors.white),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
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

  Widget _buildSwitchTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return SwitchListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      secondary: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: iconColor, size: 22),
      ),
      title: Text(
        title,
        style: GoogleFonts.cairo(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.cairo(
          fontSize: 11,
          color: Colors.grey,
        ),
      ),
      value: value,
      activeColor: const Color(0xFFD4AF37),
      onChanged: onChanged,
    );
  }

  Widget _buildListTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: iconColor, size: 22),
      ),
      title: Text(
        title,
        style: GoogleFonts.cairo(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.cairo(
          fontSize: 11,
          color: Colors.grey,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios_rounded,
          size: 14, color: Colors.grey),
      onTap: onTap,
    );
  }

  Widget _buildFrequencyChip(int minutes) {
    bool isSelected = salatFrequency == minutes;
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(left: 10.0),
      child: InkWell(
        onTap: () {
          setState(() {
            salatFrequency = minutes;
            _hasChanges = true;
          });
        },
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 75,
          decoration: BoxDecoration(
            gradient: isSelected
                ?  LinearGradient(
                    colors: [KColors.primary2Color, KColors.primary2Color],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: isSelected
                ? null
                : (isDark ? const Color(0xFF1E293B) : Colors.white),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? Colors.transparent
                  : (isDark ? Colors.white12 : Colors.grey.shade200),
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color:  KColors.primary2Color.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.1 : 0.03),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$minutes',
                style: GoogleFonts.cairo(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  height: 1.0,
                  color: isSelected
                      ? Colors.white
                      : (isDark ? Colors.white : Colors.black87),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'دقيقة',
                style: GoogleFonts.cairo(
                  fontSize: 10,
                  height: 1.0,
                  color: isSelected
                      ? Colors.white.withOpacity(0.9)
                      : (isDark ? Colors.grey : Colors.grey.shade600),
                ),
              ),
            ],
          ),
        ),
      ),
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
}
