import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:math';
import '../../../core/utils/style/responsive_util.dart';

class MemoryGameScreen extends StatefulWidget {
  const MemoryGameScreen({super.key});

  @override
  State<MemoryGameScreen> createState() => _MemoryGameScreenState();
}

class _MemoryGameScreenState extends State<MemoryGameScreen> {
  final List<MemoryCard> _cards = [];
  int? _firstCardIndex;
  int? _secondCardIndex;
  int _matchedPairs = 0;
  int _moves = 0;
  bool _isChecking = false;

  final List<Map<String, String>> _cardData = [
    {'emoji': '🕌', 'label': 'المسجد'},
    {'emoji': '📖', 'label': 'القرآن'},
    {'emoji': '🤲', 'label': 'الدعاء'},
    {'emoji': '🌙', 'label': 'رمضان'},
    {'emoji': '⭐', 'label': 'النجم'},
    {'emoji': '💧', 'label': 'الماء'},
    {'emoji': '🕊️', 'label': 'الحمامة'},
    {'emoji': '🌺', 'label': 'الزهرة'},
  ];

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  void _initializeGame() {
    _cards.clear();
    _matchedPairs = 0;
    _moves = 0;
    _firstCardIndex = null;
    _secondCardIndex = null;

    // Create pairs
    for (int i = 0; i < _cardData.length; i++) {
      _cards.add(MemoryCard(
        id: i * 2,
        emoji: _cardData[i]['emoji']!,
        label: _cardData[i]['label']!,
        pairId: i,
      ));
      _cards.add(MemoryCard(
        id: i * 2 + 1,
        emoji: _cardData[i]['emoji']!,
        label: _cardData[i]['label']!,
        pairId: i,
      ));
    }

    // Shuffle
    _cards.shuffle(Random());
    setState(() {});
  }

  void _onCardTap(int index) {
    if (_isChecking) return;
    if (_cards[index].isMatched) return;
    if (_cards[index].isFaceUp) return;

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
      // Match!
      setState(() {
        _cards[_firstCardIndex!].isMatched = true;
        _cards[_secondCardIndex!].isMatched = true;
        _matchedPairs++;
        _firstCardIndex = null;
        _secondCardIndex = null;
        _isChecking = false;
      });

      if (_matchedPairs == _cardData.length) {
        _showWinDialog();
      }
    } else {
      // No match - flip back after delay
      Future.delayed(const Duration(milliseconds: 1000), () {
        setState(() {
          _cards[_firstCardIndex!].isFaceUp = false;
          _cards[_secondCardIndex!].isFaceUp = false;
          _firstCardIndex = null;
          _secondCardIndex = null;
          _isChecking = false;
        });
      });
    }
  }

  void _showWinDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Text('🎉'),
            const SizedBox(width: 8),
            Text(
              'فزت!',
              style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(
          'أحسنت! أنهيت اللعبة في $_moves خطوة.\nلقد حصلت على 25 نجمة! ⭐',
          style: GoogleFonts.cairo(fontSize: 16.sp),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _initializeGame();
            },
            child: Text(
              'العب مرة أخرى',
              style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close game
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'رائع!',
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'لعبة الذاكرة 🧠',
            style: GoogleFonts.cairo(
              fontWeight: FontWeight.bold,
              fontSize: ResponsiveUtil.isTablet(context) ? 14.sp : 20.sp,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _initializeGame,
              tooltip: 'لعبة جديدة',
            ),
          ],
        ),
        body: Column(
          children: [
            // Score panel
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF9C27B0), Color(0xFF7B1FA2)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildScoreItem('الحركات', '$_moves', Icons.touch_app),
                  _buildScoreItem('الأزواج',
                      '$_matchedPairs/${_cardData.length}', Icons.check_circle),
                ],
              ),
            ),

            // Game grid
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.8,
                ),
                itemCount: _cards.length,
                itemBuilder: (context, index) {
                  return _buildCard(index, isDark);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreItem(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.white, size: 20),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.cairo(
                fontSize: ResponsiveUtil.isTablet(context) ? 8.sp : 12.sp,
                color: Colors.white70,
              ),
            ),
            Text(
              value,
              style: GoogleFonts.cairo(
                fontSize: ResponsiveUtil.isTablet(context) ? 10.sp : 16.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCard(int index, bool isDark) {
    final card = _cards[index];
    final isFlipped = card.isFaceUp || card.isMatched;

    return GestureDetector(
      onTap: () => _onCardTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: isFlipped
              ? (card.isMatched ? Colors.green : Colors.white)
              : (isDark ? const Color(0xFF1E293B) : Colors.blue.shade100),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isFlipped ? Colors.green : Colors.blue.shade300,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: isFlipped
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      card.emoji,
                      style: TextStyle(
                        fontSize: ResponsiveUtil.isTablet(context) ? 20 : 30,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      card.label,
                      style: GoogleFonts.cairo(
                        fontSize:
                            ResponsiveUtil.isTablet(context) ? 7.sp : 10.sp,
                        fontWeight: FontWeight.bold,
                        color: card.isMatched ? Colors.white : Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                )
              : const Icon(Icons.question_mark, size: 40, color: Colors.blue),
        ),
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
