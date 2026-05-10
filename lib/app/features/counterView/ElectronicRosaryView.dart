import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:muslimdaily/app/core/shard/widgets/ui_animations.dart';
import 'package:muslimdaily/app/core/utils/style/k_color.dart';

import '../../core/shard/exports/all_exports.dart';




class ElectronicRosaryView extends StatefulWidget {
  const ElectronicRosaryView({super.key});

  @override
  State<ElectronicRosaryView> createState() => _ElectronicRosaryViewState();
}

class _ElectronicRosaryViewState extends State<ElectronicRosaryView> with SingleTickerProviderStateMixin {
  late AnimationController _btnController;

  @override
  void initState() {
    super.initState();
    _btnController = AnimationController(vsync: this, duration: const Duration(milliseconds: 100));
  }

  @override
  void dispose() {
    _btnController.dispose();
    super.dispose();
  }

  void _onTap() {
    final provider = Provider.of<AzkarProvider>(context, listen: false);
    if (provider.isVibrationEnabled) HapticFeedback.heavyImpact();
    provider.incrementCount(vibrate: false);
    _btnController.forward().then((value) => _btnController.reverse());
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = context.isTab;
    final provider = Provider.of<AzkarProvider>(context);

    return SizedBox(
      height: MediaQuery.sizeOf(context).height/1.2,
      child: Column(
        mainAxisSize: MainAxisSize.min,

        children: [
          SizedBox(height: isTablet ? 180.h : 130.h),
          Center(
            child: Container(
              width: isTablet ? 300.w : 240.w,
              padding: EdgeInsets.all(isTablet ? 32.r : 24.r),
              decoration: BoxDecoration(
                color: const Color(0xFF111111), // Black body
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(80.r),
                  bottom: Radius.circular(120.r),
                ),
                border: Border.all(color: KColors.primaryColor, width: 8.w), // Cyan border exactly like image
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.6), blurRadius: 25, offset: const Offset(0, 15))
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // LCD Screen displaying the counter
                  Container(
                    width: double.infinity,
                    height: isTablet ? 90.h : 70.h,
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: provider.isHiddenMode ? const Color(0xFF1E1E1E) : const Color(0xFF90A492), // Darker background in hidden mode
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: const Color(0xFFD4AF37), width: 3.w), // Gold inner border
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 5) // Simulated depth
                      ],
                    ),
                    alignment: Alignment.centerRight,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 300),
                      opacity: provider.isHiddenMode ? 0.0 : 1.0,
                      child: Text(
                        '${provider.counter}',
                        style: TextStyle(
                          fontFamily: "cairo",
                          fontSize: isTablet ? 55.sp : 45.sp,
                          color: Colors.black87,
                          fontWeight: FontWeight.w900,
                          height: 1.0,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  // Text "تسبيح"
                  // Text(
                  //   'تسبيح',
                  //   style: TextStyle(
                  //     fontFamily: "cairo",
                  //     fontSize: isTablet ? 28.sp : 22.sp,
                  //     color: const Color(0xFFD4AF37), // Gold
                  //     fontWeight: FontWeight.bold,
                  //   ),
                  // ),
                  // SizedBox(height: 15.h),
                  // Small buttons row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          Text('إعادة تعيين', style: TextStyle(color: const Color(0xFFD4AF37), fontSize: 10.sp, fontFamily: "cairo", fontWeight: FontWeight.bold)),
                          SizedBox(height: 8.h),
                          GestureDetector(
                            onTap: () {
                              HapticFeedback.heavyImpact();
                              provider.restCount();
                            },
                            child: Container(
                              width: 20.w, height: 20.w,
                              decoration: BoxDecoration(
                                  color: Colors.red.shade600,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.black, width: 2),
                                  boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 2, offset: Offset(0, 2))]
                              ),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Text('الوضع الخفي', style: TextStyle(color: const Color(0xFFD4AF37), fontSize: 10.sp, fontFamily: "cairo", fontWeight: FontWeight.bold)),
                          SizedBox(height: 8.h),
                          GestureDetector(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              provider.toggleHiddenMode();
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              width: 20.w, height: 20.w,
                              decoration: BoxDecoration(
                                  color: provider.isHiddenMode ? Colors.green.shade600 : Colors.red.shade600,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.black, width: 2),
                                  boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 2, offset: Offset(0, 2))]
                              ),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Text('الاهتزاز', style: TextStyle(color: const Color(0xFFD4AF37), fontSize: 10.sp, fontFamily: "cairo", fontWeight: FontWeight.bold)),
                          SizedBox(height: 8.h),
                          GestureDetector(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              provider.toggleVibration(!provider.isVibrationEnabled);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              width: 20.w, height: 20.w,
                              decoration: BoxDecoration(
                                  color: provider.isVibrationEnabled ? Colors.green.shade600 : Colors.red.shade600,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.black, width: 2),
                                  boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 2, offset: Offset(0, 2))]
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                  SizedBox(height: 30.h),
                  // Big Red Tally Button
                  GestureDetector(
                    onTap: _onTap,
                    child: ScaleTransition(
                      scale: Tween<double>(begin: 1.0, end: 0.92).animate(
                          CurvedAnimation(parent: _btnController, curve: Curves.easeOut)
                      ),
                      child: Container(
                        width: isTablet ? 120.w : 90.w,
                        height: isTablet ? 120.w : 90.w,
                        decoration: BoxDecoration(
                          color: Colors.red.shade600, // Vibrant red
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            center: const Alignment(-0.3, -0.5),
                            radius: 1.0,
                            colors: [
                              Colors.red.shade400, // Highlight
                              Colors.red.shade800, // Base red
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(color: Colors.redAccent.withOpacity(0.4), blurRadius: 15, spreadRadius: 2),
                            const BoxShadow(color: Colors.black87, blurRadius: 10, offset: Offset(0, 8)), // Shadow below button
                          ],
                          border: Border.all(color: const Color(0xFF550000), width: 3.w), // Dark red rim
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
