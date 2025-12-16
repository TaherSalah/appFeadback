import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:confetti/confetti.dart';

class KidsCornerScreen extends StatefulWidget {
  const KidsCornerScreen({super.key});

  @override
  State<KidsCornerScreen> createState() => _KidsCornerScreenState();
}

class _KidsCornerScreenState extends State<KidsCornerScreen> {
  late ConfettiController _confettiController;
  int _totalStars = 0;
  String _selectedGender = 'boy'; // 'boy' or 'girl'
  
  // Levels Categories - Expanded to 9 Levels
  final List<Map<String, dynamic>> _levels = [
    {
      "id": 1,
      "title": "المستوى 1: المتوضئ الصغير",
      "icon": Icons.water_drop,
      "color": const Color(0xFF4DB6AC),
      "tasks": [
         {"id": "t1_1", "title": "غسلت أسناني 🦷", "points": 5, "done": false},
         {"id": "t1_2", "title": "قلت بسم الله قبل الأكل 🍎", "points": 5, "done": false},
         {"id": "t1_3", "title": "قلت الحمد لله بعد الأكل 🤲", "points": 5, "done": false},
         {"id": "t1_4", "title": "نمت مبكراً 🛌", "points": 10, "done": false},
      ]
    },
    {
      "id": 2,
      "title": "المستوى 2: المصلي البطل",
      "icon": Icons.mosque,
      "color": const Color(0xFF7986CB),
      "tasks": [
         {"id": "t2_1", "title": "توضأت بشكل صحيح 💧", "points": 10, "done": false},
         {"id": "t2_2", "title": "صليت الصلاة في وقتها 🕌", "points": 15, "done": false},
         {"id": "t2_3", "title": "دعوت لوالدي بعد الصلاة ❤️", "points": 10, "done": false},
         {"id": "t2_4", "title": "رتبت سجادة الصلاة 🛏️", "points": 10, "done": false},
      ]
    },
    {
      "id": 3,
      "title": "المستوى 3: المسلم الخلوق",
      "icon": Icons.volunteer_activism,
      "color": const Color(0xFFFFA726),
      "tasks": [
         {"id": "t3_1", "title": "قبلت يد أمي/أبي 😘", "points": 20, "done": false},
         {"id": "t3_2", "title": "لم أغضب اليوم 😊", "points": 15, "done": false},
         {"id": "t3_3", "title": "أماطة الأذى عن الطريق 🍂", "points": 10, "done": false},
         {"id": "t3_4", "title": "تصدقت بجزء من مصروفي 🪙", "points": 20, "done": false},
      ]
    },
    {
      "id": 4,
      "title": "المستوى 4: حبيب القرآن",
      "icon": Icons.menu_book_rounded,
      "color": const Color(0xFF8D6E63),
      "tasks": [
         {"id": "t4_1", "title": "راجعت سورة قصيرة 📖", "points": 20, "done": false},
         {"id": "t4_2", "title": "استمعت للقرآن 5 دقائق 🎧", "points": 15, "done": false},
         {"id": "t4_3", "title": "حفظت آية جديدة ✨", "points": 25, "done": false},
         {"id": "t4_4", "title": "وضعت المصحف في مكان مرتفع ☝️", "points": 10, "done": false},
      ]
    },
    {
      "id": 5,
      "title": "المستوى 5: واصل الرحم",
      "icon": Icons.family_restroom,
      "color": const Color(0xFFEC407A),
      "tasks": [
         {"id": "t5_1", "title": "اتصلت بجدي/جدتي 📞", "points": 30, "done": false},
         {"id": "t5_2", "title": "لعبت مع أخي/أختي بلطف 🧸", "points": 20, "done": false},
         {"id": "t5_3", "title": "ساعدت في تحضير الطعام 🥗", "points": 25, "done": false},
         {"id": "t5_4", "title": "قلت كلاماً طيباً لأهلي 💬", "points": 15, "done": false},
      ]
    },
    {
      "id": 6,
      "title": "المستوى 6: بطل التحدي",
      "icon": Icons.diamond,
      "color": const Color(0xFF9C27B0),
      "tasks": [
         {"id": "t6_1", "title": "صمت جزءاً من اليوم 🥤🚫", "points": 40, "done": false},
         {"id": "t6_2", "title": "صليت النوافل (السنن) 🕌", "points": 35, "done": false},
         {"id": "t6_3", "title": "علمت صديقي حديثاً شريفاً 🤝", "points": 30, "done": false},
         {"id": "t6_4", "title": "ذكرت الله 100 مرة 📿", "points": 30, "done": false},
      ]
    },
    // NEW LEVELS
    {
      "id": 7,
      "title": "المستوى 7: العالم الصغير",
      "icon": Icons.science,
      "color": const Color(0xFF0288D1), // Light Blue
      "tasks": [
         {"id": "t7_1", "title": "تأملت في السماء والنجوم 🌌", "points": 20, "done": false},
         {"id": "t7_2", "title": "سقيت زرعاً أو حيواناً 🌱", "points": 25, "done": false},
         {"id": "t7_3", "title": "قرأت معلومة مفيدة 📚", "points": 20, "done": false},
         {"id": "t7_4", "title": "قلت سبحان الله على خلقه 🦜", "points": 20, "done": false},
      ]
    },
    {
      "id": 8,
      "title": "المستوى 8: نصير السنة",
      "icon": Icons.light_mode,
      "color": const Color(0xFFFFD600), // Yellow/Gold
      "tasks": [
         {"id": "t8_1", "title": "استخدمت السواك 🦷", "points": 30, "done": false},
         {"id": "t8_2", "title": "دخلت المنزل باليمين 🦶", "points": 20, "done": false},
         {"id": "t8_3", "title": "ابتسمت (تبسمك صدقة) 😊", "points": 20, "done": false},
         {"id": "t8_4", "title": "قلت دعاء الدخول/الخروج 🤲", "points": 25, "done": false},
      ]
    },
    {
      "id": 9,
      "title": "المستوى 9: القائد الأمين",
      "icon": Icons.flag,
      "color": const Color(0xFFC62828), // Red
      "tasks": [
         {"id": "t9_1", "title": "قلت الصدق دائماً ✅", "points": 40, "done": false},
         {"id": "t9_2", "title": "حافظت على الوعد 🤝", "points": 40, "done": false},
         {"id": "t9_3", "title": "نظفت مكاني بعد اللعب 🧹", "points": 30, "done": false},
         {"id": "t9_4", "title": "سامحت من أخطأ في حقي ❤️", "points": 50, "done": false},
      ]
    },
  ];

