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
import '../../quran/view/SurahDetailScreen.dart'; // Assuming this exists or will utilize SurahDetailScreen directly
import '../../quran/SurahModel.dart'; // Adjust import path
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
        _lastWird == null &&
        _activeKhatmah == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
              horizontal: isTab ? 10.0 : 16.0, vertical: 8),
          child: Text(
            "متابعة القراءة والنشاط",
            style: GoogleFonts.cairo(
              fontSize: isTab ? 14.sp : 16.sp,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black38,
            ),
          ),
        ),
        SizedBox(
          height: isTab ? 170.h : 150.h, // Adaptive height
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            children: [
              if (_bookmarkVerseId != null && _bookmarkVerseName != null)
                _buildCard(
                  context,
                  title: "القرآن الكريم",
                  subtitle: "تابع من حيث توقفت",
                  detail: _bookmarkVerseName!,
                  icon: Icons.book,
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
                                    )));
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
        ),
      ],
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
      width: 210.w, // Adaptive width
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
