import 'package:animate_do/animate_do.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:muslimdaily/app/core/extensions/context_extension.dart';
import 'package:muslimdaily/app/core/services/system_control_service.dart';

class FeatureGuardService {
  static final FeatureGuardService _instance = FeatureGuardService._internal();
  factory FeatureGuardService() => _instance;
  FeatureGuardService._internal();

  /// 🛡️ Main check for features
  Future<bool> canAccess(BuildContext context, String featureName, {bool requiresInternet = true}) async {
    // 1. Check Maintenance Mode from Supabase
    final statuses = await SystemControlService().getFeatureStatuses();
    final status = statuses[featureName]?.toLowerCase() ?? 'active';

    if (status == 'maintenance') {
      if (context.mounted) {
        _showStatusDialog(
          context,
          title: 'عذراً.. القسم قيد الصيانة',
          message: 'نعمل حالياً على تحسين هذا القسم لتقديم تجربة أفضل. يرجى العودة لاحقاً.',
          icon: Icons.handyman_rounded,
          color: Colors.amber,
        );
      }
      return false;
    }

    if (status == 'hidden') {
      return false;
    }

    // 2. Check Internet if required
    if (requiresInternet) {
      final connectivity = await Connectivity().checkConnectivity();
      if (connectivity == ConnectivityResult.none) {
        if (context.mounted) {
          _showStatusDialog(
            context,
            title: 'لا يوجد اتصال بالإنترنت',
            message: 'هذا القسم يتطلب اتصالاً بالإنترنت للعمل بشكل صحيح.',
            icon: Icons.wifi_off_rounded,
            color: Colors.redAccent,
          );
        }
        return false;
      }
    }

    return true;
  }

  void _showStatusDialog(BuildContext context, {
    required String title,
    required String message,
    required IconData icon,
    required Color color,
  }) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        final isDark = context.isDark;
        return FadeInUp(
          duration: const Duration(milliseconds: 300),
          child: AlertDialog(
            backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.r)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 50.sp),
                ),
                SizedBox(height: 20.h),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: "cairo",
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: "cairo",
                    fontSize: 14.sp,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
                SizedBox(height: 25.h),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                    ),
                    child: Text(
                      'حسناً',
                      style: TextStyle(
                        fontFamily: "cairo",
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: anim1, curve: Curves.easeOutBack),
          child: child,
        );
      },
    );
  }
}
