// import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:muslimdaily/app/core/shard/exports/all_exports.dart';
import 'package:muslimdaily/app/features/Khatmah/data/khatmah_model.dart';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:quran_library/quran.dart';


///*********************////

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

// TODO: استبدل بهذا import الصحيح عندك
// import 'package:your_app/create_khatmah_screen.dart';
// import 'package:your_app/quran_library.dart'; // فيه jumpToJoz
// import 'package:your_app/models/khatmah_model.dart';

class KhatmahDashboard extends StatefulWidget {
  const KhatmahDashboard({super.key});

  @override
  State<KhatmahDashboard> createState() => _KhatmahDashboardState();
}

class _KhatmahDashboardState extends State<KhatmahDashboard> with TickerProviderStateMixin {
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

  _PlanData? _getPlanData(KhatmahModel k) {
    final data = plansBox.get(k.id);
    if (data is! Map) return null;
    if (data['distributionType'] != 'ajzaa') return null;

    final int days = (data['days'] ?? 0) as int;
    final int currentDayIndex = (data['currentDayIndex'] ?? 0) as int;
    final String json = (data['dailyPlanJson'] ?? '[]') as String;

    final List<dynamic> raw = jsonDecode(json);
    final List<List<int>> plan = raw.map<List<int>>((e) => (e as List).cast<int>()).toList();

    return _PlanData(days: days, currentDayIndex: currentDayIndex, plan: plan);
  }

  /// صياغة نص ورد اليوم في وضع الأجزاء
  String _todayWirdAjzaa(_PlanData p) {
    if (p.currentDayIndex < 0 || p.currentDayIndex >= p.plan.length) return "لا يوجد ورد اليوم";
    final today = p.plan[p.currentDayIndex];
    if (today.isEmpty) return "—";
    if (today.length == 1) return "الجزء ${today.first}";
    return "الأجزاء ${today.first}–${today.last}";
  }

  /// تقدّم تقريبي في وضع الأجزاء = (اليوم الحالي / إجمالي الأيام)
  double _progressPercentAjzaa(_PlanData p) {
    if (p.days <= 0) return 0;
    // لو currentDayIndex يبدأ من 0، نعتبر التقدم بناءً على الأيام المقروءة
    final readDays = p.currentDayIndex; // أيام تم إكمالها
    final pct = readDays / p.days;
    return pct.clamp(0.0, 1.0);
  }

  /// الأيام المتبقية في وضع الأجزاء
  int _daysLeftAjzaa(_PlanData p) {
    final left = p.days - p.currentDayIndex;
    return left < 0 ? 0 : left;
    // لو عايز تخصم اليوم الجاري: p.days - (p.currentDayIndex + 1)
  }

  /// الانتقال لأوّل جزء في ورد اليوم باستخدام jumpToJoz
  void _goToTodayAjzaa(KhatmahModel k) {
    final p = _getPlanData(k);
    if (p == null) return;
    if (p.currentDayIndex < 0 || p.currentDayIndex >= p.plan.length) return;
    final today = p.plan[p.currentDayIndex];
    if (today.isEmpty) return;

    final firstJoz = today.first;
    // TODO: نادِ دالتك الحقيقية
    jumpToJoz(jozNumber: firstJoz,context: context);


  }

  /// تأشير اليوم كمقروء في وضع الأجزاء
  void _markTodayReadAjzaa(KhatmahModel k) {
    final raw = plansBox.get(k.id);
    if (raw is! Map) return;
    if (raw['distributionType'] != 'ajzaa') return;

    final data = Map<String, dynamic>.from(raw);
    final int days = (data['days'] ?? 0) as int;
    int idx = (data['currentDayIndex'] ?? 0) as int;

    // لو الختمة خلصت، لا تفعل شيء
    if (idx >= days) return;

    // اعتبر اليوم الحالي تمّ قراءته → انتقل لليوم التالي
    idx = (idx + 1).clamp(0, days);

    data['currentDayIndex'] = idx;
    plansBox.put(k.id, data);

    // سجّل تاريخ التأشير في موديلك (لأجل الإحصاءات)
    k.progressDates.add(DateTime.now());

    // حدّث حالة الاكتمال لو تعدّينا الأيام
    if (idx >= days) {
      k.isCompleted = true;
    }

    k.save();
    setState(() {});
  }

  // ------------------ منطق الصفحات (قديمك كما هو) ------------------

