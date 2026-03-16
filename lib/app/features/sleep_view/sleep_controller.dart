import 'package:get/get.dart';
import 'package:muslimdaily/app/core/widgets/AudioManager.dart';
import 'package:muslimdaily/app/core/utils/style/k_helper.dart';
import 'package:just_audio/just_audio.dart';

class SleepController extends GetxController {
  static const String sleepUrl = 'https://cdn.jsdelivr.net/gh/TaherSalah/azkarAudio@main/sleep.mp3';
  static const String sleepKey = 'sleep_audio_path';
  static const String fileName = 'azkar_sleep.mp3';
  static const String performerName = 'مشاري العفاسي';
  static const String performerImageAsset = 'assets/images/affasy.png';

  final AudioManager audioManager = AudioManager();

  final RxBool _isPlaying = false.obs;
  final RxBool _isDownloading = false.obs;
  final RxBool _isDownloaded = false.obs;
  final RxBool _isBuffering = false.obs;

  final RxBool _showMiniPlayer = false.obs;
  final RxBool _showFullPlayer = false.obs;

  final Rx<Duration> _position = Duration.zero.obs;
  final Rx<Duration> _duration = Duration.zero.obs;

  bool get isPlaying => _isPlaying.value;
  bool get isDownloading => _isDownloading.value;
  bool get isDownloaded => _isDownloaded.value;
  bool get isBuffering => _isBuffering.value;
  bool get showMiniPlayer => _showMiniPlayer.value;
  bool get showFullPlayer => _showFullPlayer.value;
  Duration get position => _position.value;
  Duration get duration => _duration.value;

  @override
  void onInit() {
    super.onInit();
    _initAudio();
  }

  Future<void> _initAudio() async {
    audioManager.initialize();

    final savedPath = await audioManager.getSavedAudioPath(sleepKey);
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
      final processingState = state.processingState;
      _isPlaying.value = audioManager.isPlaying;
      _isBuffering.value = processingState == ProcessingState.loading || processingState == ProcessingState.buffering;

      if (processingState == ProcessingState.completed) {
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
        url: sleepUrl,
        localPath: isDownloaded ? audioManager.currentLocalPath : null,
        sharedPrefsKey: sleepKey,
      );
    } catch (_) {
      KHelper.showError(message: 'حدث خطأ أثناء تشغيل الصوت.');
    }
  }

  Future<void> downloadAudio() async {
    if (isDownloading) return;

    final hasNet = await audioManager.hasConnection();
    if (!hasNet) {
      KHelper.showError(message: 'لا يوجد اتصال بالإنترنت، لا يمكن التحميل الآن.');
      return;
    }

    _isDownloading.value = true;

    try {
      await audioManager.downloadAudio(
        url: sleepUrl,
        fileName: fileName,
        sharedPrefsKey: sleepKey,
      );

      _isDownloaded.value = true;
      KHelper.showSuccess(message: 'تم تحميل أذكار النوم، يمكن تشغيلها بدون إنترنت.');
    } catch (e) {
      KHelper.showError(message: e.toString());
    } finally {
      _isDownloading.value = false;
    }
  }

  void toggleMiniPlayer(bool show) => _showMiniPlayer.value = show;
  void toggleFullPlayer(bool show) => _showFullPlayer.value = show;

  String formatDuration(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    final m = two(d.inMinutes.remainder(60));
    final s = two(d.inSeconds.remainder(60));
    return '$m:$s';
  }
}
