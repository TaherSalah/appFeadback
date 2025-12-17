import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// class AudioManager {
//   static final AudioManager _instance = AudioManager._internal();
//   factory AudioManager() => _instance;
//   AudioManager._internal();
//
//   final AudioPlayer _player = AudioPlayer();
//
//   // الـ Streams للاستماع من الخارج
//   Stream<Duration> get positionStream => _player.positionStream;
//   Stream<Duration?> get durationStream => _player.durationStream;
//   Stream<PlayerState> get playerStateStream => _player.playerStateStream;
//
//   // المتغيرات الداخلية
//   Duration _position = Duration.zero;
//   Duration _duration = Duration.zero;
//   bool _isPlaying = false;
//   String? _currentUrl;
//   String? _currentLocalPath;
//
//   // الـ Getters للوصول من الخارج
//   Duration get position => _position;
//   Duration get duration => _duration;
//   bool get isPlaying => _isPlaying;
//   String? get currentLocalPath => _currentLocalPath;
//
//   // الـ Subscriptions
//   StreamSubscription<Duration>? _positionSub;
//   StreamSubscription<Duration?>? _durationSub;
//   StreamSubscription<PlayerState>? _playerStateSub;
//
//   // تهيئة الـ Manager
//   void initialize() {
//     _positionSub = _player.positionStream.listen((pos) {
//       _position = pos;
//     });
//
//     _durationSub = _player.durationStream.listen((dur) {
//       _duration = dur ?? Duration.zero;
//     });
//
//     _playerStateSub = _player.playerStateStream.listen((state) {
//       _isPlaying = state.playing && state.processingState != ProcessingState.completed;
//
//       if (state.processingState == ProcessingState.completed) {
//         _position = Duration.zero;
//         _player.seek(Duration.zero);
//         _player.pause();
//       }
//     });
//   }
//
//   // تشغيل أو إيقاف مؤقت
//   Future<void> playOrPause({
//     required String url,
//     String? localPath,
//     String? sharedPrefsKey,
//   }) async {
//     try {
//       // إذا كان مشغلاً بالفعل → إيقاف مؤقت
//       if (_isPlaying) {
//         await _player.pause();
//         return;
//       }
//
//       // إذا كان متوقفاً وكان هناك تقدم سابق → استئناف
//       if (_position > Duration.zero && !_isPlaying && _currentUrl == url) {
//         await _player.seek(_position);
//         await _player.play();
//         return;
//       }
//
//       // تحميل ملف جديد
//       _currentUrl = url;
//       _currentLocalPath = localPath;
//
//       if (localPath != null && File(localPath).existsSync()) {
//         await _player.setFilePath(localPath);
//       } else {
//         await _player.setUrl(url);
//       }
//
//       await _player.play();
//     } catch (e) {
//       throw Exception('حدث خطأ أثناء تشغيل الصوت: $e');
//     }
//   }
//
//   // تحميل الملف للتشغيل أوفلاين
//   Future<String> downloadAudio({
//     required String url,
//     required String fileName,
//     required String sharedPrefsKey,
//   }) async {
//     try {
//       final uri = Uri.parse(url);
//       final response = await http.get(uri).timeout(const Duration(seconds: 40));
//
//       if (response.statusCode != 200) {
//         throw Exception('فشل تحميل الملف الصوتي (كود ${response.statusCode})');
//       }
//
//       final dir = await getApplicationDocumentsDirectory();
//       final file = File('${dir.path}/$fileName');
//       await file.writeAsBytes(response.bodyBytes);
//
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.setString(sharedPrefsKey, file.path);
//
//       _currentLocalPath = file.path;
//       return file.path;
//     } on TimeoutException {
//       throw Exception('انتهت مهلة الاتصال أثناء التحميل');
//     } catch (e) {
//       throw Exception('حدث خطأ أثناء تحميل الصوت: $e');
//     }
//   }
//
//   // الانتقال إلى وقت معين
//   Future<void> seek(Duration position) async {
//     await _player.seek(position);
//     _position = position;
//   }
//
//   // إعادة التشغيل من البداية
//   Future<void> restart() async {
//     await _player.seek(Duration.zero);
//     _position = Duration.zero;
//     if (!_isPlaying) {
//       await _player.play();
//     }
//   }
//
//   // إيقاف كامل وإعادة التعيين
//   Future<void> stop() async {
//     await _player.stop();
//     _position = Duration.zero;
//     _currentUrl = null;
//     _currentLocalPath = null;
//   }
//
//   // التحقق من وجود اتصال بالإنترنت
//   Future<bool> hasConnection() async {
//     final result = await Connectivity().checkConnectivity();
//     return result != ConnectivityResult.none;
//   }
//
//   // استرجاع المسار المحفوظ
//   Future<String?> getSavedAudioPath(String sharedPrefsKey) async {
//     final prefs = await SharedPreferences.getInstance();
//     final savedPath = prefs.getString(sharedPrefsKey);
//     if (savedPath != null && File(savedPath).existsSync()) {
//       _currentLocalPath = savedPath;
//       return savedPath;
//     }
//     return null;
//   }
//
//   // التدمير والتنظيف
//   void dispose() {
//     _positionSub?.cancel();
//     _durationSub?.cancel();
//     _playerStateSub?.cancel();
//     _player.dispose();
//   }
// }

