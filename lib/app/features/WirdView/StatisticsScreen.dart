// =============== شاشة الإحصائيات ===============

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart' as intl;

import '../../core/shard/exports/all_exports.dart';
import 'data/UserStats.dart';

class StatisticsScreen extends StatefulWidget {
  final UserStats stats;

  const StatisticsScreen({super.key, required this.stats});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {

  @override
  void initState() {
    super.initState();
    _loadStats();
  }
  UserStats stats = UserStats();
  bool isLoading = true;
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

    final last7Days = List.generate(7, (i) {
      final date = DateTime.now().subtract(Duration(days: 6 - i));
      final key = intl.DateFormat('yyyy-MM-dd').format(date);
      return {
        'date': intl.DateFormat('E', 'ar').format(date),
        'count': widget.stats.dailyCompletions[key] ?? 0,
      };
    });

    return  Directionality(
      textDirection: TextDirection.rtl,
      child: RefreshIndicator(
        onRefresh: _refreshStats,
        child: Scaffold(
          // appBar: AppBar(
          //   title: const Text('الإحصائيات'),
          //   backgroundColor: Colors.teal,
          // ),
          appBar: PreferredSize(
            preferredSize:
            Size.fromHeight(MediaQuery.sizeOf(context).width > 600 ? 80 : 50),
            child: AppBar(
              leading: CupertinoNavigationBarBackButton(color: isDark?Colors.white:Colors.black,),
              centerTitle: true,
              title: Text(
                "الإحصائيات",
                style: GoogleFonts.cairo(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize:
                    MediaQuery.sizeOf(context).width > 600 ? 12.sp : 18.sp),
              ),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                         Text(
                          'إجمالي التسبيحات',
                          style: TextStyle(fontSize: 18.sp,fontFamily: "me",fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${widget.stats.totalTasbihat}',
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              const Icon(Icons.local_fire_department, size: 40, color: Colors.orange),
                              const SizedBox(height: 8),
                              Text(
                                '${widget.stats.currentStreak}',
                                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                               Text('يوم متتالي', style: TextStyle(fontFamily: "me",fontSize: 17.sp,)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              const Icon(Icons.emoji_events, size: 40, color: Colors.amber),
                              const SizedBox(height: 8),
                              Text(
                                '${widget.stats.longestStreak}',
                                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                               Text('أطول سلسلة', style: TextStyle(fontFamily: "me",fontSize: 17.sp,)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  'نشاط آخر 7 أيام',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Container(
                  height: 200,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: (last7Days.map((d) => d['count'] as int).reduce((a, b) => a > b ? a : b) + 5).toDouble(),
                      barTouchData: const BarTouchData(enabled: true),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              if (value.toInt() >= 0 && value.toInt() < last7Days.length) {
                                return Text(
                                  last7Days[value.toInt()]['date'] as String,
                                  style: const TextStyle(fontSize: 12),
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
                      gridData: const FlGridData(show: false),
                      borderData: FlBorderData(show: false),
                      barGroups: last7Days.asMap().entries.map((entry) {
                        return BarChartGroupData(
                          x: entry.key,
                          barRods: [
                            BarChartRodData(
                              toY: (entry.value['count'] as int).toDouble(),
                              color: Colors.teal,
                              width: 20,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'الإنجازات (${widget.stats.achievements.length})',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: _buildAchievements(widget.stats),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildAchievements(UserStats stats) {
  //   final allAchievements = [
  //     {'id': 'beginner', 'icon': '🌱', 'title': 'البداية', 'desc': '100 تسبيحة'},
  //     {'id': 'dedicated', 'icon': '⭐', 'title': 'المواظب', 'desc': '1000 تسبيحة'},
  //     {'id': 'master', 'icon': '👑', 'title': 'الخبير', 'desc': '10000 تسبيحة'},
  //     {'id': 'week_streak', 'icon': '🔥', 'title': 'أسبوع', 'desc': '7 أيام متتالية'},
  //     {'id': 'month_streak', 'icon': '💎', 'title': 'شهر', 'desc': '30 يوم متتالي'},
  //   ];
  final allAchievements = [
    {'id': 'beginner', 'icon': '🌱', 'title': 'البداية', 'desc': '100 تسبيحة'},
    {'id': 'dedicated', 'icon': '⭐', 'title': 'المواظب', 'desc': '1000 تسبيحة'},
    {'id': 'master', 'icon': '👑', 'title': 'الخبير', 'desc': '10000 تسبيحة'},
    {'id': 'week_streak', 'icon': '🔥', 'title': 'أسبوع', 'desc': '7 أيام متتالية'},
    {'id': 'month_streak', 'icon': '💎', 'title': 'شهر', 'desc': '30 يوم متتالي'},

    // 🌙 إضافات جديدة
    {'id': 'first_day', 'icon': '🎉', 'title': 'أول يوم', 'desc': 'أكملت أول ورد لك'},
    {'id': 'fifty', 'icon': '💠', 'title': 'نصف الطريق', 'desc': '5000 تسبيحة'},
    {'id': 'hundred_days', 'icon': '🏅', 'title': 'مئة يوم', 'desc': '100 يوم متتالي'},
    {'id': 'night_dhikr', 'icon': '🌙', 'title': 'ذكر الليل', 'desc': 'ورد بعد منتصف الليل'},
    {'id': 'millions', 'icon': '💯', 'title': 'الملهم', 'desc': '100,000 تسبيحة'},
  ];

    return allAchievements.map((ach) {
      final isUnlocked = stats.achievements.contains(ach['id']);
      return Container(
        width: 100,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isUnlocked ? Colors.teal.shade50 : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isUnlocked ? Colors.teal : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Text(
              ach['icon'] as String,
              style: TextStyle(
                fontSize: 32,
                color: isUnlocked ? null : Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              ach['title'] as String,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isUnlocked ? Colors.teal : Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              ach['desc'] as String,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }).toList();
  }
}

//