
// =============== شاشة التسبيح المتقدمة ===============

import 'package:flutter/cupertino.dart';
import 'package:muslimdaily/app/core/utils/style/k_color.dart';

import '../../core/shard/exports/all_exports.dart';
import 'data/Wird.dart';
import 'data/WirdManager.dart';

class TasbihScreen extends StatefulWidget {
  final Wird wird;
  final bool isDark;

  TasbihScreen({required this.wird, required this.isDark});

  @override
  _TasbihScreenState createState() => _TasbihScreenState();
}

class _TasbihScreenState extends State<TasbihScreen> with TickerProviderStateMixin {
  late int currentDhikrIndex;
  bool isFocusMode = false;
  bool hapticEnabled = true;
  late AnimationController _pulseController;
  late AnimationController _scaleController;
  final WirdManager manager = WirdManager();

  @override
  void initState() {
    super.initState();
    // ✅ ابدأ من آخر ذكر كان المستخدم فيه
    currentDhikrIndex = widget.wird.currentDhikrIndex;
    widget.wird.isInProgress = true;

    loadSettings();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
  }

  @override
  void dispose() {
    // ✅ احفظ التقدم قبل الخروج
    _saveProgress();
    _pulseController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  Future<void> _saveProgress() async {
    widget.wird.currentDhikrIndex = currentDhikrIndex;
    widget.wird.isInProgress = true;

    // احفظ البيانات
    final awrad = await manager.loadAwrad();
    final index = awrad.indexWhere((w) => w.id == widget.wird.id);
    if (index != -1) {
      awrad[index] = widget.wird;
      await manager.saveAwrad(awrad);
    }
  }

  Future<void> loadSettings() async {
    final h = await manager.isHapticEnabled();
    setState(() {
      hapticEnabled = h;
    });
  }

  void incrementCount() async {
    if (hapticEnabled) {
      HapticFeedback.lightImpact();
    }

    _scaleController.forward().then((_) => _scaleController.reverse());

    setState(() {
      final dhikr = widget.wird.adhkar[currentDhikrIndex];
      if (dhikr.currentCount < dhikr.targetCount) {
        dhikr.currentCount++;

        if (dhikr.currentCount == dhikr.targetCount) {
          if (hapticEnabled) {
            HapticFeedback.mediumImpact();
          }

          // الانتقال للذكر التالي تلقائياً
          if (currentDhikrIndex < widget.wird.adhkar.length - 1) {
            Future.delayed(const Duration(milliseconds: 800), () {
              _goToNextDhikr();
            });
          } else {
            // إكمال الورد
            _completeWird();
          }
        }

        // ✅ احفظ التقدم بعد كل تسبيحة
        _saveProgress();
      }
    });
  }

  // ✅ دالة الانتقال للذكر التالي
  void _goToNextDhikr() {
    if (currentDhikrIndex < widget.wird.adhkar.length - 1) {
      setState(() {
        currentDhikrIndex++;
      });
      _saveProgress();
    }
  }

  // ✅ دالة الرجوع للذكر السابق
  void _goToPreviousDhikr() {
    if (currentDhikrIndex > 0) {
      setState(() {
        currentDhikrIndex--;
      });
      _saveProgress();
    }
  }

  // ✅ دالة تخطي الذكر الحالي
  void _skipCurrentDhikr() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: widget.isDark ? Colors.grey.shade800 : Colors.white,
        title: Text(
          'تخطي الذكر؟',
          style: TextStyle(color: widget.isDark ? Colors.white : Colors.black87),
        ),
        content: Text(
          'هل تريد تخطي هذا الذكر والانتقال للتالي؟',
          style: TextStyle(color: widget.isDark ? Colors.white70 : Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              // ضع العداد على الحد الأقصى وانتقل
              widget.wird.adhkar[currentDhikrIndex].currentCount =
                  widget.wird.adhkar[currentDhikrIndex].targetCount;

              if (currentDhikrIndex < widget.wird.adhkar.length - 1) {
                _goToNextDhikr();
              } else {
                _completeWird();
              }
              Navigator.pop(context);
            },
            child: const Text('تخطي'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
          ),
        ],
      ),
    );
  }

  // void _completeWird() {
  //   widget.wird.completedCount++;
  //   widget.wird.lastCompletedDate = DateTime.now();
  //   widget.wird.isInProgress = false;
  //
  //   final totalTasbihat = widget.wird.adhkar.fold<int>(
  //     0,
  //         (sum, d) => sum + d.targetCount,
  //   );
  //   manager.updateStats(totalTasbihat);
  //
  //   Future.delayed(Duration(milliseconds: 500), () {
  //     showCompletionDialog();
  //   });
  // }
  void _completeWird() async {
    widget.wird.completedCount++;
    widget.wird.lastCompletedDate = DateTime.now();
    widget.wird.isInProgress = false;
    widget.wird.isCompleted = true; // ✅ أضف هذا السطر لتعليم الورد أنه منجز

    final totalTasbihat = widget.wird.adhkar.fold<int>(
      0,
          (sum, d) => sum + d.targetCount,
    );
    manager.updateStats(totalTasbihat);

    // ✅ حفظ الحالة الجديدة (المنجزة) داخل قائمة الأوراد
    final awrad = await manager.loadAwrad();
    final index = awrad.indexWhere((w) => w.id == widget.wird.id);
    if (index != -1) {
      awrad[index] = widget.wird;
      await manager.saveAwrad(awrad);
    }

    Future.delayed(const Duration(milliseconds: 500), () {
      showCompletionDialog();
    });
  }

  void showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: widget.isDark ? Colors.grey.shade800 : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            children: [
              const Text('🎉', style: TextStyle(fontSize: 50)),
              const SizedBox(height: 8),
              Text(
                'أحسنت!',
                style: TextStyle(color: widget.isDark ? Colors.white : Colors.black87),
              ),
            ],
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'لقد أكملت الورد بنجاح',
              style: TextStyle(
                fontSize: 16,
                color: widget.isDark ? Colors.white70 : Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.teal.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'المرة رقم ${widget.wird.completedCount}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              ),
            ),
          ],
        ),
        actions: [
          // TextButton.icon(
          //   onPressed: () {
          //     // إعادة تعيين كل شيء
          //     for (var dhikr in widget.wird.adhkar) {
          //       dhikr.currentCount = 0;
          //     }
          //     widget.wird.currentDhikrIndex = 0;
          //     widget.wird.isInProgress = false;
          //     setState(() => currentDhikrIndex = 0);
          //     _saveProgress();
          //     Navigator.pop(context);
          //   },
          //   icon: const Icon(Icons.refresh),
          //   label: const Text('ابدأ من جديد'),
          // ),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                // إعادة تعيين كل شيء
                for (var dhikr in widget.wird.adhkar) {
                  dhikr.currentCount = 0;
                }
                widget.wird.currentDhikrIndex = 0;
                widget.wird.isInProgress = false;
                setState(() => currentDhikrIndex = 0);
                _saveProgress();
                Navigator.pop(context);
              },

              icon: const Icon(Icons.refresh),
              label: const Text('ابدأ من جديد'),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            ),
          ),

          // Spacer(),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                // إعادة تعيين عند الخروج
                for (var dhikr in widget.wird.adhkar) {
                  dhikr.currentCount = 0;
                }
                widget.wird.currentDhikrIndex = 0;
                widget.wird.isInProgress = false;
                _saveProgress();
                Navigator.pop(context);
                // Navigator.pop(context, true);
                Navigator.pop(context, 'completed');

              },
              icon: const Icon(Icons.check),
              label: const Text('إنهاء'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dhikr = widget.wird.adhkar[currentDhikrIndex];
    final progress = dhikr.currentCount / dhikr.targetCount;
    final isCompleted = dhikr.currentCount == dhikr.targetCount;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return WillPopScope(
      // ✅ احفظ التقدم عند الضغط على زر الرجوع
      onWillPop: () async {
        await _saveProgress();
        return true;
      },
      child:  Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: widget.isDark ? Colors.grey.shade900 : Colors.teal.shade50,
          // appBar: isFocusMode
          //     ? null
          //     : AppBar(
          //   title: Text(widget.wird.name),
          //   backgroundColor: widget.isDark ? Colors.grey.shade800 : Colors.teal,
          //   actions: [
          //     IconButton(
          //       icon: Icon(isFocusMode ? Icons.visibility : Icons.visibility_off),
          //       onPressed: () => setState(() => isFocusMode = !isFocusMode),
          //       tooltip: 'وضع التركيز',
          //     ),
          //   ],
          // ),
          appBar: isFocusMode
                ? null
                :  PreferredSize(
            preferredSize:
            Size.fromHeight(MediaQuery.sizeOf(context).width > 600 ? 80 : 50),
            child: AppBar(
              leading: CupertinoNavigationBarBackButton(color: isDark?Colors.white:Colors.black,),
                actions: [
                  IconButton(
                    icon: Icon(isFocusMode ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => isFocusMode = !isFocusMode),
                    tooltip: 'وضع التركيز',
                  ),
                ],
              centerTitle: true,
              title: Text(
                widget.wird.name,
                style: GoogleFonts.cairo(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize:
                    MediaQuery.sizeOf(context).width > 600 ? 12.sp : 18.sp),
              ),
            ),
          ),

          body: GestureDetector(
            onTap: isCompleted ? null : incrementCount,
            child: Container(
              color: widget.isDark ? Colors.grey.shade900 : Colors.teal.shade50,
              child: Column(
                children: [
                  if (!isFocusMode) ...[
                    LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      backgroundColor: Colors.grey.shade300,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isCompleted ? Colors.green : Colors.teal,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'الذكر ${currentDhikrIndex + 1} من ${widget.wird.adhkar.length}',
                            style: TextStyle(
                              fontSize: 16,
                              color: widget.isDark ? Colors.white70 : Colors.grey.shade700,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.teal.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${((dhikr.currentCount / dhikr.targetCount) * 100).toInt()}%',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.teal,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(32),
                            child: AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 300),
                              style: TextStyle(
                                fontSize: isFocusMode ? 40 : 32,
                                fontWeight: FontWeight.bold,
                                height: 2,
                                color: widget.isDark ? Colors.white : Colors.black87,
                              ),
                              textAlign: TextAlign.center,
                              child: Text(dhikr.text),
                            ),
                          ),
                          const SizedBox(height: 40),
                          ScaleTransition(
                            scale: Tween<double>(begin: 1.0, end: 0.95).animate(
                              CurvedAnimation(
                                parent: _scaleController,
                                curve: Curves.easeInOut,
                              ),
                            ),
                            child: AnimatedBuilder(
                              animation: _pulseController,
                              builder: (context, child) {
                                return Container(
                                  width: isFocusMode ? 220 : 200,
                                  height: isFocusMode ? 220 : 200,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.teal.withOpacity(
                                          0.3 + (_pulseController.value * 0.2),
                                        ),
                                        blurRadius: 30,
                                        spreadRadius: 10,
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        '${dhikr.currentCount}',
                                        style: TextStyle(
                                          fontSize: isFocusMode ? 72 : 64,
                                          fontWeight: FontWeight.bold,
                                          color: isCompleted ? Colors.green : Colors.teal,
                                        ),
                                      ),
                                      if (!isFocusMode)
                                        Text(
                                          'من ${dhikr.targetCount}',
                                          style: const TextStyle(
                                            fontSize: 18,
                                            color: Colors.grey,
                                          ),
                                        ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                          if (!isFocusMode) ...[
                            const SizedBox(height: 40),
                            Text(
                              'اضغط في أي مكان للتسبيح',
                              style: TextStyle(
                                fontSize: 16,
                                color: widget.isDark ? Colors.white60 : Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  // ✅ أزرار التحكم الجديدة
                  if (!isFocusMode)
                    SafeArea(
                      top: false,
                      bottom: true,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Column(
                          children: [
                            // أزرار التنقل (السابق / التالي)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // زر السابق
                                ElevatedButton.icon(
                                  onPressed: currentDhikrIndex > 0 ? _goToPreviousDhikr : null,
                                  icon: const Icon(Icons.arrow_back),
                                  label: const Text('السابق'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // زر التخطي
                                ElevatedButton.icon(
                                  onPressed: _skipCurrentDhikr,
                                  icon: const Icon(Icons.skip_next),
                                  label: const Text('تخطي'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orange,
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // زر التالي
                                ElevatedButton.icon(
                                  onPressed: currentDhikrIndex < widget.wird.adhkar.length - 1
                                      ? _goToNextDhikr
                                      : null,
                                  icon: const Icon(Icons.arrow_forward),
                                  label: const Text('التالي'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 15),
                            // أزرار الإعادة
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: () {
                                    setState(() => dhikr.currentCount = 0);
                                    _saveProgress();
                                  },
                                  icon: const Icon(Icons.refresh),
                                  label: const Text('إعادة الحالي'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.grey.shade600,
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                  ),
                                ),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        backgroundColor: widget.isDark ? Colors.grey.shade800 : Colors.white,
                                        title: Text(
                                          'إعادة الورد؟',
                                          style: TextStyle(color: widget.isDark ? Colors.white : Colors.black87),
                                        ),
                                        content: Text(
                                          'هل تريد إعادة الورد من البداية؟',
                                          style: TextStyle(color: widget.isDark ? Colors.white70 : Colors.black87),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context),
                                            child: const Text('إلغاء'),
                                          ),
                                          ElevatedButton(
                                            onPressed: () {
                                              for (var d in widget.wird.adhkar) {
                                                d.currentCount = 0;
                                              }
                                              widget.wird.currentDhikrIndex = 0;
                                              widget.wird.isInProgress = false;
                                              setState(() => currentDhikrIndex = 0);
                                              _saveProgress();
                                              Navigator.pop(context);
                                            },
                                            child: const Text('إعادة الكل'),
                                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.restart_alt),
                                  label: const Text('إعادة الكل'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
            ),
          ),
        ),
      ),
    );
  }
}
