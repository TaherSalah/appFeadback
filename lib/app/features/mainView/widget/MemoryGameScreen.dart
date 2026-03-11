import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';
import '../../../core/utils/style/k_dialog_helper.dart';
import 'kids_data/sounds_helper.dart';

enum MemoryCategory {
  symbols,
  prophets,
  pillars,
  namesOfAllah,
  months
}

class MemoryLevel {
  final int rows;
  final int cols;
  final String title;
  final MemoryCategory category;

  MemoryLevel({
    required this.rows,
    required this.cols,
    required this.title,
    required this.category,
  });

  int get pairs => (rows * cols) ~/ 2;
}

class MemoryGameScreen extends StatefulWidget {
  const MemoryGameScreen({super.key});

  @override
  State<MemoryGameScreen> createState() => _MemoryGameScreenState();
}

class _MemoryGameScreenState extends State<MemoryGameScreen> {
  final List<MemoryLevel> _levels = [
    // Category 1: Islamic Symbols (Levels 1-4)
    MemoryLevel(title: 'المستوى ١', rows: 2, cols: 3, category: MemoryCategory.symbols),
    MemoryLevel(title: 'المستوى ٢', rows: 2, cols: 4, category: MemoryCategory.symbols),
    MemoryLevel(title: 'المستوى ٣', rows: 3, cols: 4, category: MemoryCategory.symbols),
    MemoryLevel(title: 'المستوى ٤', rows: 4, cols: 4, category: MemoryCategory.symbols),
    
    // Category 2: Prophets (Levels 5-8)
    MemoryLevel(title: 'المستوى ٥', rows: 3, cols: 4, category: MemoryCategory.prophets),
    MemoryLevel(title: 'المستوى ٦', rows: 4, cols: 4, category: MemoryCategory.prophets),
    MemoryLevel(title: 'المستوى ٧', rows: 4, cols: 4, category: MemoryCategory.prophets),
    MemoryLevel(title: 'المستوى ٨', rows: 4, cols: 5, category: MemoryCategory.prophets),
    
    // Category 3: Pillars of Islam (Levels 9-12)
    MemoryLevel(title: 'المستوى ٩', rows: 4, cols: 4, category: MemoryCategory.pillars),
    MemoryLevel(title: 'المستوى ١٠', rows: 4, cols: 5, category: MemoryCategory.pillars),
    MemoryLevel(title: 'المستوى ١١', rows: 4, cols: 5, category: MemoryCategory.pillars),
    MemoryLevel(title: 'المستوى ١٢', rows: 5, cols: 4, category: MemoryCategory.pillars),
    
    // Category 4: Names of Allah (Levels 13-16)
    MemoryLevel(title: 'المستوى ١٣', rows: 4, cols: 5, category: MemoryCategory.namesOfAllah),
    MemoryLevel(title: 'المستوى ١٤', rows: 5, cols: 4, category: MemoryCategory.namesOfAllah),
    MemoryLevel(title: 'المستوى ١٥', rows: 5, cols: 4, category: MemoryCategory.namesOfAllah),
    MemoryLevel(title: 'المستوى ١٦', rows: 6, cols: 4, category: MemoryCategory.namesOfAllah),
    
    // Category 5: Hijri Months (Levels 17-20)
    MemoryLevel(title: 'المستوى ١٧', rows: 4, cols: 5, category: MemoryCategory.months),
    MemoryLevel(title: 'المستوى ١٨', rows: 5, cols: 4, category: MemoryCategory.months),
    MemoryLevel(title: 'المستوى ١٩', rows: 6, cols: 4, category: MemoryCategory.months),
    MemoryLevel(title: 'المستوى ٢٠', rows: 6, cols: 5, category: MemoryCategory.months),
  ];

  int _currentLevelIndex = 0;
  List<MemoryCard> _cards = [];
  int? _firstCardIndex;
  int? _secondCardIndex;
  int _matchedPairs = 0;
  int _moves = 0;
  bool _isChecking = false;
  int _stars = 0;