  void _markTodayReadPages(KhatmahModel k) {
    if (k.isCompleted) return;

    final increment = k.dailyPages;
    k.currentPage += increment;
    if (k.currentPage >= k.totalPages) {
      k.currentPage = k.totalPages;
      k.isCompleted = true;
    }
    k.progressDates.add(DateTime.now());
    k.save();
    setState(() {});
  }

  // واجهة موحّدة للزر
  void _markTodayRead(int index) {
    final khatma = box.getAt(index);
    if (khatma == null) return;
    if (khatma.isCompleted) return;

    if (_isAjzaa(khatma)) {
      _markTodayReadAjzaa(khatma);
    } else {
      _markTodayReadPages(khatma);
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

    final pagesLeft = k.pagesLeft; // قد لا يعكس “أجزاء”، لكنه لا يضر للعرض العام

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                CircularPercentIndicator(
                  radius: 60,
                  lineWidth: 10,
                  percent: progressPercent > 1 ? 1 : progressPercent,
                  center: Text("${(progressPercent * 100).toStringAsFixed(1)}%"),
                  progressColor: Colors.green,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(k.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Text("ورد اليوم: $todayWirdText"),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          _statItem("$pagesLeft", "صفحات"),       // للعرض العام
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
                  child: ElevatedButton.icon(
                    onPressed: k.isCompleted ? null : () => _markTodayRead(index),
                    icon: const Icon(Icons.check),
                    label: Text(k.isCompleted ? "مكتملة" : "✔ قراءة اليوم"),
                  ),
                ),
                const SizedBox(width: 8),
                if (isAjzaa) // زر الذهاب لورد اليوم في وضع الأجزاء
                  ElevatedButton.icon(
                    onPressed: k.isCompleted ? null : () => _goToTodayAjzaa(k),
                    icon: const Icon(Icons.play_arrow),
                    label: const Text("اذهب لورد اليوم"),
                  ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => _openKhatmahOptions(k, index),
                  icon: const Icon(Icons.more_vert),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _statItem(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green)),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  void _openKhatmahOptions(KhatmahModel k, int index) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.delete_forever),
                title: const Text("حذف الختمة"),
                onTap: () {
                  Navigator.pop(context);
                  _deleteKhatmah(index);
                },
              ),
              ListTile(
                leading: const Icon(Icons.replay),
                title: const Text("إعادة تعيين التقدم"),
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
        );
      },
    );
  }

  Widget _buildCurrentTab() {
    final currentList = box.values.where((k) => !k.isCompleted).toList();
    if (currentList.isEmpty) {
      return Center(
        child: ElevatedButton.icon(
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CreateKhatmahScreen())),
          icon: const Icon(Icons.add),
          label: const Text("ابدأ ختمة جديدة"),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 12, bottom: 80),
      itemCount: currentList.length,
      itemBuilder: (_, i) {
        final k = currentList[i];
        final index = box.values.toList().indexOf(k);
        return _buildKhatmahCard(k, index);
      },
    );
  }

  Widget _buildCompletedTab() {
    final completed = box.values.where((k) => k.isCompleted).toList();
    if (completed.isEmpty) {
      return const Center(child: Text("لم تُنجز أي ختمة بعد."));
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 12, bottom: 80),
      itemCount: completed.length,
      itemBuilder: (_, i) {
        final k = completed[i];
        final index = box.values.toList().indexOf(k);
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          child: ListTile(
            title: Text(k.title),
            subtitle: Text("انتهت في: ${k.endDate.toLocal().toString().split(' ').first}"),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _deleteKhatmah(index),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // ملاحظة: السطر التالي كان ناقصه فاصلة منقوطة في كودك الأصلي
    // QuranLibrary();
    return Scaffold(
      appBar: AppBar(
        title: const Text("ختمتك"),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "الحالية"),
            Tab(text: "السابقة"),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CreateKhatmahScreen())),
          )
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: box.listenable(),
        builder: (context, Box<KhatmahModel> b, _) {
          return TabBarView(
            controller: _tabController,
            children: [
              _buildCurrentTab(),
              _buildCompletedTab(),
            ],
          );
        },
      ),
    );
  }
}

// ------------------ Types & Stubs ------------------

class _PlanData {
  final int days;
  final int currentDayIndex; // 0-based
  final List<List<int>> plan;
  _PlanData({required this.days, required this.currentDayIndex, required this.plan});
}

// TODO: غيّرها لاستدعاء مكتبتك الحقيقية
void jumpToJoz({required int jozNumber,required BuildContext context}) {
  QuranLibrary().jumpToJoz(jozNumber);
  Navigator.pop(context);
  debugPrint("jumpToJoz($jozNumber) called");

}

