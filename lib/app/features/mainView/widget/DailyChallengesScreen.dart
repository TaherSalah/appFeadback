import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:muslimdaily/app/core/utils/style/k_color.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/utils/style/responsive_util.dart';
import '../../../core/utils/style/k_dialog_helper.dart';
import 'dart:convert';

class DailyChallengesScreen extends StatefulWidget {
  const DailyChallengesScreen({super.key});

  @override
  State<DailyChallengesScreen> createState() => _DailyChallengesScreenState();
}

class _DailyChallengesScreenState extends State<DailyChallengesScreen> {
  Map<String, bool> _completedChallenges = {};
  String _currentDate = '';

  final List<Map<String, dynamic>> _todayChallenges = [
    {
      'id': 'daily_prayer_5',
      'title': 'صل الخمس صلوات اليوم',
      'emoji': '🕌',
      'reward': 100,
      'description': 'صل جميع الصلوات الخمس في وقتها',
    },
    {
      'id': 'daily_quran',
      'title': 'اقرأ صفحة من القرآن',
      'emoji': '📖',
      'reward': 50,
      'description': 'اقرأ صفحة واحدة على الأقل من القرآن الكريم',
    },
    {
      'id': 'daily_kindness',
      'title': 'افعل خيراً لأحد',
      'emoji': '❤️',
      'reward': 75,
      'description': 'ساعد والديك أو صديقك في شيء',
    },
  ];

  final List<Map<String, dynamic>> _weeklyChallenges = [
    {
      'id': 'weekly_mosque',
      'title': 'صل في المسجد 5 مرات',
      'emoji': '🕌',
      'reward': 200,
      'description': 'صل 5 صلوات في المسجد هذا الأسبوع',
    },
    {
      'id': 'weekly_charity',
      'title': 'تصدق 3 مرات',
      'emoji': '💰',
      'reward': 150,
      'description': 'تصدق 3 مرات خلال الأسبوع',
    },
    {
      'id': 'weekly_stars',
      'title': 'اجمع 300 نجمة',
      'emoji': '⭐',
      'reward': 250,
      'description': 'اجمع 300 نجمة من المهام والألعاب',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadChallenges();
  }

  Future<void> _loadChallenges() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toString().substring(0, 10);
    final savedDate = prefs.getString('challenges_date') ?? '';

    setState(() {
      _currentDate = today;

      if (savedDate != today) {
        // New day - reset daily challenges
        _completedChallenges = {};
        prefs.setString('challenges_date', today);
        prefs.setString('completed_challenges', '{}');
      } else {
        final saved = prefs.getString('completed_challenges') ?? '{}';
        _completedChallenges = Map<String, bool>.from(jsonDecode(saved));
      }
    });
  }

