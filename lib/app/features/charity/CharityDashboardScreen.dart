import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:muslimdaily/app/core/utils/style/k_helper.dart';
import '../../core/utils/style/k_color.dart';
import '../../core/utils/style/app_theme_colors.dart';
import '../../core/utils/style/responsive_util.dart';
import '../../core/widgets/kButtons.dart';
import 'models/charity_models.dart';
import 'services/charity_service.dart';
import 'AddCharityScreen.dart';
import 'CharityHistoryScreen.dart';
import 'CharityStoriesScreen.dart';
import 'CharityPlatformsScreen.dart';
import 'RecurringCharityScreen.dart';
import 'MonthlyGoalScreen.dart';
import 'ReminderSettingsScreen.dart';
import 'AchievementsScreen.dart';

class CharityDashboardScreen extends StatefulWidget {
  const CharityDashboardScreen({super.key});

  @override
  State<CharityDashboardScreen> createState() => _CharityDashboardScreenState();
}

class _CharityDashboardScreenState extends State<CharityDashboardScreen> {
  final CharityService _charityService = CharityService();
  CharityStats? _stats;
  CharitySuggestion? _suggestion;
  List<RecurringCharity> _dueRecurring = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    await _charityService.init();
    setState(() {
      _stats = _charityService.calculateStats();
      _suggestion = _charityService.getDailySuggestion();
      _dueRecurring = _charityService.getDueRecurringCharities();
      _loading = false;
    });
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
        //     'متتبع الصدقات 🤲',
        //     style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        //   ),
        //   centerTitle: true,
        //   elevation: 0,
        //   backgroundColor: Colors.transparent,
        //   actions: [
        //     IconButton(
        //       icon: const Icon(Icons.notifications_active_outlined),
        //       onPressed: () {
        //         Navigator.push(
        //           context,
        //           MaterialPageRoute(
        //               builder: (_) => const ReminderSettingsScreen()),
        //         ).then((_) => _loadData());
        //       },
        //       tooltip: 'إعدادات التذكير',
        //     ),
        //     SizedBox(width: 8.w),
        //     IconButton(
        //       icon: const Icon(Icons.emoji_events_outlined),
        //       onPressed: () {
        //         Navigator.push(
        //           context,
        //           MaterialPageRoute(builder: (_) => const AchievementsScreen()),
        //         );
        //       },
        //       tooltip: 'الإنجازات',
        //     ),
        //     IconButton(
        //       icon: const Icon(Icons.history),
        //       onPressed: () {
        //         Navigator.push(
        //           context,
        //           MaterialPageRoute(
        //             builder: (_) => const CharityHistoryScreen(),
        //           ),
        //         ).then((_) => _loadData());
        //       },
        //     ),
        //   ],
        // ),
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(
              MediaQuery.sizeOf(context).width > 600 ? 70 : 50),
          child: AppBar(
              actions: [
                IconButton(
                  icon: const Icon(Icons.notifications_active_outlined),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const ReminderSettingsScreen()),
                    ).then((_) => _loadData());
                  },
                  tooltip: 'إعدادات التذكير',
                ),
                SizedBox(width: 8.w),
                IconButton(
                  icon: const Icon(Icons.emoji_events_outlined),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AchievementsScreen()),
                    );
                  },
                  tooltip: 'الإنجازات',
                ),
                IconButton(
                  icon: const Icon(Icons.history),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CharityHistoryScreen(),
                      ),
                    ).then((_) => _loadData());
                  },
                ),
              ],
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
              'متتبع الصدقات',
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
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _loadData,
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
                    SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Padding(
                        padding: EdgeInsets.all(16.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // اقتراح الصدقة اليومية
                            // _buildDailySuggestionCard(isDark),
                            Row(
                              spacing: 15,
                              children: [
                                Expanded(
                                  child: _buildActionButton(
                                    Icons.repeat,
                                    'اضافة صدقات دورية',
                                    const Color(0xFF10B981),
                                        () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => const RecurringCharityScreen(),
                                        ),
                                      ).then((_) => _loadData());
                                    },
                                    isDark,
                                  ),
                                ),

                                Expanded(
                                  child: _buildActionButton(
                                    Icons.add,

                                    'اضافة صدقة حديدة',
                                    const Color(0xFF10B981),
                                        () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(builder: (_) => const AddCharityScreen()),
                                          ).then((_) => _loadData());
                                    },
                                    isDark,
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 20.h),

                            // صدقات مستحقة اليوم (الصدقات الدورية)
                            if (_dueRecurring.isNotEmpty) ...[
                              _buildDueRecurringSection(isDark),
                              SizedBox(height: 20.h),
                            ],
                            
                            // Quick Add Recommendation for Dashboard
                            _buildQuickAddRow(isDark),
                            SizedBox(height: 24.h),

                            // إحصائيات سريعة
                            _buildQuickStats(isDark),
                            SizedBox(height: 20.h),

                            // الهدف الشهري
                            _buildMonthlyGoalCard(isDark),
                            SizedBox(height: 20.h),

                            // Streak
                            _buildStreakCard(isDark),
                            SizedBox(height: 20.h),

                            // الرسم البياني
                            _buildChartCard(isDark),
                            SizedBox(height: 20.h),

                            // التوزيع حسب الفئات
                            _buildCategoryBreakdown(isDark),
                            SizedBox(height: 20.h),

                            // أزرار سريعة
                            // _buildQuickActions(isDark),
                            // SizedBox(height: 40.h),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
        // floatingActionButton: FloatingActionButton.extended(
        //   onPressed: () {
        //     Navigator.push(
        //       context,
        //       MaterialPageRoute(builder: (_) => const AddCharityScreen()),
        //     ).then((_) => _loadData());
        //   },
        //   icon: const Icon(Icons.add),
        //   label: Text(
        //     'إضافة صدقة',
        //     style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        //   ),
        //   backgroundColor: const Color(0xFF10B981),
        // ),
        floatingActionButton: FloatingActionButton.small(

          child: const Icon(Icons.add),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddCharityScreen()),
            ).then((_) => _loadData());
          },
          // icon: const Icon(Icons.add),
          // label: Text(
          //   'إضافة صدقة',
          //   style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
          // ),
          backgroundColor: const Color(0xFF10B981),
        ),
      ),
    );
  }

  Widget _buildDailySuggestionCard(bool isDark) {
    bool isTab = ResponsiveUtil.isTablet(context);

    return Container(
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
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  '✨',
                  style: TextStyle(fontSize: 24.sp),
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                'اقتراح الصدقة اليومية',
                style: GoogleFonts.cairo(
                  fontSize: isTab?10.sp:18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Text(
            '${_suggestion?.suggestedAmount.toStringAsFixed(0)} جنيه',
            style: GoogleFonts.cairo(
              fontSize: 32.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            _suggestion?.reason ?? '',
            style: GoogleFonts.cairo(
              fontSize: 13.sp,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Text(
              _suggestion?.motivation ?? '',
              style: GoogleFonts.cairo(
                fontSize: 13.sp,
                color: Colors.white,
                fontStyle: FontStyle.italic,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
          ),

        ],
      ),
    );
  }

  Widget _buildQuickStats(bool isDark) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            '📊',
            'الإجمالي الشهري',
            '${_stats?.totalThisMonth.toStringAsFixed(0) ?? '0'} جنيه',
            const Color(0xFF3B82F6),
            isDark,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _buildStatCard(
            '🎯',
            'عدد الصدقات',
            '${_stats?.donationsCount ?? 0}',
            const Color(0xFF8B5CF6),
            isDark,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String emoji, String label, String value, Color color, bool isDark) {
    bool isTab = ResponsiveUtil.isTablet(context);
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppThemeColors.cardBackgroundColor(context),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppThemeColors.cardBorderColor(context),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Text(emoji, style: TextStyle(fontSize: 28.sp)),
          // SizedBox(height: 8.h),
          Text(
            label,
            style: GoogleFonts.cairo(
              fontSize:isTab? 9.sp:12.sp,
              color: AppThemeColors.cardSubtitleColor(context),
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            style: GoogleFonts.cairo(
              fontSize:isTab? 9.sp:12.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAddRow(bool isDark) {
    bool isTab = ResponsiveUtil.isTablet(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'تسجيل سريع لصدقة اليوم:',
          style: GoogleFonts.cairo(
            fontSize: isTab?10.sp:14.sp,

            fontWeight: FontWeight.bold,
            color: AppThemeColors.cardHeaderColor(context),
          ),
        ),
        SizedBox(height: 12.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [5.0, 10.0, 20.0, 50.0, 100.0].map((amount) {
            return _buildDashboardQuickAddChip(amount, isDark);
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDashboardQuickAddChip(double amount, bool isDark) {
    bool isTab = ResponsiveUtil.isTablet(context);
    return InkWell(
      onTap: () async {
        final donation = CharityDonation.withCategory(
          id: _charityService.generateId(),
          amount: amount,
          category: CharityCategory.sadaqah,
          date: DateTime.now(),
          notes: 'تسجيل سريع من اللوحة الرئيسية',
          currency: 'EGP',

        );
        await _charityService.addDonation(donation);
        _loadData();
        if (mounted) {
          // ScaffoldMessenger.of(context).showSnackBar(
          //   SnackBar(
          //     content: Text('تم تسجيل صدقة بقيمة $amount جنيه ✨', style: GoogleFonts.cairo()),
          //     backgroundColor: const Color(0xFF10B981),
          //   ),
          // );
          KHelper.showSuccess(message: 'تم تسجيل صدقة بقيمة $amount جنيه ');
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2D3748) : Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: const Color(0xFF10B981).withOpacity(0.5),
            width: 1,
          ),
        ),
        child: Text(
          '+$amount',
          style: GoogleFonts.cairo(
            fontSize:isTab? 10.sp:16.sp,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF10B981),
          ),
        ),
      ),
    );
  }

  Widget _buildMonthlyGoalCard(bool isDark) {
    bool isTab = ResponsiveUtil.isTablet(context);
    final goal = _charityService.getMonthlyGoal();
    final progress =
        _charityService.getGoalProgress(_stats?.totalThisMonth ?? 0);

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const MonthlyGoalScreen()),
        ).then((_) => _loadData());
      },
      borderRadius: BorderRadius.circular(20.r),
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2D3748) : Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: const Color(0xFF10B981).withOpacity(0.2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text('🎯', style: TextStyle(fontSize: 24.sp)),
                    SizedBox(width: 12.w),
                    Text(
                      'الهدف الشهري',
                      style: GoogleFonts.cairo(
                        fontSize:isTab? 10.sp:16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Icon(Icons.chevron_right, color: Colors.grey, size: 24.sp),
              ],
            ),
            SizedBox(height: 20.h),
            if (goal == null)
              Center(
                child: Column(
                  children: [
                    Text(
                      'لم يتم تحديد هدف لهذا الشهر',
                      style: GoogleFonts.cairo(color: Colors.grey),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const MonthlyGoalScreen()),
                        ).then((_) => _loadData());
                      },
                      child: Text(
                        'اضبط هدفك الآن',
                        style: GoogleFonts.cairo(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF10B981),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${(_stats?.totalThisMonth ?? 0).toStringAsFixed(0)} جنيه',
                        style: GoogleFonts.cairo(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF10B981),
                        ),
                      ),
                      Text(
                        'من ${goal.amount.toStringAsFixed(0)} جنيه',
                        style: GoogleFonts.cairo(color: Colors.grey),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10.r),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.grey.withOpacity(0.1),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF10B981),
                      ),
                      minHeight: 12.h,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'لقد حققت ${(progress * 100).toStringAsFixed(0)}% من هدفك الشهري! ✨',
                    style: GoogleFonts.cairo(
                      fontSize: 12.sp,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStreakCard(bool isDark) {
    bool isTab = ResponsiveUtil.isTablet(context);
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange.shade400, Colors.deepOrange.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        children: [
          Text('🔥', style: TextStyle(fontSize: isTab?30.sp:40.sp)),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'سلسلة الصدقة المتواصلة',
                  style: GoogleFonts.cairo(
                    fontSize:isTab? 10.sp:14.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '${_stats?.currentStreak ?? 0} يوم متتالي',
                  style: GoogleFonts.cairo(
                    fontSize:isTab? 9.sp:14.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'أطول سلسلة: ${_stats?.longestStreak ?? 0} يوم',
                  style: GoogleFonts.cairo(
                    fontSize:isTab? 9.sp:14.sp,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartCard(bool isDark) {
    bool isTab = ResponsiveUtil.isTablet(context);
    if (_stats?.monthlyData == null || _stats!.monthlyData.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppThemeColors.cardBackgroundColor(context),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: AppThemeColors.cardBorderColor(context),
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
          Text(
            'الصدقات الشهرية',
            style: GoogleFonts.cairo(
              fontSize:isTab? 10.sp:18.sp,
              fontWeight: FontWeight.bold,
              color: AppThemeColors.cardHeaderColor(context),
            ),
          ),
          SizedBox(height: 10.h),
          SizedBox(
            height: 200.h,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: _stats!.monthlyData
                        .map((e) => e.value)
                        .reduce((a, b) => a > b ? a : b) *
                    1.2,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= 0 &&
                            value.toInt() < _stats!.monthlyData.length) {
                          return Text(
                            _stats!.monthlyData[value.toInt()].label,
                            style: GoogleFonts.cairo(fontSize:isTab? 6.5.sp:10.sp),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                gridData: const FlGridData(show: false),
                barGroups: _stats!.monthlyData.asMap().entries.map((entry) {
                  return BarChartGroupData(
                    x: entry.key,
                    barRods: [
                      BarChartRodData(
                        toY: entry.value.value,
                        color: const Color(0xFF10B981),
                        width: 20.w,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBreakdown(bool isDark) {
    bool isTab = ResponsiveUtil.isTablet(context);
    if (_stats?.categoryBreakdown == null ||
        _stats!.categoryBreakdown.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppThemeColors.cardBackgroundColor(context),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: AppThemeColors.cardBorderColor(context),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'التوزيع حسب الفئات',
            style: GoogleFonts.cairo(
              fontSize:isTab? 10.sp:18.sp,
              fontWeight: FontWeight.bold,
              color: AppThemeColors.cardHeaderColor(context),
            ),
          ),
          SizedBox(height: 16.h),
          ..._stats!.categoryBreakdown.entries.map((entry) {
            final percentage = (_stats!.totalAllTime > 0
                ? (entry.value / _stats!.totalAllTime) * 100
                : 0);
            return Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          // Text(entry.key.emoji,
                          //     style: TextStyle(fontSize: 20.sp)),
                          // SizedBox(width: 8.w),
                          Text(
                            entry.key.arabicName,
                            style: GoogleFonts.cairo(
                              fontSize:isTab? 9.sp:14.sp,
                              color: AppThemeColors.cardHeaderColor(context),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '${entry.value.toStringAsFixed(0)} جنيه',
                        style: GoogleFonts.cairo(
                          fontSize:isTab? 9.sp:14.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  LinearProgressIndicator(
                    value: percentage / 100,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF10B981),
                    ),
                    minHeight: 8.h,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildQuickActions(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'روابط سريعة',
          style: GoogleFonts.cairo(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            // Expanded(
            //   child: _buildActionButton(
            //     '📖',
            //     'قصص ملهمة',
            //     const Color(0xFF8B5CF6),
            //     () {
            //       Navigator.push(
            //         context,
            //         MaterialPageRoute(
            //           builder: (_) => const CharityStoriesScreen(),
            //         ),
            //       );
            //     },
            //     isDark,
            //   ),
            // ),
            // SizedBox(width: 12.w),
            Expanded(
              child: _buildActionButton(
                Icons.add_ic_call,
                'صدقات دورية',
                const Color(0xFF10B981),
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const RecurringCharityScreen(),
                    ),
                  ).then((_) => _loadData());
                },
                isDark,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDueRecurringSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.notification_important_rounded,
                color: Colors.orange, size: 24.sp),
            SizedBox(width: 8.w),
            Text(
              'صدقات مستحقة اليوم',
              style: GoogleFonts.cairo(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        ..._dueRecurring
            .map((item) => Container(
                  margin: EdgeInsets.only(bottom: 12.h),
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: AppThemeColors.cardBackgroundColor(context),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: Colors.orange.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Text(item.category.emoji,
                          style: TextStyle(fontSize: 24.sp)),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: GoogleFonts.cairo(
                                  fontWeight: FontWeight.bold, fontSize: 15.sp),
                            ),
                            Text(
                              'المقدار المستحق: ${item.amount} ${item.currency}',
                              style: GoogleFonts.cairo(
                                  fontSize: 13.sp, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          await _charityService.confirmRecurringDonation(item);
                          _loadData();
                          if (mounted) {
                            // ScaffoldMessenger.of(context).showSnackBar(
                            //   SnackBar(
                            //     content: Text(
                            //         'تقبل الله منك! تم تسجيل الصدقة ✅',
                            //         style: GoogleFonts.cairo()),
                            //     backgroundColor: const Color(0xFF10B981),
                            //   ),
                            // );
                            KHelper.showSuccess(message: 'تقبل الله منك! تم تسجيل الصدقة',);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          padding: EdgeInsets.symmetric(horizontal: 12.w),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.r)),
                        ),
                        child: Text('تبرعت ',
                            style: GoogleFonts.cairo(
                                color: Colors.white, fontSize: 12.sp)),
                      ),
                    ],
                  ),
                ))
            .toList(),
      ],
    );
  }

  Widget _buildActionButton(IconData? icon, String label, Color color,
      VoidCallback onTap, bool isDark) {
    bool isTab = ResponsiveUtil.isTablet(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppThemeColors.cardBackgroundColor(context),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon,size: isTab?45:35,),
            SizedBox(height: 8.h),
            Text(
              label,
              style: GoogleFonts.cairo(
                fontSize: isTab?10.sp :14.sp,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
