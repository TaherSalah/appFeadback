import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:muslimdaily/app/core/extensions/context_extension.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/utils/style/k_dialog_helper.dart';
import 'kids_data/sounds_helper.dart';

class WordSearchGame extends StatefulWidget {
  const WordSearchGame({super.key});

  @override
  State<WordSearchGame> createState() => _WordSearchGameState();
}

class _WordSearchGameState extends State<WordSearchGame> {
  final List<String> _wordsToFind = ['الله', 'محمد', 'مسجد', 'قرآن', 'صلاة'];
  final List<String> _foundWords = [];
  int _score = 0;
  int _highScore = 0;

  @override
  void initState() {
    super.initState();
    _loadHighScore();
  }

  Future<void> _loadHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _highScore = prefs.getInt('word_search_high_score') ?? 0;
    });
  }

  Future<void> _saveHighScore() async {
    if (_score > _highScore) {
      _highScore = _score;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('word_search_high_score', _highScore);
    }
  }

  final List<List<String>> _grid = [
    ['ا', 'ل', 'ل', 'ه', 'ص'],
    ['م', 'س', 'ج', 'د', 'ل'],
    ['ح', 'م', 'د', 'ق', 'ا'],
    ['م', 'ح', 'م', 'د', 'ة'],
    ['ق', 'ر', 'آ', 'ن', 'و'],
  ];

  String _selectedWord = '';
  final List<String> _selectedCells = [];

  void _onCellTap(int row, int col) {
    final cellId = '$row-$col';

    setState(() {
      if (_selectedCells.contains(cellId)) {
        _selectedCells.remove(cellId);
      } else {
        _selectedCells.add(cellId);
      }
      _selectedWord = _selectedCells.map((id) {
        final parts = id.split('-');
        final r = int.parse(parts[0]);
        final c = int.parse(parts[1]);
        return _grid[r][c];
      }).join('');
    });
  }

  void _checkWord() {
    if (_wordsToFind.contains(_selectedWord) &&
        !_foundWords.contains(_selectedWord)) {
      setState(() {
        _foundWords.add(_selectedWord);
        _score += 10; // 10 points per word
        _selectedCells.clear();
        _selectedWord = '';
      });

      KidsSoundHelper.playSuccess();

      if (_foundWords.length == _wordsToFind.length) {
        _saveHighScore();
        _showWinDialog();
      }
    } else {
      setState(() {
        _selectedCells.clear();
        _selectedWord = '';
      });
    }
  }

  void _showWinDialog() {
    KDialogHelper.showCustomDialog(
      context: context,
      type: KDialogType.success,
      icon: Icons.emoji_events_rounded,
      title: 'رائع يا بطل! 🎉',
      description: 'لقد وجدت جميع الكلمات بنجاح وتستحق هذه المكافأة!',
      additionalContent: Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.stars_rounded, color: Color(0xFFF59E0B), size: 28),
                const SizedBox(width: 10),
                Text(
                  'لقد حصلت على $_score نقطة! ✨',
                  style: TextStyle(
                      fontFamily: "cairo",
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF10B981),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'أعلى نتيجة: $_highScore ✨',
              style: TextStyle(
                fontFamily: "cairo",
                fontSize: 14.sp,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
      actions: [
        KDialogHelper.buildButton(
          context: context,
          label: 'رائع!',
          color: const Color(0xFF10B981),
          onPressed: () {
            Navigator.pop(context);
            Navigator.pop(context);
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'البحث عن الكلمات 🔍',
            style: TextStyle(
                  fontFamily: "cairo",
              fontWeight: FontWeight.bold,
              fontSize: context.isTab ? 14.sp : 20.sp,
            ),
          ),
          centerTitle: true,
        ),
        body: Column(
          children: [
            // Words to find
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ابحث عن هذه الكلمات:',
                    style: TextStyle(
                  fontFamily: "cairo",
                      fontSize:
                          context.isTab ? 11.sp : 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _wordsToFind.map((word) {
                      final found = _foundWords.contains(word);
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: found
                              ? Colors.green
                              : Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (found)
                              const Icon(Icons.check,
                                  color: Colors.white, size: 16),
                            if (found) const SizedBox(width: 4),
                            Text(
                              word,
                              style: TextStyle(
                  fontFamily: "cairo",
                                color: Colors.white,
                                fontWeight:
                                    found ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            // Score Header
            Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.stars, color: Colors.amber),
                      const SizedBox(width: 8),
                      Text(
                        'النتيجة: $_score',
                        style: TextStyle(
                          fontFamily: "cairo",
                          fontWeight: FontWeight.bold,
                          fontSize: 14.sp,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'الأفضل: $_highScore',
                    style: TextStyle(
                      fontFamily: "cairo",
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                      fontSize: 14.sp,
                    ),
                  ),
                ],
              ),
            ),

            // Grid
            Expanded(
              child: Center(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 5,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: 25,
                      itemBuilder: (context, index) {
                        final row = index ~/ 5;
                        final col = index % 5;
                        final cellId = '$row-$col';
                        final isSelected = _selectedCells.contains(cellId);

                        return GestureDetector(
                          onTap: () => _onCellTap(row, col),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.blue.shade300
                                  : (isDark
                                      ? const Color(0xFF1E293B)
                                      : Colors.white),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? Colors.blue
                                    : Colors.grey.shade300,
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                _grid[row][col],
                                style: TextStyle(
                  fontFamily: "cairo",
                                  fontSize: context.isTab
                                      ? 14.sp
                                      : 20.sp,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected
                                      ? Colors.white
                                      : (isDark
                                          ? Colors.white
                                          : Colors.black87),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),

            // Check button
            if (_selectedWord.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      'الكلمة: $_selectedWord',
                      style: TextStyle(
                  fontFamily: "cairo",
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _checkWord,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4CAF50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'تحقق',
                          style: TextStyle(
                  fontFamily: "cairo",
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
