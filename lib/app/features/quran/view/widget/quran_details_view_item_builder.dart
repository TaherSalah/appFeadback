import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:just_audio/just_audio.dart' as ja; // تمت التسمية هنا
import 'package:muslimdaily/app/core/extensions/context_extension.dart';
import 'package:muslimdaily/app/core/utils/log.dart';

import '../../../../core/cubit/centralized_cubit.dart';
import '../../../../core/localization/localization_manager.dart';
import '../../../../core/utils/style/k_color.dart';
import '../../../../core/utils/style/k_helper.dart';
import '../../../../core/widgets/KLoading.dart';
import '../../../../core/widgets/custom_text_widget.dart';
import '../../../../core/widgets/head_title_item_builder.dart';
import '../../../hadithDetails/view/controller/hadith_details_state.dart';
import '../controller/hadith_details_bloc.dart';
import '../controller/quran_audio_state.dart';

class QuranDetailsViewItemBuilder extends StatelessWidget {
  const QuranDetailsViewItemBuilder({super.key, required this.recitersId, required this.index});
  final String recitersId;
  final dynamic index;
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<QuranAudioBloc, QuranAudioState>(
      builder: (BuildContext context, state) {
        if (state is QuranDetailsStateSuccess) {
          QuranAudioBloc bloc = QuranAudioBloc.get(context);
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: HeadTitleItemBuilder(
                          icon: Icons.menu_book_sharp,
                          fontSize: 10,
                          iconSize: 15,

                          // iconColor: KColors.yalloColor,
                          // titleColor: KColors.yalloColor,
                          headTitle: LocalizationManager.call("hadith-text"),
                          lineColor: KColors.scoColor),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              color: CentralizedCubit.isDarkMode
                                  ? KColors.blackColor
                                  : Theme.of(context).cardColor,
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(20.r),
                                  bottomLeft: Radius.circular(20.r)),
                              border: Border(
                                  right: BorderSide(
                                      color: KColors.primaryColor, width: 4))),
                          child: Column(
                            children: [
                              TextWidget(
                                  title: bloc.quranDetailsModal!.reciterName,
                                  height: 2,
                                  fontSize: context.isTab
                                      ? 8.sp
                                      : 11.5.sp)
                            ],
                          )),
                    ),
                  ],
                ),
              ),
              SliverToBoxAdapter(
                child: Expanded(child: MusicPlayer(quran:  bloc.quranDetailsModal!.audioUrls[index].audioUrl,)),
              )
            ],
          );
        } else if (state is HadithDetailsStateLoading) {
          return KLoading.progressIOSIndicator(context: context);
        } else if (state is HadithDetailsStateError) {
          return const TextWidget(title: 'erererererer');
        } else {
          return const TextWidget(title: 'eroor in state');
        }
      },
    );
  }
}


class MusicPlayer extends StatefulWidget {
  final String quran;

  const MusicPlayer({super.key, required this.quran});

  @override
  // ignore: library_private_types_in_public_api
  _MusicPlayerState createState() => _MusicPlayerState();
}

class _MusicPlayerState extends State<MusicPlayer> {
  final ja.AudioPlayer _audioPlayer = ja.AudioPlayer(); // استخدام ja. هنا
  bool _isPlaying = false;
  bool _isRepeating = false;
  double _volume = 1.0;
  Timer? _sleepTimer;
  int currentSongIndex = 0;