// TODO: عدّل هذه الـ imports/الكلاسات حسب مشروعك
class CreateKhatmahScreens extends StatelessWidget {
  const CreateKhatmahScreens({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('CreateKhatmahScreen placeholder')));
  }
}

// موديلك الحقيقي فيه todayWird / progressPercent / pagesLeft / daysLeft

/// يبني خطة يومية من أرقام الأجزاء: [[1,2], [3], [4,5], ...]
/// - days: عدد الأيام
/// - totalJuz: إجمالي الأجزاء (افتراضي 30)
/// - startJuz: أول جزء يبدأ منه التقسيم (افتراضي 1)
List<List<int>> _buildDailyJuzPlan(
    int days, {
      int totalJuz = 30,
      int startJuz = 1,
    }) {
  if (days <= 0 || totalJuz <= 0) return const [];

  // توزيع عادل: أول (remainder) أيام تأخذ +1
  final base = totalJuz ~/ days;
  int remainder = totalJuz % days;

  final perDay = List<int>.generate(
    days,
        (_) => base + (remainder-- > 0 ? 1 : 0),
  );

  final plan = <List<int>>[];
  int current = startJuz; // 1-based

  for (final count in perDay) {
    if (current > (startJuz + totalJuz - 1)) {
      // خلّصنا كل الأجزاء
      plan.add(const []);
      continue;
    }

    final end = (current + count - 1);
    final endClamped = end.clamp(current, startJuz + totalJuz - 1);

    final today = <int>[];
    for (int j = current; j <= endClamped; j++) {
      today.add(j);
    }
    plan.add(today);

    current = endClamped + 1;
  }

  // لو لسه في أيام زيادة بعد انتهاء الأجزاء، تفضل فاضية
  while (plan.length < days) {
    plan.add(const []);
  }

  return plan;
}

// ====== شاشتك مع الدمج ======

class CreateKhatmahScreen extends StatefulWidget {
  const CreateKhatmahScreen({super.key});

  @override
  State<CreateKhatmahScreen> createState() => _CreateKhatmahScreenState();
}

class _CreateKhatmahScreenState extends State<CreateKhatmahScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController(text: "ختمة جديدة");
  int _days = 30;
  String _distribution = "صفحات"; // "صفحات" أو "أجزاء"

  void _saveKhatmah() {
    if (!_formKey.currentState!.validate()) return;

    // final khatmahBox = Hive.box<KhatmahModel>('khatmahBox');
    final khatmahBox = Hive.box<KhatmahModel>('khatmahBox');
    final plansBox   = Hive.box('khatmahPlans');


    const int totalPages = 604; // عدّله لو مصحفك مختلف

    // نولّد id الآن عشان نربط به الخطة في khatmahPlans
    final String khId = DateTime.now().toIso8601String();

    // في وضع "صفحات": نفس منطقك الحالي
    if (_distribution == "صفحات") {
      final int dailyPages = (totalPages / _days).ceil();
      final newKhatmah = KhatmahModel(
        id: khId,
        title: _titleController.text,
        totalPages: totalPages,
        currentPage: 0,
        startDate: DateTime.now(),
        endDate: DateTime.now().add(Duration(days: _days)),
        dailyPages: dailyPages,
      );
      khatmahBox.add(newKhatmah);

      // نخزّن نوع التوزيع فقط في plansBox (اختياري للمعلومة)
      plansBox.put(khId, {
        'distributionType': 'pages',
        'days': _days,
      });

    } else {
      // في وضع "أجزاء": نبني خطة يومية بالأجزاء
      final plan = _buildDailyJuzPlan(_days); // [[1,2],[3],[4,5],...]
      final planJson = jsonEncode(plan);

      // في وضع "أجزاء" مش هنستخدم dailyPages (خليه 0 أو سيبه كما تحب)
      final newKhatmah = KhatmahModel(
        id: khId,
        title: _titleController.text,
        totalPages: totalPages,
        currentPage: 0,
        startDate: DateTime.now(),
        endDate: DateTime.now().add(Duration(days: _days)),
        dailyPages: 0, // غير مستخدم مع الأجزاء
      );
      khatmahBox.add(newKhatmah);

      // نحفظ الخطة ونوع التوزيع في بوكس منفصل
      plansBox.put(khId, {
        'distributionType': 'ajzaa',
        'days': _days,
        'currentDayIndex': 0, // 0-based
        'dailyPlanJson': planJson, // List<List<int>>
      });

      // (اختياري) للديبج:
      // for (int i = 0; i < plan.length; i++) {
      //   debugPrint('اليوم ${i+1}: ${plan[i].isEmpty ? "—" : "أجزاء ${plan[i].first}..${plan[i].last}"}');
      // }
    }

    // (اختياري) جدولة إشعار… نفس كودك المعلّق

    Navigator.pop(context);
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("إنشاء ختمة جديدة")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: "اسم الختمة",
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v == null || v.isEmpty ? "أدخل اسم الختمة" : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: _days,
                decoration: const InputDecoration(
                  labelText: "مدة الختمة بالأيام",
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 7, child: Text("7 أيام")),
                  DropdownMenuItem(value: 10, child: Text("10 أيام")),
                  DropdownMenuItem(value: 30, child: Text("30 يوم")),
                  DropdownMenuItem(value: 60, child: Text("60 يوم")),
                ],
                onChanged: (v) => setState(() => _days = v ?? 30),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _distribution,
                decoration: const InputDecoration(
                  labelText: "طريقة التوزيع",
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: "صفحات", child: Text("صفحات")),
                  DropdownMenuItem(value: "أجزاء", child: Text("أجزاء")),
                ],
                onChanged: (v) => setState(() => _distribution = v ?? "صفحات"),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _saveKhatmah,
                icon: const Icon(Icons.save),
                label: const Text("ابدأ الختمة"),
                style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
              )
            ],
          ),
        ),
      ),
    );
  }
}



