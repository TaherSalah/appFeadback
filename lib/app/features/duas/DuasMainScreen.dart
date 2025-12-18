import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'models/dua_models.dart';
import 'data/duas_data.dart';
import 'services/dua_service.dart';
import 'DuaDetailScreen.dart';

class DuasMainScreen extends StatefulWidget {
  const DuasMainScreen({super.key});

  @override
  State<DuasMainScreen> createState() => _DuasMainScreenState();
}

class _DuasMainScreenState extends State<DuasMainScreen> {
  final DuaService _service = DuaService();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _service.init();
  }

  List<Dua> get _filteredDuas {
    if (_searchQuery.isEmpty) return DuasData.allDuas;
    return DuasData.allDuas
        .where((d) =>
            d.title.contains(_searchQuery) || d.arabic.contains(_searchQuery))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor:
            isDark ? const Color(0xFF1A1F36) : const Color(0xFFF5F7FA),
        appBar: AppBar(
          title: Text('الأدعية 🤲',
              style: GoogleFonts.cairo(
                  fontWeight: FontWeight.bold, fontSize: 20.sp)),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
        body: Column(
          children: [
            // بحث
            Padding(
              padding: EdgeInsets.all(16.w),
              child: TextField(
                onChanged: (value) => setState(() => _searchQuery = value),
                style: GoogleFonts.cairo(),
                decoration: InputDecoration(
                  hintText: 'ابحث عن دعاء...',
                  hintStyle: GoogleFonts.cairo(color: Colors.grey),
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF2D3748) : Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.r),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            // فئات
            SizedBox(
              height: 100.h,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                itemCount: DuasData.allCategories.length,
                itemBuilder: (context, index) {
                  final category = DuasData.allCategories[index];
                  return _buildCategoryCard(category, isDark);
                },
              ),
            ),

            SizedBox(height: 16.h),

            // قائمة الأدعية
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.all(16.w),
                itemCount: _filteredDuas.length,
                itemBuilder: (context, index) =>
                    _buildDuaCard(_filteredDuas[index], isDark),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(DuaCategory category, bool isDark) {
    return InkWell(
      onTap: () {
        // TODO: Navigate to category screen
      },
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        width: 100.w,
        margin: EdgeInsets.only(left: 12.w),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
          ),
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(category.emoji, style: TextStyle(fontSize: 32.sp)),
            SizedBox(height: 8.h),
            Text(
              category.arabicName,
              style: GoogleFonts.cairo(
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDuaCard(Dua dua, bool isDark) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => DuaDetailScreen(dua: dua)),
        );
      },
      borderRadius: BorderRadius.circular(20.r),
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2D3748) : Colors.white,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(dua.category.emoji, style: TextStyle(fontSize: 24.sp)),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    dua.title,
                    style: GoogleFonts.cairo(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Text(
              dua.arabic,
              style: GoogleFonts.cairo(
                fontSize: 14.sp,
                height: 2.0,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
