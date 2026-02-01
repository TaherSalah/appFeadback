import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart' as intl;
import 'package:muslimdaily/app/core/utils/style/responsive_util.dart';
import '../../core/shard/exports/all_exports.dart';
import '../messaView/azkar_massa.dart';
import 'data/UserStats.dart';

class StatisticsScreen extends StatefulWidget {
  final UserStats stats;

  const StatisticsScreen({super.key, required this.stats});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  UserStats stats = UserStats();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    stats = await UserStats.loadFromPrefs();
    setState(() => isLoading = false);
  }

  Future<void> _refreshStats() async {
    await _loadStats();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? Colors.tealAccent : const Color(0xFF00897B);

    final last7Days = List.generate(7, (i) {
      final date = DateTime.now().subtract(Duration(days: 6 - i));
      final key = intl.DateFormat('yyyy-MM-dd').format(date);
      return {
        'date': intl.DateFormat('E', 'ar').format(date),
        'count': widget.stats.dailyCompletions[key] ?? 0,
      };
    });

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize:
          Size.fromHeight(MediaQuery.sizeOf(context).width > 600 ? 70 : 50),
          child: AppBar(
            leading: CupertinoNavigationBarBackButton(
              color: isDark ? Colors.white : Colors.black,
            ),
            centerTitle: true,
            title: Text(
              "الإحصائيات",
              style: GoogleFonts.cairo(
                color: Colors.green,
                fontWeight: FontWeight.bold,
                fontSize: MediaQuery.sizeOf(context).width > 600 ? 12.sp : 18.sp,
              ),
            ),
            actions: const [
              // // زر اختبار الأذان 🧪
              // IconButton(
              //   icon: const Icon(Icons.bug_report, color: Colors.orange),
              //   tooltip: 'اختبار الأذان (20 ثانية)',
              //   onPressed: () async {
              //     // 1. Check Permissions First
              //     bool isAllowed =
              //         await AwesomeNotifications().isNotificationAllowed();
              //     if (!isAllowed) {
              //       await AwesomeNotifications()
              //           .requestPermissionToSendNotifications();
              //       isAllowed =
              //           await AwesomeNotifications().isNotificationAllowed();
              //       if (!isAllowed) {
              //         KHelper.showError(message: 'يجب تفعيل الإشعارات أولاً!');
              //         return;
              //       }
              //     }
              //
              //     // Check Exact Alarm (Android 12+)
              //     /*
              //      // requires specific package or method check usually,
              //      // but AwesomeNotifications handles it within scheduling often.
              //      // We will rely on the try-catch block to catch 'SecurityException'.
              //      */
              //
              //     try {
              //       KHelper.showSuccess(
              //           message: 'جاري جدولة الاختبار...'); // Feedback
              //
              //       final success = await AdhanWorkManagerService()
              //           .scheduleTestAdhan(secondsFromNow: 20);
              //       if (!mounted) return;
              //
              //       if (success != null) {
              //         KHelper.showSuccess(
              //           message:
              //               '🧪 تم جدولة أذان تجريبي بعد 20 ثانية\nانتظر وتأكد من الصوت!',
              //         );
              //       } else {
              //         KHelper.showError(
              //           message:
              //               '❌ فشلت جدولة الأذان التجريبي\nقد يكون بسبب قيود النظام (Alarms Permission)',
              //         );
              //       }
              //     } catch (e) {
              //       if (!mounted) return;
              //       // Show exact error
              //       showDialog(
              //         context: context,
              //         builder: (ctx) => AlertDialog(
              //           title: Text('خطأ في الاختبار'),
              //           content: Text(e.toString()),
              //           actions: [
              //             TextButton(
              //                 onPressed: () => Navigator.pop(ctx),
              //                 child: Text('Ok'))
              //           ],
              //         ),
              //       );
              //     }
              //   },
              // ),
              //
              // // زر اختبار فوري (بدون جدولة) للتشخيص
              // IconButton(
              //   icon: const Icon(Icons.flash_on, color: Colors.blue),
              //   tooltip: 'اختبار فوري (بدون جدولة)',
              //   onPressed: () async {
              //     await AwesomeNotifications().createNotification(
              //       content: NotificationContent(
              //         id: 77777,
              //         channelKey: 'sabah_athkar_channel',
              //         title: '⚡ اختبار فوري',
              //         body: 'إذا وصلك هذا، فالإشعارات تعمل (المشكلة في الجدولة).',
              //         notificationLayout: NotificationLayout.Default,
              //       ),
              //     );
              //     if (context.mounted) {
              //       KHelper.showSuccess(message: 'تم إرسال إشعار فوري');
              //     }
              //   },
              // ),

            ],
            // actions: [
            //   if (Platform.isAndroid)
            //     FutureBuilder<bool>(
            //       future: BatteryOptimizationHelper.isBatteryOptimizationDisabled(),
            //       builder: (context, snapshot) {
            //         return IconButton(
            //           icon: const Icon(Icons.battery_charging_full),
            //           tooltip: 'فحص إعدادات البطارية',
            //           onPressed: () async {
            //             final isDisabled = await BatteryOptimizationHelper.isBatteryOptimizationDisabled();
            //             if (!mounted) return;
            //
            //             if (isDisabled) {
            //               KHelper.showSuccess(message: "التطبيق مُستثنى من توفير البطارية");
            //             } else {
            //               BatteryOptimizationHelper.showBatteryOptimizationDialog(context);
            //             }
            //           },
            //         );
            //       },
            //     ),
            //   IconButton(
            //     icon: const Icon(Icons.refresh),
            //     tooltip: 'إعادة جدولة الإشعارات',
            //     onPressed: _scheduleAllPrayerNotifications,
            //   ),
            // ],
          ),
        ),

        body: Stack(
          children: [
            Positioned.fill(
              child: Opacity(
                opacity: isDark ? 0.05 : 0.02,
                child: Image.asset("assets/images/pattern.webp", repeat: ImageRepeat.repeat),
              ),
            ),
            CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // SliverAppBar(
                //   expandedHeight: 120.h,
                //   pinned: true,
                //   backgroundColor: isDark ? const Color(0xFF1A1A1A) : const Color(0xFF00897B),
                //   leading: const CupertinoNavigationBarBackButton(color: Colors.white),
                //   flexibleSpace: FlexibleSpaceBar(
                //     centerTitle: true,
                //     title: Text("الإحصائيات", style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14.sp)),
                //     background: Container(
                //       decoration: BoxDecoration(
                //         gradient: LinearGradient(
                //           begin: Alignment.topCenter,
                //           end: Alignment.bottomCenter,
                //           colors: isDark
                //               ? [const Color(0xFF2C2C2C), const Color(0xFF1A1A1A)]
                //               : [const Color(0xFF00BFA5), const Color(0xFF00897B)],
                //         ),
                //       ),
                //     ),
                //   ),
                // ),
                SliverPadding(
                  padding: EdgeInsets.all(20.w),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _buildMainStatCard(widget.stats.totalTasbihat, isDark, primaryColor),
                      SizedBox(height: 16.h),
                      Row(
                        children: [
                          Expanded(child: _buildInfoCard("السلسلة الحالية", "${widget.stats.currentStreak}", "يوم", Icons.local_fire_department, Colors.orange, isDark)),
                          SizedBox(width: 12.w),
                          Expanded(child: _buildInfoCard("أطول سلسلة", "${widget.stats.longestStreak}", "يوم", Icons.emoji_events, Colors.amber, isDark)),
                        ],
                      ),
                      SizedBox(height: 32.h),
                      _buildSectionHeader("نشاط آخر 7 أيام", Icons.bar_chart_rounded, isDark, primaryColor),
                      SizedBox(height: 16.h),
                      _buildActivityChart(last7Days, isDark, primaryColor),
                      SizedBox(height: 32.h),
                      _buildSectionHeader("الإنجازات (${widget.stats.achievements.length})", Icons.stars_rounded, isDark, primaryColor),
                      SizedBox(height: 16.h),
                      _buildAchievementsGrid(widget.stats, isDark),
                      SizedBox(height: 40.h),
                    ]),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainStatCard(int total, bool isDark, Color primaryColor) {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: primaryColor.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))
        ],
        border: Border.all(color: primaryColor.withOpacity(0.1), width: 1),
      ),
      child: Column(
        children: [
          Text("إجمالي التسبيحات", style: GoogleFonts.cairo(fontSize: 14.sp, color: Colors.grey, fontWeight: FontWeight.w600)),
          SizedBox(height: 8.h),
          Text(
            "$total",
            style: GoogleFonts.barlow(fontSize: 45.sp, fontWeight: FontWeight.bold, color: primaryColor),
          ),
          Container(
            height: 4.h,
            width: 40.w,
            decoration: BoxDecoration(color: primaryColor.withOpacity(0.3), borderRadius: BorderRadius.circular(2)),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, String unit, IconData icon, Color iconColor, bool isDark) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.white12 : Colors.grey.withOpacity(0.1)),
      ),
      child: Column(
        spacing: 5,
        children: [
          // Icon(icon, color: iconColor, size: 28.sp),
          // SizedBox(height: 8.h),
          Text(value, style: GoogleFonts.barlow(fontSize: 24.sp, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
          Text("$title ($unit)", style: GoogleFonts.cairo(fontSize: 10.sp, color: Colors.grey), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, bool isDark, Color primaryColor) {
    return Row(
      children: [
        Icon(icon, size: 20.sp, color: primaryColor),
        SizedBox(width: 8.w),
        Text(title, style: GoogleFonts.cairo(fontSize: 14.sp, fontWeight: FontWeight.bold, color: isDark ? Colors.white70 : Colors.black87)),
      ],
    );
  }

  Widget _buildActivityChart(List<Map<String, dynamic>> data, bool isDark, Color primaryColor) {
    final maxCount = data.map((d) => d['count'] as int).reduce((a, b) => a > b ? a : b).toDouble();
    final yMax = maxCount < 5 ? 5.0 : maxCount + 2;

    return Container(
      height: 200.h,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.white12 : Colors.grey.withOpacity(0.1)),
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: yMax,
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => isDark ? Colors.grey[800]! : Colors.teal[50]!,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  "${rod.toY.toInt()} ورد",
                  GoogleFonts.cairo(color: primaryColor, fontWeight: FontWeight.bold),
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
                      child: Text(data[value.toInt()]['date'] as String, style: GoogleFonts.cairo(fontSize: 9.sp, color: Colors.grey)),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: data.asMap().entries.map((entry) {
            return BarChartGroupData(
              x: entry.key,
              barRods: [
                BarChartRodData(
                  toY: (entry.value['count'] as int).toDouble(),
                  color: primaryColor,
                  width: 14.w,
                  borderRadius: BorderRadius.circular(4),
                  backDrawRodData: BackgroundBarChartRodData(
                    show: true,
                    toY: yMax,
                    color: isDark ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.02),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildAchievementsGrid(UserStats stats, bool isDark) {
    final allAchievements = [
      {'id': 'beginner', 'icon': '🌱', 'title': 'البداية', 'desc': '100 تسبيحة'},
      {'id': 'dedicated', 'icon': '⭐', 'title': 'المواظب', 'desc': '1000 تسبيحة'},
      {'id': 'master', 'icon': '👑', 'title': 'الخبير', 'desc': '10000 تسبيحة'},
      {'id': 'week_streak', 'icon': '🔥', 'title': 'أسبوع', 'desc': '7 أيام متتالية'},
      {'id': 'month_streak', 'icon': '💎', 'title': 'شهر', 'desc': '30 يوم متتالي'},
      {'id': 'first_day', 'icon': '🎉', 'title': 'أول يوم', 'desc': 'أكملت أول ورد لك'},
      {'id': 'fifty', 'icon': '💠', 'title': 'نصف الطريق', 'desc': '5000 تسبيحة'},
      {'id': 'millions', 'icon': '💯', 'title': 'الملهم', 'desc': '100,000 تسبيحة'},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: ResponsiveUtil.isTablet(context) ? 4 : 2,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 12.w,
        childAspectRatio: 0.85,
      ),
      itemCount: allAchievements.length,
      itemBuilder: (context, index) {
        final ach = allAchievements[index];
        final isUnlocked = stats.achievements.contains(ach['id']);
        return Container(
          decoration: BoxDecoration(
            color: isUnlocked ? (isDark ? Colors.tealAccent.withOpacity(0.1) : const Color(0xFF00897B).withOpacity(0.05)) : (isDark ? Colors.white.withOpacity(0.02) : Colors.grey.withOpacity(0.03)),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isUnlocked ? (isDark ? Colors.tealAccent.withOpacity(0.5) : const Color(0xFF00897B).withOpacity(0.3)) : Colors.grey.withOpacity(0.1)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Opacity(
                opacity: isUnlocked ? 1.0 : 0.3,
                child: Text(ach['icon']!, style: TextStyle(fontSize: 32.sp)),
              ),
              SizedBox(height: 8.h),
              Text(ach['title']!, style: GoogleFonts.cairo(fontSize: 12.sp, fontWeight: FontWeight.bold, color: isUnlocked ? (isDark ? Colors.tealAccent : const Color(0xFF00897B)) : Colors.grey)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.w),
                child: Text(ach['desc']!, style: GoogleFonts.cairo(fontSize: 10.sp, color: Colors.grey), textAlign: TextAlign.center),
              ),
              if (!isUnlocked) Icon(Icons.lock_outline_rounded, size: 14.sp, color: Colors.grey.withOpacity(0.5)),
            ],
          ),
        );
      },
    );
  }
}
