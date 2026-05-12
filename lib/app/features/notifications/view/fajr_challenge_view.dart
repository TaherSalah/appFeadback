import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:muslimdaily/app/core/services/notification_manager.dart';
import 'package:muslimdaily/app/core/shard/constanc/images_paths.dart';

import '../../../core/extensions/context_extension.dart';

class FajrChallengeView extends StatefulWidget {
  const FajrChallengeView({super.key});

  @override
  State<FajrChallengeView> createState() => _FajrChallengeViewState();
}

class _FajrChallengeViewState extends State<FajrChallengeView>
    with SingleTickerProviderStateMixin {
  int _counter = 0;
  final int _target = 20;
  bool _isSuccess = false;
  late AudioPlayer _audioPlayer;

  @override
  void initState() {
    super.initState();
    _initAudio();
  }

  Future<void> _initAudio() async {
    // 🛑 إيقاف أي صوت أذان يعمل في الخلفية (الإشعار الأصلي) لمنع تداخل الأصوات
    await NotificationManager.stopAdhan();

    _audioPlayer = AudioPlayer();
    try {
      // تشغيل صوت أذان الفجر بشكل مستمر لضمان عدم توقفه عند سحب درج الإشعارات
      await _audioPlayer.setAsset('assets/athan/fajr.mp3');
      await _audioPlayer.setLoopMode(LoopMode.one);
      _audioPlayer.play();
    } catch (e) {
      debugPrint("Error loading audio: $e");
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void _increment() {
    if (_counter < _target) {
      setState(() {
        _counter++;
        HapticFeedback.mediumImpact();
      });

      if (_counter == _target) {
        _onSuccess();
      }
    }
  }

  void _onSuccess() async {
    setState(() {
      _isSuccess = true;
    });
    HapticFeedback.heavyImpact();

    // إيقاف المشغل الصوتي المحلي
    await _audioPlayer.stop();

    // إيقاف إشعار الأذان/المنبه (الذي قد يكون لا يزال يعمل في الخلفية)
    await NotificationManager.stopAdhan();

    // تأخير بسيط لعرض رسالة النجاح
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    // Dynamic Colors based on Theme
    final bgColors = isDark 
      ? [const Color(0xFF0F2027), const Color(0xFF203A43), const Color(0xFF2C5364)]
      : [const Color(0xFFF1F9F7), const Color(0xFFF9FBFA), Colors.white]; // Fresh Morning Teal/White
      
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subTextColor = isDark ? Colors.white.withOpacity(0.8) : const Color(0xFF334155);
    final iconColor = isDark ? Colors.white70 : const Color(0xFF178B74);

    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: bgColors,
              ),
            ),
          ),
          
          // Subtle Pattern Overlay for Premium Feel
          Positioned.fill(
            child: Opacity(
              opacity: isDark ? 0.03 : 0.06,
              child: Image.asset(
                "assets/images/pattern.webp",
                repeat: ImageRepeat.repeat,
              ),
            ),
          ),

          SafeArea(
            child: Column(
            children: [
              const SizedBox(height: 40),
              FadeInDown(
                duration: const Duration(seconds: 1),
                child: Text(
                  'صلاة الفجر خير من النوم',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'cairo',
                  ),
                ),
              ),
              const SizedBox(height: 10),
              FadeInDown(
                delay: const Duration(milliseconds: 500),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (!_isSuccess)
                      Icon(Icons.info_outline, color: iconColor, size: 20),
                    if (!_isSuccess) const SizedBox(width: 8),
                    Text(
                      _isSuccess ? 'تقبل الله طاعتك' : 'صلِّ على النبي ﷺ 20 مره لكي توقف المنبه',
                      style: TextStyle(
                        color: subTextColor,
                        fontSize: 18,
                        fontFamily: 'cairo',
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              _buildCounterDisplay(isDark),
              const Spacer(),
              _buildActionButton(context),
              const SizedBox(height: 30),
              FadeInUp(
                duration: const Duration(seconds: 1),
                child: Column(
                  children: [
                    Image.asset(
                      azkaryLogo,
                      height: 45,
                      color: isDark ? null : const Color(0xFF178B74),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'رفيق المسلم اليومي رفيقك الي الجنه',
                      style: TextStyle(
                        color: isDark ? Colors.white60 : const Color(0xFF263238).withOpacity(0.6),
                        fontSize: 14,
                        fontFamily: 'cairo',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ],
    ),
  );
}

  Widget _buildCounterDisplay(bool isDark) {
    return ZoomIn(
      child: Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isDark ? Colors.transparent : Colors.white.withOpacity(0.8),
          border: Border.all(
            color: isDark ? Colors.white24 : const Color(0xFF178B74).withOpacity(0.25), 
            width: 3
          ),
          boxShadow: [
            BoxShadow(
              color: isDark 
                ? Colors.cyanAccent.withOpacity(0.1)
                : const Color(0xFF178B74).withOpacity(0.12),
              blurRadius: 40,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              '$_counter',
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF178B74),
                fontSize: 80,
                fontWeight: FontWeight.bold,
                fontFamily: 'cairo',
              ),
            ),

            // Text(
            //   'من $_target',
            //   style: TextStyle(
            //     color: Colors.white.withOpacity(0.5),
            //     fontSize: 20,
            //     fontFamily: 'cairo',
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context) {
    final isDark = context.isDark;
    
    if (_isSuccess) {
      return BounceInUp(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
          decoration: BoxDecoration(
            color: Colors.greenAccent.withOpacity(0.2),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.greenAccent),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Colors.greenAccent),
              const SizedBox(width: 10),
              Text(
                'أحسنت بارك الله فيك',
                style: TextStyle(
                  color: isDark ? Colors.greenAccent : Colors.green[700],
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'cairo',
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ElasticInUp(
      child: GestureDetector(
        onTap: _increment,
        child: Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF178B74), Color(0xFF26A69A)],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF178B74).withOpacity(isDark ? 0.4 : 0.3),
                blurRadius: 25,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: const Center(
            child: Text(
              'اللهم صلِّ على محمد',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'cairo',
              ),
            ),
          ),
        ),
      ),
    );
  }
}
