import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:animate_do/animate_do.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/utils/style/responsive_util.dart';

class KidsStatisticsScreen extends StatefulWidget {
  const KidsStatisticsScreen({super.key});

  @override
  State<KidsStatisticsScreen> createState() => _KidsStatisticsScreenState();
}

class _KidsStatisticsScreenState extends State<KidsStatisticsScreen> {
  int _totalStars = 0;
  int _currentStreak = 0;
  int _longestStreak = 0;
  int _completedStories = 0;
  int _completedGames = 0;
  int _completedTasks = 0;
  Map<String, int> _weeklyActivity = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final prefs = await SharedPreferences.getInstance();

    // Load basic stats
    final totalStars = prefs.getInt('kids_total_stars_v2') ?? 0;
    final completedStories = prefs.getInt('completed_stories') ?? 0;
    final completedGames = prefs.getInt('completed_games') ?? 0;
    final streakDays = prefs.getInt('streak_days') ?? 0;
    final longestStreak = prefs.getInt('longest_streak') ?? 0;

    // Load tasks completion count
    final savedTasks = prefs.getString('kids_tasks_v2');
    int completedTasksCount = 0;
    if (savedTasks != null) {
      final decoded = jsonDecode(savedTasks) as Map<String, dynamic>;
      completedTasksCount = decoded.values.where((v) => v == true).length;
    }

    // Load weekly activity
    final weeklyData = prefs.getString('kids_weekly_activity') ?? '{}';
    final weeklyMap = Map<String, int>.from(jsonDecode(weeklyData));

    // Calculate streak
    await _updateStreak();

