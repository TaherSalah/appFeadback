import 'package:flutter/cupertino.dart';
import '../../core/shard/exports/all_exports.dart';
import 'data/Dhikr.dart';
import 'data/Wird.dart';
import 'data/WirdManager.dart';

class TasbihScreen extends StatefulWidget {
  final Wird wird;
  final bool isDark;

  const TasbihScreen({super.key, required this.wird, required this.isDark});

  @override
  _TasbihScreenState createState() => _TasbihScreenState();
}

class _TasbihScreenState extends State<TasbihScreen> with TickerProviderStateMixin {
  late int currentDhikrIndex;
  late PageController _pageController;
  bool isFocusMode = false;
  bool hapticEnabled = true;
  late AnimationController _pulseController;
  late AnimationController _scaleController;
  final WirdManager manager = WirdManager();

  @override
  void initState() {
    super.initState();
    currentDhikrIndex = widget.wird.currentDhikrIndex;
    _pageController = PageController(initialPage: currentDhikrIndex);
    widget.wird.isInProgress = true;
    loadSettings();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _saveProgress();
    _pageController.dispose();
    _pulseController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  Future<void> _saveProgress() async {
    widget.wird.currentDhikrIndex = currentDhikrIndex;
    widget.wird.isInProgress = true;
    final awrad = await manager.loadAwrad();
    final index = awrad.indexWhere((w) => w.id == widget.wird.id);
    if (index != -1) {
      awrad[index] = widget.wird;
      await manager.saveAwrad(awrad);
    }
  }

  Future<void> loadSettings() async {
    final h = await manager.isHapticEnabled();
    setState(() => hapticEnabled = h);
  }

  void incrementCount() async {
    if (hapticEnabled) HapticFeedback.selectionClick();
    _scaleController.forward().then((_) => _scaleController.reverse());

    setState(() {
      final dhikr = widget.wird.adhkar[currentDhikrIndex];
      if (dhikr.currentCount < dhikr.targetCount) {
        dhikr.currentCount++;
        if (dhikr.currentCount == dhikr.targetCount) {
          if (hapticEnabled) HapticFeedback.heavyImpact();
          if (currentDhikrIndex < widget.wird.adhkar.length - 1) {
            Future.delayed(const Duration(milliseconds: 1000), () => _goToNextDhikr());
          } else {
            _completeWird();
          }
        }
        _saveProgress();
      }
    });
  }

  void _goToNextDhikr() {
    if (currentDhikrIndex < widget.wird.adhkar.length - 1) {
      _pageController.animateToPage(
        currentDhikrIndex + 1,
        duration: const Duration(milliseconds: 500),
        curve: Curves.elasticOut,
      );
    }
  }

  void _goToPreviousDhikr() {
    if (currentDhikrIndex > 0) {
      _pageController.animateToPage(
        currentDhikrIndex - 1,
        duration: const Duration(milliseconds: 500),
        curve: Curves.elasticOut,
      );
    }
  }

  void _skipCurrentDhikr() {
    showCupertinoDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: CupertinoAlertDialog(
          title: Text('تخطي الذكر؟', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
          content: Text('هل تريد تخطي هذا الذكر والانتقال للذكر التالي؟', style: GoogleFonts.cairo()),
          actions: [
            CupertinoDialogAction(child: Text('إلغاء', style: GoogleFonts.cairo(color: Colors.grey)), onPressed: () => Navigator.pop(context)),
            CupertinoDialogAction(
              isDestructiveAction: true,
              child: Text('تخطي', style: GoogleFonts.cairo(color: Colors.orange)),
              onPressed: () {
                widget.wird.adhkar[currentDhikrIndex].currentCount = widget.wird.adhkar[currentDhikrIndex].targetCount;
                if (currentDhikrIndex < widget.wird.adhkar.length - 1) {
                  _goToNextDhikr();
                } else {
                  _completeWird();
                }
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _completeWird() async {
    widget.wird.completedCount++;
    widget.wird.lastCompletedDate = DateTime.now();
    widget.wird.isInProgress = false;
    widget.wird.isCompleted = true;

    final totalTasbihat = widget.wird.adhkar.fold<int>(0, (sum, d) => sum + d.targetCount);
    manager.updateStats(totalTasbihat);

    final awrad = await manager.loadAwrad();
    final index = awrad.indexWhere((w) => w.id == widget.wird.id);
    if (index != -1) {
      awrad[index] = widget.wird;
      await manager.saveAwrad(awrad);
    }
    _showCompletionSheet();
  }

  void _showCompletionSheet() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showCupertinoModalPopup(
      context: context,
      barrierDismissible: false,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: Material(
          child: Container(
            padding: EdgeInsets.all(32.w),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 40, offset: const Offset(0, -10))],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 50.w, height: 5.h, decoration: BoxDecoration(color: Colors.grey.withOpacity(0.2), borderRadius: BorderRadius.circular(10))),
                SizedBox(height: 32.h),
                Container(
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(color: Colors.teal.withOpacity(0.1), shape: BoxShape.circle),
                  child: Icon(Icons.check_circle_rounded, color: Colors.teal, size: 80.sp),
                ),
                SizedBox(height: 24.h),
                Text("تقبل الله طاعتك!", style: GoogleFonts.cairo(fontSize: 24.sp, fontWeight: FontWeight.w900, color: isDark ? Colors.white : Colors.black87)),
                SizedBox(height: 8.h),
                Text(
                  "لقد أتممت هذا الورد بنجاح للمرة رقم ${widget.wird.completedCount}",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cairo(fontSize: 15.sp, color: Colors.grey),
                ),
                SizedBox(height: 40.h),
                Row(
                  children: [
                    Expanded(
                      child: CupertinoButton(
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        borderRadius: BorderRadius.circular(20),
                        color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade100,
                        child: Text("إعادة الورد", style: GoogleFonts.cairo(color: isDark ? Colors.white70 : Colors.black54, fontWeight: FontWeight.bold)),
                        onPressed: () {
                          for (var d in widget.wird.adhkar) {
                            d.currentCount = 0;
                          }
                          widget.wird.currentDhikrIndex = 0;
                          _pageController.jumpToPage(0);
                          setState(() => currentDhikrIndex = 0);
                          _saveProgress();
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: CupertinoButton(
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        borderRadius: BorderRadius.circular(20),
                        color: const Color(0xFF00897B),
                        child: Text("خروج", style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: Colors.white)),
                        onPressed: () {
                          for (var d in widget.wird.adhkar) {
                            d.currentCount = 0;
                          }
                          widget.wird.currentDhikrIndex = 0;
                          _saveProgress();
                          Navigator.pop(context);
                          Navigator.pop(context, 'completed');
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: MediaQuery.of(context).padding.bottom + 16.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? Colors.tealAccent : const Color(0xFF00897B);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF0F0F0F) : const Color(0xFFF0F4F4),
        body: Stack(
          children: [
            Positioned.fill(
              child: Opacity(
                opacity: isDark ? 0.05 : 0.03,
                child: Image.asset("assets/images/pattern.webp", repeat: ImageRepeat.repeat),
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  _buildAppBar(isDark, isFocusMode),
                  _buildTopProgressIndicator(isDark, primaryColor),
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      onPageChanged: (index) => setState(() => currentDhikrIndex = index),
                      itemCount: widget.wird.adhkar.length,
                      itemBuilder: (context, index) {
                        final dhikr = widget.wird.adhkar[index];
                        final isCompleted = dhikr.currentCount == dhikr.targetCount;

                        return GestureDetector(
                          onTap: isCompleted ? null : incrementCount,
                          behavior: HitTestBehavior.opaque,
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 24.w),
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  AnimatedOpacity(
                                    duration: const Duration(milliseconds: 300),
                                    opacity: isFocusMode ? 0.8 : 1.0,
                                    child: Text(
                                      dhikr.text,
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.amiri(
                                        fontSize: isFocusMode ? 32.sp : 26.sp,
                                        fontWeight: FontWeight.bold,
                                        height: 1.8,
                                        color: isDark ? Colors.white : Colors.black87,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 60.h),
                                  _buildCounterWidget(dhikr, isCompleted, isDark, primaryColor),
                                  SizedBox(height: 60.h),
                                  if (!isFocusMode) ...[
                                    Text(
                                      "انقر في أي مكان للتسبيح",
                                      style: GoogleFonts.cairo(fontSize: 12.sp, color: Colors.grey.withOpacity(0.5)),
                                    ),
                                    SizedBox(height: 32.h),
                                    _buildControlsRow(isDark),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        );
                      },
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

  Widget _buildTopProgressIndicator(bool isDark, Color primaryColor) {
    if (isFocusMode) return const SizedBox.shrink();
    
    final totalAdhkar = widget.wird.adhkar.length;
    final currentDhikr = widget.wird.adhkar[currentDhikrIndex];
    final progress = currentDhikr.currentCount / currentDhikr.targetCount;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "الذكر ${currentDhikrIndex + 1} من $totalAdhkar",
                style: GoogleFonts.cairo(fontSize: 13.sp, fontWeight: FontWeight.bold, color: isDark ? Colors.white60 : Colors.black54),
              ),
              Text(
                "${(progress * 100).toInt()}%",
                style: GoogleFonts.barlow(fontSize: 13.sp, fontWeight: FontWeight.bold, color: primaryColor),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Stack(
            children: [
              Container(
                height: 4.h,
                width: double.infinity,
                decoration: BoxDecoration(color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05), borderRadius: BorderRadius.circular(10)),
              ),
              AnimatedFractionallySizedBox(
                duration: const Duration(milliseconds: 300),
                alignment: Alignment.centerRight,
                widthFactor: progress,
                child: Container(
                  height: 4.h,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [primaryColor, primaryColor.withOpacity(0.8)]),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [BoxShadow(color: primaryColor.withOpacity(0.3), blurRadius: 4, spreadRadius: 1)],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCounterWidget(Dhikr dhikr, bool isCompleted, bool isDark, Color primaryColor) {
    return ScaleTransition(
      scale: Tween<double>(begin: 1.0, end: 0.92).animate(CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut)),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Dynamic Glow
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Container(
                width: 240.w,
                height: 240.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: (isCompleted ? Colors.green : primaryColor).withOpacity(0.1 + (_pulseController.value * 0.15)),
                      blurRadius: 40 + (_pulseController.value * 20),
                      spreadRadius: 10 + (_pulseController.value * 10),
                    ),
                  ],
                ),
              );
            },
          ),
          // Ring Track
          Container(
            width: 220.w,
            height: 220.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: isDark ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.03), width: 12.w),
            ),
          ),
          // Progress Ring
          SizedBox(
            width: 220.w,
            height: 220.w,
            child: CircularProgressIndicator(
              value: dhikr.currentCount / dhikr.targetCount,
              strokeWidth: 12.w,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(isCompleted ? Colors.green : primaryColor),
              strokeCap: StrokeCap.round,
            ),
          ),
          // Center Content
          Container(
            width: 180.w,
            height: 180.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
              gradient: RadialGradient(
                colors: isDark ? [const Color(0xFF2A2A2A), const Color(0xFF1A1A1A)] : [Colors.white, const Color(0xFFF8FBFB)],
              ),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(isDark ? 0.3 : 0.05), blurRadius: 20, offset: const Offset(0, 10))
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: FadeTransition(opacity: animation, child: child)),
                  child: Text(
                    "${dhikr.currentCount}",
                    key: ValueKey(dhikr.currentCount),
                    style: GoogleFonts.barlow(fontSize: 72.sp, fontWeight: FontWeight.w900, color: isDark ? Colors.white : Colors.black87),
                  ),
                ),
                Text(
                  "من ${dhikr.targetCount}",
                  style: GoogleFonts.cairo(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.grey.withOpacity(0.6)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlsRow(bool isDark) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.02),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildControlButton(CupertinoIcons.chevron_right, 'السابق', _goToPreviousDhikr, currentDhikrIndex > 0, false),
          SizedBox(width: 20.w),
          _buildControlButton(CupertinoIcons.forward_fill, 'تخطي', _skipCurrentDhikr, true, true),
          SizedBox(width: 20.w),
          _buildControlButton(CupertinoIcons.chevron_left, 'التالي', _goToNextDhikr, currentDhikrIndex < widget.wird.adhkar.length - 1, false),
          SizedBox(width: 20.w),
          _buildControlButton(CupertinoIcons.refresh, 'إعادة', () => setState(() => widget.wird.adhkar[currentDhikrIndex].currentCount = 0), true, false),
        ],
      ),
    );
  }

  Widget _buildControlButton(IconData icon, String label, VoidCallback onTap, bool enabled, bool isHighlight) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: !enabled ? Colors.transparent : (isHighlight ? Colors.orange.withOpacity(0.1) : (isDark ? Colors.white.withOpacity(0.05) : Colors.white)),
              shape: BoxShape.circle,
              boxShadow: (enabled && !isHighlight) ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))] : [],
              border: Border.all(color: isHighlight ? Colors.orange.withOpacity(0.3) : (isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05))),
            ),
            child: Icon(icon, color: !enabled ? Colors.grey.withOpacity(0.3) : (isHighlight ? Colors.orange : (isDark ? Colors.white70 : Colors.black54)), size: 22.sp),
          ),
          SizedBox(height: 6.h),
          Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 10.sp,
              fontWeight: FontWeight.bold,
              color: !enabled ? Colors.grey.withOpacity(0.3) : (isHighlight ? Colors.orange : (isDark ? Colors.white60 : Colors.black54)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(bool isDark, bool isFocus) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CupertinoButton(
            padding: EdgeInsets.zero,
            child: Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(color: isDark ? Colors.white.withOpacity(0.05) : Colors.white, shape: BoxShape.circle),
              child: Icon(CupertinoIcons.back, color: isDark ? Colors.white70 : Colors.black87, size: 20.sp),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          if (!isFocus) 
            Expanded(
              child: Text(
                widget.wird.name, 
                textAlign: TextAlign.center,
                style: GoogleFonts.cairo( fontSize: 16.sp, color: isDark ? Colors.white : Colors.black87),
              ),
            ),
          CupertinoButton(
            padding: EdgeInsets.zero,
            child: Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(color: isDark ? Colors.white.withOpacity(0.05) : Colors.white, shape: BoxShape.circle),
              child: Icon(isFocus ? CupertinoIcons.eye_fill : CupertinoIcons.eye_slash_fill, color: isDark ? Colors.tealAccent : const Color(0xFF00897B), size: 20.sp),
            ),
            onPressed: () => setState(() => isFocusMode = !isFocusMode),
          ),
        ],
      ),
    );
  }
}
