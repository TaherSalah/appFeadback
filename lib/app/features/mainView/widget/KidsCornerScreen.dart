import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:confetti/confetti.dart';

import '../../../core/utils/style/app_theme_colors.dart';
import '../../../core/utils/style/responsive_util.dart';
import 'DailyChallengesScreen.dart';
import 'GamesMenuScreen.dart';
import 'HadithsForKidsScreen.dart';
import 'DailyDuasScreen.dart';
import 'package:muslimdaily/app/features/kids/view/KidsStoriesScreen.dart';
import 'package:animate_do/animate_do.dart';
import 'VirtualShopScreen.dart';
import 'KidsStatisticsScreen.dart';
import '../../../core/utils/style/k_dialog_helper.dart';

enum KidsView { home, journey, activities, trophies }

class KidsCornerScreen extends StatefulWidget {
  const KidsCornerScreen({super.key});

  @override
  State<KidsCornerScreen> createState() => _KidsCornerScreenState();
}

class _KidsCornerScreenState extends State<KidsCornerScreen> {
  late ConfettiController _confettiController;
  int _totalStars = 0;
  int _completedStories = 0;
  int _completedGames = 0;
  int _currentStreakDays = 0;
  String _selectedGender = 'boy'; // 'boy' or 'girl'
  KidsView _currentView = KidsView.home;

