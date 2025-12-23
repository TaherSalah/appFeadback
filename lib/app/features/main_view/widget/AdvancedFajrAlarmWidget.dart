import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muslimdaily/app/core/services/settings_service.dart';
import 'package:muslimdaily/app/core/services/notification_manager.dart';
import 'package:muslimdaily/app/core/utils/style/k_helper.dart';
import 'package:muslimdaily/app/features/azanView/adhan_workmanager_service.dart';

class AdvancedFajrAlarmWidget extends StatefulWidget {
  const AdvancedFajrAlarmWidget({super.key});

  @override
  State<AdvancedFajrAlarmWidget> createState() =>
      _AdvancedFajrAlarmWidgetState();
}

class _AdvancedFajrAlarmWidgetState extends State<AdvancedFajrAlarmWidget> {
  final SettingsService _settingsService = SettingsService();
  bool _isEnabled = false;
  TimeOfDay _time = const TimeOfDay(hour: 4, minute: 0);
  List<int> _selectedDays = [1, 2, 3, 4, 5, 6, 7];
  int _repetitions = 1;
  bool _vibrate = true;
  bool _fadeIn = false;
  String? _currentFajrTime;

  Timer? _countdownTimer;
  String _timeLeft = "";

  // Motivational Quotes
  final List<String> _fajrQuotes = [
    "صلاة الفجر تجعل الإنسان في ذمة الله طوال اليوم.",
    "ركعتا الفجر خير من الدنيا وما فيها.",
    "بشر المشائين في الظلم إلى المساجد بالنور التام يوم القيامة.",
    "من صلى الفجر في جماعة فكأنما قام الليل كله.",
    "الفجر وقت توزيع الأرزاق، فلا تكن نائماً.",
    "نور الفجر يمحو ظلام القلوب والهموم.",
  ];
  late String _currentQuote;

  @override
  void initState() {
    super.initState();
    _currentQuote = (_fajrQuotes..shuffle()).first;
    _loadSettings();
    _startCountdown();
    _loadCurrentFajrTime();
  }