// class CreateKhatmahScreen extends StatefulWidget {
//   const CreateKhatmahScreen({super.key});
//
//   @override
//   State<CreateKhatmahScreen> createState() => _CreateKhatmahScreenState();
// }
//
// class _CreateKhatmahScreenState extends State<CreateKhatmahScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _titleController = TextEditingController(text: "ختمة رمضان");
//   int _days = 30;
//   String _distribution = "صفحات"; // أو "أجزاء"
//
//   void _saveKhatmah() {
//     if (_formKey.currentState!.validate()) {
//       final box = Hive.box<KhatmahModel>('khatmahBox');
//
//       final newKhatmah = KhatmahModel(
//         id: DateTime.now().toIso8601String(),
//         title: _titleController.text,
//         totalPages: 604, // عدد صفحات المصحف
//         currentPage: 0,
//         startDate: DateTime.now(),
//         endDate: DateTime.now().add(Duration(days: _days)),
//       );
//
//       box.add(newKhatmah);
//
//       Navigator.pop(context); // رجوع للـ Dashboard
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("إنشاء ختمة جديدة")),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             children: [
//               // اسم الختمة
//               TextFormField(
//                 controller: _titleController,
//                 decoration: const InputDecoration(
//                   labelText: "اسم الختمة",
//                   border: OutlineInputBorder(),
//                 ),
//                 validator: (value) =>
//                 value == null || value.isEmpty ? "أدخل اسم الختمة" : null,
//               ),
//               const SizedBox(height: 20),
//
//               // اختيار المدة
//               DropdownButtonFormField<int>(
//                 value: _days,
//                 decoration: const InputDecoration(
//                   labelText: "مدة الختمة بالأيام",
//                   border: OutlineInputBorder(),
//                 ),
//                 items: const [
//                   DropdownMenuItem(value: 10, child: Text("10 أيام")),
//                   DropdownMenuItem(value: 30, child: Text("30 يوم")),
//                   DropdownMenuItem(value: 60, child: Text("60 يوم")),
//                   DropdownMenuItem(value: 90, child: Text("90 يوم")),
//                 ],
//                 onChanged: (val) => setState(() => _days = val ?? 30),
//               ),
//               const SizedBox(height: 20),
//
//               // التوزيع
//               DropdownButtonFormField<String>(
//                 value: _distribution,
//                 decoration: const InputDecoration(
//                   labelText: "طريقة التوزيع",
//                   border: OutlineInputBorder(),
//                 ),
//                 items: const [
//                   DropdownMenuItem(value: "صفحات", child: Text("صفحات")),
//                   DropdownMenuItem(value: "أجزاء", child: Text("أجزاء")),
//                 ],
//                 onChanged: (val) =>
//                     setState(() => _distribution = val ?? "صفحات"),
//               ),
//               const SizedBox(height: 30),
//
//               // زر الحفظ
//               ElevatedButton.icon(
//                 onPressed: _saveKhatmah,
//                 icon: const Icon(Icons.save),
//                 label: const Text("ابدأ الختمة"),
//                 style: ElevatedButton.styleFrom(
//                   minimumSize: const Size.fromHeight(50),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//               )
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
