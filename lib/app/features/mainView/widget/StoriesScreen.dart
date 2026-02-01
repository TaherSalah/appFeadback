import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/utils/style/responsive_util.dart';
import '../../../core/widgets/KLoading.dart';
import 'kids_data/islamic_stories.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/services/content_service.dart';
import '../../../core/utils/style/k_dialog_helper.dart';

class StoriesScreen extends StatefulWidget {
  final VoidCallback? onStoryCompleted;

  const StoriesScreen({super.key, this.onStoryCompleted});

  @override
  State<StoriesScreen> createState() => _StoriesScreenState();
}

class _StoriesScreenState extends State<StoriesScreen> {
  Set<String> _readStories = {};
  List<IslamicStory> _allStories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final readStories = (prefs.getStringList('read_stories') ?? []).toSet();

    // Load local stories
    List<IslamicStory> stories = List.from(StoriesData.allStories);

    // Load remote stories
    try {
      final remoteData = await ContentService().getKidsStories();
      if (remoteData.isNotEmpty) {
        final remoteStories =
            remoteData.map((m) => IslamicStory.fromMap(m)).toList();
        // Add remote stories to the beginning
        stories = [...remoteStories, ...stories];
      }
    } catch (e) {
      print('Error loading remote kids stories: $e');
    }

    if (mounted) {
      setState(() {
        _readStories = readStories;
        _allStories = stories;
        _isLoading = false;
      });
    }
  }

  Future<void> _markAsRead(String storyId) async {
    final prefs = await SharedPreferences.getInstance();
    _readStories.add(storyId);
    await prefs.setStringList('read_stories', _readStories.toList());
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'قصص إسلامية 📚',
            style: GoogleFonts.cairo(
              fontWeight: FontWeight.bold,
              fontSize: ResponsiveUtil.isTablet(context) ? 14.sp : 20.sp,
            ),
          ),
          centerTitle: true,
        ),
        body: _isLoading
            ? Center(child: KLoading.progressIOSIndicator(context: context))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _allStories.length,
                itemBuilder: (context, index) {
                  final story = _allStories[index];
                  final isRead = _readStories.contains(story.id);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isRead
                            ? [Colors.grey.shade300, Colors.grey.shade400]
                            : [
                                const Color(0xFF42A5F5),
                                const Color(0xFF1976D2)
                              ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Center(
                          child: Text(
                            story.emoji,
                            style: const TextStyle(fontSize: 35),
                          ),
                        ),
                      ),
                      title: Text(
                        story.title,
                        style: GoogleFonts.cairo(
                          fontSize:
                              ResponsiveUtil.isTablet(context) ? 12.sp : 16.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      subtitle: Row(
                        children: [
                          if (isRead)
                            const Icon(Icons.check_circle,
                                color: Colors.white70, size: 16),
                          if (isRead) const SizedBox(width: 4),
                          Text(
                            isRead ? 'قرأتها ⭐' : '⭐ ${story.starsReward} نجمة',
                            style: GoogleFonts.cairo(
                              fontSize: ResponsiveUtil.isTablet(context)
                                  ? 9.sp
                                  : 12.sp,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white,
                        size: 16,
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => StoryReaderScreen(
                              story: story,
                              onFinish: () {
                                _markAsRead(story.id);
                                widget.onStoryCompleted?.call();
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
      ),
    );
  }
}

class StoryReaderScreen extends StatefulWidget {
  final IslamicStory story;
  final VoidCallback onFinish;

  const StoryReaderScreen({
    super.key,
    required this.story,
    required this.onFinish,
  });

  @override
  State<StoryReaderScreen> createState() => _StoryReaderScreenState();
}

class _StoryReaderScreenState extends State<StoryReaderScreen> {
  int _currentPage = 0;

  void _nextPage() {
    if (_currentPage < widget.story.paragraphs.length) {
      setState(() => _currentPage++);
    } else {
      widget.onFinish();
      _showCompletionDialog();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      setState(() => _currentPage--);
    }
  }

  void _showCompletionDialog() {
    KDialogHelper.showCustomDialog(
      context: context,
      type: KDialogType.success,
      icon: Icons.auto_stories_rounded,
      title: 'أحسنت يا بطل! 🎉',
      description: 'لقد أنهيت قصة "${widget.story.title}" بنجاح!',
      additionalContent: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF10B981).withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: const Color(0xFF10B981).withOpacity(0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.stars_rounded, color: Color(0xFFF59E0B), size: 28),
            const SizedBox(width: 10),
            Text(
              'لقد حصلت على ${widget.story.starsReward} نجمة ✨',
              style: GoogleFonts.cairo(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF10B981),
              ),
            ),
          ],
        ),
      ),
      actions: [
        KDialogHelper.buildButton(
          context: context,
          label: 'رائع!',
          color: const Color(0xFF10B981),
          onPressed: () {
            Navigator.pop(context); // Close dialog
            Navigator.pop(context); // Close story screen
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isLastPage = _currentPage >= widget.story.paragraphs.length;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.story.title,
            style: GoogleFonts.cairo(
              fontWeight: FontWeight.bold,
              fontSize: ResponsiveUtil.isTablet(context) ? 12.sp : 18.sp,
            ),
          ),
          centerTitle: true,
        ),
        body: Column(
          children: [
            // Progress indicator
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Text(
                    'صفحة ${_currentPage + 1} من ${widget.story.paragraphs.length + 1}',
                    style: GoogleFonts.cairo(
                      fontSize: ResponsiveUtil.isTablet(context) ? 9.sp : 12.sp,
                      color: Colors.grey,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    widget.story.emoji,
                    style: const TextStyle(fontSize: 24),
                  ),
                ],
              ),
            ),

            // Story content
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: SingleChildScrollView(
                    child: Text(
                      isLastPage
                          ? widget.story.moral
                          : widget.story.paragraphs[_currentPage],
                      style: GoogleFonts.cairo(
                        fontSize:
                            ResponsiveUtil.isTablet(context) ? 12.sp : 18.sp,
                        height: 2.0,
                        color: isDark ? Colors.white : Colors.black87,
                        fontWeight:
                            isLastPage ? FontWeight.bold : FontWeight.normal,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),

            // Navigation buttons
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentPage > 0)
                    ElevatedButton.icon(
                      onPressed: _previousPage,
                      icon: const Icon(Icons.arrow_back),
                      label: Text('السابق', style: GoogleFonts.cairo()),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    )
                  else
                    const SizedBox(),
                  ElevatedButton.icon(
                    onPressed: _nextPage,
                    icon: Icon(isLastPage ? Icons.star : Icons.arrow_forward),
                    label: Text(
                      isLastPage ? 'إنهاء' : 'التالي',
                      style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
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
