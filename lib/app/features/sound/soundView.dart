


// class SoundView extends StatelessWidget {
//   const SoundView({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//        // backgroundColor: AppColors.pinkVeryLight,
//         body: SafeArea(
//           child: MusicPlayer(),
//         ));
//   }
// }
//
// // class MusicPlayer extends StatefulWidget {
// //   @override
// //   _MusicPlayerState createState() => _MusicPlayerState();
// // }
// //
// // class _MusicPlayerState extends State<MusicPlayer> {
// //   final AudioPlayer _audioPlayer = AudioPlayer();
// //   bool _isPlaying = false;
// //   int currentSong = 0;
// //   List songs = [
// //     "audio/atmosphere-sound-effect-239969.mp3",
// //     "audio/rain-on-tent-22785.mp3",
// //     "audio/white-noise-179828.mp3",
// //   ];
// //   String actorImageUrl =
// //       'assets/images/Illustration@2x.png'; // Replace with actual image URL
// //   Duration _currentPosition = Duration.zero;
// //   Duration _totalDuration = Duration(seconds: 1); // Prevent division by zero
// //   @override
// //   void initState() {
// //     super.initState();
// //     // Listening to the duration change (total length of the audio)
// //     _audioPlayer.onDurationChanged.listen((duration) {
// //       setState(() {
// //         _totalDuration = duration;
// //       });
// //     });
// //     // Listening to the position change (current position of the audio)
// //     _audioPlayer.onPositionChanged.listen((position) {
// //       setState(() {
// //         _currentPosition = position;
// //       });
// //     });
// //   }
// //
// //   @override
// //   void dispose() {
// //     _audioPlayer.dispose();
// //     super.dispose();
// //   }
// //
// //   Future<void> _togglePlayPause() async {
// //     if (_isPlaying) {
// //       await _audioPlayer.pause();
// //     } else {
// //       await _audioPlayer.play(AssetSource(songs[currentSong]));
// //     }
// //
// //     setState(() {
// //       _isPlaying = !_isPlaying;
// //     });
// //   }
// //
// //   void _nextSong() async {
// //     await _audioPlayer.stop();
// //
// //     setState(() {
// //       currentSong = (currentSong + 1) % songs.length;
// //     });
// //
// //     await _audioPlayer.play(AssetSource(songs[currentSong]));
// //     setState(() {
// //       _isPlaying = true;
// //     });
// //   }
// //
// //   void _prevSong() async {
// //     await _audioPlayer.stop();
// //
// //     setState(() {
// //       currentSong = (currentSong - 1 + songs.length) % songs.length;
// //     });
// //
// //     await _audioPlayer.play(AssetSource(songs[currentSong]));
// //     setState(() {
// //       _isPlaying = true;
// //     });
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     double progress = (_currentPosition.inSeconds.toDouble() /
// //         (_totalDuration.inSeconds.toDouble() == 0
// //             ? 1
// //             : _totalDuration.inSeconds.toDouble()));
// //     return Padding(
// //       padding: const EdgeInsets.symmetric(horizontal: 18),
// //       child: SingleChildScrollView(
// //         child: Column(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             // Row(
// //             //   children: [
// //             //     IconButton(
// //             //         padding: EdgeInsets.zero,
// //             //         onPressed: () {},
// //             //         icon: Image.asset("assets/images/Down Arrow.png")),
// //             //     Spacer(),
// //             //     IconButton(
// //             //         padding: EdgeInsets.zero,
// //             //         onPressed: () {},
// //             //         icon: Image.asset("assets/images/playlist.png")),
// //             //   ],
// //             // ),
// //             Padding(
// //               padding: EdgeInsets.symmetric(vertical: 15.h, horizontal: 5),
// //               child: TextDefaultWidget(
// //                 title: "Calming  Playlist",
// //                 color: Colors.black,
// //                 fontWeight: FontWeight.w600,
// //                 fontSize: 22.sp,
// //               ),
// //             ),
// //             SizedBox(height: 25.h),
// //             Padding(
// //               padding: EdgeInsets.symmetric(horizontal: 25.w),
// //               child: Image.asset(
// //                 actorImageUrl,
// //                 height: 300,
// //               ),
// //             ),
// //             SizedBox(height: 60.h),
// //             Row(
// //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //               crossAxisAlignment: CrossAxisAlignment.center,
// //               children: [
// //                 IconButton(
// //                   icon: Image.asset("assets/images/rep.png"),
// //                   onPressed: () {
// //                     // You can add skip functionality here
// //                   },
// //                 ),
// //                 IconButton(
// //                   icon: Icon(
// //                     Icons.skip_previous,
// //                     color: Color(0xffEF5DA8),
// //                   ),
// //                   onPressed: () {
// //                     _prevSong();
// //                     setState(() {});
// //                   },
// //                 ),
// //                 Center(
// //                   child: GestureDetector(
// //                     onTap: _togglePlayPause,
// //                     child: Stack(
// //                       alignment: Alignment.center,
// //                       children: [
// //                         // الشريط الخارجي الذي يتحرك مع تشغيل الموسيقى
// //                         SizedBox(
// //                           width: 80,
// //                           height: 80,
// //                           child: CircularProgressIndicator(
// //                             value: progress, // تقدم التشغيل
// //                             strokeWidth: 6,
// //                             backgroundColor: Colors.pink.withOpacity(0.2),
// //                             valueColor:
// //                                 AlwaysStoppedAnimation<Color>(Colors.pink),
// //                           ),
// //                         ),
// //                         // زر التشغيل/الإيقاف المؤقت في المنتصف
// //                         Container(
// //                           width: 70,
// //                           height: 70,
// //                           decoration: BoxDecoration(
// //                             shape: BoxShape.circle,
// //                             color: Colors.pink.withOpacity(0.2),
// //                           ),
// //                           child: Icon(
// //                             _isPlaying ? Icons.pause : Icons.play_arrow,
// //                             color: Colors.pink,
// //                             size: 40,
// //                           ),
// //                         ),
// //                       ],
// //                     ),
// //                   ),
// //                 ),
// //                 IconButton(
// //                   icon: Icon(
// //                     Icons.skip_next,
// //                     color: Color(0xffEF5DA8),
// //                   ),
// //                   onPressed: () {
// //                     _nextSong();
// //                     setState(() {});
// //                     // You can add skip functionality here
// //                   },
// //                 ),
// //                 IconButton(
// //                   icon: Image.asset("assets/images/Group.png"),
// //                   onPressed: () {
// //                     // You can add skip functionality here
// //                   },
// //                 ),
// //               ],
// //             ),
// //
// //             // Progress bar
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }
//
//
//
// class MusicPlayer extends StatefulWidget {
//   @override
//   _MusicPlayerState createState() => _MusicPlayerState();
// }
//
// class _MusicPlayerState extends State<MusicPlayer> {
//   final AudioPlayer _audioPlayer = AudioPlayer();
//   bool _isPlaying = false;
//   bool _isRepeat = false;
//   double _volume = 1.0;
//   int currentSong = 0;
//
//   List songs = [
//     "audio/atmosphere-sound-effect-239969.mp3",
//     "audio/rain-on-tent-22785.mp3",
//     "audio/white-noise-179828.mp3",
//   ];
//
//   String actorImageUrl = 'assets/images/Illustration@2x.png';
//
//   Duration _currentPosition = Duration.zero;
//   Duration _totalDuration = Duration(seconds: 1);
//
//   @override
//   void initState() {
//     super.initState();
//
//     _audioPlayer.onDurationChanged.listen((duration) {
//       setState(() {
//         _totalDuration = duration;
//       });
//     });
//
//     _audioPlayer.onPositionChanged.listen((position) {
//       setState(() {
//         _currentPosition = position;
//       });
//     });
//
//     _audioPlayer.onPlayerComplete.listen((event) {
//       if (_isRepeat) {
//         _audioPlayer.seek(Duration.zero);
//         _audioPlayer.resume();
//       } else {
//         _nextSong();
//       }
//     });
//
//     _audioPlayer.setVolume(_volume);
//   }
//
//   @override
//   void dispose() {
//     _audioPlayer.dispose();
//     super.dispose();
//   }
//
//   Future<void> _togglePlayPause() async {
//     if (_isPlaying) {
//       await _audioPlayer.pause();
//     } else {
//       await _audioPlayer.play(AssetSource(songs[currentSong]));
//     }
//
//     setState(() {
//       _isPlaying = !_isPlaying;
//     });
//   }
//
//   void _nextSong() async {
//     await _audioPlayer.stop();
//     setState(() {
//       currentSong = (currentSong + 1) % songs.length;
//     });
//     await _audioPlayer.play(AssetSource(songs[currentSong]));
//     setState(() {
//       _isPlaying = true;
//     });
//   }
//
//   void _prevSong() async {
//     await _audioPlayer.stop();
//     setState(() {
//       currentSong = (currentSong - 1 + songs.length) % songs.length;
//     });
//     await _audioPlayer.play(AssetSource(songs[currentSong]));
//     setState(() {
//       _isPlaying = true;
//     });
//   }
//
//   String _formatDuration(Duration duration) {
//     String twoDigits(int n) => n.toString().padLeft(2, '0');
//     return "${twoDigits(duration.inMinutes)}:${twoDigits(duration.inSeconds.remainder(60))}";
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     double progress = (_currentPosition.inSeconds.toDouble() /
//         (_totalDuration.inSeconds.toDouble() == 0
//             ? 1
//             : _totalDuration.inSeconds.toDouble()));
//
//     String currentSongName = songs[currentSong].split("/").last;
//
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 18),
//       child: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             SizedBox(height: 25),
//             Padding(
//               padding: EdgeInsets.symmetric(vertical: 15, horizontal: 5),
//               child: Text(
//                 "Calming Playlist",
//                 style: TextStyle(
//                   color: Colors.black,
//                   fontWeight: FontWeight.w600,
//                   fontSize: 22,
//                 ),
//               ),
//             ),
//             SizedBox(height: 10),
//
//             /// اسم الأغنية
//             Center(
//               child: Text(
//                 currentSongName,
//                 style: TextStyle(
//                   fontSize: 16,
//                   color: Colors.pink.shade400,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ),
//
//             SizedBox(height: 25),
//             Padding(
//               padding: EdgeInsets.symmetric(horizontal: 25),
//               child: Image.asset(
//                 actorImageUrl,
//                 height: 300,
//               ),
//             ),
//
//             SizedBox(height: 40),
//
//             /// التوقيت الدائري مع الوقت
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Text(_formatDuration(_currentPosition)),
//                 SizedBox(width: 10),
//                 Stack(
//                   alignment: Alignment.center,
//                   children: [
//                     SizedBox(
//                       width: 80,
//                       height: 80,
//                       child: CircularProgressIndicator(
//                         value: progress,
//                         strokeWidth: 6,
//                         backgroundColor: Colors.pink.withOpacity(0.2),
//                         valueColor: AlwaysStoppedAnimation<Color>(Colors.pink),
//                       ),
//                     ),
//                     Container(
//                       width: 70,
//                       height: 70,
//                       decoration: BoxDecoration(
//                         shape: BoxShape.circle,
//                         color: Colors.pink.withOpacity(0.2),
//                       ),
//                       child: IconButton(
//                         icon: Icon(
//                           _isPlaying ? Icons.pause : Icons.play_arrow,
//                           color: Colors.pink,
//                           size: 40,
//                         ),
//                         onPressed: _togglePlayPause,
//                       ),
//                     ),
//                   ],
//                 ),
//                 SizedBox(width: 10),
//                 Text(_formatDuration(_totalDuration)),
//               ],
//             ),
//
//             SizedBox(height: 30),
//
//             /// أزرار التحكم
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 IconButton(
//                   icon: Icon(Icons.replay_10, color: Colors.pink, size: 30),
//                   onPressed: () {
//                     final newPos = _currentPosition - Duration(seconds: 10);
//                     _audioPlayer.seek(newPos > Duration.zero ? newPos : Duration.zero);
//                   },
//                 ),
//                 IconButton(
//                   icon: Icon(Icons.skip_previous, color: Colors.pink, size: 30),
//                   onPressed: _prevSong,
//                 ),
//                 IconButton(
//                   icon: Icon(Icons.skip_next, color: Colors.pink, size: 30),
//                   onPressed: _nextSong,
//                 ),
//                 IconButton(
//                   icon: Icon(Icons.forward_10, color: Colors.pink, size: 30),
//                   onPressed: () {
//                     final newPos = _currentPosition + Duration(seconds: 10);
//                     if (newPos < _totalDuration) {
//                       _audioPlayer.seek(newPos);
//                     }
//                   },
//                 ),
//               ],
//             ),
//
//             SizedBox(height: 20),
//
//             /// التحكم في الصوت
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
//               child: Row(
//                 children: [
//                   Icon(Icons.volume_down, color: Colors.black87, size: 28),
//                   Expanded(
//                     child: SliderTheme(
//                       data: SliderTheme.of(context).copyWith(
//                         activeTrackColor: Colors.pink,
//                         inactiveTrackColor: Colors.pink.shade100,
//                         thumbColor: Colors.pink,
//                         overlayColor: Colors.pink.withOpacity(0.2),
//                       ),
//                       child: Slider(
//                         value: _volume,
//                         onChanged: (value) {
//                           setState(() {
//                             _volume = value;
//                             _audioPlayer.setVolume(_volume);
//                           });
//                         },
//                         min: 0.0,
//                         max: 1.0,
//                       ),
//                     ),
//                   ),
//                   Icon(Icons.volume_up, color: Colors.black87, size: 28),
//                 ],
//               ),
//             ),
//
//             /// التكرار وإعادة التشغيل
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 IconButton(
//                   icon: Icon(
//                     Icons.repeat,
//                     color: _isRepeat ? Colors.pink : Colors.grey,
//                   ),
//                   onPressed: () {
//                     setState(() {
//                       _isRepeat = !_isRepeat;
//                     });
//                   },
//                 ),
//                 IconButton(
//                   icon: Icon(Icons.restart_alt, color: Colors.pink),
//                   onPressed: () {
//                     _audioPlayer.seek(Duration.zero);
//                   },
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
