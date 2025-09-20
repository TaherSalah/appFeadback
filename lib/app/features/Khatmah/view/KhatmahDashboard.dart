import 'package:flutter/cupertino.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:muslimdaily/app/core/shard/exports/all_exports.dart';
import 'package:muslimdaily/app/core/utils/style/k_color.dart';
import 'package:muslimdaily/app/core/utils/style/responsive_util.dart';
import 'package:muslimdaily/app/core/widgets/custom_text_widget.dart';
import 'package:muslimdaily/app/core/widgets/kButtons.dart';
import 'package:muslimdaily/app/features/Khatmah/data/PlanData.dart';
import 'package:muslimdaily/app/features/Khatmah/data/khatmah_model.dart';
import 'package:muslimdaily/app/features/Khatmah/view/CreateKhatmahView.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:quran_library/quran.dart';

// TODO: استبدل بهذا import الصحيح عندك
// import 'package:your_app/create_khatmah_screen.dart';
// import 'package:your_app/quran_library.dart'; // فيه jumpToJoz
// import 'package:your_app/models/khatmah_model.dart';

// class KhatmahDashboard extends StatefulWidget {
//   const KhatmahDashboard({super.key});
//
//   @override
//   State<KhatmahDashboard> createState() => _KhatmahDashboardState();
// }
//
// class _KhatmahDashboardState extends State<KhatmahDashboard>
//     with TickerProviderStateMixin {
//   late final Box<KhatmahModel> box;
//   late final Box plansBox; // khatmahPlans
//   late final TabController _tabController;
//
//   @override
//   void initState() {
//     super.initState();
//     box = Hive.box<KhatmahModel>('khatmahBox');
//     plansBox = Hive.box('khatmahPlans'); // لازم يكون مفتوح في main
//     _tabController = TabController(length: 2, vsync: this);
//   }
//
//   // ------------------ Helpers خاصة بوضع "أجزاء" ------------------
//
//   bool _isAjzaa(KhatmahModel k) {
//     final data = plansBox.get(k.id);
//     if (data is Map && data['distributionType'] == 'ajzaa') return true;
//     return false;
//   }
//
//   PlanData? _getPlanData(KhatmahModel k) {
//     final data = plansBox.get(k.id);
//     if (data is! Map) return null;
//     if (data['distributionType'] != 'ajzaa') return null;
//
//     final int days = (data['days'] ?? 0) as int;
//     final int currentDayIndex = (data['currentDayIndex'] ?? 0) as int;
//     final String json = (data['dailyPlanJson'] ?? '[]') as String;
//
//     final List<dynamic> raw = jsonDecode(json);
//     final List<List<int>> plan =
//         raw.map<List<int>>((e) => (e as List).cast<int>()).toList();
//
//     return PlanData(days: days, currentDayIndex: currentDayIndex, plan: plan);
//   }
//
//   /// صياغة نص ورد اليوم في وضع الأجزاء
//   String _todayWirdAjzaa(PlanData p) {
//     if (p.currentDayIndex < 0 || p.currentDayIndex >= p.plan.length) {
//       return "لا يوجد ورد اليوم";
//     }
//     final today = p.plan[p.currentDayIndex];
//     if (today.isEmpty) return "—";
//     if (today.length == 1) return "الجزء ${today.first}";
//     return "الأجزاء ${today.first}–${today.last}";
//   }
//
//   /// تقدّم تقريبي في وضع الأجزاء = (اليوم الحالي / إجمالي الأيام)
//   double _progressPercentAjzaa(PlanData p) {
//     if (p.days <= 0) return 0;
//     // لو currentDayIndex يبدأ من 0، نعتبر التقدم بناءً على الأيام المقروءة
//     final readDays = p.currentDayIndex; // أيام تم إكمالها
//     final pct = readDays / p.days;
//     return pct.clamp(0.0, 1.0);
//   }
//
//   /// الأيام المتبقية في وضع الأجزاء
//   int _daysLeftAjzaa(PlanData p) {
//     final left = p.days - p.currentDayIndex;
//     return left < 0 ? 0 : left;
//     // لو عايز تخصم اليوم الجاري: p.days - (p.currentDayIndex + 1)
//   }
//
//   void jumpToJoz({required int jozNumber, required BuildContext context}) {
//     QuranLibrary().jumpToJoz(jozNumber);
//     Navigator.pop(context);
//     debugPrint("jumpToJoz($jozNumber) called");
//   }
//
//   /// الانتقال لأوّل جزء في ورد اليوم باستخدام jumpToJoz
//   void _goToTodayAjzaa(KhatmahModel k) {
//     final p = _getPlanData(k);
//     if (p == null) return;
//     if (p.currentDayIndex < 0 || p.currentDayIndex >= p.plan.length) return;
//     final today = p.plan[p.currentDayIndex];
//     if (today.isEmpty) return;
//
//     final firstJoz = today.first;
//     // TODO: نادِ دالتك الحقيقية
//     jumpToJoz(jozNumber: firstJoz, context: context);
//   }
//
//   void jumpToPage({required int pageNumber, required BuildContext context}) {
//     QuranLibrary().jumpToPage(pageNumber);
//     Navigator.pop(context);
//     debugPrint("jumpToJoz($pageNumber) called");
//   }
//
//   /// الانتقال لأول صفحة في ورد اليوم في وضع الصفحات
//   /// الانتقال لأول صفحة في ورد اليوم في وضع الصفحات
//   void _goToTodayPages(KhatmahModel k) {
//     if (k.isCompleted) return;
//
//     // الصفحة الحالية التي المفروض يبدأ منها اليوم
//     final todayPage = k.currentPage + 1;
//
//     if (todayPage > k.totalPages) return;
//
//     // TODO: نادِ دالتك الحقيقية
//     jumpToPage(pageNumber: todayPage, context: context);
//   }
//
//   /// تأشير اليوم كمقروء في وضع الأجزاء
//   void _markTodayReadAjzaa(KhatmahModel k) {
//     final raw = plansBox.get(k.id);
//     if (raw is! Map) return;
//     if (raw['distributionType'] != 'ajzaa') return;
//
//     final data = Map<String, dynamic>.from(raw);
//     final int days = (data['days'] ?? 0) as int;
//     int idx = (data['currentDayIndex'] ?? 0) as int;
//
//     // لو الختمة خلصت، لا تفعل شيء
//     if (idx >= days) return;
//
//     // اعتبر اليوم الحالي تمّ قراءته → انتقل لليوم التالي
//     idx = (idx + 1).clamp(0, days);
//
//     data['currentDayIndex'] = idx;
//     plansBox.put(k.id, data);
//
//     // سجّل تاريخ التأشير في موديلك (لأجل الإحصاءات)
//     k.progressDates.add(DateTime.now());
//
//     // حدّث حالة الاكتمال لو تعدّينا الأيام
//     if (idx >= days) {
//       k.isCompleted = true;
//       k.endDate = DateTime.now(); // التاريخ الفعلي
//     }
//
//     k.save();
//     setState(() {});
//   }
//
//   // ------------------ منطق الصفحات (قديمك كما هو) ------------------
//
//   void _markTodayReadPages(KhatmahModel k) {
//     if (k.isCompleted) return;
//
//     final increment = k.dailyPages;
//     k.currentPage += increment;
//     if (k.currentPage >= k.totalPages) {
//       k.currentPage = k.totalPages;
//       k.isCompleted = true;
//       k.endDate = DateTime.now(); // التاريخ الفعلي
//     }
//     k.progressDates.add(DateTime.now());
//     k.save();
//     setState(() {});
//   }
//
//   // واجهة موحّدة للزر
//   void _markTodayRead(int index) {
//     final khatma = box.getAt(index);
//     if (khatma == null) return;
//     if (khatma.isCompleted) return;
//
//     if (_isAjzaa(khatma)) {
//       _markTodayReadAjzaa(khatma);
//     } else {
//       _markTodayReadPages(khatma);
//     }
//   }
//
//   // حذف ختمة
//   void _deleteKhatmah(int index) {
//     final k = box.getAt(index);
//     if (k != null) {
//       // احذف خطتها إن وُجدت
//       plansBox.delete(k.id);
//     }
//     box.deleteAt(index);
//     setState(() {});
//   }
//
//   // ------------------ UI ------------------
//
//   Widget _buildKhatmahCard(KhatmahModel k, int index) {
//     final isAjzaa = _isAjzaa(k);
//     double progressPercent;
//     int daysLeft;
//     String todayWirdText;
//
//     if (isAjzaa) {
//       final p = _getPlanData(k)!;
//       progressPercent = _progressPercentAjzaa(p);
//       daysLeft = _daysLeftAjzaa(p);
//       todayWirdText = _todayWirdAjzaa(p);
//     } else {
//       progressPercent = k.progressPercent;
//       daysLeft = k.daysLeft;
//       todayWirdText = k.todayWird; // من موديلك
//     }
//
//     final pagesLeft =
//         k.pagesLeft; // قد لا يعكس “أجزاء”، لكنه لا يضر للعرض العام
//
//     return Card(
//       margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
//       elevation: 3,
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             Row(
//               children: [
//                 CircularPercentIndicator(
//                   radius: 60,
//                   lineWidth: 10,
//                   percent: progressPercent > 1 ? 1 : progressPercent,
//                   center:
//                       Text("${(progressPercent * 100).toStringAsFixed(1)}%"),
//                   progressColor: Colors.green,
//                 ),
//                 const SizedBox(width: 16),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(k.title,
//                           style: const TextStyle(
//                               fontSize: 18, fontWeight: FontWeight.bold)),
//                       const SizedBox(height: 6),
//                       Text("ورد اليوم: $todayWirdText"),
//                       const SizedBox(height: 6),
//                       Row(
//                         children: [
//                           _statItem("$pagesLeft", "صفحات"), // للعرض العام
//                           const SizedBox(width: 10),
//                           _statItem("$daysLeft", "أيام"),
//                           const SizedBox(width: 10),
//                           _statItem(k.isCompleted ? "✅" : "❌", "مكتملة"),
//                         ],
//                       )
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 12),
//             Row(
//               children: [
//                 Expanded(
//                   child: ElevatedButton.icon(
//                     onPressed:
//                         k.isCompleted ? null : () => _markTodayRead(index),
//                     icon: const Icon(Icons.check),
//                     label: Text(k.isCompleted ? "مكتملة" : "✔ قراءة اليوم"),
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 if (isAjzaa) // زر الذهاب لورد اليوم في وضع الأجزاء
//                   ElevatedButton.icon(
//                     onPressed: k.isCompleted ? null : () => _goToTodayAjzaa(k),
//                     icon: const Icon(Icons.play_arrow),
//                     label: const Text("اذهب لورد اليوم"),
//                   ),
//                 if (!isAjzaa) // زر الذهاب لورد اليوم في وضع الصفحات
//                   ElevatedButton.icon(
//                     onPressed: k.isCompleted ? null : () => _goToTodayPages(k),
//                     icon: const Icon(Icons.play_arrow),
//                     label: const Text("اذهب لورد اليوم"),
//                   ),
//                 const SizedBox(width: 8),
//                 IconButton(
//                   onPressed: () => _openKhatmahOptions(k, index),
//                   icon: const Icon(Icons.more_vert),
//                 )
//               ],
//             )
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _statItem(String value, String label) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(value,
//             style: const TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.green)),
//         Text(label, style: const TextStyle(fontSize: 12)),
//       ],
//     );
//   }
//
//   void _openKhatmahOptions(KhatmahModel k, int index) {
//     showModalBottomSheet(
//       context: context,
//       builder: (_) {
//         return SafeArea(
//           child: Wrap(
//             children: [
//               ListTile(
//                 leading: const Icon(Icons.delete_forever),
//                 title: const Text("حذف الختمة"),
//                 onTap: () {
//                   Navigator.pop(context);
//                   _deleteKhatmah(index);
//                 },
//               ),
//               ListTile(
//                 leading: const Icon(Icons.replay),
//                 title: const Text("إعادة تعيين التقدم"),
//                 onTap: () {
//                   Navigator.pop(context);
//
//                   // Reset في الصفحات
//                   k.currentPage = 0;
//                   k.isCompleted = false;
//                   k.progressDates.clear();
//                   k.save();
//
//                   // Reset في الأجزاء (لو موجود)
//                   final data = plansBox.get(k.id);
//                   if (data is Map && data['distributionType'] == 'ajzaa') {
//                     final newMap = Map<String, dynamic>.from(data);
//                     newMap['currentDayIndex'] = 0;
//                     plansBox.put(k.id, newMap);
//                   }
//
//                   setState(() {});
//                 },
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
//
//   Widget _buildCurrentTab() {
//     final currentList = box.values.where((k) => !k.isCompleted).toList();
//     if (currentList.isEmpty) {
//       return Center(
//         child: SizedBox(
//           height: 60,
//           width: MediaQuery.sizeOf(context).width / 2,
//           child: CustomButton(
//             backgroundColor: KColors.primaryColor,
//             width: MediaQuery.sizeOf(context).width / 3,
//             title: "ابدأ وانشئ ختمة جديدة",
//             onTap: () => Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                     builder: (context) => const CreateKhatmahScreen())),
//           ),
//         ),
//
//         // return Center(
//         //   child: ElevatedButton.icon(
//         //
//         //     onPressed: () => Navigator.push(
//         //         context,
//         //         MaterialPageRoute(
//         //             builder: (context) => const CreateKhatmahScreen())),
//         //     icon: const Icon(Icons.add),
//         //     label: const Text("ابدأ ختمة جديدة"),
//         //   ),
//       );
//     }
//
//     return ListView.builder(
//       padding: const EdgeInsets.only(top: 12, bottom: 80),
//       itemCount: currentList.length,
//       itemBuilder: (_, i) {
//         final k = currentList[i];
//         final index = box.values.toList().indexOf(k);
//         return _buildKhatmahCard(k, index);
//       },
//     );
//   }
//
//   Widget _buildCompletedTab() {
//     final completed = box.values.where((k) => k.isCompleted).toList();
//     if (completed.isEmpty) {
//       return const Center(child: Text("لم تُنجز أي ختمة بعد."));
//     }
//
//     return ListView.builder(
//       padding: const EdgeInsets.only(top: 12, bottom: 80),
//       itemCount: completed.length,
//       itemBuilder: (_, i) {
//         final k = completed[i];
//         final index = box.values.toList().indexOf(k);
//         return Directionality(
//           textDirection: TextDirection.rtl,
//           child: Card(
//             margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
//             child: ListTile(
//               leading: Icon(Icons.check_circle_outline),
//               title: TextWidget(
//                 title: k.title,
//                 fontFamily: "me",
//                 fontSize: ResponsiveUtil.isTablet(context) ? 10.sp : 16.sp,
//               ),
//               subtitle: Text(
//                   "انتهت في: ${k.endDate.toLocal().toString().split(' ').first}"),
//               trailing: IconButton(
//                 icon: const Icon(Icons.delete),
//                 onPressed: () => _deleteKhatmah(index),
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     // ملاحظة: السطر التالي كان ناقصه فاصلة منقوطة في كودك الأصلي
//     // QuranLibrary();
//     return Directionality(
//       textDirection: TextDirection.rtl,
//       child: Scaffold(
//         appBar: AppBar(
//           backgroundColor: AppStyle.primColors,
//           title: const TextWidget(title: "ختمتك"),
//           bottom: TabBar(
//             labelStyle: TextStyle(color: Colors.black, fontFamily: "cairo"),
//             controller: _tabController,
//             tabs: const [
//               Tab(text: "الحالية"),
//               Tab(text: "السابقة"),
//             ],
//           ),
//           actions: [
//             IconButton(
//               icon: const Icon(Icons.add),
//               onPressed: () => Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                       builder: (context) => const CreateKhatmahScreen())),
//             )
//           ],
//         ),
//         body: ValueListenableBuilder(
//           valueListenable: box.listenable(),
//           builder: (context, Box<KhatmahModel> b, _) {
//             return TabBarView(
//               controller: _tabController,
//               children: [
//                 _buildCurrentTab(),
//                 _buildCompletedTab(),
//               ],
//             );
//           },
//         ),
//       ),
//     );
//   }
// }
//

class KhatmahDashboard extends StatefulWidget {
  const KhatmahDashboard({super.key});

  @override
  State<KhatmahDashboard> createState() => _KhatmahDashboardState();
}

class _KhatmahDashboardState extends State<KhatmahDashboard>
    with TickerProviderStateMixin {
  late final Box<KhatmahModel> box;
  late final Box plansBox; // khatmahPlans
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    box = Hive.box<KhatmahModel>('khatmahBox');
    plansBox = Hive.box('khatmahPlans'); // لازم يكون مفتوح في main
    _tabController = TabController(length: 2, vsync: this);
  }

  // ------------------ Helpers خاصة بوضع "أجزاء" ------------------

  bool _isAjzaa(KhatmahModel k) {
    final data = plansBox.get(k.id);
    if (data is Map && data['distributionType'] == 'ajzaa') return true;
    return false;
  }

  PlanData? _getPlanData(KhatmahModel k) {
    final data = plansBox.get(k.id);
    if (data is! Map) return null;
    if (data['distributionType'] != 'ajzaa') return null;

    final int days = (data['days'] ?? 0) as int;
    final int currentDayIndex = (data['currentDayIndex'] ?? 0) as int;
    final String json = (data['dailyPlanJson'] ?? '[]') as String;

    final List<dynamic> raw = jsonDecode(json);
    final List<List<int>> plan =
    raw.map<List<int>>((e) => (e as List).cast<int>()).toList();

    return PlanData(days: days, currentDayIndex: currentDayIndex, plan: plan);
  }

  /// صياغة نص ورد اليوم في وضع الأجزاء
  String _todayWirdAjzaa(PlanData p) {
    if (p.currentDayIndex < 0 || p.currentDayIndex >= p.plan.length) {
      return "لا يوجد ورد اليوم";
    }
    final today = p.plan[p.currentDayIndex];
    if (today.isEmpty) return "—";
    if (today.length == 1) return "الجزء ${today.first}";
    return "الأجزاء ${today.first}–${today.last}";
  }

  /// تقدّم تقريبي في وضع الأجزاء = (اليوم الحالي / إجمالي الأيام)
  double _progressPercentAjzaa(PlanData p) {
    if (p.days <= 0) return 0;
    final readDays = p.currentDayIndex; // أيام تم إكمالها
    final pct = readDays / p.days;
    return pct.clamp(0.0, 1.0);
  }

  /// الأيام المتبقية في وضع الأجزاء
  int _daysLeftAjzaa(PlanData p) {
    final left = p.days - p.currentDayIndex;
    return left < 0 ? 0 : left;
    // لو عايز تخصم اليوم الجاري: p.days - (p.currentDayIndex + 1)
  }

  void jumpToJoz({required int jozNumber, required BuildContext context}) {
    QuranLibrary().jumpToJoz(jozNumber);
    Navigator.pop(context);
    debugPrint("jumpToJoz($jozNumber) called");
  }

  /// الانتقال لأوّل جزء في ورد اليوم باستخدام jumpToJoz
  void _goToTodayAjzaa(KhatmahModel k) {
    final p = _getPlanData(k);
    if (p == null) return;
    if (p.currentDayIndex < 0 || p.currentDayIndex >= p.plan.length) return;
    final today = p.plan[p.currentDayIndex];
    if (today.isEmpty) return;

    final firstJoz = today.first;
    jumpToJoz(jozNumber: firstJoz, context: context);
  }

  void jumpToPage({required int pageNumber, required BuildContext context}) {
    QuranLibrary().jumpToPage(pageNumber);
    Navigator.pop(context);
    debugPrint("jumpToJoz($pageNumber) called");
  }

  /// الانتقال لأول صفحة في ورد اليوم في وضع الصفحات
  void _goToTodayPages(KhatmahModel k) {
    if (k.isCompleted) return;

    // الصفحة الحالية التي المفروض يبدأ منها اليوم
    final todayPage = k.currentPage + 1;

    if (todayPage > k.totalPages) return;

    jumpToPage(pageNumber: todayPage, context: context);
  }

  /// Dialog التهنئة عند اكتمال الختمة
  void _showCompletionDialog(KhatmahModel k) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Column(
              children: [
                Lottie.asset("assets/json/congrats.json"),
                const SizedBox(width: 8),
                Text(
                  "تهانينا!",
                  style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            content: Text(
              textAlign: TextAlign.center,
              'لقد أتممت الختمة "${k.title}". بارك الله فيك وجعلها في ميزان حسناتك.',
              style: GoogleFonts.cairo(height: 1.4),
            ),
            actions: [
              // TextButton(
              //   onPressed: () => Navigator.pop(context),
              //   child: Text("موافق", style: GoogleFonts.cairo()),
              // ),
              Center(child: KButtons.circularIconButton(fillColor: KColors.primaryColor,iconSize: 35,iconData: CupertinoIcons.check_mark_circled,radius: 60,onPressed: ()=>Navigator.pop(context),iconColor: Colors.white))
            ],
          ),
        );
      },
    );
  }

  /// تأشير اليوم كمقروء في وضع الأجزاء - ترجع true لو الختمة اكتملت الآن
  bool _markTodayReadAjzaa(KhatmahModel k) {
    final raw = plansBox.get(k.id);
    if (raw is! Map) return false;
    if (raw['distributionType'] != 'ajzaa') return false;

    final data = Map<String, dynamic>.from(raw);
    final int days = (data['days'] ?? 0) as int;
    int idx = (data['currentDayIndex'] ?? 0) as int;

    // لو الختمة خلصت، لا تفعل شيء
    if (idx >= days) return false;

    // اعتبر اليوم الحالي تمّ قراءته → انتقل لليوم التالي
    idx = (idx + 1).clamp(0, days);

    data['currentDayIndex'] = idx;
    plansBox.put(k.id, data);

    // سجّل تاريخ التأشير في موديلك (لأجل الإحصاءات)
    k.progressDates.add(DateTime.now());

    bool justCompleted = false;
    if (idx >= days) {
      k.isCompleted = true;
      k.endDate = DateTime.now(); // التاريخ الفعلي
      justCompleted = true;
    }

    k.save();
    setState(() {});
    return justCompleted;
  }

  /// منطق الصفحات: ترجع true لو الختمة اكتملت الآن
  bool _markTodayReadPages(KhatmahModel k) {
    if (k.isCompleted) return false;

    final increment = k.dailyPages;
    k.currentPage += increment;

    bool justCompleted = false;

    if (k.currentPage >= k.totalPages) {
      k.currentPage = k.totalPages;
      k.isCompleted = true;
      k.endDate = DateTime.now(); // التاريخ الفعلي
      justCompleted = true;
    }

    k.progressDates.add(DateTime.now());
    k.save();
    setState(() {});
    return justCompleted;
  }

  // واجهة موحّدة للزر
  void _markTodayRead(int index) {
    final khatma = box.getAt(index);
    if (khatma == null) return;
    if (khatma.isCompleted) return;

    bool completedNow;
    if (_isAjzaa(khatma)) {
      completedNow = _markTodayReadAjzaa(khatma);
    } else {
      completedNow = _markTodayReadPages(khatma);
    }

    if (completedNow) {
      _showCompletionDialog(khatma);
    }
  }

  // حذف ختمة
  void _deleteKhatmah(int index) {
    final k = box.getAt(index);
    if (k != null) {
      // احذف خطتها إن وُجدت
      plansBox.delete(k.id);
    }
    box.deleteAt(index);
    setState(() {});
  }

  // ------------------ UI ------------------

  Widget _buildKhatmahCard(KhatmahModel k, int index) {
    final isAjzaa = _isAjzaa(k);
    double progressPercent;
    int daysLeft;
    String todayWirdText;

    if (isAjzaa) {
      final p = _getPlanData(k)!;
      progressPercent = _progressPercentAjzaa(p);
      daysLeft = _daysLeftAjzaa(p);
      todayWirdText = _todayWirdAjzaa(p);
    } else {
      progressPercent = k.progressPercent;
      daysLeft = k.daysLeft;
      todayWirdText = k.todayWird; // من موديلك
    }

    final pagesLeft =
        k.pagesLeft; // قد لا يعكس “أجزاء”، لكنه لا يضر للعرض العام

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Stack(
        alignment: Alignment.topLeft,
        children: [
          Card(
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  CircularPercentIndicator(
                    radius: 60,
                    lineWidth: 10,
                    percent: progressPercent > 1 ? 1 : progressPercent,
                    center:
                    Text("${(progressPercent * 100).toStringAsFixed(1)}%"),
                    progressColor: Colors.green,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextWidget(
                              title: k.title,
                              fontWeight: FontWeight.bold,
                            ),
                            const SizedBox(height: 6),
                            Text("ورد اليوم: $todayWirdText"),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                _statItem("$pagesLeft", "صفحات"),
                                const SizedBox(width: 10),
                                _statItem("$daysLeft", "أيام"),
                                const SizedBox(width: 10),
                                _statItem(k.isCompleted ? "✅" : "❌", "مكتملة"),
                              ],
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          width: MediaQuery.sizeOf(context).width / 2,
                          child: KButtons.buttonIcon(
                            Theme.of(context),
                            text: k.isCompleted ? "مكتملة" : "اتممت القرأة",
                            bgColor: KColors.primaryColor,
                            fontSize: 13.sp,
                            fontColor: Colors.white,
                            icon: Icons.check,
                            onTap: k.isCompleted
                                ? null
                                : () => _markTodayRead(index),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (isAjzaa)
                        KButtons.buttonIcon(
                          Theme.of(context),
                          text: "اذهب لورد اليوم",
                          icon: CupertinoIcons.play_arrow,
                          onTap:
                          k.isCompleted ? null : () => _goToTodayAjzaa(k),
                          bgColor: KColors.primaryColor,
                          fontSize: 14.sp,
                          fontColor: Colors.white,
                        ),
                      if (!isAjzaa)
                        Expanded(
                          child: SizedBox(
                            width: MediaQuery.sizeOf(context).width / 2,
                            child: KButtons.buttonIcon(
                              Theme.of(context),
                              text: "اذهب لورد اليوم",
                              icon: CupertinoIcons.play_arrow,
                              bgColor: KColors.primaryColor,
                              fontSize: 13.sp,
                              fontColor: Colors.white,
                              onTap: k.isCompleted
                                  ? null
                                  : () => _goToTodayPages(k),
                            ),
                          ),
                        ),
                    ],
                  )
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15),
            child: IconButton(
              onPressed: () => _openKhatmahOptions(k, index),
              icon: const Icon(
                Icons.more_vert,
                size: 30,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statItem(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        TextWidget(
            title: value,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.green),
        TextWidget(
          title: label,
          fontSize: 12.sp,
        ),
      ],
    );
  }

  void _openKhatmahOptions(KhatmahModel k, int index) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: SafeArea(
            child: Wrap(
              children: [
                ListTile(
                  leading: const Icon(
                    Icons.delete_forever_outlined,
                    color: Colors.redAccent,
                  ),
                  title: const TextWidget(title: "حذف الختمة"),
                  onTap: () {
                    Navigator.pop(context);
                    _deleteKhatmah(index);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.replay_outlined),
                  title: const TextWidget(title: "إعادة تعيين التقدم"),
                  onTap: () {
                    Navigator.pop(context);

                    // Reset في الصفحات
                    k.currentPage = 0;
                    k.isCompleted = false;
                    k.progressDates.clear();
                    k.save();

                    // Reset في الأجزاء (لو موجود)
                    final data = plansBox.get(k.id);
                    if (data is Map && data['distributionType'] == 'ajzaa') {
                      final newMap = Map<String, dynamic>.from(data);
                      newMap['currentDayIndex'] = 0;
                      plansBox.put(k.id, newMap);
                    }

                    setState(() {});
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentList = box.values.where((k) => !k.isCompleted).toList();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize:
          Size.fromHeight(MediaQuery.sizeOf(context).width > 600 ? 80 : 50),
          child: AppBar(
            leading: const CupertinoNavigationBarBackButton(
              color: Colors.black,
            ),
            actions: [
              IconButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreateKhatmahScreen(),
                  ),
                ),
                icon: const Icon(Icons.add),
              )
            ],
            centerTitle: true,
            title: Text(
              "الختمات الحالية",
              style: GoogleFonts.cairo(
                color: Colors.green,
                fontWeight: FontWeight.bold,
                fontSize: MediaQuery.sizeOf(context).width > 600 ? 12.sp : 18.sp,
              ),
            ),
          ),
        ),
        body: currentList.isEmpty
            ? Center(
          child: Column(
            spacing: 25,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset("assets/json/Koran im Ramadan lesen.json"),
              TextWidget(
                title: "لاتوجد اي ختمات قد قمت بإنشأها من قبل ",
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
              ),
              TextWidget(
                title: "قم بانشاء ختمتك الان.",
                fontSize: 14.sp,
                height: 0.6,
                fontWeight: FontWeight.bold,
              ),
              Center(
                child: SizedBox(
                  width: MediaQuery.sizeOf(context).width / 2,
                  child: CustomButton(
                    fontSize: 14.sp,
                    verticalPadding: 10,
                    backgroundColor: KColors.primaryColor,
                    width: MediaQuery.sizeOf(context).width / 3,
                    title: "انشاء ختمة جديدة",
                    onTap: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                        const CreateKhatmahScreen(),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        )
            : ListView.builder(
          padding: const EdgeInsets.only(top: 12, bottom: 80),
          itemCount: currentList.length,
          itemBuilder: (_, i) {
            final k = currentList[i];
            final index = box.values.toList().indexOf(k);
            return _buildKhatmahCard(k, index);
          },
        ),
      ),
    );
  }
}

