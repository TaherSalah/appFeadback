import 'package:animate_do/animate_do.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:muslimdaily/app/core/extensions/context_extension.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/utils/style/k_color.dart';
import '../../../core/utils/style/k_dialog_helper.dart';
import '../../achievements/services/achievement_service.dart';

class StoryReaderScreen extends StatefulWidget {
  final Map<String, dynamic> story;

  const StoryReaderScreen({super.key, required this.story});

  @override
  State<StoryReaderScreen> createState() => _StoryReaderScreenState();
}

class _StoryReaderScreenState extends State<StoryReaderScreen> {
  double _fontSize = 18.0;
  late ScrollController _scrollController;
  late ConfettiController _confettiController;
  double _readingProgress = 0.0;
  bool _isAlreadyCompleted = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _checkStoryStatus();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.hasClients && _scrollController.position.maxScrollExtent > 0) {
      final progress = _scrollController.offset / _scrollController.position.maxScrollExtent;
      setState(() {
        _readingProgress = progress.clamp(0.0, 1.0);
      });
    }
  }

  Future<void> _checkStoryStatus() async {
    final storyId = widget.story['id'].toString();
    final achievementService = GetIt.I<AchievementService>();
    final isDone = achievementService.isStoryCompleted(storyId);
    setState(() {
      _isAlreadyCompleted = isDone;
    });
  }

  void _showInteractionDialog() {
    if (_isAlreadyCompleted) {
      _showAlreadyCompletedDialog();
      return;
    }

    final List<Map<String, dynamic>> interactionOptions = [
      {
        'label': 'أحببتها جداً! ',
        'color': Colors.black,
        'icon': Icons.favorite_rounded,
      },
      // {
      //   'label': 'أصبحت أذكى! ',
      //   'color': const Color(0xFF0EA5E9),
      //   'icon': Icons.lightbulb_rounded,
      // },
      // {
      //   'label': 'عمل رائع! ',
      //   'color': KColors.blackColor,
      //   'icon': Icons.stars_rounded,
      // },
    ];

    KDialogHelper.showCustomDialog(
      context: context,
      type: KDialogType.info,
      icon: Icons.auto_awesome_rounded,
      title: 'أنت بطل القراءة!',
      description: 'كيف شعرت بعد قراءة قصة "${widget.story['title']}"؟',
      additionalContent: Column(
        children: interactionOptions.map((opt) {
          return Padding(
            padding: EdgeInsets.only(bottom: 10.h),
            child: KDialogHelper.buildButton(

              context: context,
              label: opt['label'],
              color: opt['color'],
              // icon: opt['icon'],
              onPressed: () {
                Navigator.pop(context);
                _handleCompletion();
              },
            ),
          );
        }).toList(),
      ),
      actions: [],
    );
  }

  void _showAlreadyCompletedDialog() {
    KDialogHelper.showCustomDialog(
      context: context,
      type: KDialogType.info,
      icon: Icons.info_outline_rounded,
      title: 'بطل القراءة! 📚',
      description: 'لقد قرأت هذه القصة من قبل وحصلت على النجوم. استمتع بالقراءة مرة أخرى!',
      actions: [
        KDialogHelper.buildButton(
          context: context,
          label: 'حسناً',
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  Future<void> _handleCompletion() async {
    final int stars = widget.story['stars_reward'] ?? 20;
    final storyId = widget.story['id'].toString();
    final achievementService = GetIt.I<AchievementService>();
    
    final success = await achievementService.completeStory(storyId, stars);
    if (success) {
      // Also record as a general activity to unlock achievements
      await achievementService.recordActivity('read_story');
      
      // Play celebration!
      _confettiController.play();
      
      _showSuccessDialog();
    }
  }

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
                 style: const TextStyle(
                          fontFamily: "cairo",
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0EA5E9),
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
    final bool isDark = context.isDark;
    final String emoji = widget.story['emoji']?.toString() ?? '✨';
    final String title = widget.story['title']?.toString() ?? 'قصة جميلة';
    final String content = widget.story['content']?.toString() ?? '';
    final String moral = widget.story['moral']?.toString() ?? '';

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor:
            isDark ? const Color(0xFF111827) : const Color(0xFFFDFCF7),
        body: Stack(
          children: [
            CustomScrollView(
              controller: _scrollController,
              slivers: [
            // Colorful Header
            SliverAppBar(
              expandedHeight: 200.h,
              pinned: true,
              backgroundColor: KColors.primaryColor,
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(
                      decoration:  BoxDecoration(
                        gradient: LinearGradient(
                          // colors: [Color(0xFF0EA5E9), Color(0xFF38BDF8)],
                          colors: [KColors.primaryColor, KColors.primary2Color],
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
                                 style: TextStyle(
                          fontFamily: "cairo",
                                color: Colors.white,
                                fontSize: 22.sp,
                                fontWeight: FontWeight.bold,
                                shadows: const [
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
                           style: TextStyle(
                          fontFamily: "cairo",fontSize: 14.sp)),
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: () {
                        if (_fontSize > 14) setState(() => _fontSize -= 2);
                      },
                    ),
                    Text('${_fontSize.toInt()}',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
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

            SliverPadding(
              padding: EdgeInsets.all(24.w),
              sliver: SliverToBoxAdapter(
                child: Column(
                  children: <Widget>[
                    ...content.split('\n\n').where((String p) => p.trim().isNotEmpty).map((String paragraph) {
                      return FadeInUp(
                        duration: const Duration(milliseconds: 600),
                        child: Padding(
                          padding: EdgeInsets.only(bottom: 20.h),
                          child: Text(
                            paragraph.trim(),
                               style: TextStyle(
                          fontFamily: "cairo",
                              fontSize: _fontSize.sp,
                              height: 1.8,
                              color: isDark ? Colors.white70 : Colors.black87,
                            ),
                          ),
                        ),
                      );
                    }),
                    if (moral.isNotEmpty) ...[
                      SizedBox(height: 40.h),
                      FadeInUp(
                        delay: const Duration(milliseconds: 300),
                        child: Container(
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
                                       style: TextStyle(
                          fontFamily: "cairo",
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
                                   style: TextStyle(
                          fontFamily: "cairo",
                                  fontSize: (_fontSize - 2).sp,
                                  color: isDark ? Colors.white60 : Colors.black54,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    SizedBox(height: 60.h),
                    FadeInUp(
                      delay: const Duration(milliseconds: 500),
                      child: ElevatedButton.icon(
                        onPressed: _showInteractionDialog,
                        icon: Icon(_isAlreadyCompleted ? Icons.check_circle_rounded : Icons.emoji_events_rounded),
                        label: Text(
                          _isAlreadyCompleted ? 'تمت القراءة مسبقاً' : 'لقد قرأت القصة!',
                             style: const TextStyle(
                          fontFamily: "cairo",fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isAlreadyCompleted ? Colors.grey : const Color(0xFF0EA5E9),
                          foregroundColor: Colors.white,
                          minimumSize: Size(double.infinity, 56.h),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.r)),
                        ),
                      ),
                    ),
                    SizedBox(height: 30.h),
                  ],
                ),
              ),
            ),
              ],
            ),
            
            // Floating Progress Bar
            Positioned(
              top: MediaQuery.of(context).padding.top + kToolbarHeight,
              left: 0,
              right: 0,
              child: LinearProgressIndicator(
                value: _readingProgress,
                backgroundColor: Colors.white.withOpacity(0.1),
                valueColor: AlwaysStoppedAnimation<Color>(
                  isDark ? const Color(0xFF0EA5E9) : Colors.white,
                ),
                minHeight: 4.h,
              ),
            ),

            // Confetti Celebration
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                colors: const [
                  Colors.green,
                  Colors.blue,
                  Colors.pink,
                  Colors.orange,
                  Colors.purple,
                  Colors.amber,
                ],
                numberOfParticles: 30, // number of particles to emit
                gravity: 0.3, // gravity - or fall speed
              ),
            ),
          ],
        ),
      ),
    );
  }
}
