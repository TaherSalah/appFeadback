import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/utils/style/k_color.dart';
import 'data/charity_stories_data.dart';

class CharityStoriesScreen extends StatefulWidget {
  const CharityStoriesScreen({super.key});

  @override
  State<CharityStoriesScreen> createState() => _CharityStoriesScreenState();
}

class _CharityStoriesScreenState extends State<CharityStoriesScreen> {
  String _selectedCategory = 'الكل';

  List<CharityStory> get _filteredStories {
    return CharityStoriesData.getStoriesByCategory(_selectedCategory);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor:
            isDark ? const Color(0xFF1A1F36) : const Color(0xFFF5F7FA),
        // appBar: AppBar(
        //   title: Text(
        //     'قصص ملهمة عن الصدقة 📖',
        //     style: GoogleFonts.cairo(
        //       fontWeight: FontWeight.bold,
        //       fontSize: 20.sp,
        //     ),
        //   ),
        //   centerTitle: true,
        //   elevation: 0,
        //   backgroundColor: Colors.transparent,
        // ),
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(
              MediaQuery.sizeOf(context).width > 600 ? 70 : 50),
          child: AppBar(
            leading: CupertinoNavigationBarBackButton(
              color: isDark ? Colors.white : Colors.black,
            ),
            // actions: [
            //   IconButton(
            //     onPressed: () => Navigator.push(
            //       context,
            //       MaterialPageRoute(
            //         builder: (context) => CreateKhatmahScreen(),
            //       ),
            //     ),
            //     icon: const Icon(Icons.add),
            //   )
            // ],
            centerTitle: true,
            title: Text(
              'قصص ملهمة عن الصدقة',
              style: GoogleFonts.cairo(
                color: Colors.green,
                fontWeight: FontWeight.bold,
                fontSize:
                MediaQuery.sizeOf(context).width > 600 ? 12.sp : 18.sp,
              ),
            ),
          ),
        ),

        body: Stack(
          children: [
            // Subtle Pattern Background
            Positioned.fill(
              child: Opacity(
                opacity: isDark ? 0.05 : 0.08,
                child: Image.asset(
                  'assets/images/8180jjj00005.webp',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Column(
              children: [
                // Filter tabs
                SizedBox(
                  height: 60.h,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    children: CharityStoriesData.categories.map((category) {
                      final isSelected = category == _selectedCategory;
                      return Padding(
                        padding: EdgeInsets.only(left: 10.w),
                        child: FilterChip(
                          label: Text(
                            category,
                            style: GoogleFonts.cairo(
                              fontSize: 13.sp,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                            ),
                          ),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() => _selectedCategory = category);
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.r),
                            side: BorderSide(
                              color: isSelected ? Colors.transparent : (isDark ? Colors.white24 : Colors.grey.shade300),
                            ),
                          ),
                          selectedColor: AppColors.primary,
                          backgroundColor: isDark ? const Color(0xFF2D3748) : Colors.white,
                          elevation: 2,
                          pressElevation: 4,
                        ),
                      );
                    }).toList(),
                  ),
                ),

                SizedBox(height: 10.h),

                // القصص
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.all(16.w),
                    itemCount: _filteredStories.length,
                    itemBuilder: (context, index) {
                      return _buildStoryCard(_filteredStories[index], isDark);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoryCard(CharityStory story, bool isDark) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2D3748) : Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: const Color(0xFFD4AF37).withOpacity(0.4),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _showStoryDialog(story, isDark),
        borderRadius: BorderRadius.circular(20.r),
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(10.w),
                    decoration: BoxDecoration(
                      color: _getStoryColor(story.category).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Text(story.emoji, style: TextStyle(fontSize: 24.sp)),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          story.title,
                          style: GoogleFonts.cairo(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : const Color(0xFF1E293B),
                          ),
                        ),
                        Text(
                          story.source,
                          style: GoogleFonts.cairo(
                            fontSize: 11.sp,
                            color: isDark ? Colors.white60 : Colors.black45,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              Text(
                story.content.length > 150
                    ? '${story.content.substring(0, 150)}...'
                    : story.content,
                style: GoogleFonts.cairo(
                  fontSize: 13.sp,
                  color: isDark ? Colors.white70 : Colors.black87,
                  height: 1.8,
                ),
              ),
              SizedBox(height: 16.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'عرض التفاصيل ⬅️',
                    style: GoogleFonts.cairo(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStoryColor(String category) {
    switch (category) {
      case 'سيرة':
        return const Color(0xFF8B5CF6);
      case 'حديث':
        return const Color(0xFF10B981);
      case 'معاصر':
        return const Color(0xFF3B82F6);
      default:
        return const Color(0xFF6366F1);
    }
  }

  List<Color> _getGradientColors(String category) {
    switch (category) {
      case 'سيرة':
        return [const Color(0xFF8B5CF6), const Color(0xFF7C3AED)];
      case 'حديث':
        return [const Color(0xFF10B981), const Color(0xFF059669)];
      case 'معاصر':
        return [const Color(0xFF3B82F6), const Color(0xFF2563EB)];
      default:
        return [const Color(0xFF6366F1), const Color(0xFF4F46E5)];
    }
  }

  void _showStoryDialog(CharityStory story, bool isDark) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Container(
            constraints: BoxConstraints(maxHeight: 600.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: _getGradientColors(story.category),
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20.r),
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(story.emoji, style: TextStyle(fontSize: 40.sp)),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          story.title,
                          style: GoogleFonts.cairo(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
          
                // المحتوى
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(20.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          story.content,
                          style: GoogleFonts.cairo(
                            fontSize: 14.sp,
                            height: 2.0,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                          textAlign: TextAlign.justify,
                        ),
                        SizedBox(height: 16.h),
                        Container(
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(
                            color: _getGradientColors(story.category)[0]
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.menu_book,
                                size: 20.sp,
                                color: _getGradientColors(story.category)[0],
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                story.source,
                                style: GoogleFonts.cairo(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                  color: _getGradientColors(story.category)[0],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
          
                // الأزرار
                Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Share.share(
                              '${story.title}\n\n${story.content}\n\n${story.source}',
                            );
                          },
                          icon: const Icon(Icons.share),
                          label: Text(
                            'مشاركة',
                            style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _getGradientColors(story.category)[0],
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                            side: BorderSide(
                              color: _getGradientColors(story.category)[0],
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                          child: Text(
                            'إغلاق',
                            style: GoogleFonts.cairo(
                              fontWeight: FontWeight.bold,
                              color: _getGradientColors(story.category)[0],
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
        ),
      ),
    );
  }
}
