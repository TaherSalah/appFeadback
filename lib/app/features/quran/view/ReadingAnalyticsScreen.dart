import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart' as intl;
import 'package:muslimdaily/app/core/utils/style/k_color.dart';
import 'package:muslimdaily/app/core/utils/style/responsive_util.dart';
import 'package:muslimdaily/app/core/widgets/custom_text_widget.dart';
import 'package:muslimdaily/app/features/quran/data/reading_analytics_service.dart';

class ReadingAnalyticsScreen extends StatefulWidget {
  const ReadingAnalyticsScreen({super.key});

  @override
  State<ReadingAnalyticsScreen> createState() => _ReadingAnalyticsScreenState();
}

class _ReadingAnalyticsScreenState extends State<ReadingAnalyticsScreen> {
  final ReadingAnalyticsService _service = ReadingAnalyticsService();
  List<DailyReadingStat> _weeklyStats = [];
  List<DailyReadingStat> _monthlyStats = [];
  Map<String, int> _todayStats = {'seconds': 0, 'pages': 0};
  int _streak = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final weekly = await _service.getWeeklyStats();
    final today = await _service.getTodayStats();
    final streak = await _service.getStreak();
    final monthly = await _service.getMonthlyStats();

    if (mounted) {
      setState(() {
        _weeklyStats = weekly;
        _todayStats = today;
        _streak = streak;
        _monthlyStats = monthly;
        _isLoading = false;
      });
    }
  }

  String _formatDuration(int totalSeconds) {
    if (totalSeconds < 60) return '$totalSeconds ثانية';
    int minutes = totalSeconds ~/ 60;
    if (minutes < 60) return '$minutes دقيقة';
    int hours = minutes ~/ 60;
    int remainingMinutes = minutes % 60;
    return '$hours ساعة و $remainingMinutes دقيقة';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isTablet = ResponsiveUtil.isTablet(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "إحصائيات القراءة",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: isTablet ? 12.sp : 18.sp,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: const BackButton(),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Summary Cards
                    Row(
                      children: [
                        Expanded(
                          child: _SummaryCard(
                            title: "الوقت",
                            value: _formatDuration(_todayStats['seconds'] ?? 0),
                            icon: Icons.access_time_filled_rounded,
                            color: Colors.blueAccent,
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _SummaryCard(
                            title: "الصفحات",
                            value: "${_todayStats['pages'] ?? 0}",
                            icon: Icons.menu_book_rounded,
                            color: Colors.green,
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _SummaryCard(
                            title: "التتابع",
                            value: "$_streak يوم",
                            icon: Icons.local_fire_department_rounded,
                            color: Colors.orange,
                            isDark: isDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Chart Section
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xff151515) : Colors.white,
                        borderRadius: BorderRadius.circular(20),
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
                          TextWidget(
                            title: "نشاط آخر 7 أيام (بالدقائق)",
                            fontWeight: FontWeight.bold,
                            fontSize: isTablet ? 10.sp : 16,
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            height: 200,
                            child: BarChart(
                              BarChartData(
                                alignment: BarChartAlignment.spaceAround,
                                maxY: _getMaxY(),
                                barTouchData: BarTouchData(
                                  enabled: true,
                                  touchTooltipData: BarTouchTooltipData(
                                    getTooltipColor: (group) => isDark
                                        ? Colors.grey[800]!
                                        : Colors.blueGrey,
                                    getTooltipItem:
                                        (group, groupIndex, rod, rodIndex) {
                                      return BarTooltipItem(
                                        '${rod.toY.toInt()} د',
                                        const TextStyle(color: Colors.white),
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
                                        if (value.toInt() >= 0 &&
                                            value.toInt() <
                                                _weeklyStats.length) {
                                          final date =
                                              _weeklyStats[value.toInt()].date;
                                          return Padding(
                                            padding:
                                                const EdgeInsets.only(top: 8.0),
                                            child: Text(
                                              intl.DateFormat('E', 'ar')
                                                  .format(date),
                                              style: TextStyle(
                                                color: isDark
                                                    ? Colors.grey
                                                    : Colors.black54,
                                                fontSize: 10,
                                                fontFamily: 'cairo',
                                              ),
                                            ),
                                          );
                                        }
                                        return const Text('');
                                      },
                                    ),
                                  ),
                                  leftTitles: const AxisTitles(
                                      sideTitles:
                                          SideTitles(showTitles: false)),
                                  topTitles: const AxisTitles(
                                      sideTitles:
                                          SideTitles(showTitles: false)),
                                  rightTitles: const AxisTitles(
                                      sideTitles:
                                          SideTitles(showTitles: false)),
                                ),
                                gridData: const FlGridData(show: false),
                                borderData: FlBorderData(show: false),
                                barGroups:
                                    _weeklyStats.asMap().entries.map((e) {
                                  final index = e.key;
                                  final stat = e.value;
                                  final minutes = stat.secondsRead / 60;
                                  return BarChartGroupData(
                                    x: index,
                                    barRods: [
                                      BarChartRodData(
                                        toY: minutes,
                                        color: index == _weeklyStats.length - 1
                                            ? KColors.primaryColor
                                            : (isDark
                                                ? Colors.white24
                                                : Colors.grey.withOpacity(0.3)),
                                        width: 16,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Detailed History
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextWidget(
                        title: "سجل القراءة (آخر 30 يوم)",
                        fontWeight: FontWeight.bold,
                        fontSize: isTablet ? 10.sp : 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _monthlyStats.length,
                      separatorBuilder: (context, index) =>
                          Divider(color: Colors.grey.withOpacity(0.1)),
                      itemBuilder: (context, index) {
                        final stat = _monthlyStats[index];
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.white10 : Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.calendar_today_rounded,
                              size: 16,
                              color: isDark ? Colors.white70 : Colors.black54,
                            ),
                          ),
                          title: TextWidget(
                            title: intl.DateFormat('EEEE d MMMM', 'ar')
                                .format(stat.date),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          subtitle: TextWidget(
                            title:
                                "${stat.pagesRead} صفحات • ${_formatDuration(stat.secondsRead)}",
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  double _getMaxY() {
    double max = 0;
    for (var stat in _weeklyStats) {
      if ((stat.secondsRead / 60) > max) {
        max = stat.secondsRead / 60;
      }
    }
    return max == 0 ? 10 : max * 1.2;
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final bool isDark;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xff151515) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black.withOpacity(0.04),
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          TextWidget(
            title: value,
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: isDark ? Colors.white : Colors.black,
          ),
          const SizedBox(height: 4),
          TextWidget(
            title: title,
            fontSize: 12,
            color: isDark ? Colors.grey : Colors.black54,
          ),
        ],
      ),
    );
  }
}
