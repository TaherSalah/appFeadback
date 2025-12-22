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
  TimeOfDay _time = const TimeOfDay(hour: 4, minute: 0);
  List<int> _selectedDays = [1, 2, 3, 4, 5, 6, 7];
  int _repetitions = 1;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    await _settingsService.init();
    setState(() {
      _isEnabled = _settingsService.isFajrAlarmEnabled;
      _time = TimeOfDay(
        hour: _settingsService.fajrAlarmHour,
        minute: _settingsService.fajrAlarmMinute,
      );
      _selectedDays = _settingsService.fajrAlarmDays;
      _repetitions = _settingsService.fajrAlarmRepetitions;
    });
  }

  Future<void> _saveSettings() async {
    await _settingsService.setFajrAlarmEnabled(_isEnabled);
    await _settingsService.setFajrAlarmHour(_time.hour);
    await _settingsService.setFajrAlarmMinute(_time.minute);
    await _settingsService.setFajrAlarmDays(_selectedDays);
    await _settingsService.setFajrAlarmRepetitions(_repetitions);

    // Update notifications
    await NotificationManager().scheduleAdvancedFajrAlarm();
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
    _saveSettings();
  }

  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _time,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: KColors.primaryColor,
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
      _saveSettings();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _isEnabled ? KColors.primaryColor.withOpacity(0.5) : Colors.grey.withOpacity(0.2),
          width: 1.5,
        ),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _isEnabled ? KColors.primaryColor.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.alarm,
                      color: _isEnabled ? KColors.primaryColor : Colors.grey,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    "منبه الفجر المتقدم",
                    style: GoogleFonts.cairo(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
              Switch.adaptive(
                value: _isEnabled,
                activeColor: KColors.primaryColor,
                onChanged: (value) {
                  setState(() {
                    _isEnabled = value;
                  });
                  _saveSettings();
                },
              ),
            ],
          ),
          if (_isEnabled) ...[
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "وقت التنبيه",
                      style: GoogleFonts.cairo(
                        fontSize: 14.sp,
                        color: Colors.grey,
                      ),
                    ),
                    InkWell(
                      onTap: _pickTime,
                      child: Text(
                        _time.format(context),
                        style: GoogleFonts.cairo(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                          color: KColors.primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "مرات التكرار",
                      style: GoogleFonts.cairo(
                        fontSize: 14.sp,
                        color: Colors.grey,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            if (_repetitions > 1) {
                              setState(() => _repetitions--);
                              _saveSettings();
                            }
                          },
                          icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                        ),
                        Text(
                          _repetitions.toString(),
                          style: GoogleFonts.cairo(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            if (_repetitions < 5) {
                              setState(() => _repetitions++);
                              _saveSettings();
                            }
                          },
                          icon: const Icon(Icons.add_circle_outline, color: Colors.green),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              "أيام التكرار",
              style: GoogleFonts.cairo(
                fontSize: 14.sp,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [1, 2, 3, 4, 5, 6, 7].map((day) {
                  bool isSelected = _selectedDays.contains(day);
                  return Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: FilterChip(
                      label: Text(_getDayName(day)),
                      selected: isSelected,
                      onSelected: (_) => _toggleDay(day),
                      selectedColor: KColors.primaryColor.withOpacity(0.2),
                      checkmarkColor: KColors.primaryColor,
                      labelStyle: GoogleFonts.cairo(
                        fontSize: 12.sp,
                        color: isSelected ? KColors.primaryColor : (isDark ? Colors.white70 : Colors.black87),
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
