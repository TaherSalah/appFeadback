import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'base_flame_game.dart';
import 'kids_points_service.dart';

class FlameGameWrapper extends StatefulWidget {
  final BaseEducationalGame game;
  final String title;

  const FlameGameWrapper({
    super.key,
    required this.game,
    required this.title,
  });

  @override
  State<FlameGameWrapper> createState() => _FlameGameWrapperState();
}

class _FlameGameWrapperState extends State<FlameGameWrapper> {
  bool _hasSaved = false;

  @override
  void initState() {
    super.initState();
    // Monitor game over to save high score automatically
    widget.game.onGameOver = () {
      _saveScore();
    };
  }

  void _saveScore() {
    if (_hasSaved) return;
    KidsPointsService.addPoints(widget.game.score);
    _hasSaved = true;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            GameWidget(
              game: widget.game,
              overlayBuilderMap: {
                'GameOver': (context, game) {
                  _saveScore();
                  return Container(
                    color: Colors.black54, // Dim background
                    child: Center(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                        child: Container(
                          constraints: BoxConstraints(maxWidth: 400.w),
                          padding: EdgeInsets.all(24.r),
                          margin: EdgeInsets.symmetric(horizontal: 24.w),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.95),
                            borderRadius: BorderRadius.circular(24.r),
                            boxShadow: [
                              BoxShadow(color: Colors.black26, blurRadius: 15, spreadRadius: 2, offset: const Offset(0, 5))
                            ]
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: EdgeInsets.all(16.r),
                                decoration: BoxDecoration(
                                  color: Colors.orange[50],
                                  shape: BoxShape.circle,
                                ),
                                child: Text('🏁', style: TextStyle(fontSize: 40.sp)),
                              ),
                              SizedBox(height: 16.h),
                              Text(
                                '! انتهت اللعبة',
                                style: TextStyle(
                  fontFamily: "cairo",
                                  fontSize: 26.sp,

                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              SizedBox(height: 8.h),
                               Container(
                                 padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                                 decoration: BoxDecoration(
                                   color: Colors.amber[50],
                                   borderRadius: BorderRadius.circular(15.r),
                                   border: Border.all(color: Colors.amber[200]!)
                                 ),
                                 child: Column(
                                   children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.star_rounded, color: Colors.amber[700], size: 28.sp),
                                          SizedBox(width: 8.w),
                                          Text(
                                            '${widget.game.score}',
                                            style: TextStyle(
                  fontFamily: "cairo",
                                              fontSize: 24.sp,
                                              color: Colors.amber[800],
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (widget.game.isNewHighScore) ...[
                                        SizedBox(height: 4.h),
                                        Text(
                                          'رقم قياسي جديد! 🎉',
                                          style: TextStyle(
                  fontFamily: "cairo",
                                            fontSize: 14.sp,
                                            color: Colors.green[700],
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ] else ...[
                                        SizedBox(height: 4.h),
                                        Text(
                                          'أعلى نتيجة: ${widget.game.highScore}',
                                          style: TextStyle(
                  fontFamily: "cairo",
                                            fontSize: 14.sp,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ]
                                   ],
                                 ),
                               ),
                              SizedBox(height: 32.h),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () {
                                        _hasSaved = false; // Reset for new session
                                        widget.game.restart();
                                        widget.game.overlays.remove('GameOver');
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF4CAF50),
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        padding: EdgeInsets.symmetric(vertical: 14.h),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(15.r),
                                        ),
                                      ),
                                      child: Text(
                                        'لعب مجدداً',
                                        style: TextStyle(
                  fontFamily: "cairo",
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 12.w),
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () {
                                         _saveScore();
                                         Navigator.pop(context);
                                      },
                                      style: OutlinedButton.styleFrom(
                                        padding: EdgeInsets.symmetric(vertical: 14.h),
                                        side: BorderSide(color: Colors.grey[300]!, width: 2),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(15.r),
                                        ),
                                      ),
                                      child: Text(
                                        'خروج',
                                        style: TextStyle(
                  fontFamily: "cairo",
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey[700],
                                        ),
                                      ),
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
                },
              },
            ),
            
            // Custom Top App Bar / UI Overlay
            SafeArea(
              child: Align(
                alignment: Alignment.topCenter,
                child: Container(
                  margin: EdgeInsets.all(16.r),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Score Card
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2), // Glassmorphism
                          borderRadius: BorderRadius.circular(30.r),
                          border: Border.all(color: Colors.white.withOpacity(0.3)),
                        ),
                        child: ClipRRect(
                           borderRadius: BorderRadius.circular(30.r),
                           child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.star_rounded, color: Colors.amber, size: 24.sp),
                                  SizedBox(width: 8.w),
                                  ValueListenableBuilder<int>(
                                    valueListenable: widget.game.scoreNotifier,
                                    builder: (context, score, child) {
                                      return Text(
                                        '$score',
                                        style: TextStyle(
                  fontFamily: "cairo",
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18.sp,
                                        ),
                                      );
                                    },
                                  ),
                                  SizedBox(width: 12.w),
                                  Container(width: 1, height: 20.h, color: Colors.white24),
                                  SizedBox(width: 12.w),
                                  Icon(Icons.emoji_events_rounded, color: Colors.amber[200], size: 20.sp),
                                  SizedBox(width: 6.w),
                                  ValueListenableBuilder<int>(
                                    valueListenable: widget.game.highScoreNotifier,
                                    builder: (context, highScore, child) {
                                      return Text(
                                        '$highScore',
                                        style: TextStyle(
                  fontFamily: "cairo",
                                          color: Colors.white.withOpacity(0.9),
                                          fontWeight: FontWeight.w500,
                                          fontSize: 16.sp,
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                           ),
                        ),
                      ),
                      
                      Spacer(),
      
                      // Close Button
                      GestureDetector(
                        onTap: () {
                          _saveScore();
                          Navigator.pop(context);
                        },
                        child: Container(
                          padding: EdgeInsets.all(8.r),
                          decoration: BoxDecoration(
                            color: Colors.black26, 
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white.withOpacity(0.2))
                          ),
                          child: Icon(Icons.close_rounded, color: Colors.white, size: 24.sp),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

