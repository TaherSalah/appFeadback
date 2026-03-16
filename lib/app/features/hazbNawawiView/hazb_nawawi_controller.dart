import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:muslimdaily/app/core/utils/style/k_helper.dart';
import '../../core/widgets/AudioManager.dart';

class HazbNawawiController extends GetxController {
  // ================== إعدادات الصوت ==================
  static const String hazbUrl =
      'https://cdn.jsdelivr.net/gh/TaherSalah/azkarAudio@main/حزب%20الإمام%20النووي(MP3_160K).mp3';
  static const String hazbKey = 'hazb_audio_path';
  static const String fileName = 'hazb.mp3';

  final AudioManager audioManager = AudioManager();

  final _isPlaying = false.obs;
  bool get isPlaying => _isPlaying.value;

  final _isDownloading = false.obs;
  bool get isDownloading => _isDownloading.value;

  final _isDownloaded = false.obs;
  bool get isDownloaded => _isDownloaded.value;

  final _isBuffering = false.obs;
  bool get isBuffering => _isBuffering.value;

  final _showMiniPlayer = false.obs;
  bool get showMiniPlayer => _showMiniPlayer.value;
  set showMiniPlayer(bool val) => _showMiniPlayer.value = val;

  final _showFullPlayer = false.obs;
  bool get showFullPlayer => _showFullPlayer.value;
  set showFullPlayer(bool val) => _showFullPlayer.value = val;

  final _position = Duration.zero.obs;
  Duration get position => _position.value;

  final _duration = Duration.zero.obs;
  Duration get duration => _duration.value;

  static const String performerName = '';
  static const String performerImageAsset =
      'assets/images/natural-view-night_1112329-37092.jpg';

  @override
  void onInit() {
    super.onInit();
    _initAudio();
  }

  Future<void> _initAudio() async {
    audioManager.initialize();

    final savedPath = await audioManager.getSavedAudioPath(hazbKey);
    if (savedPath != null) {
      _isDownloaded.value = true;
    }

    audioManager.positionStream.listen((pos) {
      _position.value = pos;
    });

    audioManager.durationStream.listen((dur) {
      _duration.value = dur ?? Duration.zero;
    });

    audioManager.playerStateStream.listen((state) {
      final processing = state.processingState;
      final playingNow = audioManager.isPlaying;

      _isPlaying.value = playingNow;

      if (processing == ProcessingState.completed) {
        _showFullPlayer.value = false;
        _showMiniPlayer.value = false;
      }
    });

    audioManager.bufferingStream.listen((b) {
      _isBuffering.value = b;
    });
  }

  Future<void> playOrPause() async {
    try {
      await audioManager.playOrPause(
        url: hazbUrl,
        localPath: isDownloaded ? audioManager.currentLocalPath : null,
        sharedPrefsKey: hazbKey,
      );
    } catch (_) {
      KHelper.showError(message: 'حدث خطأ أثناء تشغيل الصوت.');
    }
  }

  Future<void> downloadAudio() async {
    if (isDownloading) return;

    final hasNet = await audioManager.hasConnection();
    if (!hasNet) {
      KHelper.showSuccess(
          message: 'لا يوجد اتصال بالإنترنت، لا يمكن التحميل الآن.');
      return;
    }

    _isDownloading.value = true;

    try {
      await audioManager.downloadAudio(
        url: hazbUrl,
        fileName: fileName,
        sharedPrefsKey: hazbKey,
      );

      _isDownloaded.value = true;

      KHelper.showSuccess(
          message: 'تم تحميل حزب الإمام النووي، يمكن تشغيلها بدون إنترنت.');
    } catch (e) {
      KHelper.showError(message: e.toString());
    } finally {
      _isDownloading.value = false;
    }
  }

  String formatDuration(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    final m = two(d.inMinutes.remainder(60));
    final s = two(d.inSeconds.remainder(60));
    return '$m:$s';
  }

  void toggleFullPlayer(bool show) {
    _showFullPlayer.value = show;
  }

  void toggleMiniPlayer(bool show) {
    _showMiniPlayer.value = show;
  }
}
