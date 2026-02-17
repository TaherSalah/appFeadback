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
  static const String _lastVersionKey = 'last_app_version';
  static const String _isFirstTimeKey = 'is_first_ال';

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
  final String imagePath;
  final String? version; // إضافة (اختياري)

  AppFeature({
    required this.title,
    required this.description,
    required this.imagePath,
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
      imagePath: 'assets/images/1_12_11zon.webp',
    ),
    AppFeature(
      title: 'مصحف تفاعلي',
      description:
          'استمتع بتجربة قراءة القرآن الكريم مع خيارات البحث السريع، إضافة العلامات المرجعية، والانتقال السهل بين السور والصفحات',
      imagePath: 'assets/images/4_15_11zon.webp',
    ),
    AppFeature(
      title: 'إنشاء ختمات للقرآن الكريم',
      description:
          'نظّم ختمتك بسهولة مع تحديد الأهداف اليومية، تتبع التقدم، وتذكيرات لمساعدتك على إنهاء القرآن',
      imagePath: 'assets/images/17_8_11zon.webp',
    ),
    // AppFeature(
    //   title: 'أذكار متنوعة',
    //   description:
    //       'مكتبة شاملة من أذكار الصباح والمساء، أذكار الصلاة، النوم، والمناسبات المختلفة مع عداد ذكي لتتبع التكرار',
    //   imagePath: 'assets/images/2_13_11zon.webp',
    // ),
    // AppFeature(
    //   title: 'مواقيت الصلاة',
    //   description:
    //       'احصل على مواقيت الصلاة الدقيقة حسب موقعك، مع تنبيهات قبل الأذان وإمكانية تحديد اتجاه القبلة بدقة',
    //   imagePath: 'assets/images/12_3_11zon.webp',
    // ),
    AppFeature(
      title: 'تفسير القرآن الكريم',
      description:
          'اقرأ وافهم معاني الآيات من خلال تفاسير موثوقة لعلماء معتمدين مع إمكانية البحث والمقارنة بين التفاسير',
      imagePath: 'assets/images/7_18_11zon.webp',
    ),
    AppFeature(
      title: 'الاستماع للقرآن الكريم',
      description:
          'استمع للقرآن الكريم بصوت مشايخ مختارين مع إمكانية التكرار، التحميل للاستماع بدون إنترنت،',
      imagePath: 'assets/images/6_17_11zon.webp',
    ),
    AppFeature(
      title: 'الاستماع للأذكار والرقية الشرعية',
      description:
          ' يمكنك الاستماع للأذكار والرقية الشرعية، مع خاصية التشغيل بدون انترنت',
      imagePath: 'assets/images/3_14_11zon.webp',
    ),
    // AppFeature(
    //   title: 'المسبحة الإلكترونية',
    //   description:
    //       'سبّح بسهولة مع عداد إلكتروني ذكي يحفظ تسبيحاتك، وإحصائيات يومية',
    //   imagePath: 'assets/images/19_10_11zon.webp',
    // ),
    // AppFeature(
    //   title: 'تغيير حجم الخط والوضع الليلي للتطبيق',
    //   description:
    //       'خصّص تجربتك بتعديل حجم الخط حسب راحتك، مع وضع ليلي مريح للعين للقراءة في الإضاءة الخافتة',
    //   imagePath: 'assets/images/9_20_11zon.webp',
    // ),
    // AppFeature(
    //   title: 'إنشاء ورد من الأذكار اليومية المفضلة',
    //   description:
    //       'اختر أذكارك المفضلة وأنشئ وردك الخاص، مع جدولة التذكيرات وتتبع الالتزام اليومي',
    //   imagePath: 'assets/images/14_5_11zon.webp',
    // ),
    // AppFeature(
    //   title: 'لوحة تحكم احترافية لتتبع الورد اليومي',
    //   description:
    //       'راقب تقدمك بإحصائيات تفصيلية، رسوم بيانية توضح مدى التزامك، وتحفيزات لمواصلة أورادك اليومية',
    //   imagePath: 'assets/images/13_4_11zon.webp',
    // ),
    // AppFeature(
    //   title: 'إمكانية مشاركة ونسخ الذكر أو الأحاديث',
    //   description:
    //       'شارك الفائدة مع الآخرين بسهولة عبر نسخ النصوص أو مشاركتها مباشرة على وسائل التواصل الاجتماعي',
    //   imagePath: 'assets/images/11_2_11zon.webp',
    // ),
    // AppFeature(
    //   title: 'إذاعة القرآن الكريم وعلومه',
    //   description:
    //       'استمع لبث مباشر من إذاعة القرآن الكريم، مع برامج متنوعة في التفسير والفقه وعلوم القرآن',
    //   imagePath: 'assets/images/18_9_11zon.webp',
    // ),
  ];

  // ✅ ميزات التحديث (للمستخدمين الحاليين)
  // static final List<AppFeature> updateFeatures = [
  //   AppFeature(
  //     title: 'واجهة جديدة',
  //     description:
  //         'تصميم عصري ومريح للعين مع تجربة استخدام سلسة وانتقالات سلسة بين الشاشات',
  //     imagePath: 'assets/images/1_12_11zon.webp',
  //   ),
  //   AppFeature(
  //     title: 'مصحف تفاعلي',
  //     description:
  //         'استمتع بتجربة قراءة القرآن الكريم مع خيارات البحث السريع، إضافة العلامات المرجعية، والانتقال السهل بين السور والصفحات',
  //     imagePath: 'assets/images/4_15_11zon.webp',
  //   ),
  //   AppFeature(
  //     title: 'إنشاء ختمات للقرآن الكريم',
  //     description:
  //         'نظّم ختمتك بسهولة مع تحديد الأهداف اليومية، تتبع التقدم، وتذكيرات لمساعدتك على إنهاء القرآن',
  //     imagePath: 'assets/images/17_8_11zon.webp',
  //   ),
  //   AppFeature(
  //     title: 'أذكار متنوعة',
  //     description:
  //         'مكتبة شاملة من أذكار الصباح والمساء، أذكار الصلاة، النوم، والمناسبات المختلفة مع عداد ذكي لتتبع التكرار',
  //     imagePath: 'assets/images/2_13_11zon.webp',
  //   ),
  //   AppFeature(
  //     title: 'مواقيت الصلاة',
  //     description:
  //         'احصل على مواقيت الصلاة الدقيقة حسب موقعك، مع تنبيهات قبل الأذان وإمكانية تحديد اتجاه القبلة بدقة',
  //     imagePath: 'assets/images/12_3_11zon.webp',
  //   ),
  //   AppFeature(
  //     title: 'تفسير القرآن الكريم',
  //     description:
  //         'اقرأ وافهم معاني الآيات من خلال تفاسير موثوقة لعلماء معتمدين مع إمكانية البحث والمقارنة بين التفاسير',
  //     imagePath: 'assets/images/7_18_11zon.webp',
  //   ),
  //   AppFeature(
  //     title: 'الاستماع للقرآن الكريم',
  //     description:
  //         'استمع للقرآن الكريم بصوت مشايخ مختارين مع إمكانية التكرار، التحميل للاستماع بدون إنترنت،',
  //     imagePath: 'assets/images/6_17_11zon.webp',
  //   ),
  //   AppFeature(
  //     title: 'الاستماع للأذكار والرقية الشرعية',
  //     description:
  //         ' يمكنك الاستماع للأذكار والرقية الشرعية، مع خاصية التشغيل بدون انترنت',
  //     imagePath: 'assets/images/3_14_11zon.webp',
  //   ),
  //   AppFeature(
  //     title: 'المسبحة الإلكترونية',
  //     description:
  //         'سبّح بسهولة مع عداد إلكتروني ذكي يحفظ تسبيحاتك، وإحصائيات يومية',
  //     imagePath: 'assets/images/19_10_11zon.webp',
  //   ),
  //   AppFeature(
  //     title: 'تغيير حجم الخط والوضع الليلي للتطبيق',
  //     description:
  //         'خصّص تجربتك بتعديل حجم الخط حسب راحتك، مع وضع ليلي مريح للعين للقراءة في الإضاءة الخافتة',
  //     imagePath: 'assets/images/9_20_11zon.webp',
  //   ),
  //   AppFeature(
  //     title: 'إنشاء ورد من الأذكار اليومية المفضلة',
  //     description:
  //         'اختر أذكارك المفضلة وأنشئ وردك الخاص، مع جدولة التذكيرات وتتبع الالتزام اليومي',
  //     imagePath: 'assets/images/14_5_11zon.webp',
  //   ),
  //   AppFeature(
  //     title: 'لوحة تحكم احترافية لتتبع الورد اليومي',
  //     description:
  //         'راقب تقدمك بإحصائيات تفصيلية، رسوم بيانية توضح مدى التزامك، وتحفيزات لمواصلة أورادك اليومية',
  //     imagePath: 'assets/images/13_4_11zon.webp',
  //   ),
  //   AppFeature(
  //     title: 'إمكانية مشاركة ونسخ الذكر أو الأحاديث',
  //     description:
  //         'شارك الفائدة مع الآخرين بسهولة عبر نسخ النصوص أو مشاركتها مباشرة على وسائل التواصل الاجتماعي',
  //     imagePath: 'assets/images/11_2_11zon.webp',
  //   ),
  //   AppFeature(
  //     title: 'إذاعة القرآن الكريم وعلومه',
  //     description:
  //         'استمع لبث مباشر من إذاعة القرآن الكريم، مع برامج متنوعة في التفسير والفقه وعلوم القرآن',
  //     imagePath: 'assets/images/18_9_11zon.webp',
  //   ),
  // ];
  static final List<AppFeature> updateFeatures = [
    AppFeature(
      title: 'واجهة جديدة',
      description:
      'تصميم عصري ومريح للعين مع تجربة استخدام سلسة وانتقالات سلسة بين الشاشات',
      imagePath: 'assets/images/1_12_11zon.webp',
    ),
    AppFeature(
      title: 'مصحف تفاعلي',
      description:
      'استمتع بتجربة قراءة القرآن الكريم مع خيارات البحث السريع، إضافة العلامات المرجعية، والانتقال السهل بين السور والصفحات',
      imagePath: 'assets/images/4_15_11zon.webp',
    ),
    AppFeature(
      title: 'إنشاء ختمات للقرآن الكريم',
      description:
      'نظّم ختمتك بسهولة مع تحديد الأهداف اليومية، تتبع التقدم، وتذكيرات لمساعدتك على إنهاء القرآن',
      imagePath: 'assets/images/17_8_11zon.webp',
    ),
    // AppFeature(
    //   title: 'أذكار متنوعة',
    //   description:
    //       'مكتبة شاملة من أذكار الصباح والمساء، أذكار الصلاة، النوم، والمناسبات المختلفة مع عداد ذكي لتتبع التكرار',
    //   imagePath: 'assets/images/2_13_11zon.webp',
    // ),
    // AppFeature(
    //   title: 'مواقيت الصلاة',
    //   description:
    //       'احصل على مواقيت الصلاة الدقيقة حسب موقعك، مع تنبيهات قبل الأذان وإمكانية تحديد اتجاه القبلة بدقة',
    //   imagePath: 'assets/images/12_3_11zon.webp',
    // ),
    AppFeature(
      title: 'تفسير القرآن الكريم',
      description:
      'اقرأ وافهم معاني الآيات من خلال تفاسير موثوقة لعلماء معتمدين مع إمكانية البحث والمقارنة بين التفاسير',
      imagePath: 'assets/images/7_18_11zon.webp',
    ),
    AppFeature(
      title: 'الاستماع للقرآن الكريم',
      description:
      'استمع للقرآن الكريم بصوت مشايخ مختارين مع إمكانية التكرار، التحميل للاستماع بدون إنترنت،',
      imagePath: 'assets/images/6_17_11zon.webp',
    ),
    AppFeature(
      title: 'الاستماع للأذكار والرقية الشرعية',
      description:
      ' يمكنك الاستماع للأذكار والرقية الشرعية، مع خاصية التشغيل بدون انترنت',
      imagePath: 'assets/images/3_14_11zon.webp',
    ),
    // AppFeature(
    //   title: 'المسبحة الإلكترونية',
    //   description:
    //       'سبّح بسهولة مع عداد إلكتروني ذكي يحفظ تسبيحاتك، وإحصائيات يومية',
    //   imagePath: 'assets/images/19_10_11zon.webp',
    // ),
    // AppFeature(
    //   title: 'تغيير حجم الخط والوضع الليلي للتطبيق',
    //   description:
    //       'خصّص تجربتك بتعديل حجم الخط حسب راحتك، مع وضع ليلي مريح للعين للقراءة في الإضاءة الخافتة',
    //   imagePath: 'assets/images/9_20_11zon.webp',
    // ),
    // AppFeature(
    //   title: 'إنشاء ورد من الأذكار اليومية المفضلة',
    //   description:
    //       'اختر أذكارك المفضلة وأنشئ وردك الخاص، مع جدولة التذكيرات وتتبع الالتزام اليومي',
    //   imagePath: 'assets/images/14_5_11zon.webp',
    // ),
    // AppFeature(
    //   title: 'لوحة تحكم احترافية لتتبع الورد اليومي',
    //   description:
    //       'راقب تقدمك بإحصائيات تفصيلية، رسوم بيانية توضح مدى التزامك، وتحفيزات لمواصلة أورادك اليومية',
    //   imagePath: 'assets/images/13_4_11zon.webp',
    // ),
    // AppFeature(
    //   title: 'إمكانية مشاركة ونسخ الذكر أو الأحاديث',
    //   description:
    //       'شارك الفائدة مع الآخرين بسهولة عبر نسخ النصوص أو مشاركتها مباشرة على وسائل التواصل الاجتماعي',
    //   imagePath: 'assets/images/11_2_11zon.webp',
    // ),
    // AppFeature(
    //   title: 'إذاعة القرآن الكريم وعلومه',
    //   description:
    //       'استمع لبث مباشر من إذاعة القرآن الكريم، مع برامج متنوعة في التفسير والفقه وعلوم القرآن',
    //   imagePath: 'assets/images/18_9_11zon.webp',
    // ),
  ];

  // static final List<AppFeature> updateFeatures = [
  //   AppFeature(
  //     title: 'تحسين نظام الأذان 🔔',
  //     description: 'نظام أذان جديد كلياً مع دقة عالية وصوت واضح، يعمل حتى مع إغلاق التطبيق',
  //     imagePath: 'assets/images/adhan_update.png',
  //     version: 'v1.0.5',
  //   ),
  //   AppFeature(
  //     title: 'واجهة محسّنة ✨',
  //     description: 'تصميم جديد لشاشة مواقيت الصلاة مع ألوان هادئة وتجربة أفضل',
  //     imagePath: 'assets/images/ui_update.png',
  //     version: 'v1.0.5',
  //   ),
  //   AppFeature(
  //     title: 'إصلاح الأخطاء 🐛',
  //     description: 'تحسينات في الأداء وإصلاح مشاكل الإشعارات والصوت',
  //     imagePath: 'assets/images/bugfix.png',
  //     version: 'v1.0.5',
  //   ),
  // ];

  // ✅ يمكنك تحديث القائمة هنا مع كل إصدار جديد
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
  @override
  void initState() {
    FlutterNativeSplash.remove();
    _checkAppStateAndNavigate();
    super.initState();
    // Timer(
    //     const Duration(seconds: 3),
    //     () => Navigator.pushReplacement(context,
    //         MaterialPageRoute(builder: (context) => const MainView())));
  }

