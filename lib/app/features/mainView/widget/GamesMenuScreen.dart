import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/utils/style/responsive_util.dart';
import 'MemoryGameScreen.dart';
import 'PuzzleGameScreen.dart';
import 'QuizGameScreen.dart';
import 'InteractiveWuduScreen.dart';
import 'PrayerMovementsGame.dart';
import 'AllahNamesGame.dart';
import 'WordSearchGame.dart';
import 'IslamicColoringGame.dart';

class GamesMenuScreen extends StatelessWidget {
  const GamesMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'الألعاب التعليمية 🎮',
            style: GoogleFonts.cairo(
              fontWeight: FontWeight.bold,
              fontSize: ResponsiveUtil.isTablet(context) ? 14.sp : 20.sp,
            ),
          ),
          centerTitle: true,
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildGameCard(
              context,
              title: 'لعبة الذاكرة',
              emoji: '🧠',
              description: 'طابق البطاقات المتشابهة',
              color: const Color(0xFF9C27B0),
              reward: 25,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MemoryGameScreen()),
              ),
              isDark: isDark,
            ),
            const SizedBox(height: 16),
            _buildGameCard(
              context,
              title: 'لعبة ترتيب الوضوء',
              emoji: '💧',
              description: 'رتب خطوات الوضوء الصحيحة',
              color: const Color(0xFF00BCD4),
              reward: 30,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PuzzleGameScreen()),
              ),
              isDark: isDark,
            ),
            const SizedBox(height: 16),
            _buildGameCard(
              context,
              title: 'اختبر معلوماتك',
              emoji: '🧠',
              description: 'أسئلة إسلامية ممتعة',
              color: const Color(0xFFE91E63),
              reward: 40,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const QuizGameScreen()),
              ),
              isDark: isDark,
            ),
            const SizedBox(height: 16),
            _buildGameCard(
              context,
              title: 'تعليم الوضوء التفاعلي',
              emoji: '🚿',
              description: 'تعلم الوضوء خطوة بخطوة',
              color: const Color(0xFF2196F3),
              reward: 50,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const InteractiveWuduScreen()),
              ),
              isDark: isDark,
            ),
            const SizedBox(height: 16),
            _buildGameCard(
              context,
              title: 'تعليم حركات الصلاة',
              emoji: '🙏',
              description: 'تعلم حركات الصلاة بطريقة ممتعة',
              color: const Color(0xFF4CAF50),
              reward: 40,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PrayerMovementsGame()),
              ),
              isDark: isDark,
            ),
            const SizedBox(height: 16),
            _buildGameCard(
              context,
              title: 'أسماء الله الحسنى',
              emoji: '🌟',
              description: 'تعلم أسماء الله ومعانيها',
              color: const Color(0xFFFFD700),
              reward: 75,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AllahNamesGame()),
              ),
              isDark: isDark,
            ),
            const SizedBox(height: 16),
            _buildGameCard(
              context,
              title: 'البحث عن الكلمات',
              emoji: '🔍',
              description: 'ابحث عن الكلمات الإسلامية',
              color: const Color(0xFF2196F3),
              reward: 20,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const WordSearchGame()),
              ),
              isDark: isDark,
            ),
            const SizedBox(height: 16),
            _buildGameCard(
              context,
              title: 'التلوين الإسلامي',
              emoji: '🎨',
              description: 'لوّن الأشكال الإسلامية',
              color: const Color(0xFFFF5722),
              reward: 15,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const IslamicColoringGame()),
              ),
              isDark: isDark,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameCard(
    BuildContext context, {
    required String title,
    required String emoji,
    required String description,
    required Color color,
    required int reward,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color, color.withOpacity(0.7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  emoji,
                  style: const TextStyle(fontSize: 35),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.cairo(
                      fontSize:
                          ResponsiveUtil.isTablet(context) ? 12.sp : 18.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: GoogleFonts.cairo(
                      fontSize: ResponsiveUtil.isTablet(context) ? 9.sp : 12.sp,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        'حتى $reward نجمة',
                        style: GoogleFonts.cairo(
                          fontSize:
                              ResponsiveUtil.isTablet(context) ? 8.sp : 11.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
