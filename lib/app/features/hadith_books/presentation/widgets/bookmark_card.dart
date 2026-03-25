import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:muslimdaily/app/core/extensions/context_extension.dart';

import '../../../../core/utils/style/k_color.dart';
import '../../controllers/books_controller.dart';
import '../../controllers/extensions/books_getters_extension.dart';
import '../../data/models/bookmark_model.dart';

class BookmarkCard extends StatelessWidget {
  final BookmarkModel bookmark;
  final VoidCallback onDelete;
  final Function(String) onCategoryChange;

  const BookmarkCard({
    super.key,
    required this.bookmark,
    required this.onDelete,
    required this.onCategoryChange,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final baseColor = KColors.primaryColor;
    final hadith = bookmark.hadith.target;

    if (hadith == null) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: isDark
              ? [
                  const Color(0xFF0F172A),
                  const Color(0xFF1E293B),
                ]
              : [
                  Colors.white,
                  const Color(0xFFF8F9FA),
                ],
        ),
        border: Border.all(
          color: baseColor.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: baseColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16.r),
          onTap: () {
            // Navigate to the hadith detail
             BooksController.instance.navigateToHadith(hadith);
          },
          child: Padding(
            padding: EdgeInsets.all(14.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Category & Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Category Badge
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: baseColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        bookmark.category,
                        style: TextStyle(
                  fontFamily: "cairo",
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          color: baseColor,
                        ),
                      ),
                    ),
                    
                    // Actions
                    Row(
                      children: [
                        // Change Category
                        IconButton(
                          icon: Icon(
                            Icons.label_outline,
                            size: 20.sp,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                          onPressed: () => _showCategoryDialog(context),
                        ),
                        // Delete
                        IconButton(
                          icon: Icon(
                            Icons.delete_outline,
                            size: 20.sp,
                            color: Colors.red[400],
                          ),
                          onPressed: () => _showDeleteHadithDialog(context, onDelete),
                        ),
                      ],
                    ),
                  ],
                ),

                SizedBox(height: 12.h),

                // Hadith Text (preview)
                Text(
                  hadith.hadithText.length > 150
                      ? '${hadith.hadithText.substring(0, 150)}...'
                      : hadith.hadithText,
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'naskh',
                    height: 1.7,
                    fontSize: 16.sp,
                    color: isDark ? Colors.grey[200] : Colors.grey[900],
                    fontWeight: FontWeight.w500,
                  ),
                ),

                SizedBox(height: 12.h),

                // Footer: Book Name & Date
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Book Name
                    Expanded(
                      child: Row(
                        children: [
                          Icon(
                            Icons.menu_book,
                            size: 14.sp,
                            color: isDark ? Colors.grey[500] : Colors.grey[600],
                          ),
                          SizedBox(width: 6.w),
                          Expanded(
                            child: Text(
                              hadith.bookName,
                              style: TextStyle(
                  fontFamily: "cairo",
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.grey[500] : Colors.grey[600],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Saved Date
                    Text(
                      _formatDate(bookmark.createdAt),
                      style: TextStyle(
                  fontFamily: "cairo",
                        fontSize: 11.sp,
                        color: isDark ? Colors.grey[600] : Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'اليوم';
    } else if (difference.inDays == 1) {
      return 'أمس';
    } else if (difference.inDays < 7) {
      return 'منذ ${difference.inDays} أيام';
    } else if (difference.inDays < 30) {
      return 'منذ ${(difference.inDays / 7).floor()} أسابيع';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _showCategoryDialog(BuildContext context) {
    final isDark = context.isDark;
    final baseColor = KColors.primaryColor;
    
    final categories = [
      'أخلاق',
      'عبادات',
      'فضائل',
      'أحكام',
      'سيرة نبوية',
      'دعاء',
      'عام',
    ];

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        child: Container(
          padding: EdgeInsets.all(20.r),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0F172A) : Colors.white,
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'تغيير التصنيف',
                style: TextStyle(
                  fontFamily: "cairo",
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              SizedBox(height: 20.h),
              ...categories.where((cat) => cat != bookmark.category).map((category) {
                return InkWell(
                  onTap: () {
                    Navigator.pop(context);
                    onCategoryChange(category);
                  },
                  child: Container(
                    width: double.infinity,
                    margin: EdgeInsets.only(bottom: 10.h),
                    padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
                    decoration: BoxDecoration(
                      color: baseColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: baseColor.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      category,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                  fontFamily: "cairo",
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteHadithDialog(BuildContext context, VoidCallback onDelete) {
    final bool isDark = context.isDark;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding:
          const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // جسم الديالوج
              Container(
                padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: isDark
                        ? [const Color(0xFF2B0B0B), const Color(0xFF200505)]
                        : [const Color(0xFFFFF2F2), const Color(0xFFFFE1E1)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // العنوان
                    Text(
                      'حذف الحديث؟',
                      style: TextStyle(
                  fontFamily: "cairo",
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // النص
                    Text(
                      'هل أنت متأكد من حذف هذا الحديث من المحفوظات؟\n'
                          'لا يمكن التراجع عن هذا الإجراء بعد الحذف.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                  fontFamily: "cairo",
                        fontSize: 14,
                        height: 1.4,
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // كارت تحذيري
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.red.withOpacity(0.06),
                        border: Border.all(
                          color: Colors.red.withOpacity(0.5),
                          width: 1.2,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.info_outline,
                            size: 18,
                            color: Colors.red,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'سيتم حذف الحديث نهائيًا من قائمتك.',
                              style: TextStyle(
                  fontFamily: "cairo",
                                fontSize: 12.5,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // الأزرار
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.of(dialogContext).pop();
                            },
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: isDark
                                    ? Colors.grey.shade400
                                    : Colors.grey.shade600,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              padding:
                              const EdgeInsets.symmetric(vertical: 11),
                            ),
                            child: Text(
                              'إلغاء',
                              style: TextStyle(
                  fontFamily: "cairo",
                                fontSize: 14,
                                color: isDark
                                    ? Colors.white
                                    : Colors.grey.shade800,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.of(dialogContext).pop();
                              onDelete();
                            },
                            icon: const Icon(Icons.delete_outline),
                            label: Text(
                              'حذف',
                              style: TextStyle(
                  fontFamily: "cairo",),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              padding:
                              const EdgeInsets.symmetric(vertical: 11),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // أيقونة الحذف العلوية
              Positioned(
                top: -30,
                left: 0,
                right: 0,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Colors.red, Colors.deepOrange],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.6),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.delete_forever_rounded,
                        size: 34,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}
