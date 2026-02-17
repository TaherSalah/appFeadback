import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../shareCard/PremiumShareCard.dart';

// ══════════════════════════════════════════════
//  🕌  Friday Companion Widget — رفيق الجمعة
//  ─────────────────────────────────────────────
//  • Progress bar + count
//  • Salawat card (Quranic verse)
//  • Sunnah checklist chips
//  • Open Surah Al-Kahf button
//  All merged into ONE unified card with an
//  Islamic gold × emerald palette.
// ══════════════════════════════════════════════

class FridayCompanionWidget extends StatefulWidget {
  const FridayCompanionWidget({super.key});

  @override
  State<FridayCompanionWidget> createState() => _FridayCompanionWidgetState();
}

class _FridayCompanionWidgetState extends State<FridayCompanionWidget>
    with SingleTickerProviderStateMixin {

  // ─── Visibility ─────────────────────────────
  bool _isVisible = false;

  // ─── Animation ──────────────────────────────
  late final AnimationController _fadeCtrl;
  late final Animation<double>    _fadeAnim;
  late final Animation<Offset>    _slideAnim;

  // ─── Palette ────────────────────────────────
  static const _gold      = Color(0xFFC9A84C);
  static const _goldDark  = Color(0xFF9A7225);
  static const _goldLight = Color(0xFFF0DFA0);
  static const _emerald   = Color(0xFF1E5C45);
  static const _emeraldMid= Color(0xFF2D7A5C);
  static const _emeraldLt = Color(0xFF4BAE85);
  static const _darkBg    = Color(0xFF0B1520);
  static const _darkCard  = Color(0xFF132030);
  static const _lightCard = Color(0xFFFAF7F0);
  static const _lightBg   = Color(0xFFF4EDD8);

  // ─── Sunnah data ────────────────────────────
  final List<Map<String, dynamic>> _sunnahs = [
    {"id": "ghusl",   "title": "غسل الجمعة",        "emoji": "", "done": false},
    {"id": "perfume", "title": "التطيب والسواك",      "emoji": "", "done": false},
    {"id": "kahf",    "title": "سورة الكهف",          "emoji": "", "done": false},
    {"id": "mosque",  "title": "التبكير للمسجد",      "emoji": "", "done": false},
    {"id": "salawat", "title": "الصلاة على النبي ﷺ", "emoji": "",  "done": false},
    {"id": "dua",     "title": "ساعة الاستجابة",     "emoji": "", "done": false},
  ];

  // ─── Computed ───────────────────────────────
  int get _completedCount => _sunnahs.where((s) => s['done'] == true).length;
  bool get _allDone       => _completedCount == _sunnahs.length;

  // ════════════════════════════════════════════
  @override
  void initState() {
    super.initState();

    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end:   Offset.zero,
    ).animate(CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut));

    _checkFridayAndLoad();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  // ─── Friday check + SharedPrefs load ────────
  Future<void> _checkFridayAndLoad() async {
    final now = DateTime.now();
    _isVisible = (now.weekday == DateTime.friday);
    // For testing: _isVisible = true;

    if (!_isVisible) {
      if (mounted) setState(() {});
      return;
    }

    final prefs    = await SharedPreferences.getInstance();
    final todayKey = DateFormat('yyyy-MM-dd').format(now);
    final savedDate= prefs.getString('friday_last_date');

    if (savedDate == todayKey) {
      final raw = prefs.getString('friday_tasks_state');
      if (raw != null) {
        final decoded = jsonDecode(raw) as Map<String, dynamic>;
        for (final s in _sunnahs) {
          if (decoded.containsKey(s['id'])) s['done'] = decoded[s['id']];
        }
      }
    } else {
      await prefs.setString('friday_last_date', todayKey);
      await _saveProgress();
    }

    if (mounted) {
      setState(() {});
      _fadeCtrl.forward();
    }
  }

  Future<void> _saveProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'friday_tasks_state',
      jsonEncode({for (final s in _sunnahs) s['id']: s['done']}),
    );
  }

  void _toggle(int index) {
    HapticFeedback.lightImpact();
    setState(() => _sunnahs[index]['done'] = !_sunnahs[index]['done']);
    _saveProgress();
  }

  // ════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    if (!_isVisible) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Header(isDark: isDark),
              const SizedBox(height: 14),
              _MainCard(
                isDark:    isDark,
                sunnahs:   _sunnahs,
                completed: _completedCount,
                total:     _sunnahs.length,
                allDone:   _allDone,
                onToggle:  _toggle,
                onKahf:    _openKahf,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Navigate to Surah Al-Kahf ──────────────
  Future<void> _openKahf() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('last_page', 292);

    final idx = _sunnahs.indexWhere((s) => s['id'] == 'kahf');
    if (idx != -1 && !_sunnahs[idx]['done']) _toggle(idx);

    if (mounted) Navigator.pushNamed(context, "/surahListScreen");
  }
}