class AudioManager {
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;
  AudioManager._internal();

  final AudioPlayer _player = AudioPlayer();

  // ================= Streams =================
  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;
  Stream<PlayerState> get playerStateStream => _player.playerStateStream;

  /// Stream جاهز للـ buffering
  Stream<bool> get bufferingStream => _player.playerStateStream
      .map((state) =>
          state.processingState == ProcessingState.loading ||
          state.processingState == ProcessingState.buffering)
      .distinct();

  // ================= Internal state =================
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _isPlaying = false;

  /// جديد: حالة التحميل/البفر
  bool _isBuffering = false;

  String? _currentUrl;
  String? _currentLocalPath;

  // ================= Getters =================
  Duration get position => _position;
  Duration get duration => _duration;
  bool get isPlaying => _isPlaying;

  /// جديد: getter خارجي
  bool get isBuffering => _isBuffering;

  String? get currentLocalPath => _currentLocalPath;

  // ================= Subscriptions =================
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<Duration?>? _durationSub;
  StreamSubscription<PlayerState>? _playerStateSub;

  bool _initialized = false;

  // ================= Init =================
  void initialize() {
    if (_initialized) return; // مهم عشان Singleton

    _positionSub = _player.positionStream.listen((pos) {
      _position = pos;
    });

    _durationSub = _player.durationStream.listen((dur) {
      _duration = dur ?? Duration.zero;
    });

    _playerStateSub = _player.playerStateStream.listen((state) {
      final processing = state.processingState;

      _isPlaying = state.playing && processing != ProcessingState.completed;

      // تحديث حالة الـ buffering هنا
      _isBuffering = processing == ProcessingState.loading ||
          processing == ProcessingState.buffering;

      if (processing == ProcessingState.completed) {
        _position = Duration.zero;
        _player.seek(Duration.zero);
        _player.pause();
      }
    });

    _initialized = true;
  }

  // ================= Play / Pause =================
  Future<void> playOrPause({
    required String url,
    String? localPath,
    String? sharedPrefsKey,
  }) async {
    try {
      if (_isPlaying) {
        await _player.pause();
        return;
      }

      if (_position > Duration.zero && !_isPlaying && _currentUrl == url) {
        await _player.seek(_position);
        await _player.play();
        return;
      }

      _currentUrl = url;
      _currentLocalPath = localPath;

      if (localPath != null && File(localPath).existsSync()) {
        await _player.setFilePath(localPath);
      } else {
        await _player.setUrl(url);
      }

      await _player.play();
    } catch (e) {
      throw Exception('حدث خطأ أثناء تشغيل الصوت: $e');
    }
  }

  // ================= Download =================
  Future<String> downloadAudio({
    required String url,
    required String fileName,
    required String sharedPrefsKey,
  }) async {
    try {
      final uri = Uri.parse(url);
      final response = await http.get(uri).timeout(const Duration(seconds: 40));

      if (response.statusCode != 200) {
        throw Exception('فشل تحميل الملف الصوتي (كود ${response.statusCode})');
      }

      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$fileName');
      await file.writeAsBytes(response.bodyBytes);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(sharedPrefsKey, file.path);

      _currentLocalPath = file.path;
      return file.path;
    } on TimeoutException {
      throw Exception('انتهت مهلة الاتصال أثناء التحميل');
    } catch (e) {
      throw Exception('حدث خطأ أثناء تحميل الصوت: $e');
    }
  }

  // ================= Seek / Restart / Stop =================
  Future<void> seek(Duration position) async {
    await _player.seek(position);
    _position = position;
  }

  Future<void> restart() async {
    await _player.seek(Duration.zero);
    _position = Duration.zero;
    if (!_isPlaying) {
      await _player.play();
    }
  }

  Future<void> stop() async {
    await _player.stop();
    _position = Duration.zero;
    _currentUrl = null;
    _currentLocalPath = null;
  }

  // ================= Connectivity =================
  Future<bool> hasConnection() async {
    final result = await Connectivity().checkConnectivity();
    return result != ConnectivityResult.none;
  }

  // ================= Saved Path =================
  Future<String?> getSavedAudioPath(String sharedPrefsKey) async {
    final prefs = await SharedPreferences.getInstance();
    final savedPath = prefs.getString(sharedPrefsKey);
    if (savedPath != null && File(savedPath).existsSync()) {
      _currentLocalPath = savedPath;
      return savedPath;
    }
    return null;
  }

  // ================= Dispose =================
  void dispose() {
    _positionSub?.cancel();
    _durationSub?.cancel();
    _playerStateSub?.cancel();
    _player.dispose();
    _initialized = false;
  }
}
