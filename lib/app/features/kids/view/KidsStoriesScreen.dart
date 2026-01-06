import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/services/content_service.dart';
import '../../../core/utils/style/app_theme_colors.dart';
import '../../../core/utils/style/k_color.dart';

class KidsStoriesScreen extends StatefulWidget {
  const KidsStoriesScreen({super.key});

  @override
  State<KidsStoriesScreen> createState() => _KidsStoriesScreenState();
}

class _KidsStoriesScreenState extends State<KidsStoriesScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _stories = [];

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
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading kids stories: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF1A1F36) : const Color(0xFFF0F9FF),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: isDark ? Colors.white : Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          centerTitle: true,
          title: Text(
            'ركن الطفل 👶✨',
            style: GoogleFonts.cairo(
              fontWeight: FontWeight.bold,
              fontSize: 22.sp,
              color: const Color(0xFF0EA5E9),
            ),
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF0EA5E9)))
            : _stories.isEmpty
                ? _buildEmptyState(isDark)
                : ListView.builder(
                    padding: EdgeInsets.all(16.w),
                    itemCount: _stories.length,
                    itemBuilder: (context, index) {
                      return _buildStoryCard(_stories[index], isDark);
                    },
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
          SizedBox(height: 20.h),
          Text(
            'لا توجد قصص حالياً، انتظرنا قريباً!',
            style: GoogleFonts.cairo(
              fontSize: 18.sp,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoryCard(Map<String, dynamic> story, bool isDark) {
    return Container(
      margin: EdgeInsets.only(bottom: 20.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2D3748) : Colors.white,
        borderRadius: BorderRadius.circular(25.r),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(
          color: const Color(0xFF0EA5E9).withOpacity(0.3),
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: () => _showStoryDetails(story, isDark),
        borderRadius: BorderRadius.circular(25.r),
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Text(story['emoji'] ?? '📖', style: TextStyle(fontSize: 30.sp)),
                  ),
                  SizedBox(width: 15.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          story['title'] ?? '',
                          style: GoogleFonts.cairo(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : const Color(0xFF1E293B),
                          ),
                        ),
                        Row(
                          children: List.generate(
                            5,
                            (i) => Icon(
                              Icons.star,
                              size: 16.sp,
                              color: i < (int.tryParse(story['stars']?.toString() ?? '5') ?? 5)
                                  ? Colors.amber
                                  : Colors.grey.shade300,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 15.h),
              Text(
                story['content'] ?? '',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.cairo(
                  fontSize: 14.sp,
                  color: isDark ? Colors.white70 : Colors.black87,
                  height: 1.6,
                ),
              ),
              SizedBox(height: 15.h),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'إقرأ القصة ⬅️',
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0EA5E9),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showStoryDetails(Map<String, dynamic> story, bool isDark) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      pageBuilder: (context, a1, a2) => const SizedBox.shrink(),
      transitionBuilder: (context, a1, a2, child) {
        return Transform.scale(
          scale: a1.value,
          child: Opacity(
            opacity: a1.value,
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.r)),
                title: Row(
                  children: [
                    Text(story['emoji'] ?? '✨', style: TextStyle(fontSize: 30.sp)),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Text(
                        story['title'] ?? '',
                        style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                content: SingleChildScrollView(
                  child: Text(
                    story['content'] ?? '',
                    style: GoogleFonts.cairo(fontSize: 16.sp, height: 1.8),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('إغلاق', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      Share.share('${story['title']}\n\n${story['content']}');
                    },
                    icon: const Icon(Icons.share, size: 18),
                    label: Text('مشاركة', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0EA5E9),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
