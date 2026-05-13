import 'package:muslimdaily/app/features/mainView/MainView.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:rate_my_app/rate_my_app.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
// ============================================
// 📁 lib/core/services/version_service.dart
// ============================================

import 'package:shared_preferences/shared_preferences.dart';

import '../../core/shard/exports/all_exports.dart';
import '../WhatsNewView/WhatsNewView.dart';
import '../../core/services/system_control_service.dart';
import '../mainView/view/MaintenanceScreen.dart';

class VersionService {
  static const String _lastVersionKey = 'last_ap_vin';
  static const String _isFirstTimeKey = 'is_';

  /// التحقق من حالة التطبيق (أول مرة، تحديث، أو استخدام عادي)
  static Future<AppState> checkAppState() async {
    final prefs = await SharedPreferences.getInstance();
    final packageInfo = await PackageInfo.fromPlatform();

    final currentVersion = packageInfo.version; // مثال: "1.0.5"
    final savedVersion = prefs.getString(_lastVersionKey);
    final isFirstTime = prefs.getBool(_isFirstTimeKey) ?? true;

    if (isFirstTime) {
      // ✅ أول مرة يفتح التطبيق
      await prefs.setBool(_isFirstTimeKey, false);
      await prefs.setString(_lastVersionKey, currentVersion);
      return AppState.firstTime;
    } else if (savedVersion == null || savedVersion != currentVersion) {
      // ✅ تحديث التطبيق
      await prefs.setString(_lastVersionKey, currentVersion);
      return AppState.updated;
    } else {
      // ✅ استخدام عادي
      return AppState.normal;
    }
  }

  /// الحصول على الإصدار الحالي
  static Future<String> getCurrentVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version;
  }

  /// الحصول على الإصدار السابق
  static Future<String?> getLastVersion() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastVersionKey);
  }

  /// إعادة تعيين حالة التطبيق (للتجربة فقط)
  static Future<void> resetAppState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_lastVersionKey);
    await prefs.remove(_isFirstTimeKey);
  }
}

/// حالات التطبيق
enum AppState {
  firstTime, // أول مرة
  updated, // تم التحديث
  normal, // استخدام عادي
}

// ============================================
// 📁 lib/models/app_feature.dart (إذا لم يكن موجود)
// ============================================

class AppFeature {
  final String title;
  final String description;
  final IconData? icon; // Added icon field
  final String? version;

  AppFeature({
    required this.title,
    required this.description,
    this.icon,
    this.version,
  });
}

// ============================================
// 📁 lib/core/constants/app_updates.dart
// ============================================