  // Trophies / Badges
  final List<Map<String, dynamic>> _allTrophies = [
    {"id": "badge_1", "title": "بداية بطل", "desc": "اجمع 50 نجمة", "icon": Icons.star, "required": 50, "unlocked": false},
    {"id": "badge_2", "title": "حارس الصلاة", "desc": "اجمع 150 نجمة", "icon": Icons.shield, "required": 150, "unlocked": false},
    {"id": "badge_3", "title": "قلب ذهبي", "desc": "اجمع 300 نجمة", "icon": Icons.favorite, "required": 300, "unlocked": false},
    {"id": "badge_4", "title": "عالم مبدع", "desc": "اجمع 500 نجمة", "icon": Icons.school, "required": 500, "unlocked": false},
    {"id": "badge_5", "title": "حافظ العهد", "desc": "اجمع 800 نجمة", "icon": Icons.handshake, "required": 800, "unlocked": false},
    {"id": "badge_6", "title": "أسطورة", "desc": "اجمع 1500 نجمة", "icon": Icons.workspace_premium, "required": 1500, "unlocked": false},
  ];

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
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
      _totalStars = prefs.getInt('kids_total_stars') ?? 0;
      _selectedGender = prefs.getString('kids_gender') ?? 'boy';
      
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
    await prefs.setInt('kids_total_stars', _totalStars);
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
    if (_levels[levelIndex]['tasks'][taskIndex]['done']) return;

    setState(() {
      _levels[levelIndex]['tasks'][taskIndex]['done'] = true;
      final points = _levels[levelIndex]['tasks'][taskIndex]['points'] as int;
      _totalStars += points;
      
      _checkTrophies();
      _confettiController.play();
    });

