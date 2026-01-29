import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muslimdaily/app/core/widgets/KLoading.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:animate_do/animate_do.dart';
import '../../../core/services/content_service.dart';
import '../../../core/utils/style/app_theme_colors.dart';
import '../../../core/utils/style/k_color.dart';
import 'StoryReaderScreen.dart';

class KidsStoriesScreen extends StatefulWidget {
  const KidsStoriesScreen({super.key});

  @override
  State<KidsStoriesScreen> createState() => _KidsStoriesScreenState();
}

class _KidsStoriesScreenState extends State<KidsStoriesScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _stories = [];
  List<Map<String, dynamic>> _filteredStories = [];
  String _selectedCategory = 'الكل';
  int _userStars = 0;
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, String>> _categories = [
    {'name': 'الكل', 'emoji': '🌈', 'color': '0xFF0EA5E9'},
    {'name': 'قصص الأنبياء', 'emoji': '📖', 'color': '0xFF6366F1'},
    {'name': 'أخلاق', 'emoji': '🌟', 'color': '0xFFF59E0B'},
    {'name': 'صحابة', 'emoji': '🕌', 'color': '0xFF10B981'},
    {'name': 'عبر', 'emoji': '💡', 'color': '0xFFEC4899'},
  ];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await _loadStories();
    await _loadUserStars();
  }

  Future<void> _loadUserStars() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userStars = prefs.getInt('kids_total_stars_v2') ?? 0;
    });
  }

  Future<void> _updateStars(int additionalStars) async {
    final prefs = await SharedPreferences.getInstance();
    final newStars = _userStars + additionalStars;
    await prefs.setInt('kids_total_stars_v2', newStars);
    setState(() {
      _userStars = newStars;
    });
  }

  Future<void> _loadStories() async {
    setState(() => _isLoading = true);
    try {
      final data = await ContentService().getKidsStories();
      setState(() {
        _stories = data;
        _filteredStories = data;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading kids stories: $e');
      setState(() => _isLoading = false);
    }
  }

  void _applyFilters() {
    setState(() {
      final query = _searchController.text.toLowerCase();
      _filteredStories = _stories.where((s) {
        final title = (s['title'] ?? '').toString().toLowerCase();
        final content = (s['content'] ?? '').toString().toLowerCase();
        final category = (s['category'] ?? '').toString();

        bool matchesQuery = title.contains(query) || content.contains(query);
        bool matchesCategory = _selectedCategory == 'الكل' || category == _selectedCategory;

        return matchesQuery && matchesCategory;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Playful Header
            SliverAppBar(
              expandedHeight: 180.h,
              pinned: true,
              backgroundColor: const Color(0xFF0EA5E9),
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF0EA5E9), Color(0xFF38BDF8)],
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned(
                        left: -20,
                        bottom: -10,
                        child: Opacity(
                          opacity: 0.1,
                          child: Icon(Icons.child_care_rounded, size: 150.sp, color: Colors.white),
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'ركن الطفل المسلم 🧸',
                            style: GoogleFonts.cairo(
                              fontWeight: FontWeight.bold,
                              fontSize: 24.sp,
                              color: Colors.white,
                              shadows: [Shadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 2))],
                            ),
                          ),
                          Text(
                            'قصص وعبر ومغامرات جميلة ✨',
                            style: GoogleFonts.cairo(
                              fontSize: 14.sp,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Stats Card (Achievement) V2
            SliverToBoxAdapter(
              child: FadeInDown(child: _buildAchievementCard(isDark)),
            ),

            // Categories Header
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                child: Row(
                  children: [
                    Text(
                      'اختر مغامرتك القادمة 🚀',
                      style: GoogleFonts.cairo(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const Spacer(),
                    Icon(Icons.auto_stories_rounded, color: const Color(0xFF0EA5E9), size: 20.sp),
                  ],
                ),
              ),
            ),

            // Categories
            SliverToBoxAdapter(
              child: _buildCategoriesSection(isDark),
            ),

            // Search Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
                    borderRadius: BorderRadius.circular(20.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (_) => _applyFilters(),
                    style: GoogleFonts.cairo(fontSize: 14.sp),
                    decoration: InputDecoration(
                      hintText: 'ابحث عن قصة جميلة... 🔍',
                      hintStyle: GoogleFonts.cairo(color: Colors.grey.shade400, fontSize: 13.sp),
                      prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF0EA5E9)),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    ),
                  ),
                ),
              ),
            ),

            // Vertical Shelf Grid (V2 Redesign)
            _isLoading
                ? SliverFillRemaining(child: Center(child: KLoading.progressIOSIndicator(context: context)))
                : _filteredStories.isEmpty
                    ? SliverFillRemaining(child: _buildEmptyState(isDark))
                    : SliverPadding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        sliver: SliverGrid(
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.7,
                            crossAxisSpacing: 16.w,
                            mainAxisSpacing: 16.h,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, index) => FadeInUp(
                              delay: Duration(milliseconds: index * 50),
                              child: _buildBookCoverCard(_filteredStories[index], isDark),
                            ),
                            childCount: _filteredStories.length,
                          ),
                        ),
                      ),
            SliverToBoxAdapter(child: SizedBox(height: 100.h)),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('🌈', style: TextStyle(fontSize: 80.sp)),
          SizedBox(height: 10.h),
          Text(
            'لا توجد قصص بهذا الاسم حالياً!',
            style: GoogleFonts.cairo(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
          SizedBox(height: 5.h),
          Text(
            'جرب البحث بكلمات أخرى أو اختر تصنيفاً مختلفاً',
            style: GoogleFonts.cairo(
              fontSize: 12.sp,
              color: isDark ? Colors.white38 : Colors.black38,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementCard(bool isDark) {
    final nextLevelStars = ((_userStars / 100).floor() + 1) * 100;
    final progress = (_userStars % 100) / 100;
    final level = (_userStars / 100).floor() + 1;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 15.h),
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark 
            ? [const Color(0xFF1E293B), const Color(0xFF0F172A)] 
            : [const Color(0xFF0EA5E9), const Color(0xFF0284C7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30.r),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : const Color(0xFF0284C7)).withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Text(
                    'مستواك: بطل مغامر $level 🏆',
                    style: GoogleFonts.cairo(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12.sp,
                    ),
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  'لقد جمعت $_userStars نجمة! ✨',
                  style: GoogleFonts.cairo(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20.sp,
                  ),
                ),
                SizedBox(height: 15.h),
                Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      height: 12.h,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    FractionallySizedBox(
                      alignment: Alignment.centerRight,
                      widthFactor: progress,
                      child: Container(
                        height: 12.h,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Color(0xFFF59E0B), Color(0xFFFBBF24)]),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Text(
                  'بقي لك ${nextLevelStars - _userStars} نجوم للمستوى القادم',
                  style: GoogleFonts.cairo(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 11.sp,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 20.w),
          Container(
            padding: EdgeInsets.all(15.w),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: ZoomIn(
              child: Icon(Icons.stars_rounded, size: 50.sp, color: Colors.amber),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesSection(bool isDark) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: _categories.map((cat) {
          final isSelected = _selectedCategory == cat['name'];
          final color = Color(int.parse(cat['color']!));
          return GestureDetector(
            onTap: () {
              setState(() => _selectedCategory = cat['name']!);
              _applyFilters();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: EdgeInsets.symmetric(horizontal: 4.w),
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: isSelected ? color : (isDark ? Colors.white.withOpacity(0.05) : Colors.white),
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: isSelected ? Colors.transparent : (isDark ? Colors.white10 : Colors.black12),
                ),
                boxShadow: isSelected ? [
                  BoxShadow(color: color.withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 4))
                ] : [],
              ),
              child: Row(
                children: [
                  Text(cat['emoji']!, style: TextStyle(fontSize: 16.sp)),
                  SizedBox(width: 8.w),
                  Text(
                    cat['name']!,
                    style: GoogleFonts.cairo(
                      fontSize: 14.sp,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBookCoverCard(Map<String, dynamic> story, bool isDark) {
    const covers = [
      [Color(0xFFE0F2FE), Color(0xFFBAE6FD)], // Blue
      [Color(0xFFFEF9C3), Color(0xFFFEF08A)], // Yellow
      [Color(0xFFF0FDF4), Color(0xFFDCFCE7)], // Green
      [Color(0xFFFDF2F8), Color(0xFFFCE7F3)], // Pink
      [Color(0xFFF5F3FF), Color(0xFFEDE9FE)], // Purple
    ];
    final random = (story['id']?.toString().hashCode ?? 0) % covers.length;
    final gradient = covers[random];

    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          CupertinoPageRoute(builder: (context) => StoryReaderScreen(story: story)),
        );
        if (result == true) {
          _updateStars(story['stars_reward'] ?? 10);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(25.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(25.r),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Cover Top
                  Expanded(
                    flex: 3,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: gradient,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Center(
                        child: ZoomIn(
                          child: Text(
                            story['emoji'] ?? '📖',
                            style: TextStyle(fontSize: 60.sp),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Cover Bottom (Title)
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: EdgeInsets.all(12.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            story['title'] ?? '',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.cairo(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.bold,
                              height: 1.3,
                              color: isDark ? Colors.white : const Color(0xFF1E293B),
                            ),
                          ),
                          const Spacer(),
                          Row(
                            children: [
                              Icon(Icons.stars_rounded, size: 14.sp, color: Colors.amber),
                              SizedBox(width: 4.w),
                              Text(
                                '${story['stars_reward'] ?? 10}',
                                style: GoogleFonts.cairo(
                                  fontSize: 11.sp,
                                  color: Colors.amber.shade700,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              // Ribbon for "New" or category
              Positioned(
                top: 10,
                right: 0,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0EA5E9),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10.r),
                      bottomLeft: Radius.circular(10.r),
                    ),
                  ),
                  child: Text(
                    story['category'] ?? 'منوع',
                    style: GoogleFonts.cairo(color: Colors.white, fontSize: 10.sp, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStoryCard(Map<String, dynamic> story, bool isDark) {
    const listGradients = [
      [Color(0xFFE0F2FE), Color(0xFFBAE6FD)], // Blue
      [Color(0xFFFEF9C3), Color(0xFFFEF08A)], // Yellow
      [Color(0xFFF0FDF4), Color(0xFFDCFCE7)], // Green
      [Color(0xFFFDF2F8), Color(0xFFFCE7F3)], // Pink
    ];
    final random = (story['id']?.toString().hashCode ?? 0) % listGradients.length;
    final gradient = listGradients[random];

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
          color: isDark ? Colors.white10 : gradient[1],
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            CupertinoPageRoute(builder: (context) => StoryReaderScreen(story: story)),
          );
        },
        borderRadius: BorderRadius.circular(24.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Row(
            children: [
              Container(
                width: 70.w,
                height: 70.w,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: gradient),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Center(child: Text(story['emoji'] ?? '📖', style: TextStyle(fontSize: 35.sp))),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      story['title'] ?? '',
                      style: GoogleFonts.cairo(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF1E293B),
                      ),
                    ),
                    Row(
                      children: [
                        Icon(Icons.star_rounded, size: 16.sp, color: Colors.amber),
                        SizedBox(width: 4.w),
                        Text(
                          '${story['stars_reward'] ?? 5} نجوم مكافأة',
                          style: GoogleFonts.cairo(fontSize: 12.sp, color: Colors.amber.shade700),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Color(0xFF0EA5E9)),
            ],
          ),
        ),
      ),
    );
  }
}
