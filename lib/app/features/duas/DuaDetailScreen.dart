import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/shard/widgets/ui_animations.dart';
import 'models/dua_models.dart';
import 'services/dua_service.dart';

class DuaDetailScreen extends StatefulWidget {
  final Dua dua;

  const DuaDetailScreen({super.key, required this.dua});

  @override
  State<DuaDetailScreen> createState() => _DuaDetailScreenState();
}

class _DuaDetailScreenState extends State<DuaDetailScreen> {
  final DuaService _service = DuaService();
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _service.init();
    setState(() => _isFavorite = _service.isFavorite(widget.dua.id));
  }

  @override
  Widget build(BuildContext context) {

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _getGradientColors(widget.dua.category),
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // AppBar
                Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Row(
                    children: [
                      IconButton(
                        icon:
                            const Icon(Icons.arrow_back_ios, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Spacer(),
                      Text(
                        widget.dua.category.arabicName,
                           style: TextStyle(
                          fontFamily: "cairo",
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const Spacer(),
                      SizedBox(width: 40.w),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(24.w),
                    child: Column(
                      children: [
                        StaggeredItemAnimation(
                          index: 0,
                          child: Text(
                            widget.dua.category.emoji,
                            style: TextStyle(fontSize: 60.sp),
                          ),
                        ),
                        SizedBox(height: 20.h),
                        StaggeredItemAnimation(
                          index: 1,
                          child: Text(
                            widget.dua.title,
                               style: TextStyle(
                          fontFamily: "cairo",
                              fontSize: 24.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(height: 32.h),
                        StaggeredItemAnimation(
                          index: 2,
                          child: Container(
                            padding: EdgeInsets.all(24.w),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: Text(
                              widget.dua.arabic,
                                 style: TextStyle(
                          fontFamily: "cairo",
                                fontSize: 22.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                height: 2.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        SizedBox(height: 24.h),
                        StaggeredItemAnimation(
                          index: 3,
                          child: Container(
                            padding: EdgeInsets.all(20.w),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.translate,
                                        color: Colors.white.withOpacity(0.9),
                                        size: 20.sp),
                                    SizedBox(width: 8.w),
                                    Text(
                                      'المعنى',
                                         style: TextStyle(
                          fontFamily: "cairo",
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white.withOpacity(0.9),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 12.h),
                                Text(
                                  widget.dua.meaning,
                                     style: TextStyle(
                          fontFamily: "cairo",
                                    fontSize: 15.sp,
                                    color: Colors.white.withOpacity(0.95),
                                    height: 1.8,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (widget.dua.source != null) ...[
                          SizedBox(height: 16.h),
                          StaggeredItemAnimation(
                            index: 4,
                            child: Container(
                              padding: EdgeInsets.all(16.w),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.menu_book,
                                      color: Colors.white.withOpacity(0.9),
                                      size: 18.sp),
                                  SizedBox(width: 8.w),
                                  Text(
                                    widget.dua.source!,
                                       style: TextStyle(
                          fontFamily: "cairo",
                                      fontSize: 13.sp,
                                      color: Colors.white.withOpacity(0.9),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                        SizedBox(height: 32.h),
                        StaggeredItemAnimation(
                          index: 5,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildActionButton(
                                Icons.copy,
                                'نسخ',
                                () {
                                  Clipboard.setData(
                                      ClipboardData(text: widget.dua.arabic));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('تم النسخ',
                                             style: TextStyle(
                          fontFamily: "cairo",)),
                                    ),
                                  );
                                },
                              ),
                              _buildActionButton(
                                _isFavorite ? Icons.favorite : Icons.favorite_border,
                                _isFavorite ? 'مفضل' : 'إضافة',
                                () async {
                                  await _service.toggleFavorite(widget.dua.id);
                                  setState(() => _isFavorite = !_isFavorite);
                                },
                              ),
                              _buildActionButton(
                                Icons.share,
                                'مشاركة',
                                () {
                                  Share.share(
                                      '${widget.dua.title}\n\n${widget.dua.arabic}\n\n${widget.dua.meaning}${widget.dua.source != null ? '\n\n${widget.dua.source}' : ''}');
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 24.sp),
            SizedBox(height: 4.h),
            Text(
              label,
                 style: TextStyle(
                          fontFamily: "cairo",
                fontSize: 12.sp,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Color> _getGradientColors(DuaCategory category) {
    switch (category) {
      case DuaCategory.travel:
        return [const Color(0xFF3B82F6), const Color(0xFF2563EB)];
      case DuaCategory.study:
        return [const Color(0xFF8B5CF6), const Color(0xFF7C3AED)];
      case DuaCategory.health:
        return [const Color(0xFF10B981), const Color(0xFF059669)];
      case DuaCategory.anxiety:
        return [const Color(0xFF06B6D4), const Color(0xFF0891B2)];
      case DuaCategory.morning:
        return [const Color(0xFFF59E0B), const Color(0xFFD97706)];
      case DuaCategory.evening:
        return [const Color(0xFF6366F1), const Color(0xFF4F46E5)];
      case DuaCategory.sleep:
        return [const Color(0xFF4338CA), const Color(0xFF3730A3)];
      case DuaCategory.prophet:
        return [const Color(0xFF10B981), const Color(0xFF059669)];
      case DuaCategory.quran:
        return [const Color(0xFF8B5CF6), const Color(0xFF7C3AED)];
      default:
        return [const Color(0xFF6366F1), const Color(0xFF4F46E5)];
    }
  }
}
