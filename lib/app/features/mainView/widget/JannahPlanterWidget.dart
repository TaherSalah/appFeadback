import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

class JannahPlanterWidget extends StatefulWidget {
  const JannahPlanterWidget({super.key});

  @override
  State<JannahPlanterWidget> createState() => _JannahPlanterWidgetState();
}

class _JannahPlanterWidgetState extends State<JannahPlanterWidget> with SingleTickerProviderStateMixin {
  int _dailyCount = 0;
  int _totalCount = 0;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _showPlusOne = false;

  @override
  void initState() {
    super.initState();
    _loadCounts();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  Future<void> _loadCounts() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _dailyCount = prefs.getInt('jannah_daily_count') ?? 0;
      _totalCount = prefs.getInt('jannah_total_count') ?? 0;
    });
  }

  Future<void> _increment() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _dailyCount++;
      _totalCount++;
      _showPlusOne = true;
    });
    
    // Animate button press
    await _controller.forward();
    await _controller.reverse();

    // Hide +1 after a moment
    Timer(const Duration(milliseconds: 600), () {
      if (mounted) {
        setState(() {
          _showPlusOne = false;
        });
      }
    });

    await prefs.setInt('jannah_daily_count', _dailyCount);
    await prefs.setInt('jannah_total_count', _totalCount);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Text(
            "غراس الجنة 🌴",
            style: TextStyle(
                  fontFamily: "cairo",
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark 
                    ? [const Color(0xFF004D40), const Color(0xFF00695C)] 
                    : [const Color(0xFFE0F2F1), const Color(0xFFB2DFDB)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.teal.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                // زر التسبيح (النخلة)
                Expanded(
                  flex: 3,
                  child: GestureDetector(
                    onTap: _increment,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: Container(
                        height: 110,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white.withOpacity(0.1) : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.teal.shade300,
                            width: 2,
                          ),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.park, size: 40, color: Colors.green),
                                const SizedBox(height: 8),
                                Text(
                                  "اغرس",
                                  style: TextStyle(
                  fontFamily: "cairo",
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                            if (_showPlusOne)
                              Positioned(
                                top: 10,
                                child: TweenAnimationBuilder<double>(
                                  tween: Tween(begin: 0.0, end: 1.0),
                                  duration: const Duration(milliseconds: 500),
                                  builder: (context, value, child) {
                                    return Opacity(
                                      opacity: 1.0 - value,
                                      child: Transform.translate(
                                        offset: Offset(0, -30 * value),
                                        child: Text(
                                          "+1 🌴",
                                          style: TextStyle(
                  fontFamily: "cairo",
                                            fontSize: 18.sp,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // المعلومات والعدادات
                Expanded(
                  flex: 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "قال رسول الله ﷺ:",
                        style: TextStyle(
                  fontFamily: "cairo",
                          fontSize: 10.sp,
                          color: isDark ? Colors.teal.shade100 : Colors.teal.shade800,
                        ),
                      ),
                      Text(
                        "«من قال: سبحان الله وبحمده، غرست له نخلة في الجنة»",
                        style: GoogleFonts.amiri(
                          fontSize: 12.sp,
                          color: isDark ? Colors.white : Colors.black87,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildCounterBox("اليوم", _dailyCount, isDark),
                          _buildCounterBox("المجموع", _totalCount, isDark),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCounterBox(String label, int count, bool isDark) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
                  fontFamily: "cairo",
            fontSize: 10.sp,
            color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: isDark ? Colors.black26 : Colors.white60,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            "$count",
            style: TextStyle(
                  fontFamily: "cairo",
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.tealAccent : Colors.teal,
            ),
          ),
        ),
      ],
    );
  }
}
