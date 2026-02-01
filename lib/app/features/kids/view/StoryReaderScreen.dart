import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/utils/style/k_dialog_helper.dart';

class StoryReaderScreen extends StatefulWidget {
  final Map<String, dynamic> story;

  const StoryReaderScreen({super.key, required this.story});

  @override
  State<StoryReaderScreen> createState() => _StoryReaderScreenState();
}

class _StoryReaderScreenState extends State<StoryReaderScreen> {
  double _fontSize = 18.0;

  void _showSuccessDialog() {
    final int stars = widget.story['stars_reward'] ?? 10;

    KDialogHelper.showCustomDialog(
      context: context,
      type: KDialogType.success,
      icon: Icons.emoji_events_rounded,
      title: 'أحسنت يا بطل! 🎉',
      description:
          'لقد أتممت قراءة قصة "${widget.story['title']}" بنجاح وتستحق هذه المكافأة!',
      additionalContent: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF0EA5E9).withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: const Color(0xFF0EA5E9).withOpacity(0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.stars_rounded, color: Color(0xFFF59E0B), size: 28),
            const SizedBox(width: 10),
            Text(
              'لقد حصلت على $stars نجمة ✨',
              style: GoogleFonts.cairo(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0EA5E9),
              ),
            ),
          ],
        ),
      ),
      actions: [
        KDialogHelper.buildButton(
          context: context,
          label: 'رائع!',
          onPressed: () {
            Navigator.of(context).pop(); // Close dialog
            Navigator.of(context).pop(true); // Return to stories screen
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final emoji = widget.story['emoji'] ?? '✨';
    final title = widget.story['title'] ?? 'قصة جميلة';
    final content = widget.story['content'] ?? '';
    final moral = widget.story['moral'] ?? '';

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor:
            isDark ? const Color(0xFF111827) : const Color(0xFFFDFCF7),
        body: CustomScrollView(
          slivers: [
            // Colorful Header
            SliverAppBar(
              expandedHeight: 200.h,
              pinned: true,
              backgroundColor: const Color(0xFF0EA5E9),
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF0EA5E9), Color(0xFF38BDF8)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
                    // Decorative circles
                    Positioned(
                      top: -20,
                      right: -20,
                      child: CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.white.withOpacity(0.1)),
                    ),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(emoji, style: TextStyle(fontSize: 60.sp)),
                          SizedBox(height: 10.h),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Text(
                              title,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.cairo(
                                color: Colors.white,
                                fontSize: 22.sp,
                                fontWeight: FontWeight.bold,
                                shadows: [
                                  Shadow(
                                      color: Colors.black26,
                                      blurRadius: 10,
                                      offset: Offset(0, 2)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              leading: IconButton(
                icon: const Icon(Icons.close_rounded, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.share_rounded, color: Colors.white),
                  onPressed: () => Share.share('$title\n\n$content'),
                ),
              ],
            ),

            // Font controls fixed bar
            SliverToBoxAdapter(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
                  border: Border(
                      bottom: BorderSide(
                          color: isDark ? Colors.white10 : Colors.black12)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('حجم الخط: ',
                        style: GoogleFonts.cairo(fontSize: 14.sp)),
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: () {
                        if (_fontSize > 14) setState(() => _fontSize -= 2);
                      },
                    ),
                    Text('${_fontSize.toInt()}',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: () {
                        if (_fontSize < 32) setState(() => _fontSize += 2);
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Content
            SliverPadding(
              padding: EdgeInsets.all(24.w),
              sliver: SliverToBoxAdapter(
                child: Column(
                  children: [
                    Text(
                      content,
                      style: GoogleFonts.cairo(
                        fontSize: _fontSize.sp,
                        height: 1.8,
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                    ),
                    if (moral.isNotEmpty) ...[
                      SizedBox(height: 40.h),
                      Container(
                        padding: EdgeInsets.all(20.w),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(isDark ? 0.1 : 0.05),
                          borderRadius: BorderRadius.circular(20.r),
                          border:
                              Border.all(color: Colors.amber.withOpacity(0.3)),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.stars_rounded,
                                    color: Colors.amber),
                                SizedBox(width: 8.w),
                                Text(
                                  'ماذا تعلمنا من القصة؟',
                                  style: GoogleFonts.cairo(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18.sp,
                                    color: Colors.amber.shade800,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10.h),
                            Text(
                              moral,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.cairo(
                                fontSize: (_fontSize - 2).sp,
                                color: isDark ? Colors.white60 : Colors.black54,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    SizedBox(height: 60.h),
                    ElevatedButton.icon(
                      onPressed: _showSuccessDialog,
                      icon: const Icon(Icons.check_circle_rounded),
                      label: Text('لقد قرأت القصة!',
                          style:
                              GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0EA5E9),
                        foregroundColor: Colors.white,
                        minimumSize: Size(double.infinity, 56.h),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.r)),
                      ),
                    ),
                    SizedBox(height: 30.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
