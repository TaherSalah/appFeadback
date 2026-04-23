import 'package:muslimdaily/app/core/utils/style/k_helper.dart';
import 'package:muslimdaily/app/features/shareCard/PremiumShareCard.dart';
import 'package:share_plus/share_plus.dart';

import '../exports/all_exports.dart';
import 'AzkarActionButton.dart';


class AzkarActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const AzkarActionButton({super.key, 
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final primary = Theme.of(context).colorScheme.primary;

    return InkWell(
      borderRadius: BorderRadius.circular(30.r),
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30.r),
          color: isDark
              ? Colors.white.withOpacity(0.04)
              : primary.withOpacity(0.06),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: context.isTab ? 15.sp : 18.sp,
              color: isDark ? Colors.greenAccent : primary,
            ),
            SizedBox(width: 6.w),
            Text(
              label,
              style: TextStyle(
                fontFamily: "cairo",
                fontSize: context.isTab ? 9.sp : 12.sp,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white70 : Colors.grey[900],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
