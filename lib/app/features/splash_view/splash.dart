

import 'package:package_info_plus/package_info_plus.dart';
import 'package:rate_my_app/rate_my_app.dart';

import '../../core/shard/exports/all_exports.dart';
import '../main_view/MainView.dart';

// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});
//
//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }
//
// class _SplashScreenState extends State<SplashScreen> {
//   @override
//   void initState() {
//     super.initState();
//     Timer(
//         const Duration(seconds: 3),
//         () => Navigator.pushReplacement(context,
//             MaterialPageRoute(builder: (context) => const MainView())));
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return const Scaffold(
//       body: SplashItemBuilder(),
//     );
//   }
// }
// في main.dart أو SplashScreen
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkFirstLaunch();
  }

  void _checkFirstLaunch() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFirstLaunch = prefs.getBool('first_launch') ?? true;
    String currentVersion = await PackageInfo.fromPlatform().then((info) => info.version);
    String lastVersion = prefs.getString('last_version') ?? '';

    await Future.delayed(const Duration(seconds: 2)); // وقت الشاشة التمهيدية

    if (isFirstLaunch || currentVersion != lastVersion) {
      // حفظ البيانات للمرة القادمة
      await prefs.setBool('first_launch', false);
      await prefs.setString('last_version', currentVersion);
      final List<AppFeature> features = [
        AppFeature(
          title: 'مصحف تفاعلي',
          description: 'استمتع بتجربة قراءة المصحف بتصميم جديد وسهل الاستخدام مع إمكانية البحث والعلامات',
          imagePath: 'assets/images/8.jpg',
        ),

        AppFeature(
          title: 'مصحف تفاعلي',
          description: 'استمتع بتجربة قراءة المصحف بتصميم جديد وسهل الاستخدام مع إمكانية البحث والعلامات',
          imagePath: 'assets/images/9.jpg',
        ),

        AppFeature(
          title: 'مصحف تفاعلي',
          description: 'استمتع بتجربة قراءة المصحف بتصميم جديد وسهل الاستخدام مع إمكانية البحث والعلامات',
          imagePath: 'assets/images/10.jpg',
        ),
        AppFeature(
          title: 'أذكار متنوعة',
          description: 'مجموعة شاملة من الأذكار اليومية مع تذكير وتتبع لعدد المرات',
          imagePath: 'assets/images/11.jpg',
        ),
        AppFeature(
          title: 'مواقيت الصلاة',
          description: 'احصل على مواقيت الصلاة بدقة مع تحديد اتجاه القبلة وتنبيهات قبل الأذان',
          imagePath: 'assets/images/13.jpg',
        ),
      ];
      // الانتقال لصفحة What's New
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => WhatsNewScreen(isFirstTime: true,newFeatures: features,)),
      );
    } else {
      // الانتقال للصفحة الرئيسية مباشرة
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainView()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const SplashItemBuilder();
  }
}
class WhatsNewScreen extends StatefulWidget {
  final bool isFirstTime; // هل هذه أول مرة للمستخدم؟
  final List<AppFeature> newFeatures; // قائمة الميزات الجديدة

  const WhatsNewScreen({
    super.key,
    required this.isFirstTime,
    required this.newFeatures,
  });

  @override
  State<WhatsNewScreen> createState() => _WhatsNewScreenState();
}

class _WhatsNewScreenState extends State<WhatsNewScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // شريط التقدم
            _buildProgressIndicator(),

            // منطقة المحتوى الرئيسية
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: widget.newFeatures.length,
                onPageChanged: (int page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                itemBuilder: (context, index) {
                  return _buildFeaturePage(widget.newFeatures[index]);
                },
              ),
            ),

            // أزرار التنقل
            _buildNavigationButtons(),

            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  // شريط التقدم
  Widget _buildProgressIndicator() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
      child: Row(
        children: [
          ...List.generate(widget.newFeatures.length, (index) {
            return Expanded(
              child: Container(
                height: 4.h,
                margin: EdgeInsets.symmetric(horizontal: 2.w),
                decoration: BoxDecoration(
                  color: _currentPage >= index
                      ? Theme.of(context).primaryColor
                      : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // صفحة عرض الميزة
  Widget _buildFeaturePage(AppFeature feature) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 30.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // الصورة التوضيحية
          Container(
            height: 250.h,
            width: 250.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.grey.shade50,
            ),
            child: Image.asset(
              feature.imagePath,
              fit: BoxFit.contain,
            ),
          ),

          SizedBox(height: 40.h),

          // عنوان الميزة
          Text(
            feature.title,
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),

          SizedBox(height: 15.h),

          // وصف الميزة
          Text(
            feature.description,
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(
              fontSize: 16.sp,
              color: Colors.grey.shade700,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // أزرار التنقل
  Widget _buildNavigationButtons() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 30.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // زر تخطي (يظهر فقط إذا لم تكن آخر صفحة)
          if (_currentPage < widget.newFeatures.length - 1)
            TextButton(
              onPressed: () {
                // الانتقال للصفحة الرئيسية
                Navigator.pushReplacementNamed(context, 'home');
              },
              child: Text(
                'تخطي',
                style: GoogleFonts.cairo(
                  fontSize: 16.sp,
                  color: Colors.grey.shade600,
                ),
              ),
            )
          else
            const SizedBox(width: 80),

          // نقاط الصفحات
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.newFeatures.length, (index) {
              return Container(
                margin: EdgeInsets.symmetric(horizontal: 4.w),
                width: 8.w,
                height: 8.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentPage == index
                      ? Theme.of(context).primaryColor
                      : Colors.grey.shade300,
                ),
              );
            }),
          ),

          // زر التالي/البدء
          ElevatedButton(
            onPressed: () {
              if (_currentPage < widget.newFeatures.length - 1) {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              } else {
                // الانتقال للصفحة الرئيسية
                Navigator.pushReplacementNamed(context, 'home');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
            ),
            child: Text(
              _currentPage < widget.newFeatures.length - 1 ? 'التالي' : 'ابدأ الآن',
              style: GoogleFonts.cairo(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

// نموذج بيانات الميزة
class AppFeature {
  final String title;
  final String description;
  final String imagePath;

  AppFeature({
    required this.title,
    required this.description,
    required this.imagePath,
  });
}

// مثال على استخدام الصفحة
class ExampleUsage extends StatelessWidget {
  final List<AppFeature> features = [
    AppFeature(
      title: 'مصحف تفاعلي',
      description: 'استمتع بتجربة قراءة المصحف بتصميم جديد وسهل الاستخدام مع إمكانية البحث والعلامات',
      imagePath: 'assets/images/quran_feature.png',
    ),
    AppFeature(
      title: 'أذكار متنوعة',
      description: 'مجموعة شاملة من الأذكار اليومية مع تذكير وتتبع لعدد المرات',
      imagePath: 'assets/images/adhkar_feature.png',
    ),
    AppFeature(
      title: 'مواقيت الصلاة',
      description: 'احصل على مواقيت الصلاة بدقة مع تحديد اتجاه القبلة وتنبيهات قبل الأذان',
      imagePath: 'assets/images/prayer_feature.png',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return WhatsNewScreen(
      isFirstTime: true,
      newFeatures: features,
    );
  }
}