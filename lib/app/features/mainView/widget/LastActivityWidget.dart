import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/utils/style/responsive_util.dart';
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

  // Wird Data
  Wird? _lastWird;

  // Khatmah Data
  KhatmahModel? _activeKhatmah;

  late final Box<KhatmahModel> _khatmahBox;

  @override
  void initState() {
    super.initState();
    _khatmahBox = Hive.box<KhatmahModel>('khatmahBox');
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();

    // 1. Load Quran Bookmark
    setState(() {
      _bookmarkVerseId = prefs.getInt('bookmark_verseId');
      _bookmarkVerseName = prefs.getString('bookmark_verseName');
      _bookmarkedSurahJson = prefs.getString('bookmarked_surah');
    });

    // 1.1 Load Last Read Quran Page
    final lastPage = prefs.getInt('last_page');
    print("DEBUG: last_page from prefs: $lastPage");
    
    // Log all keys starting with last_page to help identify campaign-specific progress
    final allKeys = prefs.getKeys();
    for (var key in allKeys) {
      if (key.startsWith('last_page')) {
        print("DEBUG: Storage Key found: $key = ${prefs.get(key)}");
      }
    }

    if (lastPage != null) {
      try {
        final ql = QuranLibrary();
        
        // Give a tiny delay for library assets buffer if needed (sometimes helps on cold start)
        List<AyahModel> ayahs = ql.getPageAyahsByPageNumber(pageNumber: lastPage + 1);
        
        if (ayahs.isEmpty) {
          // Retry once after 200ms if empty
          await Future.delayed(const Duration(milliseconds: 200));
          ayahs = ql.getPageAyahsByPageNumber(pageNumber: lastPage + 1);
        }

        print("DEBUG: ayahs found for page ${lastPage + 1}: ${ayahs.length}");
        if (ayahs.isNotEmpty) {
          setState(() {
            _lastReadPage = lastPage + 1;
            // Use .toString() as safely as possible
            _lastReadSurahName = ayahs.first.arabicName.toString();
          });
        }
      } catch (e) {
        print("DEBUG: ERROR loading last read page: $e");
      }
    }

    // 2. Load Last Wird
    final lastWirdId = prefs.getString('last_opened_wird_id');
    if (lastWirdId != null) {
      final manager = WirdManager();
      final allAwrad = await manager.loadAwrad();
      try {
        final wird = allAwrad.firstWhere((w) => w.id == lastWirdId);
        // Only show if available
        setState(() {
          _lastWird = wird;
        });
      } catch (e) {
        // Wird might have been deleted
      }
    }

    // 3. Load Active Khatmah
    if (_khatmahBox.isNotEmpty) {
      try {
        // Try to find the first uncompleted khatma
        final activeKhatmah = _khatmahBox.values.firstWhere(
          (k) => !k.isCompleted,
          orElse: () => _khatmahBox.values
              .first, // Fallback to the first khatma if all are completed
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
    bool isTab = ResponsiveUtil.isTablet(context);

    // If no data at all, return empty
    if (_bookmarkVerseId == null &&
        _lastReadPage == null &&
        _lastWird == null &&
        _activeKhatmah == null) {
      return const SizedBox.shrink();
    }

    return SizedBox(

      height: isTab ? 170.h : 150.h, // Adaptive height
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        children: [
          if (_lastReadPage != null && _lastReadSurahName != null)
            _buildCard(
              context,
              title: "آخر قراءة",
              subtitle: "تابع من صفحة $_lastReadPage",
              detail: "سورة $_lastReadSurahName",
              icon: Icons.menu_book_rounded,
              color: Colors.green,
              isDark: isDark,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => QuranViewItemBuilder(
                      initialPage: _lastReadPage! - 1, // 0-indexed for the builder
                    ),
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
              color: Colors.brown.shade400,
              isDark: isDark,
              onTap: () async {
                if (_bookmarkedSurahJson != null) {
                  try {
                    final surah = SurahModel.fromJson(
                        jsonDecode(_bookmarkedSurahJson!));
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
                                ))).then((_) => _loadData());
                  } catch (e) {
                    print("Error parsing saved surah: $e");
                  }
                }
              },
            ),
          if (_lastWird != null)
            _buildCard(
              context,
              title: "الأوراد",
              subtitle:
                  _lastWird!.isCompleted ? "تم إكمال الورد" : "أكمل وردك",
              detail: _lastWird!.name,
              icon: _lastWird!.isCompleted
                  ? Icons.check_circle
                  : Icons.access_time_filled,
              color: _lastWird!.isCompleted ? Colors.green : Colors.teal,
              isDark: isDark,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TasbihScreen(
                      wird: _lastWird!,
                      isDark: isDark,
                    ),
                  ),
                ).then((_) => _loadData());
              },
            ),
          if (_activeKhatmah != null)
            _buildCard(
              context,
              title: "الختمة",
              subtitle: "تقدمك الحالي",
              detail:
                  "${(_activeKhatmah!.progressPercent * 100).toInt()}% - الباقي ${_activeKhatmah!.daysLeft} يوم",
              icon: Icons.pie_chart,
              color: Colors.purple.shade400,
              isDark: isDark,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const KhatmahDashboard(),
                  ),
                ).then((_) => _loadData());
              },
            ),
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
  }) {
    return Container(
      width: 345.w, // Adaptive width
      margin: EdgeInsets.symmetric(horizontal: 6.w),
      child: Card(
        elevation: 4,
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        child: InkWell(
          borderRadius: BorderRadius.circular(16.r),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(12.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: color, size: 24.sp),
                    ),
                    Icon(Icons.arrow_forward_ios,
                        size: 14.sp,
                        color: isDark ? Colors.white54 : Colors.grey),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.cairo(
                        fontSize: 12.sp,
                        color: isDark ? Colors.white70 : Colors.grey.shade600,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      detail,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.cairo(
                        fontSize: 15.sp, // Slightly reduced to fit more
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: GoogleFonts.cairo(
                          fontSize: 11.sp,
                          color: color,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
