
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:muslimdaily/app/core/cubit/centralized_cubit.dart';
import 'package:muslimdaily/app/core/shard/exports/all_exports.dart';
import 'package:muslimdaily/app/core/utils/style/responsive_util.dart';
import 'package:muslimdaily/app/core/widgets/custom_text_widget.dart';
import 'package:muslimdaily/app/features/radio/view/widget/QuranRadioItemBuilder.dart';
import 'package:muslimdaily/main.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import 'package:rxdart/rxdart.dart';

import '../../../core/widgets/NoConnectionScreen.dart';


class QuranChannalPlayerView extends StatefulWidget {
  const QuranChannalPlayerView({super.key});


  @override
  State<QuranChannalPlayerView> createState() => _QuranChannalPlayerViewState();
}

class _QuranChannalPlayerViewState extends State<QuranChannalPlayerView> {
  late CentralizedCubit centralizedCubit;

  @override
  void initState() {
    centralizedCubit = context.read<CentralizedCubit>();
    centralizedCubit.checkConnectivity();
    centralizedCubit.trackConnectivityChange();
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    // centralizedCubit.dispose();
  }
  @override
  Widget build(BuildContext context) {
    GlobalKey<ScaffoldState> scaffoldState = GlobalKey<ScaffoldState>();

    return BlocBuilder<CentralizedCubit, CentralizedState>(
      builder: (context, state) {
        return state is ConnectivityState &&
            state.status == ConnectivityStatus.disconnected
            ? const NoConnectionScreen():  PopScope(
          child: Directionality(
            textDirection:  TextDirection.rtl,
            child: Scaffold(
              // backgroundColor: AppStyle.bgColors,
              appBar: PreferredSize(
                preferredSize:
                Size.fromHeight(MediaQuery.sizeOf(context).width > 600 ? 80 : 50),
                child: AppBar(
                  leading: const CupertinoNavigationBarBackButton(
                    color: Colors.black,
                  ),
                  // actions: [
                  //   IconButton(
                  //     onPressed: () => Navigator.push(
                  //       context,
                  //       MaterialPageRoute(
                  //         builder: (context) => CreateKhatmahScreen(),
                  //       ),
                  //     ),
                  //     icon: const Icon(Icons.add),
                  //   )
                  // ],
                  centerTitle: true,
                  title: Text(
                    "اذاعة القران الكريم ",
                    style: GoogleFonts.cairo(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: MediaQuery.sizeOf(context).width > 600 ? 12.sp : 18.sp,
                    ),
                  ),
                ),
              ),

              key: scaffoldState,
              // appBar: AppBar(
              //     centerTitle: true,
              //     title: Padding(
              //       padding: const EdgeInsets.symmetric(horizontal: 15.0),
              //       child: Image.asset(
              //         AssetsManager.logo,
              //         height: 70.h,
              //         width: 70.w,
              //       ),
              //     ),
              //     leading: const SizedBox()),
              body:  SafeArea(child: QuranRadioPlayer(title:"widget.title",streamUrl: "https://win.holol.com/live/quran/playlist.m3u8",)),
            ),
          ),
        );
      },
    );
  }
}


class QuranRadioPlayer extends StatefulWidget {
  const QuranRadioPlayer({
    super.key,
    this.title = "إذاعة القرآن",
    this.streamUrl = "https://backup.qurango.net/radio/mohammad_alabdullah_albizi",
    this.accentColor,
    this.compact = false,
  });

  final String title;
  final String streamUrl;
  final Color? accentColor;
  final bool compact; // لو عايز نسخة صغيرة

  @override
  State<QuranRadioPlayer> createState() => _QuranRadioPlayerState();
}

class _QuranRadioPlayerState extends State<QuranRadioPlayer> {
  late final AudioPlayer _player;
  double _volume = 1.0;
  Timer? _retryTimer;

  Color get _accent => widget.accentColor ?? const Color(0xFF1B5E20);

  // نجمع حالة التشغيل + التحميل لعرضها في الواجهة
  Stream<PlayerState> get _playerStateStream => _player.playerStateStream;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();

    _setup();