// التحقق من حالة التطبيق والانتقال للشاشة المناسبة
  Future<void> _checkAppStateAndNavigate() async {
    try {
      // ✅ انتظار 1 ثانية (شاشة السبلاش)
      // تم تقليل المدة من 2 ثانية إلى 1 ثانية لتحسين سرعة فتح التطبيق
      // يمكن تعديل المدة حسب الحاجة (مثلاً: Duration(milliseconds: 500) لنصف ثانية)
      await Future.delayed(const Duration(seconds: 1));

      // ✅ التحقق من حالة التطبيق
      final isMaintenance =
          await SystemControlService().isMaintenanceModeActive();
      if (isMaintenance) {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MaintenanceScreen()),
        );
        return;
      }

      final appState = await VersionService.checkAppState();

      if (!mounted) return;

      switch (appState) {
        case AppState.firstTime:
          // ✅ أول مرة - عرض جميع الميزات
          _navigateToWhatsNew(
            isFirstTime: true,
            features: AppUpdates.firstTimeFeatures,
          );
          break;

        case AppState.updated:
          // ✅ تحديث - عرض الميزات الجديدة فقط
          _navigateToWhatsNew(
            isFirstTime: false,
            features: AppUpdates.updateFeatures,
          );
          break;

        case AppState.normal:
          // ✅ استخدام عادي - الذهاب مباشرة للشاشة الرئيسية
          _navigateToMain();
          break;
      }
    } catch (e) {
      print('❌ خطأ في التحقق من حالة التطبيق: $e');
      // في حالة الخطأ، الذهاب للشاشة الرئيسية
      if (mounted) {
        _navigateToMain();
      }
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
      body: SplashItemBuilder(),
    );
  }
}
