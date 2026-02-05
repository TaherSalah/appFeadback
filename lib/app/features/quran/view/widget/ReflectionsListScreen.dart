import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quran_library/quran_library.dart';
import 'package:muslimdaily/app/core/shard/exports/all_exports.dart';
import 'package:muslimdaily/app/features/quran/data/reflections_service.dart';

class ReflectionsListScreen extends StatefulWidget {
  const ReflectionsListScreen({super.key});

  @override
  State<ReflectionsListScreen> createState() => _ReflectionsListScreenState();
}

class _ReflectionsListScreenState extends State<ReflectionsListScreen> {
  final ReflectionsService _reflectionsService = ReflectionsService();
  bool _isLoading = true;
  Map<int, String> _reflections = {};

  @override
  void initState() {
    super.initState();
    _loadReflections();
  }

  Future<void> _loadReflections() async {
    final reflections = await _reflectionsService.getAllReflections();
    if (mounted) {
      setState(() {
        _reflections = reflections;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "قائمة الخواطر",
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _reflections.isEmpty
                ? _buildEmptyState(isDark)
                : _buildReflectionsList(isDark),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.note_alt_outlined,
            size: 80.sp,
            color: isDark ? Colors.white24 : Colors.grey[300],
          ),
          SizedBox(height: 16.h),
          Text(
            "لا توجد خواطر مسجلة بعد",
            style: GoogleFonts.cairo(
              fontSize: 16.sp,
              color: isDark ? Colors.white70 : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReflectionsList(bool isDark) {
    final sortedPages = _reflections.keys.toList()..sort();

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      itemCount: sortedPages.length,
      itemBuilder: (context, index) {
        final pageIndex = sortedPages[index];
        final content = _reflections[pageIndex]!;
        final pageNumber = pageIndex + 1;
        
        // Use QuranLibrary to get surah name if possible, or just show page number
        String surahName = "";
        try {
           // We might need to find which surah this page belongs to
           // This is a simplified approach, usually quran packages provide this
           surahName = "صفحة $pageNumber"; 
        } catch (e) {
           surahName = "صفحة $pageNumber";
        }

        return Card(
          elevation: 2,
          margin: EdgeInsets.only(bottom: 12.h),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          color: isDark ? const Color(0xFF1B263B) : Colors.white,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              // Navigate back to Quran page
              Navigator.pushNamed(
                context,
                "/surahListScreen",
                arguments: pageIndex,
              );
            },
            child: Padding(
              padding: EdgeInsets.all(16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: Colors.teal.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          surahName,
                          style: GoogleFonts.cairo(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal,
                          ),
                        ),
                      ),
                      Text(
                        "صفحة ${pageIndex + 1}",
                        style: GoogleFonts.cairo(
                          fontSize: 12.sp,
                          color: isDark ? Colors.white54 : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    content,
                    style: GoogleFonts.cairo(
                      fontSize: 14.sp,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
