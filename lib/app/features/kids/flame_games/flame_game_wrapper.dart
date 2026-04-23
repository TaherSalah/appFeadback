import 'dart:ui';

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


import '../../../core/widgets/game_dialog.dart';
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
                  return GameDialog(
                    title: 'انتهت اللعبة!',
                    subtitle: widget.game.isNewHighScore 
                      ? 'رقم قياسي جديد: ${widget.game.score} 🎉' 
                      : 'نتيجتك: ${widget.game.score}',
                    icon: Text('🏁', style: TextStyle(fontSize: 32.sp)),
                    actions: [
                      GameDialogAction(
                        label: 'لعب مجدداً',
                        icon: Icons.replay_rounded,
                        gradient: const LinearGradient(colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)]),
                        onPressed: () {
                          _hasSaved = false;
                          widget.game.restart();
                          widget.game.overlays.remove('GameOver');
                        },
                      ),
                      GameDialogAction(
                        label: 'خروج',
                        icon: Icons.exit_to_app_rounded,
                        backgroundColor: Colors.grey.shade200,
                        textColor: Colors.grey.shade700,
                        onPressed: () {
                          _saveScore();
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  );
                },

                'Pause': (context, game) {
                  return GameDialog(
                    title: 'إيقاف مؤقت',
                    subtitle: 'هل تريد الاستمرار؟',
                    icon: const Icon(Icons.pause_rounded, color: Colors.white, size: 32),
                    actions: [
                      GameDialogAction(
                        label: 'استكمال',
                        icon: Icons.play_arrow_rounded,
                        gradient: const LinearGradient(colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)]),
                        onPressed: () {
                          widget.game.resumeEngine();
                          widget.game.overlays.remove('Pause');
                        },
                      ),
                      GameDialogAction(
                        label: 'إعادة اللعب',
                        icon: Icons.replay_rounded,
                        gradient: const LinearGradient(colors: [Color(0xFF2196F3), Color(0xFF1565C0)]),
                        onPressed: () {
                          _hasSaved = false;
                          widget.game.restart();
                          widget.game.overlays.remove('Pause');
                        },
                      ),
                      GameDialogAction(
                        label: 'خروج',
                        icon: Icons.exit_to_app_rounded,
                        backgroundColor: Colors.grey.shade200,
                        textColor: Colors.grey.shade700,
                        onPressed: () {
                          _saveScore();
                          Navigator.pop(context);
                        },
                      ),
                    ],
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
                      
                      const Spacer(),
      
                      // Pause Button
                      GestureDetector(
                        onTap: () {
                          widget.game.pauseEngine();
                          widget.game.overlays.add('Pause');
                        },
                        child: Container(
                          padding: EdgeInsets.all(8.r),
                          decoration: BoxDecoration(
                            color: Colors.black26, 
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white.withOpacity(0.2))
                          ),
                          child: Icon(Icons.pause_rounded, color: Colors.white, size: 24.sp),
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

