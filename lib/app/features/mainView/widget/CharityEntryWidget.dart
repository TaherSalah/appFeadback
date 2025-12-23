import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../charity/CharityDashboardScreen.dart';
import '../../charity/services/charity_service.dart';
import '../../charity/models/charity_models.dart';

class CharityEntryWidget extends StatefulWidget {
  const CharityEntryWidget({super.key});

  @override
  State<CharityEntryWidget> createState() => _CharityEntryWidgetState();
}

class _CharityEntryWidgetState extends State<CharityEntryWidget> {
  final CharityService _charityService = CharityService();
  CharityStats? _stats;
  bool _hasDueReminder = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _charityService.init();
    if (mounted) {
      setState(() {
        _stats = _charityService.calculateStats();
        _hasDueReminder = _charityService.getDueRecurringCharities().isNotEmpty;
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CharityDashboardScreen()),
        );
      },
      borderRadius: BorderRadius.circular(20.r),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF10B981), Color(0xFF059669)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF10B981).withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 5),
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
                    Text('🤲', style: TextStyle(fontSize: 32.sp)),
                    SizedBox(width: 12.w),
                    Text(
                      'مُساعد الصدقة',
                      style: GoogleFonts.cairo(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16.sp),
              ],
            ),
            SizedBox(height: 16.h),
            if (_stats != null) ...[
              Row(
                children: [
                  Expanded(
                    child: _buildStatItem(
                      '${_stats!.totalThisMonth.toStringAsFixed(0)}',
                      'صدقة هذا الشهر',
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _buildStatItem(
                      '${_stats!.currentStreak}',
                      'سلسلة الأيام 🔥',
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              // Removed _suggestion related UI
              SizedBox(height: 12.h),
              // Removed _buildGoalProgress()
              SizedBox(height: 12.h),
              if (_hasDueReminder)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade400,
                    borderRadius: BorderRadius.circular(10.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.notifications_active, color: Colors.white, size: 16.sp),
                      SizedBox(width: 8.w),
                      Text(
                        'لديك صدقة مستحقة اليوم! ✨',
                        style: GoogleFonts.cairo(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            value,
            style: GoogleFonts.cairo(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 11.sp,
              color: Colors.white.withOpacity(0.9),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
