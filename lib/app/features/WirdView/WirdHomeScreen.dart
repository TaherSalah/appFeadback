// =============== الشاشة الرئيسية ===============
import 'package:flutter/cupertino.dart';
import 'package:muslimdaily/app/core/utils/style/k_helper.dart';
import '../../core/shard/exports/all_exports.dart';
import '../../core/utils/style/k_color.dart';
import '../../core/widgets/KLoading.dart';
import 'AddWirdScreen.dart';
import 'StatisticsScreen.dart';
import 'TasbihScreen.dart';
import 'data/UserStats.dart';
import 'data/Wird.dart';
import 'data/WirdManager.dart';

class WirdHomeScreen extends StatefulWidget {
  const WirdHomeScreen({super.key});

  @override
  _WirdHomeScreenState createState() => _WirdHomeScreenState();
}

class _WirdHomeScreenState extends State<WirdHomeScreen>
    with WidgetsBindingObserver {
  List<Wird> awrad = [];
  List<Wird> completedAwrad = [];
  UserStats stats = UserStats();
  final WirdManager manager = WirdManager();
  bool isLoading = true;
  String selectedCategory = 'الكل';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    loadData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      loadData(); // تحديث البيانات عند العودة للتطبيق للتأكد من إعادة تعيين الأوراد اليومية
    }
  }

  Future<void> loadData() async {
    final data = await manager.loadAwrad();
    final statsData = await manager.loadStats();

    if (mounted) {
      setState(() {
        awrad = data.where((w) => !w.isCompleted).toList();
        completedAwrad = data.where((w) => w.isCompleted).toList();
        stats = statsData;
        isLoading = false;
      });
    }
  }

  List<String> get categories {
    final cats = awrad.map((w) => w.category).toSet().toList();
    return ['الكل', ...cats];
  }

  List<Wird> get filteredAwrad {
    if (selectedCategory == 'الكل') return awrad;
    return awrad.where((w) => w.category == selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor =
        context.isDark ? KColors.primaryColor : const Color(0xFF00897B);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(context.isTab ? 70 : 50),
        child: AppBar(
          leading: CupertinoNavigationBarBackButton(
            color: context.isDark ? Colors.white : Colors.black,
          ),
          centerTitle: true,
          title: Text(
            "أورادك اليومية",
               style: TextStyle(
                          fontFamily: "cairo",
              color: Colors.green,
              fontWeight: FontWeight.bold,
              fontSize: context.isTab ? 12.sp : 18.sp,
            ),
          ),
          actions: [
            IconButton(
              onPressed: () async {
                await context.push(StatisticsScreen(stats: stats));
                final updatedStats = await manager.loadStats();
                setState(() => stats = updatedStats);
              },
              icon: const Icon(Icons.insights_rounded, color: Colors.white),
            )
          ],
        ),
      ),
      body: isLoading
          ? Center(child: KLoading.progressIOSIndicator(context: context))
          : Directionality(
              textDirection: TextDirection.rtl,
              child: Stack(
                children: [
                  // Background Pattern
                  Positioned.fill(
                    child: Opacity(
                      opacity: context.isDark ? 0.05 : 0.03,
                      child: Image.asset(
                        "assets/images/pattern.webp",
                        repeat: ImageRepeat.repeat,
                      ),
                    ),
                  ),
                  CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: FadeInDown(
                          duration: const Duration(milliseconds: 600),
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
                            child: _buildStatsRow(),
                          ),
                        ),
                      ),

                      // Category Filter Sliver
                      if (categories.length > 1)
                        SliverToBoxAdapter(
                          child: FadeIn(
                            duration: const Duration(milliseconds: 500),
                            delay: const Duration(milliseconds: 200),
                            child: _buildCategoryFilter(),
                          ),
                        ),

                      // Active Awrad Header
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 10.h),
                          child: Row(
                            children: [
                              Text(
                                "الأوراد الجارية",
                                   style: TextStyle(
                          fontFamily: "cairo",
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.bold,
                                  color: context.isDark
                                      ? Colors.white70
                                      : Colors.black87,
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 2),
                                decoration: BoxDecoration(
                                  color: primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  "${filteredAwrad.length}",
                                  style: GoogleFonts.barlow(
                                    color: primaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Active Awrad List
                      if (filteredAwrad.isEmpty)
                        SliverToBoxAdapter(child: _buildEmptyState())
                      else
                        SliverPadding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) => FadeInUp(
                                duration: const Duration(milliseconds: 500),
                                delay: Duration(milliseconds: index * 40),
                                child: _buildWirdCard(filteredAwrad[index]),
                              ),
                              childCount: filteredAwrad.length,
                            ),
                          ),
                        ),

                      // Completed Awrad Section
                      if (completedAwrad.isNotEmpty) ...[
                        SliverToBoxAdapter(
                          child: Padding(
                            padding:
                                EdgeInsets.fromLTRB(20.w, 30.h, 20.w, 10.h),
                            child: Text(
                              "الأوراد المنجزة",
                                 style: TextStyle(
                          fontFamily: "cairo",
                                fontSize: 15.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                        SliverPadding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) => _buildWirdCard(
                                  completedAwrad[index],
                                  completed: true),
                              childCount: completedAwrad.length,
                            ),
                          ),
                        ),
                      ],
                      SliverToBoxAdapter(child: SizedBox(height: 100.h)),
                    ],
                  ),
                ],
              ),
            ),
      floatingActionButton: Directionality(
        textDirection: TextDirection.rtl,
        child: FloatingActionButton.extended(
          onPressed: () async {
            final newWird = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddWirdScreen(),
              ),
            );
            if (newWird != null) {
              setState(() => awrad.add(newWird));
              await manager.saveAwrad([...awrad, ...completedAwrad]);
            }
          },
          label: Text(
            'إضافة ورد جديد',
               style: TextStyle(
                          fontFamily: "cairo",fontWeight: FontWeight.bold),
          ),
          icon: const Icon(Icons.add_rounded),
          backgroundColor: KColors.primaryColor,
          foregroundColor: Colors.white,
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: context.isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: context.isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildHeroStat('🔥', '${stats.currentStreak}', 'أيام'),
          Container(width: 1, height: 30, color: Colors.grey.withOpacity(0.2)),
          _buildHeroStat('✨', '${stats.totalTasbihat}', 'تسبيحة'),
          Container(width: 1, height: 30, color: Colors.grey.withOpacity(0.2)),
          _buildHeroStat('🏅', '${stats.level}', 'مستوى'),
        ],
      ),
    );
  }

  Widget _buildHeroStat(String emoji, String value, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min, // Added to prevent infinite height
      children: [
        // Text(emoji, style: TextStyle(fontSize: 18.sp)),
        // SizedBox(height: 4.h),
        Text(
          value,
          style: GoogleFonts.barlow(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: context.isDark ? Colors.white : Colors.black87,
          ),
        ),
        Text(
          label,
             style: TextStyle(
                          fontFamily: "cairo",
            fontSize: 10.sp,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(height: 60.h),
        Opacity(
          opacity: 0.3,
          child:
              Icon(Icons.auto_stories_rounded, size: 80.sp, color: Colors.grey),
        ),
        SizedBox(height: 16.h),
        Text(
          "لا توجد أوراد حالية",
             style: TextStyle(
                          fontFamily: "cairo",
            fontSize: 14.sp,
            color: Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          "ابدأ بإضافة أول ورد لك اليوم",
             style: TextStyle(
                          fontFamily: "cairo",
            fontSize: 11.sp,
            color: Colors.grey.shade500,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryFilter() {
    return Container(
      height: 45.h,
      margin: EdgeInsets.only(top: 20.h),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = cat == selectedCategory;
          return GestureDetector(
            onTap: () => setState(() => selectedCategory = cat),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(left: 8.w),
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              decoration: BoxDecoration(
                color: isSelected
                    ? (context.isDark
                        ? KColors.primaryColor
                        : const Color(0xFF00897B))
                    : (context.isDark
                        ? Colors.white.withOpacity(0.05)
                        : Colors.white),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? Colors.transparent
                      : Colors.grey.withOpacity(0.2),
                ),
              ),
              child: Center(
                child: Text(
                  cat,
                     style: TextStyle(
                          fontFamily: "cairo",
                    color: isSelected
                        ? (context.isDark ? Colors.black : Colors.white)
                        : (context.isDark ? Colors.white70 : Colors.black87),
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 11.sp,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildWirdCard(Wird wird, {bool completed = false}) {
    final totalCount =
        wird.adhkar.fold<int>(0, (sum, dhikr) => sum + dhikr.targetCount);
    // ✅ استخدام لون الورد المخصص، أو اللون الافتراضي
    final cardColor = wird.color != 0
        ? Color(wird.color)
        : (context.isDark ? KColors.primaryColor : const Color(0xFF00897B));

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: context.isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: context.isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                )
              ],
        // ✅ إضافة حدود ملونة خفيفة لتمييز الورد
        border: Border.all(color: cardColor.withOpacity(0.3), width: 1.5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () async {
              if (completed) {
                showReactivateWirdDialog(wird);
                return;
              }

              final result = await context.push(TasbihScreen(wird: wird));
              if (result == 'completed') {
                setState(() {
                  wird.isCompleted = true;
                  wird.lastCompletedDate =
                      DateTime.now(); // ✅ تسجيل تاريخ الإكمال
                  awrad.remove(wird);
                  completedAwrad.add(wird);
                });
                await manager.saveAwrad([...awrad, ...completedAwrad]);
                KHelper.showSuccess(message: "تم إكمال الورد بنجاح");
              } else if (result == true) {
                await manager.saveAwrad([...awrad, ...completedAwrad]);
                await loadData();
              }
              final updatedStats = await manager.loadStats();
              setState(() => stats = updatedStats);
            },
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Row(
                children: [
                  Container(
                    width: 50.w,
                    height: 50.w,
                    decoration: BoxDecoration(
                      color: cardColor
                          .withOpacity(0.1), // ✅ خلفية الأيقونة بنفس لون الورد
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Center(
                      child: Text(
                        '📿',
                        style: TextStyle(fontSize: 22.sp),
                      ),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          wird.name,
                             style: TextStyle(
                          fontFamily: "cairo",
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color:
                                context.isDark ? Colors.white : Colors.black87,
                            decoration:
                                completed ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          '${wird.adhkar.length} ذكر • $totalCount تسبيحة',
                             style: TextStyle(
                          fontFamily: "cairo",
                            color: Colors.grey,
                            fontSize: 10.sp,
                          ),
                        ),
                        if (wird.completedCount > 0) ...[
                          SizedBox(height: 4.h),
                          Row(
                            children: [
                              Icon(Icons.check_circle_rounded,
                                  size: 12.sp, color: Colors.green),
                              SizedBox(width: 4.w),
                              Text(
                                'أكملته ${wird.completedCount} مرة',
                                   style: TextStyle(
                          fontFamily: "cairo",
                                  color: Colors.green,
                                  fontSize: 9.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (!completed)
                    IconButton(
                      icon: Icon(Icons.delete_outline_rounded,
                          color: Colors.redAccent.withOpacity(0.7),
                          size: 20.sp),
                      onPressed: () =>
                          showDeleteWirdDialog(wird, completed: completed),
                    )
                  else
                    Icon(Icons.check_circle_rounded,
                        color: Colors.green.withOpacity(0.5), size: 22.sp),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void showDeleteWirdDialog(Wird wird, {required bool completed}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: Dialog(
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
                    colors: context.isDark
                        ? [const Color(0xFF2B0B0B), const Color(0xFF200505)]
                        : [const Color(0xFFFFF2F2), const Color(0xFFFFE1E1)],
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
                    // العنوان
                    Text(
                      'حذف الورد؟',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: context.isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // النص التحذيري
                    Text(
                      'هل أنت متأكد من رغبتك في حذف هذا الورد؟\n'
                      'سيتم حذف جميع التقدّم المرتبط به ولا يمكن التراجع عن هذه العملية.',
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.4,
                        color: context.isDark ? Colors.white70 : Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),

                    // كارت توضيحي صغير
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.red.withOpacity(0.06),
                        border: Border.all(
                          color: Colors.red.withOpacity(0.5),
                          width: 1.2,
                        ),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.info_outline, size: 18, color: Colors.red),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'لن يتم احتساب هذا الورد كمكتمل بعد حذفه.',
                              style: TextStyle(
                                fontSize: 12.5,
                                color: Colors.red,
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
                              Navigator.of(dialogContext)
                                  .pop(); // إغلاق الديالوج فقط
                            },
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: context.isDark
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
                                color: context.isDark
                                    ? Colors.white
                                    : Colors.grey.shade800,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              // منطق الحذف الفعلي
                              setState(() {
                                if (completed) {
                                  completedAwrad.remove(wird);
                                } else {
                                  awrad.remove(wird);
                                }
                              });

                              await manager
                                  .saveAwrad([...awrad, ...completedAwrad]);

                              Navigator.of(dialogContext)
                                  .pop(); // إغلاق الديالوج
                              KHelper.showSuccess(
                                message: "تم حذف الورد بنجاح",
                              );
                            },
                            icon: const Icon(Icons.delete_outline),
                            label: const Text('حذف'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
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

              // الأيقونة الدائرية أعلى الديالوج
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
                        colors: [Colors.red, Colors.deepOrange],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.6),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.delete_forever_rounded,
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

  void showReactivateWirdDialog(Wird wird) {
    final Color primaryColor =
        context.isDark ? KColors.primaryColor : const Color(0xFF00897B);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: Dialog(
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          backgroundColor: Colors.transparent,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: context.isDark
                        ? [const Color(0xFF0E2B1A), const Color(0xFF071A10)]
                        : [const Color(0xFFF2FFF7), const Color(0xFFE1FFE9)],
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
                    Text(
                      'إعادة تفعيل الورد؟',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: context.isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'هل تود إعادة تفعيل هذا الورد ليظهر في قائمة الأوراد الجارية؟',
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.4,
                        color: context.isDark ? Colors.white70 : Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(dialogContext).pop(),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: context.isDark
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
                                color: context.isDark
                                    ? Colors.white
                                    : Colors.grey.shade800,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              setState(() {
                                wird.isCompleted = false;
                                completedAwrad.remove(wird);
                                awrad.add(wird);
                              });
                              await manager
                                  .saveAwrad([...awrad, ...completedAwrad]);
                              Navigator.of(dialogContext).pop();
                              KHelper.showSuccess(
                                message: "تمت إعادة تفعيل الورد",
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor:
                                  context.isDark ? Colors.black : Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 11),
                            ),
                            child: const Text('تفعيل'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
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
                      gradient: LinearGradient(
                        colors: [primaryColor, primaryColor.withOpacity(0.8)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withOpacity(0.6),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.restore_rounded,
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
}