    _saveProgress();
  }

  String _getRankTitle() {
    if (_totalStars < 200) return "مستكشف صغير 🥉";
    if (_totalStars < 600) return "بطل شجاع 🥈";
    if (_totalStars < 1200) return "قائد عظيم 🥇";
    return "أسطورة 👑";
  }

  Color _getThemeColor() {
    return _selectedGender == 'boy' ? const Color(0xFF2196F3) : const Color(0xFFE91E63);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeColor = _getThemeColor();
    final bgColor = isDark 
        ? const Color(0xFF121212) 
        : (_selectedGender == 'boy' ? const Color(0xFFE3F2FD) : const Color(0xFFFCE4EC));

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          "ركن المسلم الصغير 🦸‍♂️",
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: isDark ? Colors.white : themeColor),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.person_pin, color: isDark ? Colors.white : themeColor),
            onPressed: _showAvatarSelection,
          )
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildProfileCard(isDark),
                const SizedBox(height: 20),
                _buildTrophySection(isDark),
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Icon(Icons.map, size: 20, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(
                      "رحلة الأبطال 🗺️",
                      style: GoogleFonts.cairo(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ...List.generate(_levels.length, (index) => _buildLevelCard(index, isDark)),
                const SizedBox(height: 40),
              ],
            ),
          ),
          
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [Colors.green, Colors.blue, Colors.pink, Colors.orange, Colors.purple],
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
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("اختر بطلك", style: GoogleFonts.cairo(fontSize: 18.sp, fontWeight: FontWeight.bold)),
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
                      CircleAvatar(radius: 40, backgroundColor: Colors.blue.withOpacity(0.2), child: const Text("👦", style: TextStyle(fontSize: 40))),
                      const SizedBox(height: 8),
                      Text("ولد", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
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
                      CircleAvatar(radius: 40, backgroundColor: Colors.pink.withOpacity(0.2), child: const Text("🧕", style: TextStyle(fontSize: 40))),
                      const SizedBox(height: 8),
                      Text("بنت", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
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

  Widget _buildProfileCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _selectedGender == 'boy'
              ? [const Color(0xFF42A5F5), const Color(0xFF1976D2)]
              : [const Color(0xFFEC407A), const Color(0xFFC2185B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 5))],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 45,
            backgroundColor: Colors.white,
            child: Text(_selectedGender == 'boy' ? "👦" : "🧕", style: const TextStyle(fontSize: 50)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "المستوى: ${_getRankTitle()}",
                  style: GoogleFonts.cairo(fontSize: 18.sp, color: Colors.white, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(10)),
                  child: Text("⭐ $_totalStars نقطة", style: GoogleFonts.cairo(fontSize: 14.sp, color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrophySection(bool isDark) {
    return SizedBox(
      height: 110,
      child: ListView.separated(
        itemCount: _allTrophies.length,
        scrollDirection: Axis.horizontal,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final trophy = _allTrophies[index];
          final unlocked = trophy['unlocked'];
          return Container(
            width: 90,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2C3E50) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: unlocked ? Colors.amber : Colors.grey.withOpacity(0.3), width: 2),
              boxShadow: [
                 if(unlocked) BoxShadow(color: Colors.amber.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4))
              ]
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(trophy['icon'], size: 35, color: unlocked ? Colors.amber : Colors.grey),
                const SizedBox(height: 5),
                Text(
                  trophy['title'], 
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cairo(fontSize: 10.sp, fontWeight: FontWeight.bold, color: unlocked ? (isDark ? Colors.white : Colors.black87) : Colors.grey),
                  maxLines: 1, 
                  overflow: TextOverflow.ellipsis
                ),
                Text("${trophy['required']}", style: GoogleFonts.cairo(fontSize: 10.sp, fontWeight: FontWeight.bold, color: unlocked ? Colors.amber : Colors.grey)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLevelCard(int index, bool isDark) {
    final level = _levels[index];
    final color = level['color'] as Color;
    final tasks = level['tasks'] as List;
    final completedCount = tasks.where((t) => t['done']).length;
    final progress = completedCount / tasks.length;
    final isLevelComplete = progress == 1.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isLevelComplete ? Colors.green : color.withOpacity(0.3), width: isLevelComplete ? 2 : 1.5),
        boxShadow: [
          BoxShadow(color: (isLevelComplete ? Colors.green : color).withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: index <= 1, // Expand first two
          leading: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: progress,
                backgroundColor: color.withOpacity(0.1),
                valueColor: AlwaysStoppedAnimation(isLevelComplete ? Colors.green : color),
                strokeWidth: 4,
              ),
              if(isLevelComplete) const Icon(Icons.star, size: 16, color: Colors.green)
            ],
          ),
          title: Text(
            level['title'],
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 16.sp, color: isDark ? Colors.white : Colors.black87),
          ),
          subtitle: Text(
            isLevelComplete ? "رائع! أنهيت المستوى 🏆" : "$completedCount / ${tasks.length} مكتمل",
            style: GoogleFonts.cairo(fontSize: 12.sp, color: isLevelComplete ? Colors.green : Colors.grey, fontWeight: isLevelComplete ? FontWeight.bold : FontWeight.normal),
          ),
          children: tasks.map<Widget>((task) {
            final isDone = task['done'];
            return Container(
               margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
               decoration: BoxDecoration(
                 color: isDone ? (isLevelComplete ? Colors.green.withOpacity(0.1) : color.withOpacity(0.1)) : Colors.transparent,
                 borderRadius: BorderRadius.circular(12),
                 border: Border.all(color: isDone ? (isLevelComplete ? Colors.green : color) : Colors.grey.withOpacity(0.2))
               ),
               child: ListTile(
                onTap: () => _toggleTask(index, tasks.indexOf(task)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                title: Text(
                  task['title'],
                  style: GoogleFonts.cairo(
                    fontSize: 14.sp,
                    fontWeight: isDone ? FontWeight.bold : FontWeight.normal,
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                ),
                trailing: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: isDone ? (isLevelComplete ? Colors.green : color) : Colors.grey.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isDone ? Icons.check : Icons.star_border,
                    color: isDone ? Colors.white : Colors.grey,
                    size: 18,
                  ),
                ),
                visualDensity: VisualDensity.compact,
              ),
            );
          }).toList() + [const SizedBox(height: 10)],
        ),
      ),
    );
  }
}
