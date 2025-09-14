import 'package:flutter/cupertino.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:muslimdaily/app/core/cubit/centralized_cubit.dart';
import 'package:muslimdaily/app/core/shard/exports/all_exports.dart';
import 'package:muslimdaily/app/core/utils/style/k_color.dart';
import 'package:muslimdaily/app/core/utils/style/responsive_util.dart';
import 'package:muslimdaily/app/core/utils/vaildator.dart';
import 'package:muslimdaily/app/core/widgets/custom_form_faild.dart';
import 'package:muslimdaily/app/features/Khatmah/data/khatmah_model.dart';

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
    final plansBox = Hive.box('khatmahPlans');

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
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppStyle.bgColors,
        appBar: AppBar(
          leading: const CupertinoNavigationBarBackButton(color: Colors.black),
          centerTitle: true,
          title: Text(
            'إنشاء ختمة جديدة',
            style: GoogleFonts.cairo(
              color: Colors.green,
              fontWeight: FontWeight.bold,
              fontSize: MediaQuery.sizeOf(context).width > 600 ? 12.sp : 18.sp,
            ),
          ),
        ),
      
      
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                CustomTextFieldWidget(
                  backGroundColor: CentralizedCubit.isDarkMode
                      ? KColors.blackColor
                      : Theme.of(context).cardColor,
                  label: "اسم الختمة",
                  prefixIcon: Icon(
                    Icons.drive_file_rename_outline,
                    size: ResponsiveUtil.isTablet(context)
                        ? 11.sp
                        : 14.sp,
                  ),
                  controller:_titleController,
                  hint: "قم يادخال اسم الختمة",
                  borderRadiusValue: 15,
                  validator: Validator.name,
                  textInputType: TextInputType.name,
                ),

                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: "اسم الختمة",
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                  v == null || v.isEmpty ? "أدخل اسم الختمة" : null,
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
                  style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50)),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}