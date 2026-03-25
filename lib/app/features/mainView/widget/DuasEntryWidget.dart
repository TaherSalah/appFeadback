import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../duas/DuasMainScreen.dart';
import '../../duas/data/duas_data.dart';
import 'dart:math';

class DuasEntryWidget extends StatelessWidget {
  const DuasEntryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // دعاء اليوم (عشوائي)
    final randomDua = DuasData.allDuas[Random().nextInt(DuasData.allDuas.length)];

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const DuasMainScreen()),
        );
      },
      borderRadius: BorderRadius.circular(20.r),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6366F1).withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text('🤲', style: TextStyle(fontSize: 32.sp)),
                    SizedBox(width: 12.w),
                    Text(
                      'دعاء اليوم',
                      style: TextStyle(
                  fontFamily: "cairo",
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16.sp),
              ],
            ),
            SizedBox(height: 16.h),
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    randomDua.title,
                    style: TextStyle(
                  fontFamily: "cairo",
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    randomDua.arabic,
                    style: TextStyle(
                  fontFamily: "cairo",
                      fontSize: 13.sp,
                      color: Colors.white.withOpacity(0.95),
                      height: 1.8,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
