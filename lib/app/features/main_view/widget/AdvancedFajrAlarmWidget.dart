import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muslimdaily/app/core/services/settings_service.dart';
import 'package:muslimdaily/app/core/services/notification_manager.dart';
import 'package:muslimdaily/app/core/utils/style/k_color.dart';
import 'package:muslimdaily/app/core/utils/style/k_helper.dart';

class AdvancedFajrAlarmWidget extends StatefulWidget {
  const AdvancedFajrAlarmWidget({super.key});

  @override
  State<AdvancedFajrAlarmWidget> createState() => _AdvancedFajrAlarmWidgetState();
}

class _AdvancedFajrAlarmWidgetState extends State<AdvancedFajrAlarmWidget> {
  final SettingsService _settingsService = SettingsService();
  bool _isEnabled = false;
  bool _isExpanded = false;
  TimeOfDay _time = const TimeOfDay(hour: 4, minute: 0);
  List<int> _selectedDays = [1, 2, 3, 4, 5, 6, 7];
  int _repetitions = 1;

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
        _timeLeft = "${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
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
    });
    _updateCountdown();
  }

  bool _isCheckingPermissions = false;

  Future<void> _applySettings() async {
    setState(() => _isCheckingPermissions = true);
    
    // Request permission once
    await NotificationManager().checkAndRequestExactAlarmPermission();
    
    await _settingsService.setFajrAlarmEnabled(_isEnabled);
    await _settingsService.setFajrAlarmHour(_time.hour);
    await _settingsService.setFajrAlarmMinute(_time.minute);
    await _settingsService.setFajrAlarmDays(_selectedDays);
    await _settingsService.setFajrAlarmRepetitions(_repetitions);

    // Update notifications
    await NotificationManager().scheduleAdvancedFajrAlarm();
    
    _updateCountdown();

    if (mounted) {
      KHelper.showSuccess(message: "تم حفظ الإعدادات بنجاح ✨");
    }
    
    // Request battery optimization ignore for reliability
    if (_isEnabled && Platform.isAndroid) {
       await NotificationManager().requestIgnoreBatteryOptimizations();
    }
    
    setState(() => _isCheckingPermissions = false);
  }

  String _getDayName(int day) {
    switch (day) {
      case 1: return "إثنين";
      case 2: return "ثلاثاء";
      case 3: return "أربعاء";
      case 4: return "خميس";
      case 5: return "جمعة";
      case 6: return "سبت";
      case 7: return "أحد";
      default: return "";
    }
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
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: const Color(0xFFD4AF37),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
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

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: isDark
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF1a1a2e).withOpacity(0.95),
                  const Color(0xFF16213e).withOpacity(0.85),
                ],
              )
            : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.98),
                  const Color(0xFFFFF8E7).withOpacity(0.95),
                ],
              ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: _isEnabled 
              ? const Color(0xFFD4AF37).withOpacity(0.6) 
              : Colors.grey.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: _isEnabled 
                ? const Color(0xFFD4AF37).withOpacity(0.15) 
                : Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header (Clickable to expand)
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: BorderRadius.circular(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _isEnabled ? const Color(0xFFD4AF37).withOpacity(0.15) : Colors.grey.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _isEnabled ? Icons.alarm_on : Icons.alarm_off,
                        color: _isEnabled ? const Color(0xFFD4AF37) : Colors.grey,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "منبه الفجر الذكي",
                          style: GoogleFonts.cairo(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : const Color(0xFF2C3E50),
                          ),
                        ),
                        if (_isEnabled)
                          Text(
                            _isExpanded ? "مضبوط على ${_time.format(context)}" : "متبقي: $_timeLeft",
                            style: GoogleFonts.cairo(
                              fontSize: 12.sp,
                              color: const Color(0xFFD4AF37),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                Row(
                  children: [
                    if (_isCheckingPermissions)
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFD4AF37)),
                      )
                    else
                      Switch.adaptive(
                        value: _isEnabled,
                        activeColor: const Color(0xFFD4AF37),
                        onChanged: (value) {
                          setState(() {
                            _isEnabled = value;
                            if (value) _isExpanded = true;
                          });
                          _applySettings();
                        },
                      ),
                    Icon(
                      _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: _isExpanded ? Column(
               children: [
                  const SizedBox(height: 15),
                  
                  // Quote Box
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4AF37).withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.1)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.format_quote, color: Color(0xFFD4AF37), size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _currentQuote,
                            style: GoogleFonts.cairo(
                              fontSize: 11.sp,
                              fontStyle: FontStyle.italic,
                              color: isDark ? Colors.white70 : Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                  
                  // Countdown Display
                  if (_isEnabled)
                    Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.black26 : Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.timer, color: Color(0xFFD4AF37), size: 20),
                          const SizedBox(width: 10),
                          Text(
                            "متبقي على المنبه: ",
                            style: GoogleFonts.cairo(fontSize: 14.sp, color: isDark ? Colors.white60 : Colors.grey.shade700),
                          ),
                          Text(
                            _timeLeft,
                            style: GoogleFonts.blackOpsOne(
                              fontSize: 18.sp,
                              color: const Color(0xFFD4AF37),
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                  Divider(color: const Color(0xFFD4AF37).withOpacity(0.2)),
                  const SizedBox(height: 20),
                  
                  // Time & Repetitions
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: InkWell(
                          onTap: _pickTime,
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.3)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "وقت التنبيه",
                                  style: GoogleFonts.cairo(
                                    fontSize: 12.sp,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _time.format(context),
                                  style: GoogleFonts.cairo(
                                    fontSize: 26.sp,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFFD4AF37),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.3)),
                          ),
                          child: Column(
                            children: [
                              Text(
                                "التكرار",
                                style: GoogleFonts.cairo(
                                  fontSize: 12.sp,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      if (_repetitions > 1) setState(() => _repetitions--);
                                    },
                                    child: const Icon(Icons.remove_circle_outline, color: Colors.redAccent, size: 28),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    _repetitions.toString(),
                                    style: GoogleFonts.cairo(
                                      fontSize: 20.sp,
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? Colors.white : const Color(0xFF2C3E50),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  GestureDetector(
                                    onTap: () {
                                      if (_repetitions < 5) setState(() => _repetitions++);
                                    },
                                    child: const Icon(Icons.add_circle_outline, color: Colors.greenAccent, size: 28),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Days Selector
                  Text(
                    "أيام التكرار أسبوعياً",
                    style: GoogleFonts.cairo(
                      fontSize: 14.sp,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: [1, 2, 3, 4, 5, 6, 7].map((day) {
                        bool isSelected = _selectedDays.contains(day);
                        return Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: InkWell(
                            onTap: () => _toggleDay(day),
                            borderRadius: BorderRadius.circular(12),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected 
                                    ? const Color(0xFFD4AF37) 
                                    : (isDark ? Colors.white.withOpacity(0.08) : Colors.grey.shade200),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: isSelected ? [
                                  BoxShadow(
                                    color: const Color(0xFFD4AF37).withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  )
                                ] : null,
                              ),
                              child: Text(
                                _getDayName(day),
                                style: GoogleFonts.cairo(
                                  fontSize: 13.sp,
                                  color: isSelected ? Colors.white : (isDark ? Colors.white70 : const Color(0xFF2C3E50)),
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Save & Test Buttons
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: ElevatedButton(
                          onPressed: _applySettings,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFD4AF37),
                            foregroundColor: Colors.white,
                            elevation: 4,
                            shadowColor: const Color(0xFFD4AF37).withOpacity(0.4),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.check_circle_outline, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                "حفظ وتفعيل",
                                style: GoogleFonts.cairo(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 1,
                        child: OutlinedButton(
                          onPressed: () async {
                             await NotificationManager().scheduleInstantTestNotification();
                             KHelper.showSuccess(message: "تجربة الجرس (10 ثوانٍ)");
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.orangeAccent, width: 2),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: const Icon(Icons.flash_on, color: Colors.orangeAccent),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 1,
                        child: OutlinedButton(
                          onPressed: () async {
                             await NotificationManager().scheduleBasicSystemTest();
                             KHelper.showSuccess(message: "تجربة النظام (5 ثوانٍ)");
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.blueAccent, width: 2),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: const Icon(Icons.notifications_active, color: Colors.blueAccent),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 15),
                  Text(
                    "⚠️ إذا لم يعمل الجرس: تأكد من ضبط إعدادات البطارية على 'غير مقيد' (Unrestricted) وتفعيل 'التشغيل التلقائي' (Auto-start) في تطبيقك.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.cairo(
                      fontSize: 10.sp,
                      color: Colors.redAccent.withOpacity(0.8),
                    ),
                  ),
               ],
            ) : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