    setState(() {
      _totalStars = totalStars;
      _currentStreak = prefs.getInt('streak_days') ?? 0;
      _longestStreak = longestStreak > streakDays ? longestStreak : streakDays;
      _completedStories = completedStories;
      _completedGames = completedGames;
      _completedTasks = completedTasksCount;
      _weeklyActivity = weeklyMap;
      _isLoading = false;
    });
  }

  Future<void> _updateStreak() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final lastActiveDate = prefs.getString('last_active_date') ?? '';

    if (lastActiveDate.isEmpty) {
      // First time
      await prefs.setString('last_active_date', today);
      await prefs.setInt('streak_days', 1);
      return;
    }

    final lastDate = DateTime.parse(lastActiveDate);
    final todayDate = DateTime.now();
    final difference = todayDate.difference(lastDate).inDays;

    if (difference == 0) {
      // Same day, no change needed
      return;
    } else if (difference == 1) {
      // Consecutive day - increase streak
      final currentStreak = prefs.getInt('streak_days') ?? 0;
      final newStreak = currentStreak + 1;
      await prefs.setInt('streak_days', newStreak);

      // Update longest streak
      final longestStreak = prefs.getInt('longest_streak') ?? 0;
      if (newStreak > longestStreak) {
        await prefs.setInt('longest_streak', newStreak);
      }
    } else {
      // Streak broken
      await prefs.setInt('streak_days', 1);
    }

    await prefs.setString('last_active_date', today);

    // Record today's activity
    final weeklyData = prefs.getString('kids_weekly_activity') ?? '{}';
    final weeklyMap = Map<String, int>.from(jsonDecode(weeklyData));
    weeklyMap[today] = (weeklyMap[today] ?? 0) + 1;
    await prefs.setString('kids_weekly_activity', jsonEncode(weeklyMap));
  }

  String _getRankTitle() {
    if (_totalStars < 200) return "مستكشف صغير 🥉";
    if (_totalStars < 600) return "بطل شجاع 🥈";
    if (_totalStars < 1200) return "قائد عظيم 🥇";
    return "أسطورة 👑";
  }

  Color _getRankColor() {
    if (_totalStars < 200) return const Color(0xFFCD7F32); // Bronze
    if (_totalStars < 600) return const Color(0xFFC0C0C0); // Silver
    if (_totalStars < 1200) return const Color(0xFFFFD700); // Gold
    return const Color(0xFFE5E4E2); // Platinum
  }

  List<Map<String, dynamic>> _getLast7DaysData() {
    final result = <Map<String, dynamic>>[];
    for (int i = 6; i >= 0; i--) {
      final date = DateTime.now().subtract(Duration(days: i));
      final key = DateFormat('yyyy-MM-dd').format(date);
      final dayName = DateFormat('E', 'ar').format(date);
      result.add({
        'date': dayName,
        'count': _weeklyActivity[key] ?? 0,
      });
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const primaryColor = Color(0xFF0EA5E9);

    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: primaryColor),
        ),
      );
    }

    final last7Days = _getLast7DaysData();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor:
            isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Header
            SliverAppBar(
              expandedHeight: 200.h,
              pinned: true,
              backgroundColor: primaryColor,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF0EA5E9), Color(0xFF6366F1)],
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        right: -30,
                        bottom: -20,
                        child: Icon(
                          Icons.bar_chart_rounded,
                          size: 200.sp,
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('📊', style: TextStyle(fontSize: 50.sp)),
                            SizedBox(height: 10.h),
                            Text(
                              'إحصائياتي',
                              style: GoogleFonts.cairo(
                                fontSize: 24.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'شاهد تقدمك الرائع!',
                              style: GoogleFonts.cairo(
                                fontSize: 14.sp,
                                color: Colors.white.withOpacity(0.9),
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

            SliverPadding(
              padding: EdgeInsets.all(20.w),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Main Stars Card
                  FadeInDown(child: _buildMainStarsCard(isDark, primaryColor)),
                  SizedBox(height: 20.h),

                  // Streak and Rank Row
                  FadeInUp(
                    child: Row(
                      children: [
                        Expanded(child: _buildStreakCard(isDark)),
                        SizedBox(width: 12.w),
                        Expanded(child: _buildRankCard(isDark)),
                      ],
                    ),
                  ),
                  SizedBox(height: 20.h),

                  // Stats Grid
                  FadeInUp(
                    delay: const Duration(milliseconds: 100),
                    child: _buildStatsGrid(isDark),
                  ),
                  SizedBox(height: 24.h),

                  // Weekly Activity Chart
                  FadeInUp(
                    delay: const Duration(milliseconds: 200),
                    child: _buildSectionHeader(
                        'نشاط آخر 7 أيام 📈', isDark, primaryColor),
                  ),
                  SizedBox(height: 12.h),
                  FadeInUp(
                    delay: const Duration(milliseconds: 250),
                    child: _buildWeeklyChart(last7Days, isDark, primaryColor),
                  ),
                  SizedBox(height: 24.h),

                  // Badges Section
                  FadeInUp(
                    delay: const Duration(milliseconds: 300),
                    child:
                        _buildSectionHeader('الأوسمة 🏅', isDark, primaryColor),
                  ),
                  SizedBox(height: 12.h),
                  FadeInUp(
                    delay: const Duration(milliseconds: 350),
                    child: _buildBadgesSection(isDark),
                  ),
                  SizedBox(height: 40.h),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainStarsCard(bool isDark, Color primaryColor) {
    final nextLevel = ((_totalStars / 200).floor() + 1) * 200;
    final progress = (_totalStars % 200) / 200;

    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
              : [const Color(0xFF0EA5E9), const Color(0xFF6366F1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28.r),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : primaryColor).withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.stars_rounded, color: Colors.amber, size: 40.sp),
              SizedBox(width: 12.w),
              Text(
                '$_totalStars',
                style: GoogleFonts.barlow(
                  fontSize: 50.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                'نجمة',
                style: GoogleFonts.cairo(
                  fontSize: 18.sp,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          // Progress to next level
          Stack(
            children: [
              Container(
                width: double.infinity,
                height: 12.h,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              FractionallySizedBox(
                widthFactor: progress,
                child: Container(
                  height: 12.h,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFF59E0B), Color(0xFFFBBF24)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            'بقي لك ${nextLevel - _totalStars} نجمة للمستوى التالي',
            style: GoogleFonts.cairo(
              fontSize: 12.sp,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakCard(bool isDark) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text('🔥', style: TextStyle(fontSize: 30.sp)),
          SizedBox(height: 8.h),
          Text(
            '$_currentStreak',
            style: GoogleFonts.barlow(
              fontSize: 28.sp,
              fontWeight: FontWeight.bold,
              color: Colors.orange,
            ),
          ),
          Text(
            'أيام متتالية',
            style: GoogleFonts.cairo(
              fontSize: 12.sp,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
          if (_longestStreak > _currentStreak) ...[
            SizedBox(height: 4.h),
            Text(
              'أعلى: $_longestStreak',
              style: GoogleFonts.cairo(
                fontSize: 10.sp,
                color: Colors.grey,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRankCard(bool isDark) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: _getRankColor(), width: 2),
        boxShadow: [
          BoxShadow(
            color: _getRankColor().withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            _getRankTitle().split(' ').last,
            style: TextStyle(fontSize: 30.sp),
          ),
          SizedBox(height: 8.h),
          Text(
            _getRankTitle().split(' ').first,
            style: GoogleFonts.cairo(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          Text(
            'الرتبة الحالية',
            style: GoogleFonts.cairo(
              fontSize: 11.sp,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(bool isDark) {
    final stats = [
      {'icon': '📖', 'label': 'قصص مقروءة', 'value': '$_completedStories'},
      {'icon': '🎮', 'label': 'ألعاب أكملت', 'value': '$_completedGames'},
      {'icon': '✅', 'label': 'مهام منجزة', 'value': '$_completedTasks'},
      {'icon': '⭐', 'label': 'إجمالي النجوم', 'value': '$_totalStars'},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 12.h,
        childAspectRatio: 1.5,
      ),
      itemCount: stats.length,
      itemBuilder: (context, index) {
        final stat = stats[index];
        return Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(stat['icon']!, style: TextStyle(fontSize: 24.sp)),
              SizedBox(height: 4.h),
              Text(
                stat['value']!,
                style: GoogleFonts.barlow(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              Text(
                stat['label']!,
                style: GoogleFonts.cairo(
                  fontSize: 11.sp,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title, bool isDark, Color primaryColor) {
    return Row(
      children: [
        Text(
          title,
          style: GoogleFonts.cairo(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildWeeklyChart(
      List<Map<String, dynamic>> data, bool isDark, Color primaryColor) {
    final maxCount = data
        .map((d) => d['count'] as int)
        .reduce((a, b) => a > b ? a : b)
        .toDouble();
    final yMax = maxCount < 5 ? 5.0 : maxCount + 2;

    return Container(
      height: 180.h,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: yMax,
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) =>
                  isDark ? Colors.grey[800]! : primaryColor.withOpacity(0.1),
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  '${rod.toY.toInt()} نشاط',
                  GoogleFonts.cairo(
                      color: primaryColor, fontWeight: FontWeight.bold),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= 0 && value.toInt() < data.length) {
                    return Padding(
                      padding: EdgeInsets.only(top: 8.h),
                      child: Text(
                        data[value.toInt()]['date'] as String,
                        style: GoogleFonts.cairo(
                            fontSize: 9.sp, color: Colors.grey),
                      ),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            leftTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: data.asMap().entries.map((entry) {
            return BarChartGroupData(
              x: entry.key,
              barRods: [
                BarChartRodData(
                  toY: (entry.value['count'] as int).toDouble(),
                  gradient: LinearGradient(
                    colors: [primaryColor, primaryColor.withOpacity(0.7)],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                  width: 16.w,
                  borderRadius: BorderRadius.circular(6),
                  backDrawRodData: BackgroundBarChartRodData(
                    show: true,
                    toY: yMax,
                    color: isDark
                        ? Colors.white.withOpacity(0.03)
                        : Colors.black.withOpacity(0.02),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildBadgesSection(bool isDark) {
    final allBadges = [
      {
        'id': 'first_star',
        'icon': '⭐',
        'title': 'أول نجمة',
        'desc': 'اجمع أول نجمة',
        'required': 1
      },
      {
        'id': 'starter',
        'icon': '🌱',
        'title': 'البداية',
        'desc': 'اجمع 50 نجمة',
        'required': 50
      },
      {
        'id': 'rising',
        'icon': '🚀',
        'title': 'صاعد',
        'desc': 'اجمع 150 نجمة',
        'required': 150
      },
      {
        'id': 'champion',
        'icon': '🏆',
        'title': 'بطل',
        'desc': 'اجمع 300 نجمة',
        'required': 300
      },
      {
        'id': 'master',
        'icon': '👑',
        'title': 'خبير',
        'desc': 'اجمع 500 نجمة',
        'required': 500
      },
      {
        'id': 'legend',
        'icon': '🌟',
        'title': 'أسطورة',
        'desc': 'اجمع 1000 نجمة',
        'required': 1000
      },
      {
        'id': 'streak_3',
        'icon': '🔥',
        'title': '3 أيام',
        'desc': 'سلسلة 3 أيام',
        'required_streak': 3
      },
      {
        'id': 'streak_7',
        'icon': '💎',
        'title': 'أسبوع',
        'desc': 'سلسلة 7 أيام',
        'required_streak': 7
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: ResponsiveUtil.isTablet(context) ? 4 : 4,
        crossAxisSpacing: 10.w,
        mainAxisSpacing: 10.h,
        childAspectRatio: 0.8,
      ),
      itemCount: allBadges.length,
      itemBuilder: (context, index) {
        final badge = allBadges[index];
        bool isUnlocked = false;

        if (badge.containsKey('required')) {
          isUnlocked = _totalStars >= (badge['required'] as int);
        } else if (badge.containsKey('required_streak')) {
          isUnlocked = _longestStreak >= (badge['required_streak'] as int);
        }

        return Container(
          decoration: BoxDecoration(
            color: isUnlocked
                ? (isDark
                    ? const Color(0xFF0EA5E9).withOpacity(0.1)
                    : const Color(0xFF0EA5E9).withOpacity(0.05))
                : (isDark
                    ? Colors.white.withOpacity(0.02)
                    : Colors.grey.withOpacity(0.03)),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: isUnlocked
                  ? const Color(0xFF0EA5E9).withOpacity(0.3)
                  : Colors.grey.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Opacity(
                opacity: isUnlocked ? 1.0 : 0.3,
                child: Text(badge['icon'] as String,
                    style: TextStyle(fontSize: 28.sp)),
              ),
              SizedBox(height: 4.h),
              Text(
                badge['title'] as String,
                style: GoogleFonts.cairo(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.bold,
                  color: isUnlocked
                      ? (isDark ? Colors.white : const Color(0xFF0EA5E9))
                      : Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              if (!isUnlocked)
                Icon(Icons.lock_outline_rounded,
                    size: 12.sp, color: Colors.grey.withOpacity(0.5)),
            ],
          ),
        );
      },
    );
  }
}