class AppUpdates {
  // ✅ ميزات التطبيق الجديدة (للمستخدمين الجدد)
  static final List<AppFeature> firstTimeFeatures = [
    AppFeature(
      title: 'واجهة جديدة',
      description:
          'تصميم عصري ومريح للعين مع تجربة استخدام سلسة وانتقالات سلسة بين الشاشات',
    ),
    AppFeature(
      title: 'مصحف التجويد والتفسير والقراءات ',
      description:
          'استمتع بتجربة قراءة القرآن الكريم مع خيارات البحث السريع، إضافة العلامات المرجعية، والانتقال السهل بين السور والصفحات والاستماع للقرآن الكريم',
    ),
    AppFeature(
      title: 'إنشاء ختمات للقرآن الكريم',
      description:
          'نظّم ختمتك بسهولة مع تحديد الأهداف اليومية، تتبع التقدم، وتذكيرات لمساعدتك على إنهاء القرآن',
    ),
    AppFeature(
      title: 'الاستماع للأذكار والرقية الشرعية',
      description:
          ' يمكنك الاستماع للأذكار والرقية الشرعية، مع خاصية التشغيل بدون انترنت',
    ),
    AppFeature(
      title: 'متتبع الصدقات',
      description:
          'أضف هدفك الشهري من الصدقات وقم بتسجيل صدقاتك مع تذكير بالاشعارات بالصدقات الدورية',
    ),
    AppFeature(
      title: 'حاسبة الزكاة',
      description:
          'احسب زكاتك بسهولة مع حاسبة الزكاة، وتذكيرك بموعد الحول وتقرير مفصل',
    ),
  ];
  static final List<AppFeature> updateFeatures = [
    AppFeature(
      title: 'إضافة معلومات إضافية في المواريث',
      description: 'تم توفير شرح مفصل وقواعد فقهية شاملة لجميع حالات المواريث لتبسيط فهم الحسابات الشرعية.',
      icon: Icons.account_balance_outlined,
    ),
    AppFeature(
      title: 'تطوير المسبحة الإلكترونية',
      description: 'أصبحت المسبحة تضم وضعين مختلفين: مسبحة إلكترونية حديثة ومسبحة تقليدية لتناسب جميع المستخدمين.',
      icon: Icons.fingerprint_outlined,
    ),
    AppFeature(
      title: 'إضافة الاهتزاز أثناء التسبيح',
      description: 'تم دعم الاهتزاز أثناء العد في المسبحة لمنح تجربة تسبيح أكثر تفاعلاً وراحة.',
      icon: Icons.vibration_outlined,
    ),
    AppFeature(
      title: 'التسبيح في الوضع الخفي',
      description: 'يمكنك الآن استخدام المسبحة في الوضع الخفي للحفاظ على الخصوصية أثناء التسبيح.',
      icon: Icons.visibility_off_outlined,
    ),
    AppFeature(
      title: 'إضافة الشيخ علي جابر للقرآن الكريم',
      description: 'تم إضافة تلاوات القارئ الشيخ علي جابر بجودة عالية داخل قسم القرآن الكريم.',
      icon: Icons.library_music_outlined,
    ),
    AppFeature(
      title: 'تغيير صوت الأذان للشيخ ناصر القطامي',
      description: 'تم اعتماد صوت الأذان بصوت الشيخ ناصر القطامي لتحسين تجربة التنبيهات والأذان.',
      icon: Icons.record_voice_over_outlined,
    ),
    AppFeature(
      title: 'تعديلات في المصحف وتحسينات',
      description: 'تحسينات تقنية وجمالية شاملة في المصحف الشريف لتوفير تجربة قراءة مريحة وأكثر سلاسة.',
      icon: Icons.menu_book_outlined,
    ),
    AppFeature(
      title: 'تحسين وتطوير التمرير التلقائي',
      description: 'تم تحسين التمرير التلقائي داخل المصحف ليصبح أكثر سلاسة ودقة أثناء القراءة.',
      icon: Icons.swipe_vertical_outlined,
    ),
    AppFeature(
      title: 'إضافة البحث داخل موسوعة الأحاديث',
      description: 'يمكنك الآن البحث بسهولة في اكثر من 10 الالف حديث في موسوعة الأحاديث للوصول السريع إلى أي حديث.',
      icon: Icons.search_outlined,
    ),
    AppFeature(
      title: 'التعديل في نظام الإشعارات',
      description: 'تطوير جذري لنظام التنبيهات لضمان دقة المواعيد وسرعة وصول الإشعارات لكافة الأجهزة.',
      icon: Icons.notifications_active_outlined,
    ),
    AppFeature(
      title: 'إضافة اختيارات للوضع الليلي الصامت للإشعارات',
      description: 'الآن يمكنك اختيار وقت بداية ونهاية الوضع الصامت للإشعارات بما يناسب أوقات راحتك ونومك.',
      icon: Icons.nights_stay_outlined,
    ),
    AppFeature(
      title: 'تحسين وتطوير منبه الفجر',
      description: 'تم تطوير منبه الفجر ليعمل بدقة واستقرار أكبر، مع إضافة ميزة جديدة تمنع إيقاف التنبيه إلا بعد التسبيح والصلاة على النبي ﷺ عشرين مرة للمساعدة على الاستيقاظ الكامل.',
      icon: Icons.alarm_outlined,
    ),    AppFeature(
      title: 'إضافة التذكير اليومي بالورد القرآني',
      description: 'ميزة جديدة لتذكيرك يومياً بوردك الشخصي من القرآن الكريم للمساعدة على الاستمرار والالتزام.',
      icon: Icons.auto_stories_outlined,
    ),
    AppFeature(
      title: 'تحسين وتطوير ركن الطفل المسلم',
      description: 'تم تحسين قسم الطفل المسلم وإضافة تطويرات جديدة لتقديم تجربة تعليمية وترفيهية أفضل للأطفال.',
      icon: Icons.child_care_outlined,
    ),
  ];

  static List<AppFeature> getFeaturesForVersion(String version) {
    // يمكنك إضافة منطق لإرجاع ميزات معينة حسب الإصدار
    return updateFeatures;
  }
}

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  // 🛠️ للمطور: اجعل القيمة true إذا كنت تريد تثبيت الشاشة للاختبار
  final bool _freezeForTesting = false;

  @override
  void initState() {
    FlutterNativeSplash.remove();
    _checkAppStateAndNavigate();
    super.initState();
  }

// التحقق من حالة التطبيق والانتقال للشاشة المناسبة
  Future<void> _checkAppStateAndNavigate() async {
    try {
      // ✅ Parallelize all initial checks and a short delay
      final results = await Future.wait([
        SystemControlService()
            .isMaintenanceModeActive()
            .timeout(const Duration(seconds: 2), onTimeout: () => false),
        VersionService.checkAppState(),
        Future.delayed(const Duration(milliseconds: 6000)),
      ]);

      final bool isMaintenance = results[0] as bool;
      final AppState appState = results[1] as AppState;

      if (!mounted) return;

      // 🛑 إذا كان وضع الاختبار مفعلاً، لا تنتقل لأي شاشة
      if (_freezeForTesting) {
        debugPrint('ℹ️ Splash is frozen for testing mode.');
        return;
      }

      if (isMaintenance) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MaintenanceScreen()),
        );
        return;
      }

      switch (appState) {
        case AppState.firstTime:
          _navigateToWhatsNew(
            isFirstTime: true,
            features: AppUpdates.firstTimeFeatures,
          );
          break;
        case AppState.updated:
          _navigateToWhatsNew(
            isFirstTime: false,
            features: AppUpdates.updateFeatures,
          );
          break;
        case AppState.normal:
          _navigateToMain();
          break;
      }
    } catch (e) {
      debugPrint('❌ Error in Splash: $e');
      if (mounted && !_freezeForTesting) _navigateToMain();
    }
  }

  /// الانتقال لشاشة "ما الجديد"
  void _navigateToWhatsNew({
    required bool isFirstTime,
    required List<AppFeature> features,
  }) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => WhatsNewView(
          isFirstTime: isFirstTime,
          newFeatures: features,
        ),
      ),
    );
  }

  /// الانتقال للشاشة الرئيسية
  void _navigateToMain() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const MainView(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SplashItemBuilderWidget(),
    );
  }
}
