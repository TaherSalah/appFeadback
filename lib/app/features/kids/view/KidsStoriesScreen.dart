import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
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
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadStories();
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

  void _filterStories(String query) {
    setState(() {
      _filteredStories = _stories.where((s) {
        final title = (s['title'] ?? '').toString().toLowerCase();
        final content = (s['content'] ?? '').toString().toLowerCase();
        return title.contains(query.toLowerCase()) || content.contains(query.toLowerCase());
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
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _filterStories,
                    style: GoogleFonts.cairo(fontSize: 14.sp),
                    decoration: InputDecoration(
                      hintText: 'ابحث عن قصة جميلة... 🔍',
                      hintStyle: GoogleFonts.cairo(color: Colors.grey),
                      prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF0EA5E9)),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    ),
                  ),
                ),
              ),
            ),

            // Stories List/Grid
            _isLoading
                ? const SliverFillRemaining(child: Center(child: CircularProgressIndicator(color: Color(0xFF0EA5E9))))
                : _filteredStories.isEmpty
                    ? SliverFillRemaining(child: _buildEmptyState(isDark))
                    : SliverPadding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) => _buildStoryCard(_filteredStories[index], isDark),
                            childCount: _filteredStories.length,
                          ),
                        ),
                      ),
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
        ],
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
