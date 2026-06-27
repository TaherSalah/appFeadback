import 'core/device_push_detector.dart';
import 'core/push_notification_logger.dart';
import 'data/datasources/token_local_datasource.dart';
import 'data/datasources/token_remote_datasource.dart';
import 'data/providers/fcm_push_provider.dart';
import 'data/providers/hms_push_provider.dart';
import 'data/repositories/push_notification_repository_impl.dart';
import 'domain/repositories/push_notification_repository.dart';
import 'domain/usecases/get_push_token_usecase.dart';
import 'domain/usecases/handle_notification_usecase.dart';
import 'domain/usecases/send_token_to_backend_usecase.dart';
import 'presentation/cubit/notification_cubit.dart';

/// الخدمة الموحدة للـ Push Notifications
///
/// ### الغرض:
/// تُوفّر نقطة وصول واحدة لبناء كل مكونات نظام الـ Push.
/// باقي التطبيق لا يعرف شيئاً عن FCM أو HMS — يتعامل فقط مع هذه الخدمة.
///
/// ### الاستخدام في `Di.init()`:
/// ```dart
/// await UnifiedPushService.setup(sharedPreferences: prefs);
/// // ثم:
/// final cubit = Di.pushNotificationCubit;
/// ```
///
/// ### المكونات التي تُنشئها:
/// ```
/// UnifiedPushService
///   ├── DevicePushDetector (GMS/HMS/iOS)
///   ├── FcmPushProvider
///   ├── HmsPushProvider
///   ├── TokenLocalDataSource (SharedPreferences)
///   ├── TokenRemoteDataSource (Supabase)
///   ├── PushNotificationRepositoryImpl
///   ├── GetPushTokenUseCase
///   ├── SendTokenToBackendUseCase
///   ├── HandleNotificationUseCase
///   └── NotificationCubit
/// ```
class UnifiedPushService {
  static final PushNotificationLogger _logger = PushNotificationLogger();

  // Singleton instances — تُبنى مرة واحدة
  static late final PushNotificationRepositoryImpl _repository;
  static late final GetPushTokenUseCase _getTokenUseCase;
  static late final SendTokenToBackendUseCase _sendTokenUseCase;
  static late final HandleNotificationUseCase _handleNotificationUseCase;
  static late final NotificationCubit _cubit;

  static bool _isSetup = false;

  // ─────────────────────────────────────────────────────────────────
  //  Setup — يُستدعى مرة واحدة في Di.init()
  // ─────────────────────────────────────────────────────────────────

  /// بناء وتهيئة كل مكونات نظام الـ Push
  ///
  /// يجب الاستدعاء في `Di.init()` بعد تهيئة SharedPreferences وSupabase
  static Future<void> setup({
    required dynamic sharedPreferences,
    required dynamic supabaseClient,
  }) async {
    if (_isSetup) {
      _logger.d('UnifiedPushService already set up, skipping');
      return;
    }

    _logger.i('🔧 Setting up UnifiedPushService...');

    // ── Layer 1: Core Utilities ────────────────────────────────────
    final logger = PushNotificationLogger();

    // DevicePushDetector يأخذ SharedPreferences + Logger كـ positional args
    final detector = DevicePushDetector(sharedPreferences, logger);

    // ── Layer 2: Providers ─────────────────────────────────────────
    final fcmProvider = FcmPushProvider(logger: logger);
    final hmsProvider = HmsPushProvider(logger: logger);

    // ── Layer 3: Data Sources ──────────────────────────────────────
    final localDataSource = TokenLocalDataSource(sharedPreferences, logger);
    final remoteDataSource = TokenRemoteDataSource(supabaseClient, logger);

    // ── Layer 4: Repository ────────────────────────────────────────
    _repository = PushNotificationRepositoryImpl(
      detector: detector,
      fcmProvider: fcmProvider,
      hmsProvider: hmsProvider,
      localDataSource: localDataSource,
      remoteDataSource: remoteDataSource,
      logger: logger,
    );

    // تهيئة الـ Repository (يختار FCM أو HMS ويبدأ الـ Streams)
    await _repository.initialize();

    // ── Layer 5: Use Cases ─────────────────────────────────────────
    _getTokenUseCase = GetPushTokenUseCase(_repository);
    _sendTokenUseCase = SendTokenToBackendUseCase(_repository);
    _handleNotificationUseCase = HandleNotificationUseCase(_repository);

    // ── Layer 6: Cubit ─────────────────────────────────────────────
    _cubit = NotificationCubit(
      getTokenUseCase: _getTokenUseCase,
      sendTokenUseCase: _sendTokenUseCase,
      handleNotificationUseCase: _handleNotificationUseCase,
      logger: logger,
    );

    _isSetup = true;
    _logger.i('✅ UnifiedPushService ready');
  }

  // ─────────────────────────────────────────────────────────────────
  //  Getters — للوصول من Di
  // ─────────────────────────────────────────────────────────────────

  static PushNotificationRepository get repository => _repository;
  static GetPushTokenUseCase get getTokenUseCase => _getTokenUseCase;
  static SendTokenToBackendUseCase get sendTokenUseCase => _sendTokenUseCase;
  static HandleNotificationUseCase get handleUseCase => _handleNotificationUseCase;

  /// الـ Cubit الجاهز للاستخدام في BlocProvider
  static NotificationCubit get cubit => _cubit;

  // ─────────────────────────────────────────────────────────────────
  //  Convenience API للاستخدام الداخلي
  // ─────────────────────────────────────────────────────────────────

  static bool get isReady => _isSetup;
}
