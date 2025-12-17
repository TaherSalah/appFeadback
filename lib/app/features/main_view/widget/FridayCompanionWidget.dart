import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class FridayCompanionWidget extends StatefulWidget {
  const FridayCompanionWidget({super.key});

  @override
  State<FridayCompanionWidget> createState() => _FridayCompanionWidgetState();
}

class _FridayCompanionWidgetState extends State<FridayCompanionWidget> {
  bool _isVisible = false;

  final List<Map<String, dynamic>> _sunnahs = [
    {"id": "ghusl", "title": "غسل الجمعة 🚿", "done": false},
    {"id": "perfume", "title": "التطيب والسواك 🧴", "done": false},
    {"id": "kahf", "title": "قراءة سورة الكهف 📖", "done": false},
    {"id": "mosque", "title": "التبكير للمسجد 🕌", "done": false},
    {"id": "salawat", "title": "الصلاة على النبي ﷺ ❤️", "done": false},
    {"id": "dua", "title": "دعاء ساعة الاستجابة 🤲", "done": false},
  ];

  @override
  void initState() {
    super.initState();
    _checkFridayAndLoad();
  }

  Future<void> _checkFridayAndLoad() async {
    final now = DateTime.now();
    // Friday is weekday 5 in standard Dart DateTime (Mon=1 ... Sun=7)??
    // Wait, let's verify standard Dart DateTime: Mon=1, Tue=2, Wed=3, Thu=4, Fri=5, Sat=6, Sun=7.
    // So Friday is 5.

    // 🛠️ للتحكم في ظهور الودجت:

    // 1. الوضع الطبيعي (يظهر يوم الجمعة فقط):
    // _isVisible = true; // ❌ اجعل هذا السطر تعليقاً (comment)

    if (now.weekday == DateTime.friday) {
      _isVisible = true;
    } else {
      // 2. وضع الاختبار (لإظهاره في أي يوم):
      // قم بإلغاء التعليق عن السطر التالي لجعله يظهر دائماً:
      // _isVisible = true;

      _isVisible = false;

      // If today is NOT Friday (and forced mode is OFF), hide it.
      if (!_isVisible) {
        if (mounted) setState(() {});
        return;
      }
    }

    // Load progress for TODAY's Friday
    final prefs = await SharedPreferences.getInstance();
    final todayKey = DateFormat('yyyy-MM-dd').format(now);

    // Check if we have saved data for THIS specific Friday
    final savedDate = prefs.getString('friday_last_date');
    if (savedDate == todayKey) {
      final savedState = prefs.getString('friday_tasks_state');
      if (savedState != null) {
        final decoded = jsonDecode(savedState) as Map<String, dynamic>;
        for (var sunnah in _sunnahs) {
          if (decoded.containsKey(sunnah['id'])) {
            sunnah['done'] = decoded[sunnah['id']];
          }
        }
      }
    } else {
      // It's a new Friday, reset everything
      await prefs.setString('friday_last_date', todayKey);
      await _saveProgress();
    }

    if (mounted) setState(() {});
  }

  Future<void> _saveProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final Map<String, dynamic> state = {};
    for (var sunnah in _sunnahs) {
      state[sunnah['id']] = sunnah['done'];
    }
    await prefs.setString('friday_tasks_state', jsonEncode(state));
  }

  void _toggle(int index) {
    setState(() {
      _sunnahs[index]['done'] = !_sunnahs[index]['done'];
    });
    _saveProgress();
  }

  @override
  Widget build(BuildContext context) {
    // If it's not Friday (and not forced for debug), hide the widget entirely
    if (!_isVisible) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final total = _sunnahs.length;
    final completed = _sunnahs.where((s) => s['done']).length;
    final progress = completed / total;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.mosque_outlined, color: Colors.green),
              const SizedBox(width: 8),
              Text(
                "رفيق الجمعة 🕌",
                style: GoogleFonts.cairo(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green)),
                child: Text(
                  "$completed / $total",
                  style: GoogleFonts.cairo(
                      fontWeight: FontWeight.bold, color: Colors.green),
                ),
              )
            ],
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF1E293B)
                  : const Color(0xFFF1F8E9), // Light Green bg
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.green.withOpacity(0.5)),
            ),
            child: Column(
              children: [
                // Checklist
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: List.generate(_sunnahs.length, (index) {
                    final sunnah = _sunnahs[index];
                    final isDone = sunnah['done'];

                    return InkWell(
                      onTap: () => _toggle(index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isDone
                              ? Colors.green
                              : (isDark ? Colors.white10 : Colors.white),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: isDone
                                  ? Colors.green
                                  : Colors.grey.withOpacity(0.3)),
                          boxShadow: isDone
                              ? [
                                  BoxShadow(
                                      color: Colors.green.withOpacity(0.4),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2))
                                ]
                              : [],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isDone)
                              const Icon(Icons.check,
                                  color: Colors.white, size: 16),
                            if (isDone) const SizedBox(width: 4),
                            Text(
                              sunnah['title'],
                              style: GoogleFonts.cairo(
                                  fontSize: 12.sp,
                                  fontWeight: isDone
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: isDone
                                      ? Colors.white
                                      : (isDark
                                          ? Colors.white70
                                          : Colors.black87)),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 16),

                // Kahf Button Special
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      // Set page to Surat Al-Kahf (Page 293 -> Index 292)
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setInt('last_page', 292);

                      int kahfIndex =
                          _sunnahs.indexWhere((s) => s['id'] == 'kahf');
                      if (kahfIndex != -1 && !_sunnahs[kahfIndex]['done']) {
                        _toggle(kahfIndex);
                      }

                      if (context.mounted) {
                        Navigator.pushNamed(context, "/surahListScreen");
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD4AF37), // Gold
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.menu_book, color: Colors.black87),
                    label: Text("اقرأ سورة الكهف الآن",
                        style: GoogleFonts.cairo(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87)),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
