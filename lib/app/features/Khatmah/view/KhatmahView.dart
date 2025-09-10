import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:muslimdaily/app/core/shard/exports/all_exports.dart';
import 'package:muslimdaily/app/features/Khatmah/data/khatmah_model.dart';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:percent_indicator/percent_indicator.dart';


///*********************////

class KhatmahDashboard extends StatefulWidget {
  const KhatmahDashboard({super.key});

  @override
  State<KhatmahDashboard> createState() => _KhatmahDashboardState();
}

class _KhatmahDashboardState extends State<KhatmahDashboard> with TickerProviderStateMixin {
  late final Box<KhatmahModel> box;
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    box = Hive.box<KhatmahModel>('khatmahBox');
    _tabController = TabController(length: 2, vsync: this);
  }

  void _markTodayRead(int index) {
    final khatma = box.getAt(index);
    if (khatma == null) return;

    // إذا اكتملت الختمة لا نفعل شيء
    if (khatma.isCompleted) return;

    final increment = khatma.dailyPages;
    khatma.currentPage += increment;
    if (khatma.currentPage >= khatma.totalPages) {
      khatma.currentPage = khatma.totalPages;
      khatma.isCompleted = true;
    }

    // سجل تاريخ التأشير للاحصائيات
    khatma.progressDates.add(DateTime.now());
    khatma.save();

    setState(() {});
  }

  // حذف ختمة (مثلاً من السجل)
  void _deleteKhatmah(int index) {
    box.deleteAt(index);
    setState(() {});
  }

  Widget _buildKhatmahCard(KhatmahModel k, int index) {
    final progressPercent = k.progressPercent;
    final pagesLeft = k.pagesLeft;
    final daysLeft = k.daysLeft;
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
                      Text("ورد اليوم: ${k.todayWird}"),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          _statItem("${pagesLeft}", "صفحات"),
                          const SizedBox(width: 10),
                          _statItem("${daysLeft}", "أيام"),
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
                  k.currentPage = 0;
                  k.isCompleted = false;
                  k.progressDates.clear();
                  k.save();
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
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => CreateKhatmahScreen(),)),
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
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => CreateKhatmahScreen(),)),
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


class CreateKhatmahScreen extends StatefulWidget {
  const CreateKhatmahScreen({super.key});

  @override
  State<CreateKhatmahScreen> createState() => _CreateKhatmahScreenState();
}

class _CreateKhatmahScreenState extends State<CreateKhatmahScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController(text: "ختمة جديدة");
  int _days = 30;
  String _distribution = "صفحات"; // لمستقبلية توسعات

  void _saveKhatmah() {
    if (!_formKey.currentState!.validate()) return;

    final box = Hive.box<KhatmahModel>('khatmahBox');
    const int totalPages = 604; // مصحف كامل — عدّله لو عندك مصدر آخر
    final int dailyPages = (totalPages / _days).ceil();

    final newKhatmah = KhatmahModel(
      id: DateTime.now().toIso8601String(),
      title: _titleController.text,
      totalPages: totalPages,
      currentPage: 0,
      startDate: DateTime.now(),
      endDate: DateTime.now().add(Duration(days: _days)),
      dailyPages: dailyPages,
    );

    box.add(newKhatmah);

    // جدولة إشعار يومي فريد لهذه الختمة (ملاحظة: حفظنا id للإشعار كـ hash)
    final notifId = DateTime.now().millisecondsSinceEpoch.remainder(100000);
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: notifId,
        channelKey: 'khatmah_channel',
        title: 'وردك اليوم 📖',
        body: '${newKhatmah.title} — ${newKhatmah.todayWird}',
        notificationLayout: NotificationLayout.Default,
      ),
      schedule: NotificationCalendar(
        hour: 20,
        minute: 0,
        second: 0,
        repeats: true,
      ),
    );

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