    // Auto-retry لو حصل خطأ (انقطاع بث)
    _player.playerStateStream.listen((state) {
      final playing = state.playing;
      final processing = state.processingState;
      if (state.processingState == ProcessingState.idle ||
          state.processingState == ProcessingState.completed) {
        // تجاهل
        _cancelRetry();
      }

      if (state.processingState == ProcessingState.ready && playing) {
        _cancelRetry();
      }

      if (processing == ProcessingState.idle ||
          processing == ProcessingState.buffering) {
        _scheduleRetry();
      }
    });
  }

  Future<void> _setup() async {
    try {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.music());
      await _player.setUrl(widget.streamUrl); // ستريم مباشر (بدون seek)
      _player.setVolume(_volume);
    } catch (e) {
      _showSnack("تعذّر التحميل: $e");
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
        // لو فشل، جرّب تاني تلقائيًا
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
      // لو لسه مش جاهز، أعِد الضبط
      if (_player.processingState == ProcessingState.idle ||
          _player.processingState == ProcessingState.buffering) {
        try {
          await _player.setUrl(widget.streamUrl);
        } catch (e) {
          _showSnack("تعذّر إعادة التحميل: $e");
          return;
        }
      }
      await _player.play();
    }
  }

  Future<void> _stop() async {
    await _player.stop();
  }

  void _showSnack(String msg) {
    final ctx = context;
    if (!mounted) return;
    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(content: Text(msg)),
    );
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
    final cardPadding = widget.compact ? 12.0 : 16.0;
    final iconSize = widget.compact ? 34.0 : 44.0;

    return Padding(
      padding:  EdgeInsets.all(cardPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: _accent.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.radio, color: _accent),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextWidget(title:
                widget.title,
                
                  fontSize: widget.compact ? 8.sp : 14.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),

            ],
          ),
          const SizedBox(height: 12),

          Card(
            elevation: 6,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            // margin: const EdgeInsets.all(12),
            child: Padding(
              padding: EdgeInsets.all(0),
              child: StreamBuilder<PlayerState>(
                stream: _playerStateStream,
                builder: (context, snapshot) {
                  final state = snapshot.data ?? _player.playerState;
                  final isBuffering = state.processingState == ProcessingState.loading ||
                      state.processingState == ProcessingState.buffering;

                  return Column(
                    mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
                    children: [

                      Stack(
                        alignment: Alignment.topRight,
                        children: [

                          ClipRRect(

                              borderRadius:  BorderRadius.all(Radius.circular(20)),
                              child: Image.asset("assets/images/unnamed.jpg",width: MediaQuery.sizeOf(context).width,fit: BoxFit.contain,)),
                          Positioned(
                            top: 10,
                            left: 10,

                            child: Row(
                              children: [

                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Row(
                                    spacing: 10,
                                    children: [
                                      LiveIndicator(),
                                      TextWidget(title:
                                      _statusText(state),
                                        color: Colors.white,
                                        fontSize:ResponsiveUtil.isTablet(context)?8.sp: 12.sp,
                                        fontWeight: FontWeight.w600,

                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                        ],
                      ),
                      // Header

                      SizedBox(height: widget.compact ? 8 : 14),

                      // Controls
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // IconButton(
                          //   tooltip: 'إيقاف',
                          //   onPressed: _stop,
                          //   icon: const Icon(Icons.stop_rounded),
                          //   iconSize: iconSize - 8,
                          // ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _accent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: widget.compact ? 18 : 22,
                                vertical: widget.compact ? 8 : 10,
                              ),
                              elevation: 0,
                            ),
                            onPressed: isBuffering ? null : _togglePlay,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (isBuffering) ...[
                                  const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white),
                                  ),
                                  const SizedBox(width: 10),
                                   TextWidget(title:"جارٍ التحميل…",fontSize: ResponsiveUtil.isTablet(context)?8.sp: 14.sp,),
                                ] else ...[
                                  Icon(_player.playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                      color: Colors.white, size: iconSize),
                                  const SizedBox(width: 6),
                                  TextWidget(title:_player.playing ? "إيقاف مؤقت" : "تشغيل",color: Colors.white, fontWeight: FontWeight.w700,fontSize: ResponsiveUtil.isTablet(context)?8.sp: 14.sp)

                                ]
                              ],
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: widget.compact ? 8 : 12),

                      // Volume
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 15,horizontal: 10),
                        child: Row(
                          children: [
                            const Icon(Icons.volume_down_rounded),
                            Expanded(
                              child: Slider(
                                value: _volume,
                                min: 0,
                                max: 1,
                                onChanged: (v) {
                                  setState(() => _volume = v);
                                  _player.setVolume(v);
                                },
                                activeColor: _accent,
                              ),
                            ),
                            const Icon(Icons.volume_up_rounded),
                          ],
                        ),
                      ),

                      // Tiny hint
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 15,horizontal: 10),
                        child: Align(
                          alignment: Alignment.center,
                          child: TextWidget(title:
                            "بث مباشر – لا يدعم التقديم أو الترجيع",
                              fontSize: 12,
                              color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.8)
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
class LiveIndicator extends StatefulWidget {
  const LiveIndicator({super.key});

  @override
  State<LiveIndicator> createState() => _LiveIndicatorState();
}

class _LiveIndicatorState extends State<LiveIndicator>
    with SingleTickerProviderStateMixin {
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
      child: CircleAvatar(
        backgroundColor: Colors.redAccent,
        radius: 5,
      ),
    );
  }
}