  Future<void> _saveChallenges() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'completed_challenges', jsonEncode(_completedChallenges));
  }

  /// حفظ النقاط المكتسبة من التحديات إلى إجمالي النجوم
  Future<void> _addStarsReward(int reward) async {
    final prefs = await SharedPreferences.getInstance();
    final currentStars = prefs.getInt('kids_total_stars_v2') ?? 0;
    await prefs.setInt('kids_total_stars_v2', currentStars + reward);
  }

  void _completeChallenge(Map<String, dynamic> challenge) {
    if (_completedChallenges[challenge['id']] == true) {
      return; // Already completed
    }

    KDialogHelper.showCustomDialog(
      context: context,
      type: KDialogType.info,
      icon: Icons.help_outline_rounded,
      title: 'تأكيد الإنجاز',
      description: 'هل أتممت حقاً: \n"${challenge['title']}"؟',
      actions: [
        KDialogHelper.buildButton(
          context: context,
          label: 'ليس بعد',
          isPrimary: false,
          onPressed: () => Navigator.pop(context),
        ),
        KDialogHelper.buildButton(
          context: context,
          label: 'نعم، أتممتها',
          onPressed: () async {
            Navigator.pop(context);
            setState(() {
              _completedChallenges[challenge['id']] = true;
            });
            await _saveChallenges();
            await _addStarsReward(challenge['reward'] as int);
            _showRewardDialog(challenge);
          },
        ),
      ],
    );
  }

  void _showRewardDialog(Map<String, dynamic> challenge) {
    KDialogHelper.showCustomDialog(
      context: context,
      type: KDialogType.success,
      icon: Icons.stars_rounded,
      title: 'عمل رائع!',
      description: 'لقد حصلت على مكافأة المهمة بنجاح.',
      additionalContent: Column(
        children: [
          // Text(
          //   challenge['emoji'],
          //   style: const TextStyle(fontSize: 60),
          // ),
          // const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.stars_rounded, color: Colors.amber, size: 30),
              const SizedBox(width: 8),
              Text(
                '+${challenge['reward']}',
                style: GoogleFonts.barlow(
                  fontSize: 32.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        KDialogHelper.buildButton(
          context: context,
          label: 'رائع!',
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final dailyCompleted = _todayChallenges
        .where((c) => _completedChallenges[c['id']] == true)
        .length;
    final weeklyCompleted = _weeklyChallenges
        .where((c) => _completedChallenges[c['id']] == true)
        .length;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        // appBar: AppBar(
        //   title: Text(
        //     'التحديات ⚡',
        //     style: GoogleFonts.cairo(
        //       fontWeight: FontWeight.bold,
        //       fontSize: ResponsiveUtil.isTablet(context) ? 14.sp : 20.sp,
        //     ),
        //   ),
        //   centerTitle: true,
        // ),
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(
            MediaQuery.sizeOf(context).width > 600 ? 70 : 50,
          ),
          child: AppBar(
            leading: CupertinoNavigationBarBackButton(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black,
            ),

            centerTitle: true,
            title: Text(
              "التحديات",
              style: GoogleFonts.cairo(
                color: Colors.green,
                fontWeight: FontWeight.bold,
                fontSize:
                MediaQuery.sizeOf(context).width > 600 ? 12.sp : 18.sp,
              ),
            ),
          ),
        ),

        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Daily Challenges
            _buildSectionHeader('التحديات اليومية', dailyCompleted,
                _todayChallenges.length, isDark, KColors.primaryColor),
            const SizedBox(height: 12),
            ..._todayChallenges
                .map((c) => _buildChallengeCard(c, isDark, KColors.primary)),

            const SizedBox(height: 24),

            // Weekly Challenges
            _buildSectionHeader('التحديات الأسبوعية', weeklyCompleted,
                _weeklyChallenges.length, isDark, KColors.primaryColor),
            const SizedBox(height: 12),
            ..._weeklyChallenges
                .map((c) => _buildChallengeCard(c, isDark, KColors.primary)),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
      String title, int completed, int total, bool isDark, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.7)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.cairo(
              fontSize: ResponsiveUtil.isTablet(context) ? 12.sp : 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$completed/$total',
              style: GoogleFonts.cairo(
                fontSize: ResponsiveUtil.isTablet(context) ? 10.sp : 14.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChallengeCard(
      Map<String, dynamic> challenge, bool isDark, Color color) {
    final isCompleted = _completedChallenges[challenge['id']] == true;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCompleted ? Colors.green : color.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        // leading: Container(
        //   width: 60,
        //   height: 60,
        //   decoration: BoxDecoration(
        //     color: (isCompleted ? Colors.green : color).withOpacity(0.1),
        //     borderRadius: BorderRadius.circular(12),
        //   ),
        //   child: Center(
        //     child: Text(
        //       challenge['emoji'],
        //       style: const TextStyle(fontSize: 30),
        //     ),
        //   ),
        // ),
        title: Text(
          challenge['title'],
          style: GoogleFonts.cairo(
            fontSize: ResponsiveUtil.isTablet(context) ? 11.sp : 15.sp,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              challenge['description'],
              style: GoogleFonts.cairo(
                fontSize: ResponsiveUtil.isTablet(context) ? 8.sp : 11.sp,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 18),
                const SizedBox(width: 4),
                Text(
                  '+${challenge['reward']}',
                  style: GoogleFonts.cairo(
                    fontSize: ResponsiveUtil.isTablet(context) ? 9.sp : 13.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: isCompleted
            ? const Icon(Icons.check_circle, color: Colors.green, size: 32)
            : ElevatedButton(
                onPressed: () => _completeChallenge(challenge),
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'تم!',
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
      ),
    );
  }
}
