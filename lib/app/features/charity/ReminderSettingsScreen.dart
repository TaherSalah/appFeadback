import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/widgets/KLoading.dart';
import 'services/charity_service.dart';

class ReminderSettingsScreen extends StatefulWidget {
  const ReminderSettingsScreen({super.key});

  @override
  State<ReminderSettingsScreen> createState() => _ReminderSettingsScreenState();
}

class _ReminderSettingsScreenState extends State<ReminderSettingsScreen> {
  final _charityService = CharityService();
  bool _dailyEnabled = true;
  TimeOfDay _dailyTime = const TimeOfDay(hour: 9, minute: 0);
  bool _weeklyEnabled = false;
  int _weeklyDay = 5; // Friday
  TimeOfDay _weeklyTime = const TimeOfDay(hour: 10, minute: 0);
  bool _goalReminderEnabled = true;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() => _loading = true);
    await _charityService.init();

    // Load from SharedPreferences via service (will implement these methods)
    final settings = await _charityService.getReminderSettings();
    setState(() {
      _dailyEnabled = settings['dailyEnabled'] ?? true;
      _dailyTime = TimeOfDay(
        hour: settings['dailyHour'] ?? 9,
        minute: settings['dailyMinute'] ?? 0,
      );
      _weeklyEnabled = settings['weeklyEnabled'] ?? false;
      _weeklyDay = settings['weeklyDay'] ?? 5;
      _weeklyTime = TimeOfDay(
        hour: settings['weeklyHour'] ?? 10,
        minute: settings['weeklyMinute'] ?? 0,
      );
      _goalReminderEnabled = settings['goalReminderEnabled'] ?? true;
      _loading = false;
    });
  }

  Future<void> _saveSettings() async {
    await _charityService.saveReminderSettings({
      'dailyEnabled': _dailyEnabled,
      'dailyHour': _dailyTime.hour,
      'dailyMinute': _dailyTime.minute,
      'weeklyEnabled': _weeklyEnabled,
      'weeklyDay': _weeklyDay,
      'weeklyHour': _weeklyTime.hour,
      'weeklyMinute': _weeklyTime.minute,
      'goalReminderEnabled': _goalReminderEnabled,
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم حفظ إعدادات التذكير بنجاح 🔔'),
          backgroundColor: Color(0xFF10B981),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        // backgroundColor:
        //     isDark ? const Color(0xFF1A1F36) : const Color(0xFFF5F7FA),
        // appBar: AppBar(
        //   title: Text(
        //     'إعدادات التذكير 🔔',
        //     style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        //   ),
        //   centerTitle: true,
        //   elevation: 0,
        //   backgroundColor: Colors.transparent,
        // ),
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(
              MediaQuery.sizeOf(context).width > 600 ? 70 : 50),
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
              'إعدادات التذكير ',
              style: GoogleFonts.cairo(
                color: Colors.green,
                fontWeight: FontWeight.bold,
                fontSize:
                MediaQuery.sizeOf(context).width > 600 ? 12.sp : 18.sp,
              ),
            ),
          ),
        ),

        body: _loading
            ?  Center(child:  KLoading.progressIOSIndicator(context: context))
            : ListView(
                padding: EdgeInsets.all(16.w),
                children: [
                  _buildSectionTitle('التذكير اليومي'),
                  _buildSwitchTile(
                    'تفعيل التذكير اليومي',
                    'تذكير لطيف كل يوم لإخراج صدقة',
                    _dailyEnabled,
                    (v) => setState(() => _dailyEnabled = v),
                    isDark,
                  ),
                  if (_dailyEnabled)
                    _buildTimeTile(
                      'وقت التذكير',
                      _dailyTime,
                      () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: _dailyTime,
                        );
                        if (time != null) setState(() => _dailyTime = time);
                      },
                      isDark,
                    ),
                  SizedBox(height: 24.h),
                  _buildSectionTitle('التذكير الأسبوعي'),
                  _buildSwitchTile(
                    'تفعيل التذكير الأسبوعي',
                    'تذكير مخصص مرة في الأسبوع',
                    _weeklyEnabled,
                    (v) => setState(() => _weeklyEnabled = v),
                    isDark,
                  ),
                  if (_weeklyEnabled) ...[
                    _buildDaySelector(isDark),
                    _buildTimeTile(
                      'وقت التذكير',
                      _weeklyTime,
                      () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: _weeklyTime,
                        );
                        if (time != null) setState(() => _weeklyTime = time);
                      },
                      isDark,
                    ),
                  ],
                  SizedBox(height: 24.h),
                  _buildSectionTitle('أهداف الصدقة'),
                  _buildSwitchTile(
                    'تذكيرات التقدم نحو الهدف',
                    'تنبيهك عند الاقتراب من تحقيق هدفك الشهري',
                    _goalReminderEnabled,
                    (v) => setState(() => _goalReminderEnabled = v),
                    isDark,
                  ),
                  SizedBox(height: 40.h),
                  SizedBox(
                    width: double.infinity,
                    height: 56.h,
                    child: ElevatedButton(
                      onPressed: _saveSettings,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'حفظ الإعدادات',
                        style: GoogleFonts.cairo(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h, right: 8.w),
      child: Text(
        title,
        style: GoogleFonts.cairo(
          fontSize: 16.sp,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF10B981),
        ),
      ),
    );
  }

  Widget _buildSwitchTile(String title, String subtitle, bool value,
      Function(bool) onChanged, bool isDark) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2D3748) : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: SwitchListTile(
        title: Text(title,
            style: GoogleFonts.cairo(
                fontWeight: FontWeight.bold, fontSize: 14.sp)),
        subtitle: Text(subtitle,
            style: GoogleFonts.cairo(fontSize: 11.sp, color: Colors.grey)),
        value: value,
        onChanged: onChanged,
        activeColor: const Color(0xFF10B981),
      ),
    );
  }

  Widget _buildTimeTile(
      String title, TimeOfDay time, VoidCallback onTap, bool isDark) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2D3748) : Colors.white,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: GoogleFonts.cairo(fontWeight: FontWeight.w600)),
            Text(
              '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF10B981),
                fontSize: 18.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDaySelector(bool isDark) {
    final days = [
      'السبت',
      'الأحد',
      'الاثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة'
    ];
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2D3748) : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('يوم التذكير',
              style: GoogleFonts.cairo(
                  fontWeight: FontWeight.w600, fontSize: 13.sp)),
          SizedBox(height: 8.h),
          Wrap(
            spacing: 6.w,
            children: List.generate(7, (index) {
              final isSelected = _weeklyDay ==
                  (index + 6) % 7 +
                      1; // Map Saturday index 0 to 6, etc. Actually simpler:
              // Let's use 1=Mon, 2=Tue, ..., 7=Sun (ISO standard)
              final isoDay = (index + 5) % 7 + 1; // SAT=6, SUN=7, MON=1...
              final currentIsSelected = _weeklyDay == isoDay;

              return ChoiceChip(
                label: Text(days[index],
                    style: GoogleFonts.cairo(fontSize: 10.sp)),
                selected: currentIsSelected,
                onSelected: (selected) {
                  if (selected) setState(() => _weeklyDay = isoDay);
                },
                selectedColor: const Color(0xFF10B981),
                labelStyle:
                    TextStyle(color: currentIsSelected ? Colors.white : null),
              );
            }),
          ),
        ],
      ),
    );
  }
}
