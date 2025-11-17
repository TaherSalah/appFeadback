
// =============== الشاشة الرئيسية ===============
import 'package:flutter/cupertino.dart';
import 'package:muslimdaily/app/core/utils/style/k_helper.dart';

import '../../core/shard/exports/all_exports.dart';
import '../../core/utils/style/k_color.dart';
import '../../core/widgets/KLoading.dart';
import '../main_view/MainView.dart';
import 'AddWirdScreen.dart';
import 'StatisticsScreen.dart';
import 'TasbihScreen.dart';
import 'data/UserStats.dart';
import 'data/Wird.dart';
import 'data/WirdManager.dart';

class WirdHomeScreen extends StatefulWidget {
  @override
  _WirdHomeScreenState createState() => _WirdHomeScreenState();
}

class _WirdHomeScreenState extends State<WirdHomeScreen> {
  List<Wird> awrad = [];
  List<Wird> completedAwrad = [];
  UserStats stats = UserStats();
  final WirdManager manager = WirdManager();
  bool isLoading = true;
  String selectedCategory = 'الكل';

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final data = await manager.loadAwrad();
    final statsData = await manager.loadStats();

    setState(() {
      awrad = data.where((w) => !w.isCompleted).toList();
      completedAwrad = data.where((w) => w.isCompleted).toList();
      stats = statsData;
      isLoading = false;
    });
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
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
      // appBar: AppBar(
      //   title: Text('أورادك اليومية'),
      //   centerTitle: true,
      //   backgroundColor: isDark ? Colors.grey.shade800 : Colors.teal,
      //   elevation: 0,
      //   actions: [
      //     IconButton(
      //       icon: Icon(Icons.bar_chart),
      //       onPressed: () {
      //         Navigator.push(
      //           context,
      //           MaterialPageRoute(
      //             builder: (context) => StatisticsScreen(stats: stats),
      //           ),
      //         );
      //       },
      //     ),
      //   ],
      // ),
      appBar: PreferredSize(
        preferredSize:
        Size.fromHeight(MediaQuery.sizeOf(context).width > 600 ? 70 : 50),
        child: AppBar(
          leading:  CupertinoNavigationBarBackButton(
            color:isDark? Colors.white :Colors.black,
          ),
          actions: [
            IconButton(
              // onPressed: () => Navigator.pushReplacement(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) => StatisticsScreen(stats: stats),
              //   ),
              // ),
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StatisticsScreen(stats: stats),
                  ),
                );

// بعد العودة، أعد تحميل البيانات
                final updatedStats = await manager.loadStats(); // أو UserStats.loadFromPrefs()
                setState(() => stats = updatedStats);

              },
              icon: const Icon(Icons.bar_chart),
            )
          ],
          centerTitle: true,
          title: Text(
            "أورادك من الأذكار اليومية",
            style: GoogleFonts.cairo(
              color: Colors.green,
              fontWeight: FontWeight.bold,
              fontSize: MediaQuery.sizeOf(context).width > 600 ? 12.sp : 18.sp,
            ),
          ),
        ),
      ),

      body: isLoading
          ? Center(child: KLoading.progressIOSIndicator(context: context))
          :  Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            // بطاقة الإحصائيات السريعة
            _buildStatsCard(isDark),

            // فلتر الفئات
            if (categories.length > 1)
              _buildCategoryFilter(isDark),

            // قائمة الأوراد
            Expanded(
              child: ListView(

                padding: const EdgeInsets.all(16),
                children: [
                  ExpansionTile(
                    initiallyExpanded: true,
                    title: Text('الأوراد الجارية (${filteredAwrad.length})',style: TextStyle(fontFamily: "me",fontSize: 20.sp),),
                    children: filteredAwrad
                        .map((wird) => _buildWirdCard(wird, isDark: isDark))
                        .toList(),
                  ),
                  ExpansionTile(
                    initiallyExpanded: false,
                    title: Text('الأوراد المنجزة (${completedAwrad.length})',style: TextStyle(fontFamily: "me",fontSize: 20.sp),),
                    children: completedAwrad
                        .map((wird) => _buildWirdCard(wird, isDark: isDark, completed: true))
                        .toList(),
                  ),
                ],
              ),
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
                builder: (context) => AddWirdScreen(isDark: isDark),
              ),
            );
            if (newWird != null) {
              setState(() => awrad.add(newWird));
              await manager.saveAwrad([...awrad, ...completedAwrad]);
            }
          },
          icon: const Icon(Icons.add),
          label: const TextDefaultWidget(title: 'إضافة ورد جديد',fontWeight: FontWeight.bold,fontFamily: "cairo",color: Colors.white,),
          backgroundColor:Colors.green,
          foregroundColor: Colors.white,

        ),
      ),
    );
  }

  Widget _buildStatsCard(bool isDark) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [Colors.grey.shade900, Colors.grey.shade700]
                : [Colors.teal, Colors.teal.shade300],
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildStatItem('🔥', '${stats.currentStreak}', 'يوم متتالي', isDark),
            _buildStatItem('⭐', 'المستوى ${stats.level}', '${stats.totalTasbihat} تسبيحة', isDark),
            _buildStatItem('🏆', '${stats.achievements.length}', 'إنجاز', isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String emoji, String value, String label, bool isDark) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white,fontFamily: "me")),
        Text(label, style: const TextStyle(fontSize: 20, color: Colors.white70,fontFamily: "me",fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildCategoryFilter(bool isDark) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        height: 50,
        margin: const EdgeInsets.symmetric(vertical: 15),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final cat = categories[index];
            final isSelected = cat == selectedCategory;
            return GestureDetector(
              onTap: () => setState(() => selectedCategory = cat),
              child: Container(
                margin: const EdgeInsets.only(left: 8),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? KColors.primaryColor
                      : (isDark ? Colors.grey.shade800 : Colors.white),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: isSelected ? Colors.teal : Colors.grey.shade300,
                  ),
                ),
                child: Text(
                  cat,
                  style: TextStyle(
                    color: isSelected ? Colors.white : (isDark ? Colors.white : Colors.black87),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildWirdCard(Wird wird, {required bool isDark, bool completed = false}) {
    final totalCount = wird.adhkar.fold<int>(0, (sum, dhikr) => sum + dhikr.targetCount);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Card(
        elevation: 3,
        margin: const EdgeInsets.only(bottom: 12),
        color: isDark ? Colors.grey.shade800 : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: completed
              ? null
              : () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TasbihScreen(
                  wird: wird,
                  isDark: isDark,
                ),
              ),
            );

            if (result == 'completed') {
              setState(() {
                wird.isCompleted = true;
                awrad.remove(wird);
                completedAwrad.add(wird);
              });
              await manager.saveAwrad([...awrad, ...completedAwrad]);
              // ScaffoldMessenger.of(context).showSnackBar(
                // const SnackBar(content: Text('✅ تم نقل الورد إلى قائمة الأوراد المنجزة')),

              // );
              KHelper.showSuccess(message: "تم نقل الورد إلى قائمة الأوراد المنجزة");
            } else if (result == true) {
              await manager.saveAwrad([...awrad, ...completedAwrad]);
              await loadData();
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.teal.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(child: Text('📿', style: TextStyle(fontSize: 30))),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        wird.name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${wird.adhkar.length} ذكر • $totalCount تسبيحة',
                        style: const TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.check_circle, size: 16, color: Colors.green),
                          const SizedBox(width: 4),
                          Text(
                            'أكملته ${wird.completedCount} مرة',
                            style: const TextStyle(color: Colors.green, fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // أيقونة الحذف إذا كان الورد منجز أو لتسهيل الحذف
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                  onPressed: () {
                    showDeleteWirdDialog(wird, completed: completed);
                  },
                ),

                if (!completed)
                  const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }
  void showDeleteWirdDialog(Wird wird, {required bool completed}) {
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
                        color: isDark ? Colors.white : Colors.black87,
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
                        color: isDark ? Colors.white70 : Colors.black87,
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
                      child: Row(
                        children: const [
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
                              Navigator.of(dialogContext).pop(); // إغلاق الديالوج فقط
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
                              padding:
                              const EdgeInsets.symmetric(vertical: 11),
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

                              Navigator.of(dialogContext).pop(); // إغلاق الديالوج
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
                              padding:
                              const EdgeInsets.symmetric(vertical: 11),
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


}

