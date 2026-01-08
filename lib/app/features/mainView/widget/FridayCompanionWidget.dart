import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../../shareCard/PremiumShareCard.dart';

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

    // Default visibility logic (Friday only)
    if (now.weekday == DateTime.friday) {
      _isVisible = true;
    } else {
      // For testing, you can force it here:
      // _isVisible = true;
      _isVisible = false;
    }

    if (!_isVisible) {
      if (mounted) setState(() {});
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final todayKey = DateFormat('yyyy-MM-dd').format(now);

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
    if (!_isVisible) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
            ],
          ),
          const SizedBox(height: 12),

          // 1. Salawat Card
          _buildSalawatCard(context, isDark),

          const SizedBox(height: 16),

          // 2. Sunnahs Checklist Card
          _buildSunnahsCard(context, isDark),
        ],
      ),
    );
  }

  Widget _buildSalawatCard(BuildContext context, bool isDark) {
    const salawatText =
        "إِنَّ اللَّهَ وَمَلَائِكَتَهُ يُصَلُّونَ عَلَى النَّبِيِّ ۚ يَا أَيُّهَا الَّذِينَ آمَنُوا صَلُّوا عَلَيْهِ وَسَلِّمُوا تَسْلِيمًا";

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
              : [const Color(0xFFF1F8E9), const Color(0xFFE8F5E9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Stack(
        children: [
          // Background pattern/icon
          Positioned(
            left: -20,
            bottom: -20,
            child: Icon(
              Icons.favorite,
              size: 150,
              color: Colors.green.withOpacity(0.05),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Text(
                  "الصلاة على النبي ﷺ",
                  style: GoogleFonts.cairo(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  salawatText,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.amiri(
                    fontSize: 18.sp,
                    height: 1.6,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => const PremiumShareCard(
                          text: salawatText,
                          azkarName: "الصلاة على النبي ﷺ",
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.share, size: 18),
                    label: Text(
                      "شارك كصورة",
                      style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSunnahsCard(BuildContext context, bool isDark) {
    final completed = _sunnahs.where((s) => s['done']).length;
    final total = _sunnahs.length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "سنن الجمعة ✨",
                style: GoogleFonts.cairo(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              Text(
                "$completed / $total",
                style: GoogleFonts.cairo(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isDone
                        ? Colors.green
                        : (isDark ? Colors.white10 : Colors.grey.shade100),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color:
                          isDone ? Colors.green : Colors.grey.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isDone)
                        const Icon(Icons.check, color: Colors.white, size: 14),
                      if (isDone) const SizedBox(width: 4),
                      Text(
                        sunnah['title'],
                        style: GoogleFonts.cairo(
                          fontSize: 11.sp,
                          fontWeight:
                              isDone ? FontWeight.bold : FontWeight.normal,
                          color: isDone
                              ? Colors.white
                              : (isDark ? Colors.white70 : Colors.black87),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setInt('last_page', 292);
                int kahfIndex = _sunnahs.indexWhere((s) => s['id'] == 'kahf');
                if (kahfIndex != -1 && !_sunnahs[kahfIndex]['done']) {
                  _toggle(kahfIndex);
                }
                if (context.mounted) {
                  Navigator.pushNamed(context, "/surahListScreen");
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37),
                foregroundColor: Colors.black87,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.menu_book, size: 18),
              label: Text(
                "اقرأ سورة الكهف الآن",
                style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
