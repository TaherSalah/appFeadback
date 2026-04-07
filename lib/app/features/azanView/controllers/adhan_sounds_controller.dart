import 'dart:convert';
import 'dart:developer';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:just_audio/just_audio.dart';
import '../data/model/adhan_data.dart';
import '../helpers/adhan_audio_downloader.dart';

class AdhanSoundsController extends GetxController {
  static AdhanSoundsController get instance {
    try {
      return Get.find<AdhanSoundsController>();
    } catch (_) {
      return Get.put(AdhanSoundsController._());
    }
  }

  AdhanSoundsController._();

  List<AdhanData> adhanList = [];
  bool isLoading = true;
  int selectedIndex = 0;

  // Audio Player state
  final AudioPlayer audioPlayer = AudioPlayer();
  int? currentlyPlayingIndex;

  // Download state
  int downloadIndex = -1;
  bool isDownloading = false;
  double downloadProgress = 0.0;

  final AdhanAudioDownloader _downloader = AdhanAudioDownloader();

  @override
  void onInit() {
    super.onInit();
    _loadAdhanData();
  }

  Future<void> _loadAdhanData() async {
    isLoading = true;
    update();
    try {
      final jsonString =
          await rootBundle.loadString('assets/json/adhanSounds.json');
      final List<dynamic> jsonList = json.decode(jsonString);
      adhanList = jsonList.map((j) => AdhanData.fromJson(j)).toList();

      final prefs = await SharedPreferences.getInstance();
      selectedIndex = prefs.getInt('selected_adhan_index') ?? 0;
    } catch (e) {
      log('Error loading Adhan sounds: $e');
    }
    isLoading = false;
    update();
  }

  Future<void> selectAdhan(int index) async {
    if (isDownloading) return; // Prevent multiple downloads at once

    final prefs = await SharedPreferences.getInstance();

    // Check if it's already downloaded
    String? fajirPath =
        prefs.getString('$index${AdhanAudioDownloader.ADHAN_PATH_FAJIR_AUDIO}');
    String? audioPath =
        prefs.getString('$index${AdhanAudioDownloader.ADHAN_PATH_AUDIO}');

    if (fajirPath == null || audioPath == null) {
      // Need to download
      await _downloadAdhan(index);

      // Re-read after download
      fajirPath = prefs
          .getString('$index${AdhanAudioDownloader.ADHAN_PATH_FAJIR_AUDIO}');
      audioPath =
          prefs.getString('$index${AdhanAudioDownloader.ADHAN_PATH_AUDIO}');
    }

    // Set as selected
    selectedIndex = index;
    update();
    await prefs.setInt('selected_adhan_index', index);

    // Also save the file names for backwards compatibility if needed
    await prefs.setString(
        'selected_fajr_adhan', adhanList[index].adhanFileName);
    await prefs.setString(
        'selected_normal_adhan', adhanList[index].adhanFileName);

    // Specifically required by NotifyHelper to play custom local sounds
    if (audioPath != null) {
      await prefs.setString('adhan_path', 'file://$audioPath');
    }
    if (fajirPath != null) {
      await prefs.setString('adhan_path_fajir', 'file://$fajirPath');
    }

    log('Selected Adhan index: $index (Paths saved)');
  }

  Future<void> _downloadAdhan(int index) async {
    isDownloading = true;
    downloadIndex = index;
    downloadProgress = 0.0;
    update();

    try {
      await _downloader.downloadAndUnzipAdhan(
        adhanList[index],
        onReceiveProgress: (received, total) {
          if (total != -1) {
            downloadProgress = received / total;
            update();
          }
        },
      );
    } catch (e) {
      log('Error during download: $e');
    } finally {
      isDownloading = false;
      downloadIndex = -1;
      downloadProgress = 0.0;
      update();
    }
  }

  Future<void> togglePlay(int index) async {
    if (currentlyPlayingIndex == index && audioPlayer.playing) {
      await audioPlayer.pause();
      currentlyPlayingIndex = null;
      update();
    } else {
      try {
        await audioPlayer.stop();
        currentlyPlayingIndex = index;
        update();

        final prefs = await SharedPreferences.getInstance();
        final fajirPath = prefs
            .getString('$index${AdhanAudioDownloader.ADHAN_PATH_FAJIR_AUDIO}');

        if (fajirPath != null) {
          // Play local downloaded file
          await audioPlayer.setFilePath(fajirPath);
        } else {
          // Play from URL for preview
          await audioPlayer.setUrl(adhanList[index].urlPlayAdhan);
        }
        await audioPlayer.play();

        // Listen to completion
        audioPlayer.playerStateStream.listen((state) {
          if (state.processingState == ProcessingState.completed) {
            currentlyPlayingIndex = null;
            update();
          }
        });
      } catch (e) {
        log('Error playing audio: $e');
        currentlyPlayingIndex = null;
        update();
      }
    }
  }

  @override
  void onClose() {
    audioPlayer.dispose();
    super.onClose();
  }
}