// ════════════════════════════════════════════════════════════
//  Sub-widgets (stateless, pure UI)
// ════════════════════════════════════════════════════════════

// ─── Header ──────────────────────────────────────────────
class _Header extends StatelessWidget {
  final bool isDark;
  const _Header({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Icon badge
        Container(
          width: 46, height: 46,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [_FridayCompanionWidgetState._gold, _FridayCompanionWidgetState._goldDark],
              begin: Alignment.topLeft,
              end:   Alignment.bottomRight,
            ),
            boxShadow: [BoxShadow(
              color: _FridayCompanionWidgetState._gold.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            )],
          ),
          child: const Center(child: Text("🕌", style: TextStyle(fontSize: 22))),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "رفيق الجمعة",
              style: GoogleFonts.amiri(
                fontSize: 21.sp,
                fontWeight: FontWeight.bold,
                color: isDark ? _FridayCompanionWidgetState._goldLight
                    : _FridayCompanionWidgetState._goldDark,
              ),
            ),
            Text(
              "يَوْمَ الْجُمُعَةِ سَيِّدُ الأَيَّامِ",
              style: GoogleFonts.cairo(
                fontSize: 11.sp,
                color: isDark ? Colors.white38 : Colors.black38,
              ),
            ),
          ],
        ),
        const Spacer(),
        Text("✦", style: TextStyle(
          fontSize: 24,
          color: _FridayCompanionWidgetState._gold.withOpacity(0.45),
        )),
      ],
    );
  }
}

// ─── Main Unified Card ───────────────────────────────────
class _MainCard extends StatelessWidget {
  final bool     isDark;
  final List<Map<String,dynamic>> sunnahs;
  final int      completed;
  final int      total;
  final bool     allDone;
  final void Function(int) onToggle;
  final VoidCallback onKahf;

  const _MainCard({
    required this.isDark,
    required this.sunnahs,
    required this.completed,
    required this.total,
    required this.allDone,
    required this.onToggle,
    required this.onKahf,
  });

  Color get _cardColor  => isDark ? _FridayCompanionWidgetState._darkCard
      : _FridayCompanionWidgetState._lightCard;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: _FridayCompanionWidgetState._gold.withOpacity(0.22),
          width: 1.4,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.35 : 0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Background ornament
            // Positioned(
            //   left: -10, top: -10,
            //   child: Text("☪", style: TextStyle(
            //     fontSize: 140,
            //     color: _FridayCompanionWidgetState._gold.withOpacity(0.04),
            //     fontFamily: 'cairo',
            //   )),
            // ),

