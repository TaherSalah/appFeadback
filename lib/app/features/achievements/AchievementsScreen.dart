import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:muslimdaily/app/core/extensions/context_extension.dart';

import '../../core/widgets/KLoading.dart';
import 'ChallengesManagementScreen.dart';
import 'LeaderboardScreen.dart';
import 'models/achievement_models.dart';
import 'services/achievement_service.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  final AchievementService _service = AchievementService();
  UserProgress? _progress;
  List<Achievement> _achievements = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    await _service.init();
    await _service.generateDailyChallenges();
    setState(() {
      _progress = _service.getProgress();
      _achievements = _service.getAllAchievements();
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF1A1F36) : const Color(0xFFF5F7FA),
        appBar: AppBar(
          title: Text('الإنجازات 🏆',    style: TextStyle(
                          fontFamily: "cairo",fontWeight: FontWeight.bold, fontSize: 20.sp)),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
          actions: [
            IconButton(
              icon: const Icon(Icons.leaderboard),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LeaderboardScreen())),
            ),
          ],
        ),
        body: _loading
            ?  Center(child:  KLoading.progressIOSIndicator(context: context))
            : SingleChildScrollView(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  children: [
                    _buildProgressCard(isDark),
                    SizedBox(height: 20.h),
                    _buildQuickActions(isDark),
                    SizedBox(height: 20.h),
                    _buildAchievementsGrid(isDark),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildProgressCard(bool isDark) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)]),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [BoxShadow(color: const Color(0xFF8B5CF6).withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('المستوى ${_progress!.level}',    style: TextStyle(
                          fontFamily: "cairo",fontSize: 24.sp, fontWeight: FontWeight.bold, color: Colors.white)),
                  Text(_progress!.levelTitle,    style: TextStyle(
                          fontFamily: "cairo",fontSize: 14.sp, color: Colors.white.withOpacity(0.9))),
                ],
              ),
              Text('${_progress!.totalPoints} نقطة',    style: TextStyle(
                          fontFamily: "cairo",fontSize: 20.sp, fontWeight: FontWeight.bold, color: Colors.white)),
            ],
          ),
          SizedBox(height: 16.h),
          LinearProgressIndicator(
            value: _progress!.levelProgress,
            backgroundColor: Colors.white.withOpacity(0.3),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            minHeight: 10.h,
            borderRadius: BorderRadius.circular(5.r),
          ),
          SizedBox(height: 8.h),
          Text('${_progress!.currentLevelPoints} / ${_progress!.nextLevelPoints} للمستوى التالي',
                 style: TextStyle(
                          fontFamily: "cairo",fontSize: 12.sp, color: Colors.white.withOpacity(0.9))),
        ],
      ),
    );
  }

  Widget _buildQuickActions(bool isDark) {
    return Row(
      children: [
        Expanded(
          child: _buildActionCard('🎯', 'التحديات', const Color(0xFFEF4444), () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const ChallengesManagementScreen()));
          }, isDark),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _buildActionCard(
              '📊', 'المفتوحة', const Color(0xFF10B981), () {}, isDark, subtitle: '${_service.getUnlockedAchievements().length}'),
        ),
      ],
    );
  }

  Widget _buildActionCard(String emoji, String label, Color color, VoidCallback onTap, bool isDark, {String? subtitle}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(color: isDark ? const Color(0xFF2D3748) : Colors.white, borderRadius: BorderRadius.circular(16.r)),
        child: Column(
          children: [
            Text(emoji, style: TextStyle(fontSize: 32.sp)),
            SizedBox(height: 8.h),
            Text(label,    style: TextStyle(
                          fontFamily: "cairo",fontSize: 14.sp, fontWeight: FontWeight.bold, color: color)),
            if (subtitle != null) Text(subtitle,    style: TextStyle(
                          fontFamily: "cairo",fontSize: 12.sp, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementsGrid(bool isDark) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 12, mainAxisSpacing: 12),
      itemCount: _achievements.length,
      itemBuilder: (context, index) {
        final achievement = _achievements[index];
        return Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: achievement.isUnlocked
                ? (isDark ? const Color(0xFF2D3748) : Colors.white)
                : (isDark ? Colors.grey.shade800 : Colors.grey.shade200),
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Opacity(
                opacity: achievement.isUnlocked ? 1.0 : 0.3,
                child: Text(achievement.emoji, style: TextStyle(fontSize: 32.sp)),
              ),
              SizedBox(height: 8.h),
              Text(achievement.title,
                     style: TextStyle(
                          fontFamily: "cairo",fontSize: 11.sp, fontWeight: FontWeight.bold), textAlign: TextAlign.center, maxLines: 2),
            ],
          ),
        );
      },
    );
  }
}
