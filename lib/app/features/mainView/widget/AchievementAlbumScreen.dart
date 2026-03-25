import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/utils/style/responsive_util.dart';

class AchievementAlbumScreen extends StatelessWidget {
  final int totalStars;
  final List<Map<String, dynamic>> unlockedBadges;
  final int completedStories;
  final int completedGames;
  final int streakDays;

  const AchievementAlbumScreen({
    super.key,
    required this.totalStars,
    required this.unlockedBadges,
    required this.completedStories,
    required this.completedGames,
    required this.streakDays,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'ألبوم الإنجازات 📸',
            style: TextStyle(
                  fontFamily: "cairo",
              fontWeight: FontWeight.bold,
              fontSize: ResponsiveUtil.isTablet(context) ? 14.sp : 20.sp,
            ),
          ),
          centerTitle: true,
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Overall stats
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text('🏆', style: TextStyle(fontSize: 50)),
                  const SizedBox(height: 12),
                  Text(
                    'إجمالي النجوم',
                    style: TextStyle(
                  fontFamily: "cairo",
                      fontSize:
                          ResponsiveUtil.isTablet(context) ? 11.sp : 16.sp,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    '$totalStars ⭐',
                    style: TextStyle(
                  fontFamily: "cairo",
                      fontSize:
                          ResponsiveUtil.isTablet(context) ? 18.sp : 32.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.3,
              children: [
                _buildStatCard(
                  '📚',
                  'قصص مقروءة',
                  '$completedStories',
                  Colors.blue,
                  isDark,
                  context,
                ),
                _buildStatCard(
                  '🎮',
                  'ألعاب مكتملة',
                  '$completedGames',
                  Colors.purple,
                  isDark,
                  context,
                ),
                _buildStatCard(
                  '🔥',
                  'أطول سلسلة',
                  '$streakDays يوم',
                  Colors.orange,
                  isDark,
                  context,
                ),
                _buildStatCard(
                  '🏅',
                  'شارات مفتوحة',
                  '${unlockedBadges.length}',
                  Colors.green,
                  isDark,
                  context,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Badges section
            Text(
              'الشارات المفتوحة 🏅',
              style: TextStyle(
                  fontFamily: "cairo",
                fontSize: ResponsiveUtil.isTablet(context) ? 12.sp : 18.sp,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 12),

            if (unlockedBadges.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color:
                      isDark ? const Color(0xFF1E293B) : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Column(
                    children: [
                      const Text('🎯', style: TextStyle(fontSize: 40)),
                      const SizedBox(height: 12),
                      Text(
                        'لا توجد شارات بعد\nابدأ بجمع النجوم!',
                        style: TextStyle(
                  fontFamily: "cairo",
                          fontSize: 14.sp,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            else
              ...unlockedBadges.map((badge) => Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.amber, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.amber.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Icon(
                              badge['icon'] as IconData,
                              color: Colors.amber,
                              size: 30,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                badge['title'],
                                style: TextStyle(
                  fontFamily: "cairo",
                                  fontSize: ResponsiveUtil.isTablet(context)
                                      ? 11.sp
                                      : 16.sp,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                badge['desc'],
                                style: TextStyle(
                  fontFamily: "cairo",
                                  fontSize: ResponsiveUtil.isTablet(context)
                                      ? 9.sp
                                      : 12.sp,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.check_circle,
                            color: Colors.green, size: 28),
                      ],
                    ),
                  )),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String emoji, String label, String value, Color color,
      bool isDark, context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 35)),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
                  fontFamily: "cairo",
              fontSize: ResponsiveUtil.isTablet(context) ? 9.sp : 12.sp,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
                  fontFamily: "cairo",
              fontSize: ResponsiveUtil.isTablet(context) ? 12.sp : 18.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