            // Gold top stripe
            Positioned(
              top: 0, left: 0, right: 0,
              child: Container(
                height: 3,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    Colors.transparent,
                    _FridayCompanionWidgetState._gold,
                    _FridayCompanionWidgetState._goldLight,
                    _FridayCompanionWidgetState._gold,
                    Colors.transparent,
                  ]),
                ),
              ),
            ),

            Column(
              children: [
                const SizedBox(height: 3), // space for stripe
                _ProgressSection(isDark: isDark, completed: completed, total: total, allDone: allDone),
                _Divider(),
                _SalawatSection(isDark: isDark),
                _Divider(),
                _SunnahsSection(
                  isDark:    isDark,
                  sunnahs:   sunnahs,
                  allDone:   allDone,
                  onToggle:  onToggle,
                  onKahf:    onKahf,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Progress ────────────────────────────────────────────
class _ProgressSection extends StatelessWidget {
  final bool isDark;
  final int completed, total;
  final bool allDone;
  const _ProgressSection({
    required this.isDark, required this.completed,
    required this.total,  required this.allDone,
  });

  @override
  Widget build(BuildContext context) {
    final progress = total == 0 ? 0.0 : completed / total;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                allDone ? "🌟 أكملت كل السنن!" : "إنجازك اليوم",
                style: GoogleFonts.cairo(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white60 : Colors.black54,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 3),
                decoration: BoxDecoration(
                  color: _FridayCompanionWidgetState._gold.withOpacity(0.12),
                  border: Border.all(color: _FridayCompanionWidgetState._gold.withOpacity(0.35)),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "$completed / $total",
                  style: GoogleFonts.cairo(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                    color: _FridayCompanionWidgetState._goldDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: progress),
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeInOut,
              builder: (_, value, __) => LinearProgressIndicator(
                value: value,
                minHeight: 7,
                backgroundColor: isDark ? Colors.white10 : Colors.black38,
                valueColor: AlwaysStoppedAnimation(
                  allDone ? _FridayCompanionWidgetState._emeraldLt
                      : _FridayCompanionWidgetState._gold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Salawat ─────────────────────────────────────────────
class _SalawatSection extends StatelessWidget {
  final bool isDark;
  const _SalawatSection({required this.isDark});

  static const _verse =
      "إِنَّ اللَّهَ وَمَلَائِكَتَهُ يُصَلُّونَ عَلَى النَّبِيِّ ۚ "
      "يَا أَيُّهَا الَّذِينَ آمَنُوا صَلُّوا عَلَيْهِ وَسَلِّمُوا تَسْلِيمًا";

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        // gradient: LinearGradient(
        //   colors: isDark
        //       ? [const Color(0xFF0F2B1C), const Color(0xFF0B1B12)]
        //       : [const Color(0xFFEDF7F1), const Color(0xFFD6EEE3)],
        //   begin: Alignment.topRight,
        //   end:   Alignment.bottomLeft,
        // ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
        child: Column(
          children: [
            // Badge
            // Container(
            //   padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            //   decoration: BoxDecoration(
            //     color: _FridayCompanionWidgetState._emerald.withOpacity(0.15),
            //     border: Border.all(
            //       color: _FridayCompanionWidgetState._emeraldLt.withOpacity(0.4),
            //     ),
            //     borderRadius: BorderRadius.circular(20),
            //   ),
            //   child: Text(
            //     "☪  الصلاة على النبي ﷺ",
            //     style: GoogleFonts.cairo(
            //       fontSize: 11.sp,
            //       fontWeight: FontWeight.bold,
            //       color: isDark ? _FridayCompanionWidgetState._emeraldLt
            //           : _FridayCompanionWidgetState._emerald,
            //     ),
            //   ),
            // ),
            Row(
              children: [
                Container(
                  width: 4, height: 22,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    gradient: const LinearGradient(
                      colors: [_FridayCompanionWidgetState._gold, _FridayCompanionWidgetState._goldDark],
                      begin: Alignment.topCenter,
                      end:   Alignment.bottomCenter,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  "الصلاة على النبي ﷺ",
                  style: GoogleFonts.amiri(
                    fontSize: 17.sp, fontWeight: FontWeight.bold,
                    color: isDark ? _FridayCompanionWidgetState._goldLight
                        : _FridayCompanionWidgetState._goldDark,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Brackets + verse
            // Text("﴾",
            //   style: TextStyle(
            //     fontFamily: 'Amiri', fontSize: 28,
            //     color: _FridayCompanionWidgetState._gold.withOpacity(0.65),
            //   ),
            // ),
            // const SizedBox(height: 6),
            Text(
              _verse,
              textAlign: TextAlign.center,
              style: GoogleFonts.amiri(
                fontSize: 18.sp,
                height: 1.95,
                fontWeight: FontWeight.bold,
                color: isDark ? const Color(0xFFF0EAD6) : const Color(0xFF0F2B1C),
              ),
            ),
            // const SizedBox(height: 6),
            // Text("﴿",
            //   style: TextStyle(
            //     fontFamily: 'Amiri', fontSize: 28,
            //     color: _FridayCompanionWidgetState._gold.withOpacity(0.65),
            //   ),
            // ),

            const SizedBox(height: 10),

            // Share button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _sharePressed(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _FridayCompanionWidgetState._emeraldMid,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  shadowColor: _FridayCompanionWidgetState._emerald.withOpacity(0.4),
                ),
                icon: const Icon(Icons.share_outlined, size: 17),
                label: Text(
                  "شارك كصورة",
                  style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 12.sp),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _sharePressed(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const PremiumShareCard(
        text: _verse,
        azkarName: "الصلاة على النبي ﷺ",
      ),
    );
  }
}

// ─── Sunnahs ─────────────────────────────────────────────
class _SunnahsSection extends StatelessWidget {
  final bool isDark;
  final List<Map<String,dynamic>> sunnahs;
  final bool allDone;
  final void Function(int) onToggle;
  final VoidCallback onKahf;

  const _SunnahsSection({
    required this.isDark,
    required this.sunnahs,
    required this.allDone,
    required this.onToggle,
    required this.onKahf,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Row(
            children: [
              Container(
                width: 4, height: 22,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  gradient: const LinearGradient(
                    colors: [_FridayCompanionWidgetState._gold, _FridayCompanionWidgetState._goldDark],
                    begin: Alignment.topCenter,
                    end:   Alignment.bottomCenter,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                "سنن الجمعة",
                style: GoogleFonts.amiri(
                  fontSize: 17.sp, fontWeight: FontWeight.bold,
                  color: isDark ? _FridayCompanionWidgetState._goldLight
                      : _FridayCompanionWidgetState._goldDark,
                ),
              ),
            ],
          ),

          // All-done banner
          if (allDone) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  _FridayCompanionWidgetState._emerald.withOpacity(0.2),
                  _FridayCompanionWidgetState._emeraldLt.withOpacity(0.1),
                ]),
                border: Border.all(
                  color: _FridayCompanionWidgetState._emeraldLt.withOpacity(0.35),
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("🌟", style: TextStyle(fontSize: 15.sp)),
                  const SizedBox(width: 8),
                  Text(
                    "أتممت سنن الجمعة — بارك الله فيك",
                    style: GoogleFonts.cairo(
                      fontSize: 12.sp, fontWeight: FontWeight.bold,
                      color: isDark ? _FridayCompanionWidgetState._emeraldLt
                          : _FridayCompanionWidgetState._emerald,
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 14),

          // Chips
          Wrap(
            spacing: 8, runSpacing: 10,
            children: List.generate(sunnahs.length, (i) => _SunnahChip(
              sunnah: sunnahs[i],
              isDark: isDark,
              onTap:  () => onToggle(i),
            )),
          ),

          const SizedBox(height: 18),

          // Divider
          Divider(color: _FridayCompanionWidgetState._gold.withOpacity(0.2), thickness: 1),
          // const SizedBox(height: 14),

          // Kahf button
          // SizedBox(
          //   width: double.infinity,
          //   child: DecoratedBox(
          //     decoration: BoxDecoration(
          //       gradient: const LinearGradient(
          //         colors: [_FridayCompanionWidgetState._gold, _FridayCompanionWidgetState._goldDark],
          //         begin: Alignment.topLeft,
          //         end:   Alignment.bottomRight,
          //       ),
          //       borderRadius: BorderRadius.circular(14),
          //       boxShadow: [BoxShadow(
          //         color: _FridayCompanionWidgetState._gold.withOpacity(0.35),
          //         blurRadius: 14, offset: const Offset(0, 5),
          //       )],
          //     ),
          //     child: ElevatedButton(
          //       onPressed: onKahf,
          //       style: ElevatedButton.styleFrom(
          //         backgroundColor: Colors.transparent,
          //         shadowColor: Colors.transparent,
          //         foregroundColor: Colors.white,
          //         padding: const EdgeInsets.symmetric(vertical: 9),
          //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          //       ),
          //       child: Row(
          //         mainAxisAlignment: MainAxisAlignment.center,
          //         children: [
          //           // Text("📖", style: TextStyle(fontSize: 17.sp)),
          //           // const SizedBox(width: 8),
          //           Text(
          //             "اقرأ سورة الكهف الآن",
          //             style: GoogleFonts.cairo(
          //               fontWeight: FontWeight.bold, fontSize: 12.sp,
          //             ),
          //           ),
          //         ],
          //       ),
          //     ),
          //   ),
          // ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => onKahf,
              style: ElevatedButton.styleFrom(
                backgroundColor: _FridayCompanionWidgetState._emeraldMid,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 9),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                shadowColor: _FridayCompanionWidgetState._emerald.withOpacity(0.4),
              ),
              icon: const Icon(Icons.chrome_reader_mode, size: 17),
              label: Text(
                            "اقرأ سورة الكهف الآن",
                style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 12.sp),
              ),
            ),
          ),

        ],
      ),
    );
  }
}

// ─── Sunnah Chip ─────────────────────────────────────────
class _SunnahChip extends StatelessWidget {
  final Map<String,dynamic> sunnah;
  final bool isDark;
  final VoidCallback onTap;

  const _SunnahChip({
    required this.sunnah,
    required this.isDark,
    required this.onTap,
  });

  bool get _isDone => sunnah['done'] == true;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          gradient: _isDone
              ? const LinearGradient(
            colors: [_FridayCompanionWidgetState._emerald, _FridayCompanionWidgetState._emeraldLt],
            begin: Alignment.topLeft,
            end:   Alignment.bottomRight,
          )
              : null,
          color: _isDone ? null
              : (isDark ? Colors.white10 : const Color(0xFFF5F0E4)),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: _isDone
                ? Colors.transparent
                : _FridayCompanionWidgetState._gold.withOpacity(0.25),
          ),
          boxShadow: _isDone
              ? [BoxShadow(
            color: _FridayCompanionWidgetState._emerald.withOpacity(0.35),
            blurRadius: 8, offset: const Offset(0, 3),
          )]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(sunnah['emoji'], style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 5),
            Text(
              sunnah['title'],
              style: GoogleFonts.cairo(
                fontSize: 11.sp,
                fontWeight: _isDone ? FontWeight.bold : FontWeight.w500,
                color: _isDone
                    ? Colors.white
                    : (isDark ? Colors.white70 : const Color(0xFF4A3728)),
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              child: _isDone
                  ? const Padding(
                padding: EdgeInsets.only(right: 5),
                child: Icon(Icons.check_circle, color: Colors.white, size: 14),
              )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Divider helper ──────────────────────────────────────
class _Divider extends StatelessWidget {
  const _Divider();
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          Colors.transparent,
          _FridayCompanionWidgetState._gold.withOpacity(0.2),
          Colors.transparent,
        ]),
      ),
    );
  }
}