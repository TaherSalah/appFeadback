import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class MaintenanceGameDialog extends StatefulWidget {
  final bool isDark;
  
  const MaintenanceGameDialog({super.key, required this.isDark});

  @override
  State<MaintenanceGameDialog> createState() => _MaintenanceGameDialogState();
}

class _MaintenanceGameDialogState extends State<MaintenanceGameDialog> with TickerProviderStateMixin {
  late AnimationController _jumpController;
  late Animation<double> _jumpAnimation;
  late AnimationController _obstacleController;
  
  int _score = 0;
  bool _isGameOver = false;
  bool _isJumping = false;
  double _obstaclePosition = 1.5;
  
  @override
  void initState() {
    super.initState();
    
    _jumpController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _jumpAnimation = Tween<double>(begin: 0, end: -100).animate(
      CurvedAnimation(parent: _jumpController, curve: Curves.easeOut),
    );
    
    _obstacleController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..addListener(() {
      setState(() {
        _obstaclePosition = 1.5 - (_obstacleController.value * 2.5);
        
        if (_obstaclePosition < 0.1 && _obstaclePosition > -0.1 && !_isJumping) {
          _gameOver();
        }
        
        if (_obstaclePosition < -0.2 && !_isGameOver) {
          _score++;
          _obstaclePosition = 1.5;
        }
      });
    });
    
    _startGame();
  }

  void _startGame() {
    _score = 0;
    _isGameOver = false;
    _obstaclePosition = 1.5;
    _obstacleController.repeat();
  }

  void _gameOver() {
    setState(() {
      _isGameOver = true;
    });
    _obstacleController.stop();
  }

  void _jump() {
    if (!_isJumping && !_isGameOver) {
      setState(() {
        _isJumping = true;
      });
      _jumpController.forward().then((_) {
        _jumpController.reverse().then((_) {
          setState(() {
            _isJumping = false;
          });
        });
      });
    }
  }

  @override
  void dispose() {
    _jumpController.dispose();
    _obstacleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 45, 20, 25),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: widget.isDark
                      ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                      : [const Color(0xFFFFF7ED), const Color(0xFFFFEDD5)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
                border: Border.all(
                  color: const Color(0xFFf97316).withOpacity(0.5),
                  width: 1.2,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'عذراً، القسم قيد الصيانة',
                    style: GoogleFonts.cairo(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: widget.isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    'في انتظار العودة، استمتع باللعبة! 🎮',
                    style: GoogleFonts.cairo(
                      fontSize: 14.sp,
                      height: 1.5,
                      color: widget.isDark ? Colors.white70 : Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20.h),
                  
                  // Game Area
                  GestureDetector(
                    onTap: _jump,
                    child: Container(
                      width: double.infinity,
                      height: 200.h,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: widget.isDark 
                            ? const Color(0xFF0F172A).withOpacity(0.5)
                            : Colors.white.withOpacity(0.5),
                        border: Border.all(
                          color: const Color(0xFF10b981).withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: Stack(
                        children: [
                          // Score
                          Positioned(
                            top: 10,
                            right: 10,
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                              decoration: BoxDecoration(
                                color: const Color(0xFF10b981),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'النقاط: $_score',
                                style: GoogleFonts.cairo(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          
                          // Ground
                          Positioned(
                            bottom: 30,
                            left: 0,
                            right: 0,
                            child: Container(
                              height: 2,
                              color: widget.isDark ? Colors.white24 : Colors.black12,
                            ),
                          ),
                          
                          // Player
                          AnimatedBuilder(
                            animation: _jumpAnimation,
                            builder: (context, child) {
                              return Positioned(
                                bottom: 40 + _jumpAnimation.value,
                                left: 40,
                                child: Text(
                                  '🌙',
                                  style: TextStyle(fontSize: 40.sp),
                                ),
                              );
                            },
                          ),
                          
                          // Obstacle
                          if (_obstaclePosition > -0.5 && _obstaclePosition < 1.5)
                            Positioned(
                              bottom: 40,
                              right: MediaQuery.of(context).size.width * 0.3 * _obstaclePosition,
                              child: Text(
                                '🌵',
                                style: TextStyle(fontSize: 35.sp),
                              ),
                            ),
                          
                          // Game Over
                          if (_isGameOver)
                            Container(
                              color: Colors.black54,
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'انتهت اللعبة!',
                                      style: GoogleFonts.cairo(
                                        fontSize: 24.sp,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(height: 8.h),
                                    Text(
                                      'النقاط: $_score',
                                      style: GoogleFonts.cairo(
                                        fontSize: 18.sp,
                                        color: Colors.white70,
                                      ),
                                    ),
                                    SizedBox(height: 16.h),
                                    ElevatedButton(
                                      onPressed: () {
                                        setState(() {
                                          _startGame();
                                        });
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF10b981),
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
                                      ),
                                      child: Text(
                                        'إعادة المحاولة',
                                        style: GoogleFonts.cairo(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          
                          // Instructions
                          if (!_isGameOver && _score == 0)
                            Positioned(
                              bottom: 80,
                              left: 0,
                              right: 0,
                              child: Center(
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'اضغط للقفز! 👆',
                                    style: GoogleFonts.cairo(
                                      fontSize: 12.sp,
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

                  SizedBox(height: 20.h),

                  // Info Card
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: const Color(0xFFf97316).withOpacity(0.06),
                      border: Border.all(
                        color: const Color(0xFFf97316).withOpacity(0.5),
                        width: 1.2,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.construction_rounded, size: 18, color: Color(0xFFf97316)),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            'سنعود قريباً بميزات محسّنة وأداء أفضل.',
                            style: GoogleFonts.cairo(
                              fontSize: 12.5.sp,
                              color: const Color(0xFFf97316),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20.h),

                  // Close Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.check_circle_outline_rounded),
                      label: Text(
                        'حسناً',
                        style: GoogleFonts.cairo(
                          fontWeight: FontWeight.bold,
                          fontSize: 15.sp,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFf97316),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 13.h),
                        elevation: 4,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Top Icon
            Positioned(
              top: -30,
              left: 0,
              right: 0,
              child: Align(
                alignment: Alignment.topCenter,
                child: Container(
                  width: 65,
                  height: 65,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFFf97316), Color(0xFFea580c)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFf97316).withOpacity(0.6),
                        blurRadius: 15,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.engineering_rounded,
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
    );
  }
}
