import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:muslimdaily/app/core/extensions/context_extension.dart';
import '../../Khatmah/data/khatmah_model.dart';
import '../../Khatmah/view/KhatmahDashboard.dart';
import '../../WirdView/TasbihScreen.dart';
import '../../WirdView/data/Wird.dart';
import '../../WirdView/data/WirdManager.dart';
import 'package:quran_library/quran_library.dart' hide SurahModel;
import '../../quran/view/widget/QuranViewItemBuilder.dart';
import '../../quran/view/SurahDetailScreen.dart';
import '../../quran/SurahModel.dart';
import 'dart:convert'; // For jsonDecode
import 'package:animate_do/animate_do.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:gap/gap.dart';
import 'package:carousel_slider/carousel_slider.dart';

class LastActivityWidget extends StatefulWidget {
  const LastActivityWidget({super.key});

  @override
  State<LastActivityWidget> createState() => _LastActivityWidgetState();
}

class _LastActivityWidgetState extends State<LastActivityWidget> {
  // Quran Data
  int? _bookmarkVerseId;
  String? _bookmarkVerseName;
  String? _bookmarkedSurahJson; // To load full surah if needed

  // Last Read Quran Data
  int? _lastReadPage;
  String? _lastReadSurahName;
  String? _lastReadFirstAyah;

  // Wird Data
  Wird? _lastWird;

  // Khatmah Data
  KhatmahModel? _activeKhatmah;
  int _currentIndex = 0;

  late final Box<KhatmahModel> _khatmahBox;

