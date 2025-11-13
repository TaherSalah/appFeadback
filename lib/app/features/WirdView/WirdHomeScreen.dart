
// =============== الشاشة الرئيسية ===============
import 'package:flutter/cupertino.dart';
import 'package:muslimdaily/app/core/utils/style/k_helper.dart';

import '../../core/shard/exports/all_exports.dart';
import '../../core/utils/style/k_color.dart';
import '../../core/widgets/KLoading.dart';
import '../main_view/home.dart';
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
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('تأكيد الحذف'),
                        content: const Text('هل أنت متأكد أنك تريد حذف هذا الورد؟'),
                        actions: [
                          TextButton(
                            child: const Text('إلغاء'),
                            onPressed: () => Navigator.pop(context, false),
                          ),
                          TextButton(
                            child: const Text('حذف', style: TextStyle(color: Colors.red)),
                            onPressed: () => Navigator.pop(context, true),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      setState(() {
                        if (completed) {
                          completedAwrad.remove(wird);
                        } else {
                          awrad.remove(wird);
                        }
                      });
                      await manager.saveAwrad([...awrad, ...completedAwrad]);
                      // ScaffoldMessenger.of(context).showSnackBar(
                      //   const SnackBar(content: Text('تم حذف الورد بنجاح')),
                      // );
                      KHelper.showSuccess(message: "تم حذف الورد بنجاح");
                    }
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
}