import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:muslimdaily/app/core/extensions/context_extension.dart';

import '../../../core/utils/style/app_theme_colors.dart';
import '../../charity/CharityDashboardScreen.dart';
import '../../charity/models/charity_models.dart';
import '../../charity/services/charity_service.dart';

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
    _updateStats();
    // Listen for changes in the charity box
    _charityService.donationsListenable.addListener(_updateStats);
    // Listen for changes in the recurring charity box
    _charityService.recurringListenable.addListener(_updateStats);
  }

  void _updateStats() {
    if (mounted) {
      setState(() {
        _stats = _charityService.calculateStats();
        _hasDueReminder = _charityService.getDueRecurringCharities().isNotEmpty;
      });
    }
  }

  @override
  void dispose() {
    _charityService.donationsListenable.removeListener(_updateStats);
    _charityService.recurringListenable.removeListener(_updateStats);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppThemeColors.cardBackgroundColor(context),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: AppThemeColors.cardBorderColor(context),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.r),
        child: Stack(
          children: [
            // Subtle Pattern Background
            Positioned.fill(
              child: Opacity(
                opacity: isDark ? 0.05 : 0.08,
                child: Image.asset(
                  'assets/images/8180jjj00005.webp',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            
            Padding(
              padding: EdgeInsets.all(18.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CharityDashboardScreen()),
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            // Container(
                            //   padding: EdgeInsets.all(8.w),
                            //   decoration: BoxDecoration(
                            //     color: const Color(0xFF10B981).withOpacity(0.1),
                            //     shape: BoxShape.circle,
                            //   ),
                            //   child: Text('🤲', style: TextStyle(fontSize: 24.sp)),
                            // ),
                            // SizedBox(width: 12.w),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'مُتتبع الصدقة',
                                     style: TextStyle(
                          fontFamily: "cairo",
                                    fontSize:context.isTab ? 10.sp : 16.sp,
                                    fontWeight: FontWeight.bold,
                                    color: AppThemeColors.cardHeaderColor(context),
                                  ),
                                ),
                                if (_stats != null && _stats!.currentStreak > 0)
                                  Row(
                                    children: [
                                      Text(
                                        'نبتة الخير: ',
                                           style: TextStyle(
                          fontFamily: "cairo",
                                          fontSize: 10.sp,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      Text(
                                        _getStreakSprout(_stats!.currentStreak),
                                        style: TextStyle(fontSize: 12.sp),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ],
                        ),
                        Icon(
                          Icons.arrow_forward_ios, 
                          color: const Color(0xFFD4AF37), 
                          size: 14.sp
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: 16.h),
                  
                  // Main Content Area
                  Row(
                    children: [
                      // Total Month Stat
                      Expanded(
                        child: _buildStatItemLarge(
                          isDark,
                          '${_stats?.totalThisMonth.toStringAsFixed(0) ?? '0'}',
                          'صدقة الشهر',
                          const Color(0xFF10B981),
                          'EGP',
                        ),
                      ),
                      
                      SizedBox(width: 12.w),
                      
                      // Streak Stat
                      Expanded(
                        child: _buildStatItemLarge(
                          isDark,
                          '${_stats?.currentStreak ?? 0}',
                          'أيام الالتزام',
                          const Color(0xFFF59E0B),
                          'يوم',
                        ),
                      ),
                    ],
                  ),
                  
                  if (_hasDueReminder) ...[
                    SizedBox(height: 16.h),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: Colors.orange.withOpacity(0.2)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.notifications_active, color: Colors.orange, size: 18.sp),
                          SizedBox(width: 8.w),
                          Text(
                            'لديك صدقة مستحقة اليوم! ✨',
                               style: TextStyle(
                          fontFamily: "cairo",
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.orange.shade300 : Colors.orange.shade800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getStreakSprout(int streak) {
    if (streak <= 1) return '🌱';
    if (streak <= 7) return '🌿';
    if (streak <= 30) return '🌳';
    return '🌳✨';
  }

  Widget _buildStatItemLarge(bool isDark, String value, String label, Color color, String unit) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      decoration: BoxDecoration(
        color: AppThemeColors.patternOpacity(context),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: color.withOpacity(0.12)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                   style: TextStyle(
                          fontFamily: "cairo",
                  fontSize:context.isTab?9.5.sp :22.sp,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              if (unit.isNotEmpty) ...[
                SizedBox(width: 4.w),
                Text(
                  unit,
                     style: TextStyle(
                          fontFamily: "cairo",
                    fontSize: context.isTab?8.sp :10.sp,
                    fontWeight: FontWeight.w600,
                    color: color.withOpacity(0.7),
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: 2.h),
          Text(
            label,
               style: TextStyle(
                          fontFamily: "cairo",
              fontSize:context.isTab?8.sp: 11.sp,
              fontWeight: FontWeight.w500,
              color: AppThemeColors.cardSubtitleColor(context),
            ),
          ),
        ],
      ),
    );
  }
}
