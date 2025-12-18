import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
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
        appBar: AppBar(
          title: Text(
            'قصص ملهمة عن الصدقة 📖',
            style: GoogleFonts.cairo(
              fontWeight: FontWeight.bold,
              fontSize: 20.sp,
            ),
          ),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
        body: Column(
          children: [
            // Filter tabs
            SizedBox(
              height: 50.h,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                children: CharityStoriesData.categories.map((category) {
                  final isSelected = category == _selectedCategory;
                  return Padding(
                    padding: EdgeInsets.only(left: 8.w),
                    child: FilterChip(
                      label: Text(
                        category,
                        style: GoogleFonts.cairo(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : null,
                        ),
                      ),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() => _selectedCategory = category);
                      },
                      selectedColor: const Color(0xFF8B5CF6),
                      backgroundColor:
                          isDark ? const Color(0xFF2D3748) : Colors.white,
                    ),
                  );
                }).toList(),
              ),
            ),

            SizedBox(height: 16.h),

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
      ),
    );
  }

  Widget _buildStoryCard(CharityStory story, bool isDark) {
    return InkWell(
      onTap: () => _showStoryDialog(story, isDark),
      borderRadius: BorderRadius.circular(20.r),
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _getGradientColors(story.category),
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: _getGradientColors(story.category)[0].withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(story.emoji, style: TextStyle(fontSize: 32.sp)),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    story.title,
                    style: GoogleFonts.cairo(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Text(
              story.content.length > 150
                  ? '${story.content.substring(0, 150)}...'
                  : story.content,
              style: GoogleFonts.cairo(
                fontSize: 13.sp,
                color: Colors.white.withOpacity(0.95),
                height: 1.8,
              ),
            ),
            SizedBox(height: 12.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    story.source,
                    style: GoogleFonts.cairo(
                      fontSize: 11.sp,
                      color: Colors.white,
                    ),
                  ),
                ),
                Text(
                  'اقرأ المزيد ⬅️',
                  style: GoogleFonts.cairo(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
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
    );
  }
}