  // Levels Categories - Expanded to 9 Levels
  final List<Map<String, dynamic>> _levels = [
    {
      "id": 1,
      "title": "المستوى 1: المتوضئ الصغير",
      "icon": Icons.water_drop,
      "color": const Color(0xFF4DB6AC),
      "tasks": [
        {"id": "t1_1", "title": "غسلت أسناني 🦷", "points": 5, "done": false},
        {
          "id": "t1_2",
          "title": "قلت بسم الله قبل الأكل 🍎",
          "points": 5,
          "done": false
        },
        {
          "id": "t1_3",
          "title": "قلت الحمد لله بعد الأكل 🤲",
          "points": 5,
          "done": false
        },
        {"id": "t1_4", "title": "نمت مبكراً 🛌", "points": 10, "done": false},
      ]
    },
    {
      "id": 2,
      "title": "المستوى 2: المصلي البطل",
      "icon": Icons.mosque,
      "color": const Color(0xFF7986CB),
      "tasks": [
        {
          "id": "t2_1",
          "title": "توضأت بشكل صحيح 💧",
          "points": 10,
          "done": false
        },
        {
          "id": "t2_2",
          "title": "صليت الصلاة في وقتها 🕌",
          "points": 15,
          "done": false
        },
        {
          "id": "t2_3",
          "title": "دعوت لوالدي بعد الصلاة ❤️",
          "points": 10,
          "done": false
        },
        {
          "id": "t2_4",
          "title": "رتبت سجادة الصلاة 🛏️",
          "points": 10,
          "done": false
        },
      ]
    },
    {
      "id": 3,
      "title": "المستوى 3: المسلم الخلوق",
      "icon": Icons.volunteer_activism,
      "color": const Color(0xFFFFA726),
      "tasks": [
        {
          "id": "t3_1",
          "title": "قبلت يد أمي/أبي",
          "points": 20,
          "done": false
        },
        {
          "id": "t3_2",
          "title": "لم أغضب اليوم",
          "points": 15,
          "done": false
        },
        {
          "id": "t3_3",
          "title": "أماطة الأذى عن الطريق",
          "points": 10,
          "done": false
        },
        {
          "id": "t3_4",
          "title": "تصدقت بجزء من مصروفي",
          "points": 20,
          "done": false
        },
      ]
    },
    {
      "id": 4,
      "title": "المستوى 4: حبيب القرآن",
      "icon": Icons.menu_book_rounded,
      "color": const Color(0xFF8D6E63),
      "tasks": [
        {
          "id": "t4_1",
          "title": "راجعت سورة قصيرة",
          "points": 20,
          "done": false
        },
        {
          "id": "t4_2",
          "title": "استمعت للقرآن 5 دقائق",
          "points": 15,
          "done": false
        },
        {
          "id": "t4_3",
          "title": "حفظت آية جديدة",
          "points": 25,
          "done": false
        },
        {
          "id": "t4_4",
          "title": "وضعت المصحف في مكان مرتفع",
          "points": 10,
          "done": false
        },
      ]
    },
    {
      "id": 5,
      "title": "المستوى 5: واصل الرحم",
      "icon": Icons.family_restroom,
      "color": const Color(0xFFEC407A),
      "tasks": [
        {
          "id": "t5_1",
          "title": "اتصلت بجدي/جدتي",
          "points": 30,
          "done": false
        },
        {
          "id": "t5_2",
          "title": "لعبت مع أخي/أختي بلطف",
          "points": 20,
          "done": false
        },
        {
          "id": "t5_3",
          "title": "ساعدت في تحضير الطعام",
          "points": 25,
          "done": false
        },
        {
          "id": "t5_4",
          "title": "قلت كلاماً طيباً لأهلي",
          "points": 15,
          "done": false
        },
      ]
    },
    {
      "id": 6,
      "title": "المستوى 6: بطل التحدي",
      "icon": Icons.diamond,
      "color": const Color(0xFF9C27B0),
      "tasks": [
        {
          "id": "t6_1",
          "title": "صمت جزءاً من اليوم",
          "points": 40,
          "done": false
        },
        {
          "id": "t6_2",
          "title": "صليت النوافل (السنن)",
          "points": 35,
          "done": false
        },
        {
          "id": "t6_3",
          "title": "علمت صديقي حديثاً شريفاً",
          "points": 30,
          "done": false
        },
        {
          "id": "t6_4",
          "title": "ذكرت الله 100 مرة",
          "points": 30,
          "done": false
        },
      ]
    },
    // NEW LEVELS
    {
      "id": 7,
      "title": "المستوى 7: العالم الصغير",
      "icon": Icons.science,
      "color": const Color(0xFF0288D1), // Light Blue
      "tasks": [
        {
          "id": "t7_1",
          "title": "تأملت في السماء والنجوم",
          "points": 20,
          "done": false
        },
        {
          "id": "t7_2",
          "title": "سقيت زرعاً أو حيواناً",
          "points": 25,
          "done": false
        },
        {
          "id": "t7_3",
          "title": "قرأت معلومة مفيدة",
          "points": 20,
          "done": false
        },
        {
          "id": "t7_4",
          "title": "قلت سبحان الله على خلقه",
          "points": 20,
          "done": false
        },
      ]
    },
    {
      "id": 8,
      "title": "المستوى 8: نصير السنة",
      "icon": Icons.light_mode,
      "color": const Color(0xFFFFD600), // Yellow/Gold
      "tasks": [
        {
          "id": "t8_1",
          "title": "استخدمت السواك",
          "points": 30,
          "done": false
        },
        {
          "id": "t8_2",
          "title": "دخلت المنزل باليمين",
          "points": 20,
          "done": false
        },
        {
          "id": "t8_3",
          "title": "ابتسمت (تبسمك صدقة)",
          "points": 20,
          "done": false
        },
        {
          "id": "t8_4",
          "title": "قلت دعاء الدخول/الخروج",
          "points": 25,
          "done": false
        },
      ]
    },
    {
      "id": 9,
      "title": "المستوى 9: القائد الأمين",
      "icon": Icons.flag,
      "color": const Color(0xFFC62828), // Red
      "tasks": [
        {
          "id": "t9_1",
          "title": "قلت الصدق دائما",
          "points": 40,
          "done": false
        },
        {
          "id": "t9_2",
          "title": "حافظت على الوعد",
          "points": 40,
          "done": false
        },
        {
          "id": "t9_3",
          "title": "نظفت مكاني بعد اللعب",
          "points": 30,
          "done": false
        },
        {
          "id": "t9_4",
          "title": "سامحت من أخطأ في حقي",
          "points": 50,
          "done": false
        },
      ]
    },
    {
      "id": 10,
      "title": "المستوى 10: حارس البيئة",
      "icon": Icons.eco,
      "color": const Color(0xFF2E7D32),
      "tasks": [
        {
          "id": "t10_1",
          "title": "وفرت في استهلاك الماء",
          "points": 30,
          "done": false
        },
        {
          "id": "t10_2",
          "title": "أغلقت الأنوار غير الضرورية",
          "points": 25,
          "done": false
        },
        {
          "id": "t10_3",
          "title": "جمعت القمامة ووضعتها في الحاوية",
          "points": 30,
          "done": false
        },
        {
          "id": "t10_4",
          "title": "تحدثت عن أهمية النظافة",
          "points": 20,
          "done": false
        },
      ]
    },
    {
      "id": 11,
      "title": "المستوى 11: الفتى المؤدب",
      "icon": Icons.record_voice_over,
      "color": const Color(0xFF5D4037),
      "tasks": [
        {
          "id": "t11_1",
          "title": "خفضت صوتي أثناء الحديث",
          "points": 30,
          "done": false
        },
        {
          "id": "t11_2",
          "title": "استأذنت قبل دخول الغرفة",
          "points": 25,
          "done": false
        },
        {
          "id": "t11_3",
          "title": "قلت 'شكراً' و'لو سمحت'",
          "points": 20,
          "done": false
        },
        {
          "id": "t11_4",
          "title": "لم أقاطع أحداً أثناء كلامه",
          "points": 30,
          "done": false
        },
      ]
    },
    {
      "id": 12,
      "title": "المستوى 12: المسلم القوي",
      "icon": Icons.fitness_center,
      "color": const Color(0xFF37474F),
      "tasks": [
        {
          "id": "t12_1",
          "title": "مارست الرياضة اليوم️",
          "points": 40,
          "done": false
        },
        {
          "id": "t12_2",
          "title": "أكلت طعاماً صحيا",
          "points": 30,
          "done": false
        },
        {
          "id": "t12_3",
          "title": "ساعدت في حمل أغراض المنزل",
          "points": 40,
          "done": false
        },
        {
          "id": "t12_4",
          "title": "مشيت إلى المسجد",
          "points": 50,
          "done": false
        },
      ]
    },
  ];