  Future<void> _loadCurrentFajrTime() async {
    final nextPrayer = await AdhanWorkManagerService().getNextPrayer();
    if (nextPrayer != null && nextPrayer['name'] == 'الفجر') {
      setState(() {
        _currentFajrTime = nextPrayer['formattedTime'];
      });
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isEnabled) {
        _updateCountdown();
      }
    });
  }

  void _updateCountdown() {
    final now = DateTime.now();
    DateTime? nextAlarm;

    // Find the next occurrence
    for (int i = 0; i < 8; i++) {
      final checkDate = now.add(Duration(days: i));
      int weekday = checkDate.weekday; // 1-7 (Mon-Sun)

      if (_selectedDays.contains(weekday)) {
        final alarmDate = DateTime(
          checkDate.year,
          checkDate.month,
          checkDate.day,
          _time.hour,
          _time.minute,
        );

        if (alarmDate.isAfter(now)) {
          nextAlarm = alarmDate;
          break;
        }
      }
    }

    if (nextAlarm != null) {
      final diff = nextAlarm.difference(now);
      final hours = diff.inHours;
      final minutes = diff.inMinutes % 60;
      final seconds = diff.inSeconds % 60;

      setState(() {
        _timeLeft =
            "${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
      });
    } else {
      setState(() {
        _timeLeft = "--:--:--";
      });
    }
  }

  Future<void> _loadSettings() async {
    await _settingsService.init();
    setState(() {
      _isEnabled = _settingsService.isFajrAlarmEnabled;
      _time = TimeOfDay(
        hour: _settingsService.fajrAlarmHour,
        minute: _settingsService.fajrAlarmMinute,
      );
      _selectedDays = List<int>.from(_settingsService.fajrAlarmDays);
      _repetitions = _settingsService.fajrAlarmRepetitions;
      _vibrate = _settingsService.fajrAlarmVibrate;
      _fadeIn = _settingsService.fajrAlarmFadeIn;
    });
    _updateCountdown();
  }

  bool _isCheckingPermissions = false;

  Future<void> _applySettings() async {
    setState(() => _isCheckingPermissions = true);

    await NotificationManager().checkAndRequestExactAlarmPermission();

    await _settingsService.setFajrAlarmEnabled(_isEnabled);
    await _settingsService.setFajrAlarmHour(_time.hour);
    await _settingsService.setFajrAlarmMinute(_time.minute);
    await _settingsService.setFajrAlarmDays(_selectedDays);
    await _settingsService.setFajrAlarmRepetitions(_repetitions);
    await _settingsService.setFajrAlarmVibrate(_vibrate);
    await _settingsService.setFajrAlarmFadeIn(_fadeIn);

    await NotificationManager().scheduleAdvancedFajrAlarm();

    _updateCountdown();

    if (mounted) {
      KHelper.showSuccess(message: "تم حفظ الإعدادات بنجاح ✨");
    }

    setState(() => _isCheckingPermissions = false);
  }

  String _getDayName(int day) {
    switch (day) {
      case 1:
        return "إثنين";
      case 2:
        return "ثلاثاء";
      case 3:
        return "أربعاء";
      case 4:
        return "خميس";
      case 5:
        return "جمعة";
      case 6:
        return "سبت";
      case 7:
        return "أحد";
      default:
        return "";
    }
  }

  // Helper to convert English numbers to Arabic (Indian) numerals
  String _toArabicNums(String input) {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];

    for (int i = 0; i < english.length; i++) {
      input = input.replaceAll(english[i], arabic[i]);
    }
    return input;
  }

  // Format with Arabic AM/PM
  String _formatTime12h(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? "ص" : "م";
    return "${_toArabicNums(hour.toString())}:${_toArabicNums(minute)} $period";
  }

  void _toggleDay(int day) {
    setState(() {
      if (_selectedDays.contains(day)) {
        if (_selectedDays.length > 1) {
          _selectedDays.remove(day);
        } else {
          KHelper.showError(message: "يجب اختيار يوم واحد على الأقل");
        }
      } else {
        _selectedDays.add(day);
      }
    });
  }

  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _time,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: Color(0xFFD4AF37),
                onPrimary: Colors.white,
                onSurface: Colors.black,
              ),
            ),
            child: child!,
          ),
        );
      },
    );
    if (picked != null && picked != _time) {
      setState(() {
        _time = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final goldColor = const Color(0xFFD4AF37);
    final bgColor = isDark ? const Color(0xFF0F0F1E) : const Color(0xFFFAFAFA);
    final cardColor = isDark ? const Color(0xFF1A1A2E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF2C3E50);

    return Scaffold(
      backgroundColor: bgColor,
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Stack(
          children: [
            // Background Pattern
            Positioned.fill(
              child: Opacity(
                opacity: 0.03,
                child: Image.asset(
                  "assets/images/pattern.webp",
                  repeat: ImageRepeat.repeat,
                ),
              ),
            ),

            CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 250.h,
                  floating: false,
                  pinned: true,
                  backgroundColor: bgColor,
                  elevation: 0,
                  leading: IconButton(
                    icon: Icon(Icons.arrow_back_ios, color: textColor),
                    onPressed: () => Navigator.pop(context),
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: isDark
                              ? [
                                  const Color(0xFF1E1E2C),
                                  bgColor,
                                ]
                              : [
                                  goldColor.withOpacity(0.1),
                                  bgColor,
                                ],
                        ),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(height: 40.h),
                            // Time Display
                            GestureDetector(
                              onTap: _pickTime,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _formatTime12h(_time),
                                    style: GoogleFonts.barlow(
                                      fontSize: 64.sp,
                                      fontWeight: FontWeight.w500,
                                      color: goldColor,
                                      height: 1,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: goldColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.edit,
                                            color: goldColor, size: 14),
                                        const SizedBox(width: 6),
                                        Text(
                                          "اضغط لتعديل الوقت",
                                          style: GoogleFonts.cairo(
                                            fontSize: 12.sp,
                                            color: goldColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Countdown & Fajr Time Reference
                        if (_isEnabled || _currentFajrTime != null)
                          Container(
                            margin: const EdgeInsets.only(bottom: 24),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                  color: goldColor.withOpacity(0.2), width: 1),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                if (_isEnabled)
                                  Expanded(
                                    child: Column(
                                      children: [
                                        Text(
                                          "المتبقي",
                                          style: GoogleFonts.cairo(
                                            fontSize: 12.sp,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        Text(
                                          _toArabicNums(_timeLeft),
                                          style: GoogleFonts.barlow(
                                            fontSize: 20.sp,
                                            fontWeight: FontWeight.bold,
                                            color: goldColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                if (_isEnabled && _currentFajrTime != null)
                                  Container(
                                    width: 1,
                                    height: 40,
                                    color: Colors.grey.withOpacity(0.2),
                                  ),
                                if (_currentFajrTime != null)
                                  Expanded(
                                    child: Column(
                                      children: [
                                        Text(
                                          "أذان الفجر اليوم",
                                          style: GoogleFonts.cairo(
                                            fontSize: 12.sp,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        Text(
                                          _toArabicNums(_currentFajrTime!),
                                          style: GoogleFonts.barlow(
                                            fontSize: 20.sp,
                                            fontWeight: FontWeight.bold,
                                            color: isDark
                                                ? Colors.white
                                                : Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),

                        // Section Title
                        Text(
                          "أيام التنبيه",
                          style: GoogleFonts.cairo(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Days Selector (New Design)
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: List.generate(7, (index) {
                            int day = index + 1;
                            bool isSelected = _selectedDays.contains(day);
                            return InkWell(
                              onTap: () => _toggleDay(day),
                              borderRadius: BorderRadius.circular(12),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 10),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? goldColor
                                      : cardColor.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected
                                        ? goldColor
                                        : Colors.grey.withOpacity(0.3),
                                  ),
                                ),
                                child: Text(
                                  _getDayName(day),
                                  style: GoogleFonts.cairo(
                                    fontSize: 12.sp,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: isSelected
                                        ? Colors.white
                                        : textColor.withOpacity(0.7),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),

                        const SizedBox(height: 32),

                        // Settings List
                        Container(
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              _buildSettingsTile(
                                title: "تفعيل المنبه",
                                subtitle: "تشغيل أو إيقاف المنبه بالكامل",
                                icon: Icons.alarm,
                                dragging: Switch(
                                  value: _isEnabled,
                                  activeColor: goldColor,
                                  onChanged: (val) {
                                    setState(() => _isEnabled = val);
                                  },
                                ),
                                textColor: textColor,
                              ),
                              const Divider(height: 1, indent: 50),
                              _buildSettingsTile(
                                title: "اهتزاز الهاتف",
                                subtitle: "تفعيل الاهتزاز مع الصوت",
                                icon: Icons.vibration,
                                dragging: Switch(
                                  value: _vibrate,
                                  activeColor: goldColor,
                                  onChanged: (val) =>
                                      setState(() => _vibrate = val),
                                ),
                                textColor: textColor,
                              ),
                              const Divider(height: 1, indent: 50),
                              _buildSettingsTile(
                                title: "تدرج الصوت",
                                subtitle: "يبدأ الصوت منخفضاً ثم يرتفع",
                                icon: Icons.volume_up_rounded,
                                dragging: Switch(
                                  value: _fadeIn,
                                  activeColor: goldColor,
                                  onChanged: (val) =>
                                      setState(() => _fadeIn = val),
                                ),
                                textColor: textColor,
                              ),
                              const Divider(height: 1, indent: 50),
                              ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 4),
                                leading: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: goldColor.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(Icons.snooze,
                                      color: goldColor, size: 20),
                                ),
                                title: Text(
                                  "عدد التنبيهات (غفوة)",
                                  style: GoogleFonts.cairo(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                    color: textColor,
                                  ),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      onPressed: () => setState(() =>
                                          _repetitions = (_repetitions > 1)
                                              ? _repetitions - 1
                                              : 1),
                                      icon: Icon(Icons.remove_circle_outline,
                                          color: textColor.withOpacity(0.5)),
                                    ),
                                    Text(
                                      _toArabicNums(_repetitions.toString()),
                                      style: GoogleFonts.barlow(
                                        fontSize: 18.sp,
                                        fontWeight: FontWeight.bold,
                                        color: goldColor,
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () => setState(() =>
                                          _repetitions = (_repetitions < 5)
                                              ? _repetitions + 1
                                              : 5),
                                      icon: Icon(Icons.add_circle_outline,
                                          color: textColor.withOpacity(0.5)),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Quote
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: goldColor.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color: goldColor.withOpacity(0.2), width: 1),
                          ),
                          child: Column(
                            children: [
                              Icon(Icons.format_quote,
                                  color: goldColor, size: 28),
                              const SizedBox(height: 8),
                              Text(
                                _currentQuote,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.amiri(
                                  fontSize: 16.sp,
                                  height: 1.8,
                                  color: textColor.withOpacity(0.9),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Save Button (Fixed at bottom)
            Positioned(
              bottom: 24,
              left: 20,
              right: 20,
              child: ElevatedButton(
                onPressed: _applySettings,
                style: ElevatedButton.styleFrom(
                  backgroundColor: goldColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 8,
                  shadowColor: goldColor.withOpacity(0.4),
                ),
                child: _isCheckingPermissions
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : Text(
                        "حفظ التغييرات",
                        style: GoogleFonts.cairo(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Widget dragging,
    required Color textColor,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFFD4AF37).withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: const Color(0xFFD4AF37), size: 20),
      ),
      title: Text(
        title,
        style: GoogleFonts.cairo(
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.cairo(
          fontSize: 11.sp,
          color: textColor.withOpacity(0.6),
        ),
      ),
      trailing: dragging,
    );
  }
}