  String actorImageUrl = 'assets/images/logoApp.png';
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _initAudioPlayer();
  }

  Future<void> _initAudioPlayer() async {
    try {
      await _audioPlayer.setAudioSource(
        ja.AudioSource.uri(Uri.parse(widget.quran)), // شغل رابط واحد فقط
      );

      _audioPlayer.setVolume(_volume);

      _audioPlayer.playerStateStream.listen((state) {
        if (state.processingState == ja.ProcessingState.completed) {
          if (_isRepeating) {
            _audioPlayer.seek(Duration.zero);
            _audioPlayer.play();
          } else {
            _audioPlayer.pause(); // أو _audioPlayer.stop() إذا تريد الإيقاف الكامل
            setState(() => _isPlaying = false);
          }
        }
      });
    } catch (e) {
      log("Error initializing audio player: $e");
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _sleepTimer?.cancel();
    super.dispose();
  }

  Future<void> _togglePlayPause() async {
    _isPlaying ? await _audioPlayer.pause() : await _audioPlayer.play();
    setState(() => _isPlaying = !_isPlaying);
  }

  // Future<void> _nextSong() async {
  //   if (currentSongIndex < widget.quran.length - 1) {
  //     setState(() => currentSongIndex++);
  //     await _audioPlayer.seekToNext();
  //     await _audioPlayer.play();
  //     setState(() => _isPlaying = true);
  //   }
  // }
  //
  // Future<void> _prevSong() async {
  //   if (_audioPlayer.position.inSeconds > 3) {
  //     await _audioPlayer.seek(Duration.zero);
  //   } else if (currentSongIndex > 0) {
  //     setState(() => currentSongIndex--);
  //     await _audioPlayer.seekToPrevious();
  //     await _audioPlayer.play();
  //     setState(() => _isPlaying = true);
  //   }
  // }

  String _formatDuration(Duration? duration) {
    if (duration == null) return "--:--";
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return "${twoDigits(duration.inMinutes)}:${twoDigits(duration.inSeconds.remainder(60))}";
  }

  Stream<Duration> get _positionStream => _audioPlayer.positionStream;

  Stream<Duration?> get _durationStream => _audioPlayer.durationStream;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 25.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 25.w),
              child: Image.asset(actorImageUrl, height: 300),
            ),
            SizedBox(height: 40.h),

            StreamBuilder<Duration>(
              stream: _positionStream,
              builder: (context, positionSnapshot) {
                return StreamBuilder<Duration?>(
                  stream: _durationStream,
                  builder: (context, durationSnapshot) {
                    final duration = durationSnapshot.data ?? Duration.zero;
                    final position = positionSnapshot.data ?? Duration.zero;

                    double progressValue = duration.inSeconds > 0
                        ? position.inSeconds / duration.inSeconds
                        : 0.0;

                    return Column(
                      children: [
                        Slider(
                          min: 0.0,
                          max: duration.inSeconds.toDouble(),
                          value: position.inSeconds.toDouble().clamp(
                            0.0,
                            duration.inSeconds.toDouble(),
                          ),
                          activeColor: Colors.indigoAccent,
                          thumbColor: Colors.black,
                          onChanged: (value) {
                            setState(() => _isDragging = true);
                          },
                          onChangeEnd: (value) async {
                            await _audioPlayer.seek(Duration(seconds: value.toInt()));
                            setState(() => _isDragging = false);
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(_formatDuration(position)),
                              Text(_formatDuration(duration)),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),

            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.replay_10),
                    onPressed: () async {
                      final newPos = _audioPlayer.position - const Duration(seconds: 10);
                      await _audioPlayer.seek(newPos > Duration.zero ? newPos : Duration.zero);
                    },
                  ),
                  // IconButton(
                  //   icon: Icon(Icons.skip_previous, color: Color(0xffEF5DA8)),
                  //   onPressed: _prevSong,
                  // ),
                  StreamBuilder<ja.PlayerState>(
                    stream: _audioPlayer.playerStateStream,
                    builder: (context, snapshot) {
                      final playerState = snapshot.data;
                      final processingState = playerState?.processingState;
                      final playing = playerState?.playing;

                      return GestureDetector(
                        onTap: _togglePlayPause,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 80,
                              height: 80,
                              child: CircularProgressIndicator(
                                value: processingState == ja.ProcessingState.loading
                                    ? null
                                    : _audioPlayer.duration == null
                                    ? 0.0
                                    : _audioPlayer.position.inSeconds / _audioPlayer.duration!.inSeconds,
                                strokeWidth: 6,
                                backgroundColor: Colors.pink.withOpacity(0.2),
                                valueColor: const AlwaysStoppedAnimation<Color>(Colors.pink),
                              ),
                            ),
                            Container(
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.pink.withOpacity(0.2),
                              ),
                              child: Icon(
                                playing == true ? Icons.pause : Icons.play_arrow,
                                color: Colors.pink,
                                size: 40,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  // IconButton(
                  //   icon: Icon(Icons.skip_next, color: Color(0xffEF5DA8)),
                  //   onPressed: _nextSong,
                  // ),
                  IconButton(
                    icon: const Icon(Icons.forward_10),
                    onPressed: () async {
                      final newPos = _audioPlayer.position + const Duration(seconds: 10);
                      if (_audioPlayer.duration != null && newPos < _audioPlayer.duration!) {
                        await _audioPlayer.seek(newPos);
                      }
                    },
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.volume_down),
                      Expanded(
                        child: Slider(
                          min: 0.0,
                          max: 1.0,
                          value: _volume,
                          onChanged: (value) {
                            setState(() => _volume = value);
                            _audioPlayer.setVolume(value);
                          },
                        ),
                      ),
                      const Icon(Icons.volume_up),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: Icon(
                          _isRepeating ? Icons.repeat_one : Icons.repeat,
                          color: _isRepeating ? Colors.pink : Colors.grey,
                        ),
                        onPressed: () {
                          setState(() => _isRepeating = !_isRepeating);
                          _audioPlayer.setLoopMode(
                              _isRepeating ? ja.LoopMode.one : ja.LoopMode.off
                          );
                        },
                      ),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.timer),
                        label: const Text("مؤقت النوم"),
                        onPressed: _setSleepTimer,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _setSleepTimer() {
    _sleepTimer?.cancel();
    _sleepTimer = Timer(const Duration(minutes: 10), () async {
      await _audioPlayer.pause();
      if (mounted) setState(() {});
    });
    KHelper.showSuccess(message: 'سيتم إيقاف الصوت بعد 10 دقائق');

  }
}
