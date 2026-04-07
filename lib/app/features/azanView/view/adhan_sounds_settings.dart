import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:just_audio/just_audio.dart';
import 'package:muslimdaily/app/core/extensions/context_extension.dart';
import 'package:get/get.dart';

import '../controllers/adhan_sounds_controller.dart';

class AdhanSoundsSettingsScreen extends StatefulWidget {
  const AdhanSoundsSettingsScreen({super.key});

  @override
  State<StatefulWidget> createState() => _AdhanSoundsSettingsScreenState();
}

class _AdhanSoundsSettingsScreenState
    extends State<AdhanSoundsSettingsScreen> {
  final AdhanSoundsController _con = AdhanSoundsController.instance;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

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
      body: GetBuilder<AdhanSoundsController>(
        builder: (con) {
          return con.isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  itemCount: con.adhanList.length,
                  itemBuilder: (context, index) {
                    final adhan = con.adhanList[index];
                    final isSelected = con.selectedIndex == index;
                    final isDownloadingThis =
                        con.isDownloading && con.downloadIndex == index;

                    return GestureDetector(
                      onTap: () => con.selectAdhan(index),
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isDark
                              ? (isSelected
                                  ? Colors.teal.shade900
                                  : Colors.black26)
                              : (isSelected
                                  ? Colors.green.shade50
                                  : Colors.white),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color:
                                isSelected ? Colors.green : Colors.grey.shade300,
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
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
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
                                    value: con.downloadProgress,
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
                                stream: con.audioPlayer.playerStateStream,
                                builder: (context, snapshot) {
                                  final playerState = snapshot.data;
                                  final isCurrentlyPlaying =
                                      con.currentlyPlayingIndex == index;
                                  final isPlaying =
                                      playerState?.playing ?? false;
                                  final isBuffering =
                                      playerState?.processingState ==
                                          ProcessingState.buffering;

                                  if (isCurrentlyPlaying && isBuffering) {
                                    return const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2),
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
                                    onPressed: () => con.togglePlay(index),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
        },
      ),
    );
  }
}