  final Map<MemoryCategory, List<Map<String, String>>> _categoryData = {
    MemoryCategory.symbols: [
      {'emoji': '🕌', 'label': 'المسجد'},
      {'emoji': '📖', 'label': 'القرآن'},
      {'emoji': '🕋', 'label': 'الكعبة'},
      {'emoji': '🌙', 'label': 'الهلال'},
      {'emoji': '⭐', 'label': 'النجمة'},
      {'emoji': '🤲', 'label': 'الدعاء'},
      {'emoji': '📿', 'label': 'المسبحة'},
      {'emoji': '💧', 'label': 'الوضوء'},
    ],
    MemoryCategory.prophets: [
      {'emoji': '🐑', 'label': 'إبراهيم ع'},
      {'emoji': '🐫', 'label': 'صالح ع'},
      {'emoji': '🚢', 'label': 'نوح ع'},
      {'emoji': '🐋', 'label': 'يونس ع'},
      {'emoji': '🐍', 'label': 'موسى ع'},
      {'emoji': '🌄', 'label': 'محمد ﷺ'},
      {'emoji': '🐜', 'label': 'سليمان ع'},
      {'emoji': '⚔️', 'label': 'داوود ع'},
      {'emoji': '🥖', 'label': 'عيسى ع'},
      {'emoji': '👔', 'label': 'يوسف ع'},
    ],
    MemoryCategory.pillars: [
      {'emoji': '☝️', 'label': 'الشهادة'},
      {'emoji': '🛐', 'label': 'الصلاة'},
      {'emoji': '🥘', 'label': 'الصيام'},
      {'emoji': '💰', 'label': 'الزكاة'},
      {'emoji': '🕋', 'label': 'الحج'},
      {'emoji': '🕌', 'label': 'الجمعة'},
      {'emoji': '🌤️', 'label': 'الفجر'},
      {'emoji': '🌄', 'label': 'الظهر'},
      {'emoji': '🌇', 'label': 'العصر'},
      {'emoji': '🌆', 'label': 'المغرب'},
      {'emoji': '🌃', 'label': 'العشاء'},
    ],
    MemoryCategory.namesOfAllah: [
      {'emoji': '✨', 'label': 'الرحمن'},
      {'emoji': '🌈', 'label': 'الرحيم'},
      {'emoji': '👑', 'label': 'الملك'},
      {'emoji': '🕊️', 'label': 'القدوس'},
      {'emoji': '🛡️', 'label': 'المؤمن'},
      {'emoji': '🧿', 'label': 'المهيمن'},
      {'emoji': '🏔️', 'label': 'العزيز'},
      {'emoji': '🌪️', 'label': 'الجبار'},
      {'emoji': '🏗️', 'label': 'الخالق'},
      {'emoji': '🎨', 'label': 'المصور'},
      {'emoji': '🕯️', 'label': 'النور'},
      {'emoji': '🌍', 'label': 'الواسع'},
    ],
    MemoryCategory.months: [
      {'emoji': '🏹', 'label': 'محرم'},
      {'emoji': '🍂', 'label': 'صفر'},
      {'emoji': '🌸', 'label': 'ربيع أول'},
      {'emoji': '🌿', 'label': 'ربيع ثان'},
      {'emoji': '🌵', 'label': 'جمادى ١'},
      {'emoji': '🌴', 'label': 'جمادى ٢'},
      {'emoji': '🎋', 'label': 'رجب'},
      {'emoji': '🌾', 'label': 'شعبان'},
      {'emoji': '🌙', 'label': 'رمضان'},
      {'emoji': '🎊', 'label': 'شوال'},
      {'emoji': '📦', 'label': 'ذو القعدة'},
      {'emoji': '🕋', 'label': 'ذو الحجة'},
      {'emoji': '🐑', 'label': 'عيد الأضحى'},
      {'emoji': '🎈', 'label': 'عيد الفطر'},
      {'emoji': '🎍', 'label': 'عاشوراء'},
    ],
  };

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentLevelIndex = prefs.getInt('memory_level') ?? 0;
      _stars = prefs.getInt('memory_stars') ?? 0;
      _initializeGame();
    });
  }

  Future<void> _saveProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('memory_level', _currentLevelIndex);
    await prefs.setInt('memory_stars', _stars);
  }

  void _initializeGame() {
    final level = _levels[_currentLevelIndex];
    _cards.clear();
    _matchedPairs = 0;
    _moves = 0;
    _firstCardIndex = null;
    _secondCardIndex = null;
    _isChecking = false;

    // Select category data
    final fullData = _categoryData[level.category] ?? _categoryData[MemoryCategory.symbols]!;
    final categoryData = List<Map<String, String>>.from(fullData)..shuffle();
    
    // Ensure we have enough data for the pairs
    final levelData = categoryData.take(level.pairs).toList();

    // Create pairs
    for (int i = 0; i < levelData.length; i++) {
       final emoji = levelData[i]['emoji']!;
       final label = levelData[i]['label']!;
       final pairId = i;
       
      _cards.add(MemoryCard(id: i * 2, emoji: emoji, label: label, pairId: pairId));
      _cards.add(MemoryCard(id: i * 2 + 1, emoji: emoji, label: label, pairId: pairId));
    }

    _cards.shuffle(Random());
    setState(() {});
  }

  void _onCardTap(int index) {
    if (_isChecking) return;
    if (_cards[index].isMatched) return;
    if (_cards[index].isFaceUp) return;

    KidsSoundHelper.playClick();

    setState(() {
      _cards[index].isFaceUp = true;

      if (_firstCardIndex == null) {
        _firstCardIndex = index;
      } else if (_secondCardIndex == null) {
        _secondCardIndex = index;
        _moves++;
        _checkMatch();
      }
    });
  }

  void _checkMatch() {
    if (_firstCardIndex == null || _secondCardIndex == null) return;

    _isChecking = true;

    final firstCard = _cards[_firstCardIndex!];
    final secondCard = _cards[_secondCardIndex!];

    if (firstCard.pairId == secondCard.pairId) {
      KidsSoundHelper.playTada();
      setState(() {
        _cards[_firstCardIndex!].isMatched = true;
        _cards[_secondCardIndex!].isMatched = true;
        _matchedPairs++;
        _firstCardIndex = null;
        _secondCardIndex = null;
        _isChecking = false;
      });

      if (_matchedPairs == _levels[_currentLevelIndex].pairs) {
        _stars += 10;
        _saveProgress();
        _showWinDialog();
      }
    } else {
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted) {
          setState(() {
            _cards[_firstCardIndex!].isFaceUp = false;
            _cards[_secondCardIndex!].isFaceUp = false;
            _firstCardIndex = null;
            _secondCardIndex = null;
            _isChecking = false;
          });
        }
      });
    }
  }

  void _showWinDialog() {
    final isLastLevel = _currentLevelIndex == _levels.length - 1;
    KDialogHelper.showCustomDialog(
      context: context,
      type: KDialogType.success,
      icon: Icons.emoji_events_rounded,
      title: isLastLevel ? 'بطل العالم! 🌍🏆' : 'بطل الذاكرة! ✨',
      description: isLastLevel
          ? 'لقد أنهيت جميع الـ ٢٠ مستوى بنجاح! أنت عبقري وذاكرتك حديدية.'
          : 'أحسنت! أنهيت المستوى في $_moves محاولة. حصلت على 10 نجوم! ⭐',
      actions: [
        if (!isLastLevel)
          KDialogHelper.buildButton(
            context: context,
            label: 'المستوى التالي',
            color: Colors.deepPurple,
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _currentLevelIndex++;
                _initializeGame();
              });
            },
          ),
        KDialogHelper.buildButton(
          context: context,
          label: isLastLevel ? 'إغلاق' : 'إعادة اللعب',
          isPrimary: isLastLevel,
          onPressed: () {
            Navigator.pop(context);
            if (isLastLevel) Navigator.pop(context);
            else _initializeGame();
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final level = _levels[_currentLevelIndex];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.grey[50],
        appBar: AppBar(
          leading: CupertinoNavigationBarBackButton(
            color: isDark ? Colors.white : Colors.black,
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                   const Icon(Icons.star, color: Colors.amber, size: 20),
                   const SizedBox(width: 4),
                   Text('$_stars', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
          title: Text(
            level.title,
            style: GoogleFonts.cairo(fontSize: 14.sp, fontWeight: FontWeight.bold),
          ),
        ),
        body: Column(
          children: [
            // Stats Panel
            Container(
              margin: EdgeInsets.all(12.r),
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _getCategoryColors(level.category),
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(15.r),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: const Offset(0, 4))],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem('المحاولات', '$_moves', Icons.touch_app),
                  _buildStatItem('الأزواج', '$_matchedPairs/${level.pairs}', Icons.check_circle),
                  _buildStatItem('التقدم', '${_currentLevelIndex + 1}/${_levels.length}', Icons.trending_up),
                ],
              ),
            ),

            // Game grid
            Expanded(
              child: GridView.builder(
                padding: EdgeInsets.all(12.r),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: level.cols,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: (level.rows >= 5) ? 0.75 : 0.85,
                ),
                itemCount: _cards.length,
                itemBuilder: (context, index) {
                  return MemoryCardWidget(
                    card: _cards[index],
                    onTap: () => _onCardTap(index),
                    isDark: isDark,
                    category: level.category,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Color> _getCategoryColors(MemoryCategory cat) {
    switch (cat) {
      case MemoryCategory.symbols: return [Colors.blue, Colors.blueAccent];
      case MemoryCategory.prophets: return [Colors.green, Colors.teal];
      case MemoryCategory.pillars: return [Colors.orange, Colors.deepOrange];
      case MemoryCategory.namesOfAllah: return [Colors.purple, Colors.deepPurple];
      case MemoryCategory.months: return [Colors.redAccent, Colors.pinkAccent];
    }
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 20),
        const SizedBox(height: 2),
        Text(value, style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14.sp)),
        Text(label, style: GoogleFonts.cairo(color: Colors.white70, fontSize: 9.sp)),
      ],
    );
  }
}

