
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
  // void _skipCurrentDhikr() {
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       backgroundColor: widget.isDark ? Colors.grey.shade800 : Colors.white,
  //       title: Text(
  //         'تخطي الذكر؟',
  //         style: TextStyle(color: widget.isDark ? Colors.white : Colors.black87),
  //       ),
  //       content: Text(
  //         'هل تريد تخطي هذا الذكر والانتقال للتالي؟',
  //         style: TextStyle(color: widget.isDark ? Colors.white70 : Colors.black87),
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context),
  //           child: const Text('إلغاء'),
  //         ),
  //         ElevatedButton(
  //           onPressed: () {
  //             // ضع العداد على الحد الأقصى وانتقل
  //             widget.wird.adhkar[currentDhikrIndex].currentCount =
  //                 widget.wird.adhkar[currentDhikrIndex].targetCount;
  //
  //             if (currentDhikrIndex < widget.wird.adhkar.length - 1) {
  //               _goToNextDhikr();
  //             } else {
  //               _completeWird();
  //             }
  //             Navigator.pop(context);
  //           },
  //           child: const Text('تخطي'),
  //           style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
  //         ),
  //       ],
  //     ),
  //   );
  // }
  void _skipCurrentDhikr() {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          backgroundColor: Colors.transparent,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // جسم الديالوج
              Container(
                padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: isDark
                        ? [const Color(0xFF253A4D), const Color(0xFF13232F)]
                        : [const Color(0xFFE8F6FF), const Color(0xFFD6EEFF)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // العنوان
                    Text(
                      'تخطي الذكر؟',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // النص
                    Text(
                      'هل تريد تخطي هذا الذكر والانتقال إلى التالي؟',
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.4,
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),

                    // كارت تنبيه بسيط
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.orange.withOpacity(0.08),
                        border: Border.all(
                            color: Colors.orange.withOpacity(0.5), width: 1.2),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.info_outline,
                              size: 18, color: Colors.orange),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'سيتم اعتبار الذكر كأنك أكملته.',
                              style: TextStyle(
                                fontSize: 12.5,
                                color: Colors.orange,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // الأزرار
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.of(dialogContext).pop();
                            },
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: isDark
                                    ? Colors.grey.shade400
                                    : Colors.grey.shade600,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 11),
                            ),
                            child: Text(
                              'تراجع',
                              style: TextStyle(
                                fontSize: 14,
                                color: isDark
                                    ? Colors.white
                                    : Colors.grey.shade800,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              // 👈 نفس منطق التخطي القديم
                              widget.wird.adhkar[currentDhikrIndex].currentCount =
                                  widget.wird
                                      .adhkar[currentDhikrIndex].targetCount;

                              if (currentDhikrIndex <
                                  widget.wird.adhkar.length - 1) {
                                _goToNextDhikr();
                              } else {
                                _completeWird();
                              }

                              Navigator.of(dialogContext).pop();
                            },
                            icon: const Icon(Icons.skip_next_outlined),
                            label: const Text('تخطي'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 11),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // أيقونة فوق
              Positioned(
                top: -30,
                left: 0,
                right: 0,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Colors.orange, Colors.deepOrangeAccent],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.withOpacity(0.6),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.fast_forward_rounded,
                        size: 34,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
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
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          backgroundColor: Colors.transparent,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // جسم الديالوج
              Container(
                padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: widget.isDark
                        ? [const Color(0xFF101820), const Color(0xFF062726)]
                        : [const Color(0xFFE8FFF7), const Color(0xFFD4FFF1)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // العنوان والنص
                    Text(
                      'أحسنت!',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: widget.isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'لقد أكملت الورد بنجاح',
                      style: TextStyle(
                        fontSize: 16,
                        color: widget.isDark ? Colors.white70 : Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),

                    // الكارت اللي فيه عدد المرات
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: widget.isDark
                            ? Colors.teal.withOpacity(0.2)
                            : Colors.teal.withOpacity(0.08),
                        border: Border.all(
                          color: Colors.teal.withOpacity(0.6),
                          width: 1.2,
                        ),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'عدد مرات إكمال هذا الورد',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.teal,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'المرة رقم ${widget.wird.completedCount}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // الأزرار
                    Row(
                      children: [
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
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
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
                              Navigator.pop(context, 'completed');
                            },
                            icon: const Icon(Icons.check_circle_outline),
                            label: const Text('إنهاء'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // الأيقونة الدائرية اللي فوق الديالوج
              Positioned(
                top: -30,
                left: 0,
                right: 0,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Colors.teal, Colors.green],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.teal.withOpacity(0.6),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.check_rounded,
                        size: 34,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
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
                      child: SingleChildScrollView(
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
                                      barrierDismissible: true,
                                      builder: (context) {
                                        return Center(
                                          child: Material(
                                            color: Colors.transparent,
                                            child: Container(
                                              width: MediaQuery.of(context).size.width * 0.8,
                                              padding: const EdgeInsets.all(20),
                                              decoration: BoxDecoration(
                                                color: widget.isDark ? Colors.grey.shade900 : Colors.white,
                                                borderRadius: BorderRadius.circular(20),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: widget.isDark
                                                        ? Colors.black.withOpacity(0.4)
                                                        : Colors.grey.withOpacity(0.3),
                                                    blurRadius: 10,
                                                    offset: const Offset(0, 4),
                                                  ),
                                                ],
                                              ),

                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [

                                                  // ===== Title =====
                                                  Text(
                                                    "إعادة الورد؟",
                                                    style: TextStyle(
                                                      fontSize: 20,
                                                      fontWeight: FontWeight.bold,
                                                      color: widget.isDark ? Colors.white : Colors.black87,
                                                    ),
                                                  ),

                                                  const SizedBox(height: 10),

                                                  // ===== Content =====
                                                  Text(
                                                    "هل تريد إعادة الورد من البداية؟",
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      color: widget.isDark ? Colors.white70 : Colors.black87,
                                                    ),
                                                  ),

                                                  const SizedBox(height: 25),

                                                  // ===== Actions =====
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [

                                                      // Cancel
                                                      Expanded(
                                                        child: InkWell(
                                                          onTap: () => Navigator.pop(context),
                                                          child: Container(
                                                            padding: const EdgeInsets.symmetric(
                                                                vertical: 12
                                                            ),
                                                            decoration: BoxDecoration(
                                                              borderRadius: BorderRadius.circular(12),
                                                              color: widget.isDark
                                                                  ? Colors.grey.shade800
                                                                  : Colors.grey.shade200,
                                                            ),
                                                            alignment: Alignment.center,
                                                            child: Text(
                                                              "إلغاء",
                                                              style: TextStyle(
                                                                fontSize: 16,
                                                                color: widget.isDark
                                                                    ? Colors.white
                                                                    : Colors.black87,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),

                                                      const SizedBox(width: 10),

                                                      // Reset ALL
                                                      Expanded(
                                                        child: InkWell(
                                                          onTap: () {
                                                            for (var d in widget.wird.adhkar) {
                                                              d.currentCount = 0;
                                                            }
                                                            widget.wird.currentDhikrIndex = 0;
                                                            widget.wird.isInProgress = false;

                                                            setState(() => currentDhikrIndex = 0);
                                                            _saveProgress();

                                                            Navigator.pop(context);
                                                          },
                                                          child: Container(
                                                            padding: const EdgeInsets.symmetric(
                                                                vertical: 12
                                                            ),
                                                            decoration: BoxDecoration(
                                                              borderRadius: BorderRadius.circular(12),
                                                              color: Colors.red,
                                                            ),
                                                            alignment: Alignment.center,
                                                            child: const Text(
                                                              "إعادة الكل",
                                                              style: TextStyle(
                                                                fontSize: 16,
                                                                color: Colors.white,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    );

                                    // showDialog(
                                    //   context: context,
                                    //   builder: (context) => AlertDialog(
                                    //     backgroundColor: widget.isDark ? Colors.grey.shade900 : Colors.white,
                                    //     shape: RoundedRectangleBorder(
                                    //       borderRadius: BorderRadius.circular(16),
                                    //     ),
                                    //     title: Text(
                                    //       'إعادة الورد؟',
                                    //       textAlign: TextAlign.center,
                                    //       style: TextStyle(
                                    //         fontSize: 20,
                                    //         fontWeight: FontWeight.bold,
                                    //         color: widget.isDark ? Colors.white : Colors.black87,
                                    //       ),
                                    //     ),
                                    //     content: Text(
                                    //       'هل تريد إعادة الورد من البداية؟',
                                    //       textAlign: TextAlign.center,
                                    //       style: TextStyle(
                                    //         fontSize: 16,
                                    //         color: widget.isDark ? Colors.white70 : Colors.black87,
                                    //       ),
                                    //     ),
                                    //
                                    //     actionsAlignment: MainAxisAlignment.spaceEvenly,
                                    //
                                    //     actions: [
                                    //       TextButton(
                                    //         onPressed: () => Navigator.pop(context),
                                    //         child: Text(
                                    //           'إلغاء',
                                    //           style: TextStyle(
                                    //             color: widget.isDark ? Colors.blue[200] : Colors.blue,
                                    //             fontSize: 16,
                                    //           ),
                                    //         ),
                                    //       ),
                                    //
                                    //       ElevatedButton(
                                    //         onPressed: () {
                                    //           for (var d in widget.wird.adhkar) {
                                    //             d.currentCount = 0;
                                    //           }
                                    //
                                    //           widget.wird.currentDhikrIndex = 0;
                                    //           widget.wird.isInProgress = false;
                                    //
                                    //           setState(() => currentDhikrIndex = 0);
                                    //           _saveProgress();
                                    //
                                    //           Navigator.pop(context);
                                    //         },
                                    //         style: ElevatedButton.styleFrom(
                                    //           backgroundColor: Colors.red,
                                    //           padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                    //           shape: RoundedRectangleBorder(
                                    //             borderRadius: BorderRadius.circular(10),
                                    //           ),
                                    //         ),
                                    //         child: const Text(
                                    //           'إعادة الكل',
                                    //           style: TextStyle(fontSize: 16, color: Colors.white),
                                    //         ),
                                    //       ),
                                    //     ],
                                    //   ),
                                    // );

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
