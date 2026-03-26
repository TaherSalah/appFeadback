import 'dart:async';
import 'dart:ui' as ui;

import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:just_audio/just_audio.dart';
import 'package:muslimdaily/app/core/extensions/context_extension.dart';

class QuranRadioPlayer extends StatefulWidget {
  const QuranRadioPlayer({
    super.key,
    this.title = "إذاعة القرآن",
    this.streamUrl = "https://backup.qurango.net/radioView/mohammad_alabdullah_albizi",
    this.accentColor,
    this.compact = false,
  });

  final String title;
  final String streamUrl;
  final Color? accentColor;
  final bool compact;

  @override
  State<QuranRadioPlayer> createState() => _QuranRadioPlayerState();
}

class _QuranRadioPlayerState extends State<QuranRadioPlayer> {
  late final AudioPlayer _player;
  double _volume = 1.0;
  Timer? _retryTimer;

  Color get _accent => widget.accentColor ?? const Color(0xFF1B5E20);

  Stream<PlayerState> get _playerStateStream => _player.playerStateStream;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _setup();

    _player.playerStateStream.listen((state) {
      final playing = state.playing;
      final processing = state.processingState;
      if (processing == ProcessingState.idle || processing == ProcessingState.completed) {
        _cancelRetry();
      }
      if (processing == ProcessingState.ready && playing) {
        _cancelRetry();
      }
      if (processing == ProcessingState.idle || processing == ProcessingState.buffering) {
        _scheduleRetry();
      }
    });
  }

  Future<void> _setup() async {
    try {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.music());
      await _player.setUrl(widget.streamUrl);
      _player.setVolume(_volume);
    } catch (e) {
      _scheduleRetry();
    }
  }

  void _scheduleRetry() {
    _cancelRetry();
    _retryTimer = Timer(const Duration(seconds: 3), () async {
      try {
        await _player.setUrl(widget.streamUrl);
        await _player.play();
      } catch (_) {
        _scheduleRetry();
      }
    });
  }

  void _cancelRetry() {
    _retryTimer?.cancel();
    _retryTimer = null;
  }

  @override
  void dispose() {
    _cancelRetry();
    _player.dispose();
    super.dispose();
  }

  Future<void> _togglePlay() async {
    if (_player.playing) {
      await _player.pause();
    } else {
      if (_player.processingState == ProcessingState.idle ||
          _player.processingState == ProcessingState.buffering) {
        try {
          await _player.setUrl(widget.streamUrl);
        } catch (e) {
          return;
        }
      }
      await _player.play();
    }
  }

  String _statusText(PlayerState s) {
    switch (s.processingState) {
      case ProcessingState.idle:
        return "جاهز";
      case ProcessingState.loading:
        return "جارٍ التحميل…";
      case ProcessingState.buffering:
        return "جارٍ التخزين المؤقت…";
      case ProcessingState.ready:
        return s.playing ? "بث مباشر" : "متوقّف مؤقتًا";
      case ProcessingState.completed:
        return "انتهى";
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final cardPadding = widget.compact ? 12.0 : 20.0;
    final iconSize = widget.compact ? 30.0 : 48.0;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(cardPadding),
      child: StreamBuilder<PlayerState>(
        stream: _playerStateStream,
        builder: (context, snapshot) {
          final state = snapshot.data ?? _player.playerState;
          final isBuffering =
              state.processingState == ProcessingState.loading ||
                  state.processingState == ProcessingState.buffering;
          final isPlaying = _player.playing && !isBuffering;

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!widget.compact) ...[
                TweenAnimationBuilder<double>(
                  duration: const Duration(seconds: 2),
                  tween: Tween(begin: 0, end: 1),
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(0, 20 * (1 - value)),
                        child: child,
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: _accent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: _accent.withOpacity(0.2)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.radio_rounded, color: _accent, size: 20),
                        const SizedBox(width: 10),
                        Text(
                          widget.title,
                             style: TextStyle(
                          fontFamily: "cairo",
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : _accent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 30.h),
              ],
              Expanded(
                child: Container(
                  width: double.infinity,
                  constraints: BoxConstraints(maxWidth: 500.w),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (isPlaying)
                        TweenAnimationBuilder<double>(
                          duration: const Duration(seconds: 2),
                          tween: Tween(begin: 0.2, end: 0.5),
                          curve: Curves.easeInOutSine,
                          builder: (context, value, child) {
                            return Container(
                              width: 250.w,
                              height: 250.w,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: _accent.withOpacity(value),
                                    blurRadius: 100,
                                    spreadRadius: 20,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isDark 
                              ? Colors.white.withOpacity(0.05) 
                              : Colors.white.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: isDark 
                                ? Colors.white.withOpacity(0.1) 
                                : _accent.withOpacity(0.1),
                              width: 1.5,
                            ),
                          ),
                          child: BackdropFilter(
                            filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        if (isPlaying)
                                          const RotatingRings(),
                                        Container(
                                          width: 180.w,
                                          height: 180.w,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            image: const DecorationImage(
                                              image: AssetImage("assets/images/unnamed.jpg"),
                                              fit: BoxFit.cover,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(0.3),
                                                blurRadius: 15,
                                                spreadRadius: 2,
                                              ),
                                            ],
                                            border: Border.all(
                                              color: Colors.white.withOpacity(0.8),
                                              width: 4,
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          top: 0,
                                          right: 0,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                            decoration: BoxDecoration(
                                              color: Colors.black.withOpacity(0.6),
                                              borderRadius: BorderRadius.circular(20),
                                              border: Border.all(color: Colors.white24),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const LiveIndicator(),
                                                const SizedBox(width: 8),
                                                Text(
                                                  _statusText(state),
                                                     style: TextStyle(
                          fontFamily: "cairo",
                                                    color: Colors.white,
                                                    fontSize: 10.sp,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 30),
                                        child: Row(
                                          children: [
                                            Icon(Icons.volume_mute, size: 18, 
                                              color: isDark ? Colors.white54 : Colors.black45),
                                            Expanded(
                                              child: SliderTheme(
                                                data: SliderTheme.of(context).copyWith(
                                                  trackHeight: 2,
                                                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                                                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                                                  activeTrackColor: _accent,
                                                  inactiveTrackColor: _accent.withOpacity(0.2),
                                                  thumbColor: _accent,
                                                ),
                                                child: Slider(
                                                  value: _volume,
                                                  onChanged: (v) {
                                                    setState(() => _volume = v);
                                                    _player.setVolume(v);
                                                  },
                                                ),
                                              ),
                                            ),
                                            Icon(Icons.volume_up, size: 18, 
                                              color: isDark ? Colors.white54 : Colors.black45),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      GestureDetector(
                                        onTap: isBuffering ? null : _togglePlay,
                                        child: AnimatedContainer(
                                          duration: const Duration(milliseconds: 200),
                                          width: isPlaying ? 85.w : 75.w,
                                          height: isPlaying ? 85.w : 75.w,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            gradient: LinearGradient(
                                              colors: [
                                                _accent,
                                                _accent.withOpacity(0.8),
                                              ],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: _accent.withOpacity(0.4),
                                                blurRadius: isPlaying ? 20 : 10,
                                                spreadRadius: isPlaying ? 5 : 0,
                                                offset: const Offset(0, 5),
                                              ),
                                            ],
                                          ),
                                          child: Center(
                                            child: isBuffering
                                              ? const SizedBox(
                                                  width: 30,
                                                  height: 30,
                                                  child: CircularProgressIndicator(
                                                    color: Colors.white,
                                                    strokeWidth: 3,
                                                  ),
                                                )
                                              : Icon(
                                                  isPlaying 
                                                    ? Icons.pause_rounded 
                                                    : Icons.play_arrow_rounded,
                                                  color: Colors.white,
                                                  size: iconSize,
                                                ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      Text(
                                        "بث مباشر – لا يدعم التقديم أو الترجيع",
                                           style: TextStyle(
                          fontFamily: "cairo",
                                          fontSize: 10.sp,
                                          color: isDark ? Colors.white38 : Colors.black38,
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                    ],
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
              ),
              if (!widget.compact) SizedBox(height: 20.h),
            ],
          );
        },
      ),
    );
  }
}

class RotatingRings extends StatefulWidget {
  const RotatingRings({super.key});

  @override
  State<RotatingRings> createState() => _RotatingRingsState();
}

class _RotatingRingsState extends State<RotatingRings> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _controller,
      child: Stack(
        alignment: Alignment.center,
        children: List.generate(3, (index) {
          return Container(
            width: (200 + index * 40).w,
            height: (200 + index * 40).w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF1B5E20).withOpacity(0.1 - index * 0.03),
                width: 2,
              ),
            ),
          );
        }),
      ),
    );
  }
}

class LiveIndicator extends StatefulWidget {
  const LiveIndicator({super.key});

  @override
  State<LiveIndicator> createState() => _LiveIndicatorState();
}

class _LiveIndicatorState extends State<LiveIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.8, end: 1.4).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _animation,
      child: const CircleAvatar(
        backgroundColor: Colors.redAccent,
        radius: 5,
      ),
    );
  }
}