class MemoryCardWidget extends StatelessWidget {
  final MemoryCard card;
  final VoidCallback onTap;
  final bool isDark;
  final MemoryCategory category;

  const MemoryCardWidget({
    super.key,
    required this.card,
    required this.onTap,
    required this.isDark,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    final isFlipped = card.isFaceUp || card.isMatched;

    return GestureDetector(
      onTap: onTap,
      child: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
        tween: Tween(begin: 0, end: isFlipped ? 180 : 0),
        builder: (context, value, child) {
          final isBack = value < 90;
          return Transform(
            transform: Matrix4.identity()..setEntry(3, 2, 0.001)..rotateY(value * pi / 180),
            alignment: Alignment.center,
            child: isBack
                ? _buildBack(isDark)
                : Transform(
                    transform: Matrix4.identity()..rotateY(pi),
                    alignment: Alignment.center,
                    child: _buildFront(isDark),
                  ),
          );
        },
      ),
    );
  }

  Widget _buildBack(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark 
            ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
            : [Colors.grey.shade200, Colors.grey.shade300],
        ),
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 2, offset: const Offset(0, 1))],
      ),
      child: Center(
        child: Text('؟', style: TextStyle(fontSize: 24.sp, color: Colors.grey.withOpacity(0.5))),
      ),
    );
  }

  Widget _buildFront(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: card.isMatched ? Colors.green.withOpacity(0.1) : (isDark ? const Color(0xFF1E293B) : Colors.white),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: card.isMatched ? Colors.green : Colors.transparent,
          width: 2,
        ),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 2, offset: const Offset(0, 1))],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(card.emoji, style: TextStyle(fontSize: 28.sp)),
          const SizedBox(height: 2),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Text(
              card.label,
              style: GoogleFonts.cairo(
                fontSize: 8.sp,
                fontWeight: FontWeight.bold,
                color: card.isMatched ? Colors.green : (isDark ? Colors.white70 : Colors.black87),
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class MemoryCard {
  final int id;
  final String emoji;
  final String label;
  final int pairId;
  bool isFaceUp;
  bool isMatched;

  MemoryCard({
    required this.id,
    required this.emoji,
    required this.label,
    required this.pairId,
    this.isFaceUp = false,
    this.isMatched = false,
  });
}
