import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:muslimdaily/app/core/extensions/context_extension.dart';
import 'package:muslimdaily/app/core/utils/style/k_color.dart';
import '../../../core/utils/style/responsive_util.dart';
import 'MemoryGameScreen.dart';
import 'PuzzleGameScreen.dart';
import 'QuizGameScreen.dart';
import 'AllahNamesGame.dart';
import 'flame_games/flame_game_wrapper.dart';
import 'flame_games/fruit_collector_game.dart';
import 'flame_games/sunnah_hero_runner.dart';
import 'flame_games/kaaba_protector_game.dart';
import 'flame_games/quran_word_connector.dart';
import 'IslamicColoringScreen.dart';

class GamesMenuScreen extends StatelessWidget {
  final VoidCallback? onRefresh;
  const GamesMenuScreen({super.key, this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
 final isTablet=   context.isTablet;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        // appBar: AppBar(
        //   title: Text(
        //     'الألعاب التعليمية 🎮',
        //     style: GoogleFonts.cairo(
        //       fontWeight: FontWeight.bold,
        //       fontSize: ResponsiveUtil.isTablet(context) ? 14.sp : 20.sp,
        //     ),
        //   ),
        //   centerTitle: true,
        // ),
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(
            isTablet ? 70 : 50,
          ),
          child: AppBar(
            leading: CupertinoNavigationBarBackButton(
              color: isDark ? Colors.white : Colors.black,
            ),
            centerTitle: true,
            title: Text(
              "الألعاب التعليمية",
              style: GoogleFonts.cairo(
                color: Colors.green,
                fontWeight: FontWeight.bold,
                fontSize:
                isTablet ? 12.sp : 18.sp,
              ),
            ),
          ),
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
            // _buildGameCard(
            //   context,
            //   title: 'تعليم الوضوء التفاعلي',
            //   emoji: '🚿',
            //   description: 'تعلم الوضوء خطوة بخطوة',
            //   color: const Color(0xFF2196F3),
            //   reward: 50,
            //   onTap: () => Navigator.push(
            //     context,
            //     MaterialPageRoute(
            //         builder: (_) => const InteractiveWuduScreen()),
            //   ),
            //   isDark: isDark,
            // ),
            // const SizedBox(height: 16),
            // _buildGameCard(
            //   context,
            //   title: 'تعليم حركات الصلاة',
            //   emoji: '🙏',
            //   description: 'تعلم حركات الصلاة بطريقة ممتعة',
            //   color: const Color(0xFF4CAF50),
            //   reward: 40,
            //   onTap: () => Navigator.push(
            //     context,
            //     MaterialPageRoute(builder: (_) => const PrayerMovementsGame()),
            //   ),
            //   isDark: isDark,
            // ),
            // const SizedBox(height: 16),
            _buildGameCard(
              context,
              title: 'أسماء الله الحسنى',
              emoji: '🌟',
              description: 'تعلم أسماء الله ومعانيها',
              color: KColors.primaryColor,
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
              title: 'جامع الفواكه الحلال',
              emoji: '🍎',
              description: 'اجمع الحلال وتجنب الحرام',
              color: Colors.orange,
              reward: 50,
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FlameGameWrapper(
                      game: FruitCollectorGame(),
                      title: 'جامع الفواكه الحلال',
                    ),
                  ),
                );
                onRefresh?.call();
              },
              isDark: isDark,
            ),
            const SizedBox(height: 16),
            _buildGameCard(
              context,
              title: 'بطل السنة',
              emoji: '🏃',
              description: 'اجمع الحسنات وتخطى العقبات',
              color: Colors.indigo,
              reward: 100,
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FlameGameWrapper(
                      game: SunnahHeroRunner(),
                      title: 'بطل السنة',
                    ),
                  ),
                );
                onRefresh?.call();
              },
              isDark: isDark,
            ),
            // const SizedBox(height: 16),
            // _buildGameCard(
            //   context,
            //   title: 'حامي الكعبة',
            //   emoji: '🕋',
            //   description: 'احمِ الكعبة من الفيلة',
            //   color: Colors.black87,
            //   reward: 120,
            //   onTap: () async {
            //     await Navigator.push(
            //       context,
            //       MaterialPageRoute(
            //         builder: (_) => FlameGameWrapper(
            //           game: KaabaProtectorGame(),
            //           title: 'حامي الكعبة',
            //         ),
            //       ),
            //     );
            //     onRefresh?.call();
            //   },
            //   isDark: isDark,
            // ),
            const SizedBox(height: 16),
            // _buildGameCard(
            //   context,
            //   title: 'بناء المسجد',
            //   emoji: '🕌',
            //   description: 'ابنِ أعلى مئذنة ومسجد',
            //   color: Colors.teal,
            //   reward: 80,
            //   onTap: () async {
            //     await Navigator.push(
            //       context,
            //       MaterialPageRoute(
            //         builder: (_) => FlameGameWrapper(
            //           game: MosqueStackerGame(),
            //           title: 'بناء المسجد',
            //         ),
            //       ),
            //     );
            //     onRefresh?.call();
            //   },
            //   isDark: isDark,
            // ),
            // const SizedBox(height: 16),
            _buildGameCard(
              context,
              title: 'موصّل كلمات القرآن',
              emoji: '🧩',
              description: 'ركب حروف الكلمات القرآنية',
              color: Colors.deepPurple,
              reward: 90,
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FlameGameWrapper(
                      game: QuranWordConnector(),
                      title: 'موصّل كلمات القرآن',
                    ),
                  ),
                );
                onRefresh?.call();
              },
              isDark: isDark,
            ),
            const SizedBox(height: 16),
            // _buildGameCard(
            //   context,
            //   title: 'تلوين الأحاديث',
            //   emoji: '🎨',
            //   description: 'لوّن أحاديث نبينا واحصل على نجوم',
            //   color: Colors.pinkAccent,
            //   reward: 40,
            //   onTap: () => Navigator.push(
            //     context,
            //     MaterialPageRoute(builder: (_) => const IslamicColoringScreen()),
            //   ),
            //   isDark: isDark,
            // ),
            // const SizedBox(height: 16),
            // _buildGameCard(
            //   context,
            //   title: 'رحلة الحج',
            //   emoji: '🚶‍♂️',
            //   description: 'انطلق في رحلة بين المشاعر',
            //   color: Colors.lightGreen,
            //   reward: 150,
            //   onTap: () async {
            //     await Navigator.push(
            //       context,
            //       MaterialPageRoute(
            //         builder: (_) => FlameGameWrapper(
            //           game: HajjJourneyGame(),
            //           title: 'رحلة الحج',
            //         ),
            //       ),
            //     );
            //     onRefresh?.call();
            //   },
            //   isDark: isDark,
            // ),
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
