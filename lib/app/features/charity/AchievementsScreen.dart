import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:confetti/confetti.dart';
import 'models/charity_models.dart';
import 'services/charity_service.dart';
import 'package:intl/intl.dart' as intl;

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  final CharityService _charityService = CharityService();
  late ConfettiController _confettiController;
  List<CharityAchievement> _unlocked = [];
  bool _loading = true;

  final List<Map<String, dynamic>> _allAchievementDefinitions = [
    {
      'id': 'first_donation',
      'title': 'أول الغيث 🌧️',
      'description': 'قمت بأول تبرع لك في التطبيق',
      'icon': '🥇',
    },
    {
      'id': 'streak_7',
      'title': 'المحسن المثابر 👏',
      'description': 'حافظت على التبرع لمدة 7 أيام متتالية',
      'icon': '🔥',
    },
    {
      'id': 'generous_1000',
      'title': 'اليد السخية 💰',
      'description': 'تجاوز إجمالي صدقاتك 1000 جنيه',
      'icon': '💎',
    },
    {
      'id': 'goal_reached',
      'title': 'محقق الأهداف 🎯',
      'description': 'حققت هدفك المالي لهذا الشهر بالكامل',
      'icon': '🏆',
    },
  ];

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));
    _loadData();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    await _charityService.init();
    final unlocked = _charityService.getUnlockedAchievements();
    setState(() {
      _unlocked = unlocked;
      _loading = false;
    });

    if (_unlocked.isNotEmpty) {
      _confettiController.play();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor:
            isDark ? const Color(0xFF1A1F36) : const Color(0xFFF5F7FA),
        appBar: AppBar(
          title: Text(
            'لوحة الإنجازات 🏆',
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
        body: Stack(
          children: [
            _loading
                ? const Center(child: CircularProgressIndicator())
                : _buildBody(isDark),
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                colors: const [
                  Colors.green,
                  Colors.blue,
                  Colors.pink,
                  Colors.orange,
                  Colors.purple
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(bool isDark) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryCard(isDark),
          SizedBox(height: 24.h),
          Text(
            'الأوسمة المستحقة',
            style: GoogleFonts.cairo(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF2D3142),
            ),
          ),
          SizedBox(height: 12.h),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12.w,
              mainAxisSpacing: 12.h,
              childAspectRatio: 0.85,
            ),
            itemCount: _allAchievementDefinitions.length,
            itemBuilder: (context, index) {
              final def = _allAchievementDefinitions[index];
              final achievement =
                  _unlocked.cast<CharityAchievement?>().firstWhere(
                        (a) => a?.id == def['id'],
                        orElse: () => null,
                      );
              return _buildAchievementCard(def, achievement, isDark);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(bool isDark) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF667EEA).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.stars, color: Colors.white, size: 40.sp),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'لقد جمعت ${_unlocked.length} وسامًا!',
                  style: GoogleFonts.cairo(
                    color: Colors.white,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'استمر في العطاء لتفتح المزيد من الإنجازات',
                  style: GoogleFonts.cairo(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementCard(
      Map<String, dynamic> def, CharityAchievement? achievement, bool isDark) {
    final isUnlocked = achievement != null;

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF252B46) : Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color:
              isUnlocked ? Colors.amber.withOpacity(0.5) : Colors.transparent,
          width: 2,
        ),
        boxShadow: [
          if (isUnlocked)
            BoxShadow(
              color: Colors.amber.withOpacity(0.1),
              blurRadius: 8,
              spreadRadius: 2,
            ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Opacity(
            opacity: isUnlocked ? 1.0 : 0.3,
            child: Text(
              def['icon'],
              style: TextStyle(fontSize: 40.sp),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            def['title'],
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: isUnlocked
                  ? (isDark ? Colors.white : const Color(0xFF2D3142))
                  : (isDark ? Colors.white38 : Colors.grey),
            ),
          ),
          Text(
            def['description'],
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(
              fontSize: 10.sp,
              color: isDark ? Colors.white54 : Colors.grey[600],
            ),
          ),
          if (isUnlocked) ...[
            SizedBox(height: 8.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Text(
                intl.DateFormat('yyyy/MM/dd', 'ar')
                    .format(achievement.unlockedDate),
                style: GoogleFonts.cairo(
                  fontSize: 9.sp,
                  color: Colors.amber[800],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
