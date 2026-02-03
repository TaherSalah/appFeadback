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
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          GameWidget(
            game: widget.game,
            overlayBuilderMap: {
              'GameOver': (context, game) {
                _saveScore();
                return Center(
                  child: Container(
                    padding: EdgeInsets.all(24.r),
                    margin: EdgeInsets.symmetric(horizontal: 24.w),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(20.r),
                      boxShadow: [
                        BoxShadow(color: Colors.black26, blurRadius: 10, spreadRadius: 2)
                      ]
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'انتهت اللعبة! 🏁',
                          style: GoogleFonts.cairo(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'مجموع النجوم: ${widget.game.score}',
                          style: GoogleFonts.cairo(
                            fontSize: 18.sp,
                            color: Colors.amber[800],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 24.h),
                        ElevatedButton(
                          onPressed: () {
                            _hasSaved = false; // Reset for new session
                            widget.game.restart();
                            widget.game.overlays.remove('GameOver');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: EdgeInsets.symmetric(
                              horizontal: 32.w,
                              vertical: 12.h,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.r),
                            ),
                          ),
                          child: Text(
                            'العب مرة أخرى',
                            style: GoogleFonts.cairo(
                              fontSize: 16.sp,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(height: 12.h),
                        TextButton(
                          onPressed: () {
                             _saveScore();
                             Navigator.pop(context);
                          },
                          child: Text(
                            'خروج',
                            style: GoogleFonts.cairo(
                              fontSize: 14.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            },
          ),
          // Top UI Overlay
          SafeArea(
            child: Padding(
              padding: EdgeInsets.all(16.r),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 20.sp),
                        SizedBox(width: 8.w),
                        ValueListenableBuilder<int>(
                          valueListenable: widget.game.scoreNotifier,
                          builder: (context, score, child) {
                             return Text(
                              '$score',
                              style: GoogleFonts.cairo(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18.sp,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  // Title
                  Expanded(
                    child: Center(
                      child: Text(
                        widget.title,
                        style: GoogleFonts.cairo(
                          color: Colors.white,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  // Close Button
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.white, size: 30.sp),
                    onPressed: () {
                      _saveScore();
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
