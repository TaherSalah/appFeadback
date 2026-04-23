import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:animate_do/animate_do.dart';
import 'package:muslimdaily/app/core/extensions/context_extension.dart';

class GameDialog extends StatelessWidget {
  final String title;
  final List<GameDialogAction> actions;
  final Widget? icon;
  final String? subtitle;

  const GameDialog({
    super.key,
    required this.title,
    required this.actions,
    this.icon,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    
    return Center(
      child: FadeInDown(
        duration: const Duration(milliseconds: 400),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            constraints: BoxConstraints(maxWidth: context.isTab ? 450.w : 320.w),
            margin: EdgeInsets.symmetric(horizontal: 24.w),
            child: Material(
              color: Colors.transparent,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Main Card
                  Container(
                    padding: EdgeInsets.fromLTRB(24.r, 48.r, 24.r, 24.r),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B).withOpacity(0.9) : Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(30.r),
                      border: Border.all(
                        color: isDark ? Colors.white12 : Colors.black12,
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontFamily: "cairo",
                            fontSize: 24.sp,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                            decoration: TextDecoration.none,
                          ),
                        ),
                        if (subtitle != null) ...[
                          SizedBox(height: 8.h),
                          Text(
                            subtitle!,
                            style: TextStyle(
                              fontFamily: "cairo",
                              fontSize: 14.sp,
                              color: isDark ? Colors.white70 : Colors.black54,
                              decoration: TextDecoration.none,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                        SizedBox(height: 32.h),
                        ...actions.map((action) => Padding(
                          padding: EdgeInsets.only(bottom: 12.h),
                          child: _buildActionButton(context, action),
                        )),
                      ],
                    ),
                  ),
                  
                  // Top Icon / Decoration
                  Positioned(
                    top: -35.r,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: ZoomIn(
                        delay: const Duration(milliseconds: 200),
                        child: Container(
                          padding: EdgeInsets.all(16.r),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [Colors.amber.shade400, Colors.orange.shade700],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.orange.withOpacity(0.4),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                            border: Border.all(color: Colors.white, width: 4),
                          ),
                          child: icon ?? Icon(Icons.videogame_asset_rounded, color: Colors.white, size: 32.r),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, GameDialogAction action) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18.r),
        gradient: action.gradient,
        boxShadow: [
          if (action.gradient != null)
            BoxShadow(
              color: action.gradient!.colors.last.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: ElevatedButton(
        onPressed: action.onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: action.gradient != null ? Colors.transparent : (action.backgroundColor ?? Colors.grey.shade200),
          foregroundColor: action.textColor ?? Colors.white,
          shadowColor: Colors.transparent,
          padding: EdgeInsets.symmetric(vertical: 14.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18.r),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (action.icon != null) ...[
              Icon(action.icon, size: 20.sp),
              SizedBox(width: 10.w),
            ],
            Text(
              action.label,
              style: TextStyle(
                fontFamily: "cairo",
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GameDialogAction {
  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  final Gradient? gradient;
  final Color? backgroundColor;
  final Color? textColor;

  GameDialogAction({
    required this.label,
    required this.onPressed,
    this.icon,
    this.gradient,
    this.backgroundColor,
    this.textColor,
  });
}
