import 'dart:developer' show log;
import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:muslimdaily/app/core/utils/style/k_color.dart';
import 'package:muslimdaily/app/features/QiblaView/QiblaDirection.dart';
import 'package:muslimdaily/app/features/mainView/MainView.dart';
import 'package:muslimdaily/app/features/prayerView/post_prayer_azkar.dart';
import 'package:muslimdaily/app/features/quran/quranView.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/services/notification_manager.dart';

class AdhanOverlayScreen extends StatefulWidget {
  final String? prayerName;
  final String? cityName;
  final String? prayerTime;

  const AdhanOverlayScreen({
    super.key,
    this.prayerName,
    this.cityName,
    this.prayerTime,
  });

  @override
  State<AdhanOverlayScreen> createState() => _AdhanOverlayScreenState();
}

class _AdhanOverlayScreenState extends State<AdhanOverlayScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  AudioPlayer? _audioPlayer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // 🛑 Stop system notification adhan sound immediately before playing our own
    NotificationManager.stopAdhan();

    // Start playing the selected Adhan sound with a small delay
    Future.delayed(const Duration(milliseconds: 500), () {
      _playAdhanSound();
    });
  }

  Future<void> _playAdhanSound() async {
    print('🌙 [AdhanOverlay] Starting audio playback sequence...');
    try {
      // Setup audio session to use Alarm stream so it plays even on silent
      print('🌙 [AdhanOverlay] Configuring AudioSession...');
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration(
        avAudioSessionCategory: AVAudioSessionCategory.playback,
        avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.duckOthers,
        avAudioSessionMode: AVAudioSessionMode.defaultMode,
        avAudioSessionRouteSharingPolicy:
            AVAudioSessionRouteSharingPolicy.defaultPolicy,
        avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
        androidAudioAttributes: AndroidAudioAttributes(
          contentType: AndroidAudioContentType.music,
          flags: AndroidAudioFlags.audibilityEnforced,
          usage: AndroidAudioUsage.alarm, // ← This is key! Uses alarm volume
        ),
        androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
        androidWillPauseWhenDucked: false,
      ));

      await session.setActive(true);
      print('🌙 [AdhanOverlay] AudioSession active.');

      // Get the saved Adhan path
      final prefs = await SharedPreferences.getInstance();
      final isFajr = widget.prayerName?.contains('الفجر') ?? false;
      final isShuruq = widget.prayerName?.contains('الشروق') ?? false;

      String? adhanPath = isFajr
          ? prefs.getString('adhan_path_fajir')
          : isShuruq
              ? null // Shuruq always uses default sound for now
              : prefs.getString('adhan_path');

      print(
          '🌙 [AdhanOverlay] Preference adhanPath: $adhanPath (isFajr: $isFajr, isShuruq: $isShuruq)');

      _audioPlayer = AudioPlayer();
      await _audioPlayer!.setVolume(1.0);

      if (adhanPath != null && adhanPath.startsWith('/')) {
        // It's a local file path (downloaded custom adhan)
        print('🔊 [AdhanOverlay] Playing from local file: $adhanPath');
        await _audioPlayer!.setFilePath(adhanPath);
      } else {
        // Default: use the bundled Adhan asset
        String assetName;
        if (isShuruq) {
          assetName = 'assets/athan/shruq.mp3';
        } else if (isFajr) {
          assetName = 'assets/athan/fajr.mp3';
        } else {
          assetName = 'assets/athan/athan.mp3';
        }
        print('🔊 [AdhanOverlay] Playing from asset: $assetName');
        await _audioPlayer!.setAsset(assetName);
      }

      print('🌙 [AdhanOverlay] Audio source set. Starting playback...');
      _audioPlayer!.play();
      print('🌙 [AdhanOverlay] Playback started.');
    } catch (e, stack) {
      print('❌ [AdhanOverlay] Error playing Adhan sound: $e');
      print('❌ [AdhanOverlay] Stack: $stack');
    }
  }

  Future<void> _stopAndClose() async {
    await _audioPlayer?.stop();
    await _audioPlayer?.dispose();
    _audioPlayer = null;
    final session = await AudioSession.instance;
    await session.setActive(false);
  }

  @override
  void dispose() {
    _stopAndClose();
    _controller.dispose();
    super.dispose();
  }

  void _closeScreen() async {
    await _stopAndClose();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const MainView()),
        (Route<dynamic> route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/sultan-qaboos-grand-mosque-2606274_1280-min.jpg',
              fit: BoxFit.cover,
            ),
          ),

          // Overlay Gradient for better visibility
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.4),
                    Colors.black.withOpacity(0.6),
                  ],
                ),
              ),
            ),
          ),

          // Close Button
          Positioned(
            top: 50.h,
            left: 20.w,
            child: GestureDetector(
              onTap: _closeScreen,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withOpacity(0.5),
                  border: Border.all(color: Colors.white, width: 1),
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
          // Central Content (Animated)
          Center(
            child: FadeTransition(
              opacity: _scaleAnimation,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.prayerName?.contains('الشروق') == true
                        ? "حان الآن موعد"
                        : "حان الان موعد صلاة",
                    style: GoogleFonts.amiri(
                      fontSize: 35.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      shadows: const [
                        Shadow(
                          blurRadius: 10,
                          color: Colors.black,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    widget.prayerName ?? "وقت الصلاة",
                    style: GoogleFonts.amiri(
                      fontSize: 48.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      shadows: const [
                        Shadow(
                          blurRadius: 10,
                          color: Colors.black,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                  ),
                  if (widget.prayerName?.contains('الشروق') == true) ...[
                    SizedBox(height: 20.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 30.w),
                      child: Text(
                        "«صلاة الضحى صلاة الأوابين وهي صدقة عن كل مفصل من مفاصلك»",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.amiri(
                          fontSize: 20.sp,
                          color: KColors.whiteDarkColor,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                  if (widget.cityName != null) ...[
                    SizedBox(height: 10.h),
                    Text(
                      widget.cityName!,
                      style: GoogleFonts.cairo(
                        fontSize: 25.sp,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                  if (widget.prayerTime != null) ...[
                    SizedBox(height: 5.h),
                    Text(
                      widget.prayerTime!,
                      style: GoogleFonts.barlow(
                        fontSize: 24.sp,
                        color: Colors.amber,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Bottom Action Buttons
          Positioned(
            bottom: 50.h,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.white24, width: 1),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildActionButton(
                    icon: Icons.mosque,
                    label: "أذكار الصلاة",
                    onTap: () async {
                      await _stopAndClose();
                      if (mounted) {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                              builder: (_) => const PrayerAzkar()),
                          (r) => false,
                        );
                      }
                    },
                  ),
                  _buildActionButton(
                    icon: Icons.menu_book,
                    label: "القرآن",
                    onTap: () async {
                      await _stopAndClose();
                      if (mounted) {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (_) => const QuranView()),
                          (r) => false,
                        );
                      }
                    },
                  ),
                  _buildActionButton(
                    icon: Icons.explore,
                    label: "القبلة",
                    onTap: () async {
                      await _stopAndClose();
                      if (mounted) {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                              builder: (_) => const QiblaDirection()),
                          (r) => false,
                        );
                      }
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

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 28),
          SizedBox(height: 5.h),
          Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 12.sp,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
