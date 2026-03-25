import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import '../controllers/adhan_sounds_controller.dart';
import 'package:just_audio/just_audio.dart';

class AdhanSoundsSettingsScreen extends StatefulWidget {
  const AdhanSoundsSettingsScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AdhanSoundsSettingsScreenState();
}

class _AdhanSoundsSettingsScreenState
    extends StateMVC<AdhanSoundsSettingsScreen> {
  late AdhanSoundsController _con;

  _AdhanSoundsSettingsScreenState() : super(AdhanSoundsController()) {
    _con = controller as AdhanSoundsController;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "أصوات الأذان",
          style: TextStyle(
                  fontFamily: "cairo",
            color: Colors.green,
            fontWeight: FontWeight.bold,
            fontSize: 18.sp,
          ),
        ),
        centerTitle: true,
      ),
      body: _con.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 16),
              itemCount: _con.adhanList.length,
              itemBuilder: (context, index) {
                final adhan = _con.adhanList[index];
                final isSelected = _con.selectedIndex == index;
                final isDownloadingThis =
                    _con.isDownloading && _con.downloadIndex == index;

                return GestureDetector(
                  onTap: () => _con.selectAdhan(index),
                  child: Container(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isDark
                          ? (isSelected ? Colors.teal.shade900 : Colors.black26)
                          : (isSelected ? Colors.green.shade50 : Colors.white),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? Colors.green : Colors.grey.shade300,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      title: Text(
                        adhan.adhanName, // In a real app, translate this
                        style: TextStyle(
                  fontFamily: "cairo",
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 16.sp,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isDownloadingThis)
                            SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                value: _con.downloadProgress,
                                strokeWidth: 3,
                                color: Colors.green,
                              ),
                            )
                          else if (isSelected)
                            const Icon(Icons.check_circle,
                                color: Colors.green, size: 28),
                          const SizedBox(width: 8),
                          // Play Button
                          StreamBuilder<PlayerState>(
                            stream: _con.audioPlayer.playerStateStream,
                            builder: (context, snapshot) {
                              final playerState = snapshot.data;
                              final isCurrentlyPlaying =
                                  _con.currentlyPlayingIndex == index;
                              final isPlaying = playerState?.playing ?? false;
                              final isBuffering =
                                  playerState?.processingState ==
                                      ProcessingState.buffering;

                              if (isCurrentlyPlaying && isBuffering) {
                                return const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                );
                              }

                              return IconButton(
                                icon: Icon(
                                  (isCurrentlyPlaying && isPlaying)
                                      ? Icons.pause_circle_filled
                                      : Icons.play_circle_fill,
                                  color: Colors.green.shade700,
                                  size: 32,
                                ),
                                onPressed: () => _con.togglePlay(index),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
