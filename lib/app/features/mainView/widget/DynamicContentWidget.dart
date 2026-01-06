import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/services/content_service.dart';

class DynamicContentWidget extends StatefulWidget {
  const DynamicContentWidget({super.key});

  @override
  State<DynamicContentWidget> createState() => _DynamicContentWidgetState();
}

class _DynamicContentWidgetState extends State<DynamicContentWidget> {
  List<Map<String, dynamic>> _contentList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadContent();
  }

  Future<void> _loadContent() async {
    final content = await ContentService().getActiveContent();
    if (mounted) {
      setState(() {
        _contentList = content;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _contentList.isEmpty) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Use a page view if multiple, or just a single card if one
    // For simplicity, let's show the LATEST active item prominently
    final item = _contentList.first;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Optional Image
          if (item['image_url'] != null && item['image_url'].toString().isNotEmpty)
             ClipRRect(
               borderRadius: BorderRadius.only(
                 topLeft: Radius.circular(16.r),
                 topRight: Radius.circular(16.r),
               ),
               child: CachedNetworkImage(
                 imageUrl: item['image_url'],
                 height: 150.h,
                 fit: BoxFit.cover,
                 placeholder: (context, url) => Container(
                   height: 150.h,
                   color: isDark ? Colors.grey[800] : Colors.grey[200],
                 ),
                 errorWidget: (context, url, error) => const SizedBox.shrink(),
               ),
             ),

          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: _getTypeColor(item['type']).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        _getTypeLabel(item['type']),
                        style: GoogleFonts.cairo(
                          fontSize: 10.sp,
                          color: _getTypeColor(item['type']),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Spacer(),
                    if (item['created_at'] != null)
                      Text(
                        _formatDate(item['created_at']),
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: Colors.grey,
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 8.h),
                Text(
                  item['title'] ?? '',
                  style: GoogleFonts.cairo(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  item['body'] ?? '',
                  style: GoogleFonts.cairo(
                    fontSize: 12.sp,
                    color: isDark ? Colors.grey[300] : Colors.grey[700],
                    height: 1.5,
                  ),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getTypeColor(String? type) {
    if (type == 'announcement') return Colors.redAccent;
    if (type == 'tip') return Colors.orange;
    return const Color(0xFF10B981); // Article (Green)
  }

  String _getTypeLabel(String? type) {
    if (type == 'announcement') return '📢 إعلان هام';
    if (type == 'tip') return '💡 نصيحة';
    return '📝 مقال';
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}';
    } catch (e) {
      return '';
    }
  }
}