  // Trophies / Badges
  final List<Map<String, dynamic>> _allTrophies = [
    {
      "id": "badge_1",
      "title": "بداية بطل",
      "desc": "اجمع 50 نجمة",
      "icon": Icons.star,
      "required": 50,
      "unlocked": false
    },
    {
      "id": "badge_2",
      "title": "حارس الصلاة",
      "desc": "اجمع 150 نجمة",
      "icon": Icons.shield,
      "required": 150,
      "unlocked": false
    },
    {
      "id": "badge_3",
      "title": "قلب ذهبي",
      "desc": "اجمع 300 نجمة",
      "icon": Icons.favorite,
      "required": 300,
      "unlocked": false
    },
    {
      "id": "badge_4",
      "title": "عالم مبدع",
      "desc": "اجمع 500 نجمة",
      "icon": Icons.school,
      "required": 500,
      "unlocked": false
    },
    {
      "id": "badge_5",
      "title": "حافظ العهد",
      "desc": "اجمع 800 نجمة",
      "icon": Icons.handshake,
      "required": 800,
      "unlocked": false
    },
    {
      "id": "badge_6",
      "title": "أسطورة",
      "desc": "اجمع 1500 نجمة",
      "icon": Icons.workspace_premium,
      "required": 1500,
      "unlocked": false
    },
  ];

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));
    _loadProgress();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _totalStars = prefs.getInt('kids_total_stars_v2') ?? 0;
      _selectedGender = prefs.getString('kids_gender') ?? 'boy';
      _completedStories = prefs.getInt('completed_stories') ?? 0;
      _completedGames = prefs.getInt('completed_games') ?? 0;
      _currentStreakDays = prefs.getInt('streak_days') ?? 0;

      final savedTasks = prefs.getString('kids_tasks_v2');
      if (savedTasks != null) {
        final decoded = jsonDecode(savedTasks) as Map<String, dynamic>;
        for (var level in _levels) {
          for (var task in level['tasks']) {
            if (decoded.containsKey(task['id'])) {
              task['done'] = decoded[task['id']];
            }
          }
        }
      }
      _checkTrophies();
    });
  }

  Future<void> _saveProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('kids_total_stars_v2', _totalStars);
    await prefs.setString('kids_gender', _selectedGender);

    final Map<String, dynamic> tasksState = {};
    for (var level in _levels) {
      for (var task in level['tasks']) {
        tasksState[task['id']] = task['done'];
      }
    }
    await prefs.setString('kids_tasks_v2', jsonEncode(tasksState));
  }

  void _checkTrophies() {
    for (var trophy in _allTrophies) {
      if (_totalStars >= (trophy['required'] as int)) {
        trophy['unlocked'] = true;
      }
    }
  }

  void _toggleTask(int levelIndex, int taskIndex) {
    setState(() {
      final isDone = _levels[levelIndex]['tasks'][taskIndex]['done'];
      _levels[levelIndex]['tasks'][taskIndex]['done'] = !isDone;
      final points = _levels[levelIndex]['tasks'][taskIndex]['points'] as int;

      if (!isDone) {
        _totalStars += points;
        _confettiController.play();
        _saveProgress(); // Ensure it saves immediately
      } else {
        _totalStars -= points;
      }

      _checkTrophies();
    });

    _saveProgress();
  }

  Future<void> _resetProgress() async {
    final confirm = await KDialogHelper.showCustomDialog<bool>(
      context: context,
      type: KDialogType.warning,
      icon: Icons.refresh_rounded,
      title: 'تصفير التقدم',
      description:
          'هل أنت متأكد من تصفير كل تقدمك في ركن المسلم الصغير؟ ستفقد جميع النجوم والأوسمة.',
      actions: [
        KDialogHelper.buildButton(
          context: context,
          label: 'إلغاء',
          isPrimary: false,
          onPressed: () => Navigator.pop(context, false),
        ),
        KDialogHelper.buildButton(
          context: context,
          label: 'نعم، تصفير',
          color: Colors.red,
          onPressed: () => Navigator.pop(context, true),
        ),
      ],
    );

    if (confirm == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('kids_total_stars');
      await prefs.remove('kids_tasks_v2');
      await prefs.remove('completed_stories');
      await prefs.remove('completed_games');
      await prefs.remove('streak_days');

      setState(() {
        _totalStars = 0;
        _completedStories = 0;
        _completedGames = 0;
        _currentStreakDays = 0;
        for (var level in _levels) {
          for (var task in level['tasks']) {
            task['done'] = false;
          }
        }
        _checkTrophies();
      });
    }
  }

  String _getRankTitle() {
    if (_totalStars < 200) return "مستكشف صغير 🥉";
    if (_totalStars < 600) return "بطل شجاع 🥈";
    if (_totalStars < 1200) return "قائد عظيم 🥇";
    return "أسطورة 👑";
  }

  Color _getThemeColor() {
    return _selectedGender == 'boy'
        ? const Color(0xFF2196F3)
        : const Color(0xFFE91E63);
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "صباح الخير يا بطل! ☀️";
    if (hour < 17) return "أهلاً بك يا بطل! 👋";
    return "مساء النور يا بطل! ✨";
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeColor = _getThemeColor();
    final bgColor = isDark
        ? const Color(0xFF121212)
        : (_selectedGender == 'boy'
            ? const Color(0xFFE3F2FD)
            : const Color(0xFFFCE4EC));

    return Directionality(
      textDirection: TextDirection.rtl,
      child: PopScope(
        canPop: _currentView == KidsView.home,
        onPopInvoked: (didPop) {
          if (didPop) return;
          if (_currentView != KidsView.home) {
            setState(() => _currentView = KidsView.home);
          }
        },
        child: Scaffold(
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(
              MediaQuery.sizeOf(context).width > 600 ? 70 : 50,
            ),
            child: AppBar(
              leading: _currentView == KidsView.home
                  ? CupertinoNavigationBarBackButton(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black,
                    )
                  : IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () =>
                          setState(() => _currentView = KidsView.home),
                    ),
              centerTitle: true,
              actions: [
                if (_currentView == KidsView.home)
                  IconButton(
                    icon: Icon(Icons.person_pin,
                        color: isDark ? Colors.white : themeColor),
                    onPressed: _showAvatarSelection,
                  )
              ],
              title: Text(
                _getViewTitle(),
                style: GoogleFonts.cairo(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize:
                      MediaQuery.sizeOf(context).width > 600 ? 12.sp : 18.sp,
                ),
              ),
            ),
          ),
          body: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _buildCurrentView(isDark),
                ),
              ),
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
      ),
    );
  }

  String _getViewTitle() {
    switch (_currentView) {
      case KidsView.home:
        return "ركن المسلم الصغير";
      case KidsView.journey:
        return "رحلة الأبطال";
      case KidsView.activities:
        return "المرح والتعلم";
      case KidsView.trophies:
        return "إنجازاتي";
    }
  }

  Widget _buildCurrentView(bool isDark) {
    switch (_currentView) {
      case KidsView.home:
        return _buildDashboard(isDark);
      case KidsView.journey:
        return _buildJourneyContent(isDark);
      case KidsView.activities:
        return _buildActivitiesContent(isDark);
      case KidsView.trophies:
        return _buildTrophiesContent(isDark);
    }
  }

  Widget _buildDashboard(bool isDark) {
    return Column(
      key: const ValueKey('home'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FadeInDown(
          child: Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                    : [const Color(0xFF0EA5E9), const Color(0xFF38BDF8)],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
              borderRadius: BorderRadius.circular(30.r),
              boxShadow: [
                BoxShadow(
                  color: (isDark ? Colors.black : const Color(0xFF0EA5E9))
                      .withOpacity(0.2),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 35.r,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      child: Text(
                        _selectedGender == 'boy' ? '👦' : '👧',
                        style: TextStyle(fontSize: 40.sp),
                      ),
                    ),
                    SizedBox(width: 15.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getGreeting(),
                            style: GoogleFonts.cairo(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            _getRankTitle(),
                            style: GoogleFonts.cairo(
                              fontSize: 12.sp,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 15.h),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.stars_rounded,
                              color: Colors.amber, size: 24.sp),
                          SizedBox(width: 8.w),
                          Text(
                            '$_totalStars نقطة',
                            style: GoogleFonts.cairo(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16.sp,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'إنجاز رائع!',
                        style: GoogleFonts.cairo(
                            color: Colors.white70, fontSize: 11.sp),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        FadeInUp(
          child: Row(
            children: [
              const Icon(Icons.auto_awesome_rounded, color: Colors.amber),
              const SizedBox(width: 8),
              Text(
                "اختر مغامرتك اليوم",
                style: GoogleFonts.cairo(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 16.w,
          crossAxisSpacing: 16.w,
          childAspectRatio: 1.1,
          children: [
            FadeInLeft(
              child: _buildQuickNavCard(
                title: "رحلة الأبطال",
                subtitle: "مهام وتحديات يومية",
                emoji: "�️",
                color: const Color(0xFF6366F1),
                onTap: () => setState(() => _currentView = KidsView.journey),
              ),
            ),
            FadeInRight(
              child: _buildQuickNavCard(
                title: "مكتبة الحكايات",
                subtitle: "قصص ممتعة ومفيدة",
                emoji: "📖",
                color: const Color(0xFFF43F5E), // Rose color
                onTap: () async {
                  await Navigator.push(
                    context,
                    CupertinoPageRoute(
                        builder: (_) => const KidsStoriesScreen()),
                  );
                  _loadProgress(); // Refresh stars when coming back
                },
              ),
            ),
            FadeInRight(
              child: _buildQuickNavCard(
                title: "المرح والتعلم",
                subtitle: "ألعاب وذكاء",
                emoji: "🧩",
                color: const Color(0xFFF59E0B),
                onTap: () => setState(() => _currentView = KidsView.activities),
              ),
            ),
            FadeInLeft(
              delay: const Duration(milliseconds: 200),
              child: _buildQuickNavCard(
                title: "ألبوم الإنجازات",
                subtitle: "أوسمتي وبطولاتي",
                emoji: "🏅",
                color: const Color(0xFFEC4899),
                onTap: () async {
                  await Navigator.push(
                    context,
                    CupertinoPageRoute(
                        builder: (_) => const KidsStatisticsScreen()),
                  );
                  _loadProgress();
                },
              ),
            ),
            FadeInRight(
              delay: const Duration(milliseconds: 200),
              child: _buildQuickNavCard(
                title: "أدعية يومية",
                subtitle: "أتعلم وأدعو",
                emoji: "🌈",
                color: const Color(0xFF10B981),
                onTap: () {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(builder: (_) => const DailyDuasScreen()),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickNavCard({
    required String title,
    required String subtitle,
    required String emoji,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF1E293B)
              : Colors.white,
          borderRadius: BorderRadius.circular(28.r),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: color.withOpacity(0.1), width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Text(emoji, style: TextStyle(fontSize: 35.sp)),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.bold,
                fontSize: 14.sp,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              subtitle,
              style: GoogleFonts.cairo(
                fontSize: 10.sp,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJourneyContent(bool isDark) {
    return Column(
      key: const ValueKey('journey'),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.blue.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  const Text("🗺️", style: TextStyle(fontSize: 30)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "تتبع المسار لتصبح بطلاً خارقاً! أكمل كل مستوى لفتح المستوى التالي.",
                      style: GoogleFonts.cairo(
                        fontSize: 13.sp,
                        color: isDark ? Colors.white70 : Colors.blue.shade900,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: _levels
                          .where((l) =>
                              (l['tasks'] as List).every((t) => t['done']))
                          .length /
                      _levels.length,
                  backgroundColor: Colors.blue.withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                  minHeight: 10,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "أكملت ${_levels.where((l) => (l['tasks'] as List).every((t) => t['done'])).length} من ${_levels.length} مستويات",
                style: GoogleFonts.cairo(fontSize: 11.sp, color: Colors.grey),
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _levels.length,
          itemBuilder: (context, index) {
            final level = _levels[index];
            final isEven = index % 2 == 0;
            final isLast = index == _levels.length - 1;

            return _buildPathLevelNode(level, index, isEven, isLast, isDark);
          },
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildPathLevelNode(Map<String, dynamic> level, int index, bool isEven,
      bool isLast, bool isDark) {
    final color = level['color'] as Color;
    final tasks = level['tasks'] as List;
    final completedCount = tasks.where((t) => t['done']).length;
    final progress = completedCount / tasks.length;
    final isLevelComplete = progress == 1.0;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        children: [
          Row(
            mainAxisAlignment:
                isEven ? MainAxisAlignment.start : MainAxisAlignment.end,
            children: [
              if (!isEven) const Spacer(),
              GestureDetector(
                onTap: () {
                  // Show floating task list or dialog
                  _showLevelTasksDialog(index, isDark);
                },
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 90.w,
                          height: 90.w,
                          decoration: BoxDecoration(
                            color:
                                isDark ? const Color(0xFF1E293B) : Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: (isLevelComplete ? Colors.green : color)
                                    .withOpacity(0.3),
                                blurRadius: 15,
                                spreadRadius: 2,
                              ),
                            ],
                            border: Border.all(
                              color: isLevelComplete ? Colors.green : color,
                              width: 4,
                            ),
                          ),
                          child: Icon(
                            level['icon'],
                            size: 40,
                            color: isLevelComplete ? Colors.green : color,
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color:
                                  isLevelComplete ? Colors.green : Colors.amber,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: Icon(
                              isLevelComplete ? Icons.check : Icons.lock_open,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      level['title'].split(':')[1].trim(),
                      style: GoogleFonts.cairo(
                        fontWeight: FontWeight.bold,
                        fontSize: 14.sp,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    Text(
                      "$completedCount / ${tasks.length}",
                      style: GoogleFonts.cairo(
                        fontSize: 11.sp,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              if (isEven) const Spacer(),
            ],
          ),
          if (!isLast)
            Container(
              height: 60,
              width: 2,
              margin: EdgeInsets.only(
                right: isEven ? 0 : 45.w,
                left: isEven ? 45.w : 0,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    isLevelComplete ? Colors.green : color,
                    (_levels[index + 1]['tasks'] as List)
                            .every((t) => t['done'])
                        ? Colors.green
                        : (_levels[index + 1]['color'] as Color),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showLevelTasksDialog(int index, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(builder: (context, setModalState) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Container(
            height: MediaQuery.of(context).size.height * 0.7,
            decoration: BoxDecoration(
              // color: isDark ? const Color(0xFF1E293B) : Colors.white,
              color: AppThemeColors.cardBackgroundColor(context),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(32)),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Icon(_levels[index]['icon'],
                        size: 30, color: _levels[index]['color']),
                    const SizedBox(width: 12),
                    Text(
                      _levels[index]['title'],
                      style: GoogleFonts.cairo(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView(
                    children:
                        (_levels[index]['tasks'] as List).map<Widget>((task) {
                      final taskIndex =
                          (_levels[index]['tasks'] as List).indexOf(task);
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: task['done']
                              ? Colors.green.withOpacity(0.1)
                              : Colors.grey.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: task['done']
                                ? Colors.green
                                : Colors.grey.withOpacity(0.2),
                          ),
                        ),
                        child: ListTile(
                          onTap: () {
                            _toggleTask(index, taskIndex);
                            setModalState(() {});
                          },
                          leading: Icon(
                            task['done']
                                ? Icons.check_circle
                                : Icons.radio_button_unchecked,
                            color: task['done'] ? Colors.green : Colors.grey,
                          ),
                          title: Text(
                            task['title'],
                            style: GoogleFonts.cairo(
                              fontWeight: task['done']
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              decoration: task['done']
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                          trailing: Text(
                            "+${task['points']} ⭐",
                            style: GoogleFonts.cairo(
                                color: Colors.amber,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildTrophiesContent(bool isDark) {
    final unlockedBadges = _allTrophies.where((t) => t['unlocked']).toList();
    return Column(
      key: const ValueKey('trophies'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Overall stats Header
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.orange.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              const Text('🏆', style: TextStyle(fontSize: 45)),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'إجمالي النجوم',
                      style: GoogleFonts.cairo(
                        fontSize: 14.sp,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '$_totalStars ⭐',
                      style: GoogleFonts.cairo(
                        fontSize: 28.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Stats grid
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.2,
          children: [
            _buildStatCard(
                '📚', 'قصص مقروءة', '$_completedStories', Colors.blue, isDark),
            _buildStatCard('🎮', 'ألعاب مكتملة', '$_completedGames',
                Colors.purple, isDark),
            _buildStatCard('🔥', 'أطول سلسلة', '$_currentStreakDays يوم',
                Colors.orange, isDark),
            _buildStatCard('🏅', 'شارات مفتوحة', '${unlockedBadges.length}',
                Colors.green, isDark),
          ],
        ),
        const SizedBox(height: 32),

        // Badges section
        Text(
          'أوسمتك المستحقة 🏅',
          style: GoogleFonts.cairo(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 12),

        if (unlockedBadges.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            width: double.infinity,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                const Text('🎯', style: TextStyle(fontSize: 40)),
                const SizedBox(height: 12),
                Text(
                  'لا توجد شارات بعد\nابدأ بجمع النجوم والتحديات!',
                  style: GoogleFonts.cairo(
                    fontSize: 14.sp,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        else
          ...unlockedBadges.map((badge) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: Colors.amber.withOpacity(0.5), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.amber.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(
                          badge['icon'] as IconData,
                          color: Colors.amber,
                          size: 25,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            badge['title'] ?? '',
                            style: GoogleFonts.cairo(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          Text(
                            badge['desc'] ?? '',
                            style: GoogleFonts.cairo(
                              fontSize: 12.sp,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.check_circle,
                        color: Colors.green, size: 24),
                  ],
                ),
              )),
        const SizedBox(height: 32),
        Center(
          child: TextButton.icon(
            onPressed: _resetProgress,
            icon: const Icon(Icons.refresh, color: Colors.red),
            label: Text(
              'تصفير كل التقدم',
              style: GoogleFonts.cairo(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildStatCard(
      String emoji, String label, String value, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3), width: 2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 30)),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 11.sp,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            value,
            style: GoogleFonts.cairo(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  void _showAvatarSelection() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppThemeColors.cardBackgroundColor(context),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("اختر بطلك",
                style: GoogleFonts.cairo(
                    fontSize: ResponsiveUtil.isTablet(context) ? 14.sp : 18.sp,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                InkWell(
                  onTap: () {
                    setState(() => _selectedGender = 'boy');
                    _saveProgress();
                    Navigator.pop(context);
                  },
                  child: Column(
                    children: [
                      CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.blue.withOpacity(0.2),
                          child:
                              const Text("👦", style: TextStyle(fontSize: 40))),
                      const SizedBox(height: 8),
                      Text("ولد",
                          style:
                              GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () {
                    setState(() => _selectedGender = 'girl');
                    _saveProgress();
                    Navigator.pop(context);
                  },
                  child: Column(
                    children: [
                      CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.pink.withOpacity(0.2),
                          child:
                              const Text("🧕", style: TextStyle(fontSize: 40))),
                      const SizedBox(height: 8),
                      Text("بنت",
                          style:
                              GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivitiesContent(bool isDark) {
    return Column(
      key: const ValueKey('activities'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.orange.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              const Text("🎮", style: TextStyle(fontSize: 30)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  "هنا تجد كل المتعة والتعلم! اختر نشاطاً لتبدأ رحلتك.",
                  style: GoogleFonts.cairo(
                    fontSize: 13.sp,
                    color: isDark ? Colors.white70 : Colors.orange.shade900,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.9,
          children: [
            // _buildQuickNavCard(
            //   title: "قصص إسلامية",
            //   emoji: "📚",
            //   color: const Color(0xFFFF9800),
            //   onTap: () async {
            //     await Navigator.push(
            //       context,
            //       CupertinoPageRoute(builder: (_) => const KidsStoriesScreen()),
            //     );
            //     _loadProgress();
            //   },
            //   subtitle: '',
            // ),
            _buildQuickNavCard(
              title: "ألعاب تعليمية",
              emoji: "🎮",
              color: const Color(0xFF9C27B0),
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => GamesMenuScreen(onRefresh: _loadProgress),
                  ),
                );
                _loadProgress();
              },
              subtitle: '',
            ),
            _buildQuickNavCard(
              title: "المتجر",
              emoji: "🏪",
              color: const Color(0xFF00BCD4),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => VirtualShopScreen(
                      currentStars: _totalStars,
                      onPurchase: (cost) {
                        setState(() {
                          _totalStars -= cost;
                        });
                        _saveProgress();
                      },
                    ),
                  ),
                );
              },
              subtitle: '',
            ),
            _buildQuickNavCard(
              subtitle: "",
              title: "التحديات",
              emoji: "⚡",
              color: const Color(0xFFE91E63),
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const DailyChallengesScreen()),
                );
                _loadProgress();
              },
            ),
            // _buildQuickNavCard(
            //   title: "أحاديث للأطفال",
            //   emoji: "📿",
            //   color: const Color(0xFF009688),
            //   onTap: () async {
            //     await Navigator.push(
            //       context,
            //       MaterialPageRoute(
            //           builder: (_) => const HadithsForKidsScreen()),
            //     );
            //     _loadProgress();
            //   },
            //   subtitle: '',
            // ),
            _buildQuickNavCard(
              subtitle: "",
              title: "أدعية يومية",
              emoji: "🤲",
              color: const Color(0xFF673AB7),
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const DailyDuasScreen()),
                );
                _loadProgress();
              },
            ),
          ],
        ),
        const SizedBox(height: 40),
      ],
    );
  }
}
