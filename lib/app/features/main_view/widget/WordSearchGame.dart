import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/utils/style/responsive_util.dart';
import 'kids_data/sounds_helper.dart';
import 'dart:math';

class WordSearchGame extends StatefulWidget {
  const WordSearchGame({super.key});

  @override
  State<WordSearchGame> createState() => _WordSearchGameState();
}

class _WordSearchGameState extends State<WordSearchGame> {
  final List<String> _wordsToFind = ['الله', 'محمد', 'مسجد', 'قرآن', 'صلاة'];
  final List<String> _foundWords = [];

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
        _selectedCells.clear();
        _selectedWord = '';
      });

      KidsSoundHelper.playSuccess();

      if (_foundWords.length == _wordsToFind.length) {
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
              'رائع!',
              style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🔍', style: TextStyle(fontSize: 60)),
            const SizedBox(height: 16),
            Text(
              'وجدت جميع الكلمات!',
              style: GoogleFonts.cairo(
                  fontSize: 18.sp, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 30),
                const SizedBox(width: 8),
                Text(
                  '+20',
                  style: GoogleFonts.cairo(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
            ),
            child: Text(
              'تمام',
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
            'البحث عن الكلمات 🔍',
            style: GoogleFonts.cairo(
              fontWeight: FontWeight.bold,
              fontSize: ResponsiveUtil.isTablet(context) ? 14.sp : 20.sp,
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
                    style: GoogleFonts.cairo(
                      fontSize:
                          ResponsiveUtil.isTablet(context) ? 11.sp : 16.sp,
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
                              style: GoogleFonts.cairo(
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
                                style: GoogleFonts.cairo(
                                  fontSize: ResponsiveUtil.isTablet(context)
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
                      style: GoogleFonts.cairo(
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
                          style: GoogleFonts.cairo(
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
