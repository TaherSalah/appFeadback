
import '../exports/all_exports.dart';


class AzkarOrnamentDivider extends StatelessWidget {
  final Color color;

  const AzkarOrnamentDivider({super.key, required this.color});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 12.w),
      child: Row(
        children: [
          // خط يسار
          Expanded(
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerRight,
                  end: Alignment.centerLeft,
                  colors: [
                    color.withOpacity(0.0),
                    color.withOpacity(isDark ? 0.7 : 0.6),
                  ],
                ),
              ),
            ),
          ),

          // دائرة مزخرفة في المنتصف
          Container(
            margin: EdgeInsets.symmetric(horizontal: 8.w),
            padding: EdgeInsets.all(4.r),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: color.withOpacity(0.7),
                width: 1,
              ),
            ),
            child: Container(
              width: 6.r,
              height: 6.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withOpacity(0.9),
              ),
            ),
          ),

          // خط يمين
          Expanded(
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    color.withOpacity(0.0),
                    color.withOpacity(isDark ? 0.7 : 0.6),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
