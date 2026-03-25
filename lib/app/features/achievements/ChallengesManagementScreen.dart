import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:muslimdaily/app/core/extensions/context_extension.dart';

import 'models/achievement_models.dart';
import 'services/achievement_service.dart';

class ChallengesManagementScreen extends StatefulWidget {
  const ChallengesManagementScreen({super.key});

  @override
  State<ChallengesManagementScreen> createState() => _ChallengesManagementScreenState();
}

class _ChallengesManagementScreenState extends State<ChallengesManagementScreen> {
  final AchievementService _service = AchievementService();
  List<Challenge> _challenges = [];

  @override
  void initState() {
    super.initState();
    _loadChallenges();
  }

  Future<void> _loadChallenges() async {
    await _service.init();
    await _service.generateDailyChallenges();
    setState(() => _challenges = _service.getActiveChallenges());
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF1A1F36) : const Color(0xFFF5F7FA),
        appBar: AppBar(
          title: Text('التحديات 🎯',    style: TextStyle(
                          fontFamily: "cairo",fontWeight: FontWeight.bold, fontSize: 20.sp)),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
        body: ListView.builder(
          padding: EdgeInsets.all(16.w),
          itemCount: _challenges.length,
          itemBuilder: (context, index) => _buildChallengeCard(_challenges[index], isDark),
        ),
      ),
    );
  }

  Widget _buildChallengeCard(Challenge challenge, bool isDark) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2D3748) : Colors.white,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(challenge.emoji, style: TextStyle(fontSize: 32.sp)),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(challenge.title,    style: TextStyle(
                          fontFamily: "cairo",fontSize: 16.sp, fontWeight: FontWeight.bold)),
                    Text(challenge.description,    style: TextStyle(
                          fontFamily: "cairo",fontSize: 12.sp, color: Colors.grey)),
                  ],
                ),
              ),
              Text('${challenge.rewardPoints} نقطة',    style: TextStyle(
                          fontFamily: "cairo",fontSize: 14.sp, fontWeight: FontWeight.bold, color: const Color(0xFF10B981))),
            ],
          ),
          SizedBox(height: 16.h),
          LinearProgressIndicator(
            value: challenge.progress,
            backgroundColor: Colors.grey.shade200,
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
            minHeight: 8.h,
            borderRadius: BorderRadius.circular(4.r),
          ),
          SizedBox(height: 8.h),
          Text('${challenge.currentProgress} / ${challenge.targetValue}',    style: TextStyle(
                          fontFamily: "cairo",fontSize: 12.sp, color: Colors.grey)),
        ],
      ),
    );
  }
}