  @override
  void initState() {
    super.initState();
    _khatmahBox = Hive.box<KhatmahModel>('khatmahBox');
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();

    // 1. Load Quran Bookmark
    setState(() {
      _bookmarkVerseId = prefs.getInt('bookmark_verseId');
      _bookmarkVerseName = prefs.getString('bookmark_verseName');
      _bookmarkedSurahJson = prefs.getString('bookmarked_surah');
    });

    // 1.1 Load Last Read Quran Page
    final lastPage = prefs.getInt('last_page');
    if (lastPage != null) {
      try {
        final ql = QuranLibrary();
        List<AyahModel> ayahs =
            ql.getPageAyahsByPageNumber(pageNumber: lastPage + 1);
        if (ayahs.isEmpty) {
          await Future.delayed(const Duration(milliseconds: 200));
          ayahs = ql.getPageAyahsByPageNumber(pageNumber: lastPage + 1);
        }
        if (ayahs.isNotEmpty) {
          setState(() {
            _lastReadPage = lastPage + 1;
            _lastReadSurahName = ayahs.first.arabicName.toString();
            _lastReadFirstAyah = ayahs.first.ayaTextEmlaey;
          });
        }
      } catch (e) {
        debugPrint("ERROR loading last read page: $e");
      }
    }

    // 2. Load Last Wird
    final lastWirdId = prefs.getString('last_opened_wird_id');
    if (lastWirdId != null) {
      final manager = WirdManager();
      final allAwrad = await manager.loadAwrad();
      try {
        final wird = allAwrad.firstWhere((w) => w.id == lastWirdId);
        setState(() {
          _lastWird = wird;
        });
      } catch (e) {}
    }

    // 3. Load Active Khatmah
    if (_khatmahBox.isNotEmpty) {
      try {
        final activeKhatmah = _khatmahBox.values.firstWhere(
          (k) => !k.isCompleted,
          orElse: () => _khatmahBox.values.first,
        );
        setState(() {
          _activeKhatmah = activeKhatmah;
        });
      } catch (e) {
        debugPrint('Error loading khatma: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    bool isTab = context.isTablet;

    if (_bookmarkVerseId == null &&
        _lastReadPage == null &&
        _lastWird == null &&
        _activeKhatmah == null) {
      return const SizedBox.shrink();
    }

    final List<Widget> cards = [
      if (_lastReadPage != null && _lastReadSurahName != null)
        _buildCard(
          context,
          title: "آخر قراءة",
          subtitle: _lastReadFirstAyah != null
              ? "﴿ $_lastReadFirstAyah ﴾"
              : "تابع من صفحة $_lastReadPage",
          detail: "$_lastReadSurahName",
          icon: Icons.menu_book_rounded,
          color: Colors.green,
          isDark: isDark,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    QuranViewItemBuilder(initialPage: _lastReadPage! - 1),
              ),
            ).then((_) => _loadData());
          },
        ),
      if (_bookmarkVerseId != null && _bookmarkVerseName != null)
        _buildCard(
          context,
          title: "علامة حفظ",
          subtitle: "انتقل إلى الآية",
          detail: _bookmarkVerseName!,
          icon: Icons.bookmark,
          color: Colors.orange,
          isDark: isDark,
          onTap: () async {
            if (_bookmarkedSurahJson != null) {
              try {
                final surah =
                    SurahModel.fromJson(jsonDecode(_bookmarkedSurahJson!));
                final prefs = await SharedPreferences.getInstance();
                final List<String>? jsonList =
                    prefs.getStringList('saved_surahs');
                List<SurahModel> allSurahs = [];
                if (jsonList != null) {
                  allSurahs = jsonList
                      .map((j) => SurahModel.fromJson(jsonDecode(j)))
                      .toList();
                }
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SurahDetailScreen(
                      surah: surah,
                      allSurahs: allSurahs,
                      verseId: _bookmarkVerseId!,
                      isDark: isDark,
                    ),
                  ),
                ).then((_) => _loadData());
              } catch (e) {}
            }
          },
        ),
      if (_lastWird != null)
        _buildCard(
          context,
          title: "الأوراد",
          subtitle: _lastWird!.isCompleted ? "تم إكمال الورد" : "أكمل وردك",
          detail: _lastWird!.name,
          icon: _lastWird!.isCompleted
              ? Icons.check_circle
              : Icons.access_time_filled,
          color: Colors.teal,
          isDark: isDark,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    TasbihScreen(wird: _lastWird!),
              ),
            ).then((_) => _loadData());
          },
        ),
      if (_activeKhatmah != null)
        _buildCard(
          context,
          title: "الختمة",
          subtitle: "تقدمك الحالي",
          detail: "${_activeKhatmah!.title}",
          extra: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 4,
            children: [
              Row(
                children: [
                  Expanded(
                    child: LinearPercentIndicator(
                      padding: EdgeInsets.zero,
                      lineHeight: 6.h,
                      percent: _activeKhatmah!.progressPercent,
                      backgroundColor: Colors.purple.withOpacity(0.1),
                      progressColor: Colors.purple.shade400,
                      barRadius: Radius.circular(10.r),
                      isRTL: true,
                    ),
                  ),
                  Gap(8.w),
                  Text(
                    "${(_activeKhatmah!.progressPercent * 100).toInt()}%",
                    style: GoogleFonts.cairo(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple.shade400,
                    ),
                  ),
                ],
              ),
              const Gap(2),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _activeKhatmah!.isBehind
                        ? "متأخر بـ ${_activeKhatmah!.daysBehind} يوم"
                        : "اليوم ${_activeKhatmah!.currentDay}",
                    style: GoogleFonts.cairo(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.bold,
                      color: _activeKhatmah!.isBehind
                          ? Colors.redAccent
                          : Colors.green,
                    ),
                  ),
                  Text(
                    _activeKhatmah!.isBehind
                        ? "أنت متأخر"
                        : _activeKhatmah!.daysAhead > 0
                            ? "متقدم بـ ${_activeKhatmah!.daysAhead} يوم"
                            : "في الموعد",
                    style: GoogleFonts.cairo(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.bold,
                      color: _activeKhatmah!.isBehind
                          ? Colors.redAccent
                          : Colors.green,
                    ),
                  ),
                ],
              ),
            ],
          ),
          icon: Icons.pie_chart,
          color: Colors.purple.shade400,
          isDark: isDark,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const KhatmahDashboard()),
            ).then((_) => _loadData());
          },
        ),
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        children: [
          CarouselSlider(
            items: cards,
            options: CarouselOptions(
              height: isTab ? 180.h : 155.h,
              viewportFraction: isTab ? 0.9 : 0.88,
              enlargeCenterPage: true,
              enlargeStrategy: CenterPageEnlargeStrategy.zoom,
              enlargeFactor: 0.25,
              enableInfiniteScroll: cards.length > 1,
              autoPlay: false,
              padEnds: true,
              onPageChanged: (index, reason) {
                setState(() {
                  _currentIndex = index;
                });
              },
            ),
          ),
          if (cards.length > 1) ...[
            Gap(12.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: cards.asMap().entries.map((entry) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: _currentIndex == entry.key ? 20.w : 6.w,
                  height: 6.w,
                  margin: EdgeInsets.symmetric(horizontal: 3.w),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: _currentIndex == entry.key
                        ? Theme.of(context).primaryColor
                        : Theme.of(context).primaryColor.withOpacity(0.2),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String detail,
    required IconData icon,
    required Color color,
    required bool isDark,
    required VoidCallback onTap,
    Widget? extra,
  }) {
    return FadeInRight(
      duration: const Duration(milliseconds: 600),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 8.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.r),
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: isDark
                ? [color.withOpacity(0.15), color.withOpacity(0.05)]
                : [Colors.white, color.withOpacity(0.08)],
          ),
          border: Border.all(
              color: isDark ? color.withOpacity(0.2) : color.withOpacity(0.15),
              width: 1.2),
          boxShadow: [
            BoxShadow(
                color: color.withOpacity(0.1),
                blurRadius: 15,
                offset: const Offset(0, 5))
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20.r),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Row(
                  children: [
                    Container(

                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: isDark
                            ? color.withOpacity(0.2)
                            : color.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon,
                          color: isDark ? color : color.withOpacity(0.8),
                          size: 28.sp),
                    ),
                    const Gap(16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min, // ✅ أضف هذا
                        children: [
                          Text(
                            title,
                            style: GoogleFonts.cairo(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black87),
                            maxLines: 1,                    // ✅ أضف هذا
                            overflow: TextOverflow.ellipsis, // ✅ أضف هذا
                          ),
                          const Gap(2),
                          if (extra != null)
                            extra
                          else
                            Text(
                              detail,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: "me",
                                fontSize: 13.sp,
                                  color: isDark ? Colors.white70 : Colors.black54
                              ),
                              // style: GoogleFonts.cairo(
                              //     fontSize: 13.sp,
                              //     color: isDark ? Colors.white70 : Colors.black54),
                            ),
                          if (extra == null) ...[
                            const Gap(2),
                            Text(
                              subtitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontFamily: "me",
                                  fontSize: 13.sp,
                                  color: color,
                                  fontWeight: FontWeight.bold
                              ),

                              // style: GoogleFonts.cairo(
                              //     fontSize: 11.sp,
                              //     color: color,
                              //     fontWeight: FontWeight.bold),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios_rounded,
                        size: 16.sp,
                        color: isDark ? Colors.white38 : Colors.black26),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
