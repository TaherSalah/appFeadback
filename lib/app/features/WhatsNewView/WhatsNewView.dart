import 'package:muslimdaily/app/core/utils/style/responsive_util.dart';
import 'package:muslimdaily/app/features/splashView/splash.dart';

import '../../core/shard/exports/all_exports.dart';
import '../../core/utils/style/k_color.dart';

class WhatsNewView extends StatefulWidget {
  final bool isFirstTime;
  final List<AppFeature> newFeatures;

  const WhatsNewView({
    super.key,
    required this.isFirstTime,
    required this.newFeatures,
  });

  @override
  State<WhatsNewView> createState() => _WhatsNewViewState();
}

class _WhatsNewViewState extends State<WhatsNewView>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // ✅ Controllers للأنيميشن
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // ✅ تهيئة Controllers
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    // ✅ تهيئة Animations
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOutBack),
    );

    // ✅ بدء الأنيميشن
    _startAnimations();
  }

  void _startAnimations() {
    _fadeController.forward();
    _slideController.forward();
    _scaleController.forward();
  }

  void _resetAnimations() {
    _fadeController.reset();
    _slideController.reset();
    _scaleController.reset();
    _startAnimations();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              // شريط التقدم مع أنيميشن
              _buildAnimatedProgressIndicator(),

              // منطقة المحتوى الرئيسية
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: widget.newFeatures.length,
                  onPageChanged: (int page) {
                    setState(() {
                      _currentPage = page;
                    });
                    // ✅ إعادة تشغيل الأنيميشن عند تغيير الصفحة
                    _resetAnimations();
                  },
                  itemBuilder: (context, index) {
                    return _buildAnimatedFeaturePage(widget.newFeatures[index]);
                  },
                ),
              ),

              // أزرار التنقل مع أنيميشن
              _buildAnimatedNavigationButtons(),

              SizedBox(height: 10.h),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ شريط التقدم مع أنيميشن
  Widget _buildAnimatedProgressIndicator() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
      child: Row(
        children: List.generate(widget.newFeatures.length, (index) {
          return Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
              height: 4.h,
              margin: EdgeInsets.symmetric(horizontal: 2.w),
              decoration: BoxDecoration(
                color: _currentPage >= index
                    ? KColors.primaryColor
                    : Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(10),
                // ✅ ظل خفيف للشريط النشط
                boxShadow: _currentPage == index
                    ? [
                        BoxShadow(
                          color:
                              Theme.of(context).primaryColor.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
            ),
          );
        }),
      ),
    );
  }

  // ✅ صفحة عرض الميزة مع أنيميشن
  Widget _buildAnimatedFeaturePage(AppFeature feature) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ✅ الصورة التوضيحية مع Scale Animation
              ScaleTransition(
                scale: _scaleAnimation,
                child: Hero(
                  tag: 'feature_${feature.imagePath}',
                  child: Container(
                    height: 510.h,
                    width: MediaQuery.sizeOf(context).width,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      // ✅ ظل جميل للصورة
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        feature.imagePath,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 10.h),

              // ✅ عنوان الميزة مع أنيميشن
              TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 800),
                tween: Tween(begin: 0.0, end: 1.0),
                curve: Curves.easeOut,
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0, 20 * (1 - value)),
                      child: child,
                    ),
                  );
                },
                child: Text(
                  feature.title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cairo(
                    fontSize: ResponsiveUtil.isTablet(context) ? 15.sp : 20.sp,
                    fontWeight: FontWeight.bold,
                    color: isDark ? KColors.primaryColor : Colors.black87,
                  ),
                ),
              ),

              SizedBox(height: 10.h),

              // ✅ وصف الميزة مع تأخير في الأنيميشن
              TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 1000),
                tween: Tween(begin: 0.0, end: 1.0),
                curve: Curves.easeOut,
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0, 30 * (1 - value)),
                      child: child,
                    ),
                  );
                },
                child: Text(
                  feature.description,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cairo(
                    fontSize: ResponsiveUtil.isTablet(context) ? 10.sp : 15.sp,
                    color: Colors.grey.shade700,
                    height: 1.5,
                  ),
                ),
              ),

              SizedBox(height: 10.h),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ أزرار التنقل مع أنيميشن
  Widget _buildAnimatedNavigationButtons() {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 600),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 30.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // ✅ زر تخطي مع أنيميشن
            if (_currentPage < widget.newFeatures.length - 1)
              AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity:
                    _currentPage < widget.newFeatures.length - 1 ? 1.0 : 0.0,
                child: TextButton(
                  onPressed: () {
                    _pageController.animateToPage(
                      widget.newFeatures.length - 1,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                    );
                  },
                  style: TextButton.styleFrom(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  ),
                  child: Text(
                    'تخطي',
                    style: GoogleFonts.cairo(
                      fontSize:
                          ResponsiveUtil.isTablet(context) ? 10.sp : 16.sp,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              )
            else
              const SizedBox(width: 80),

            // ✅ مؤشر الصفحات مع أنيميشن
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Theme.of(context).primaryColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Text(
                '${_currentPage + 1} / ${widget.newFeatures.length}',
                style: GoogleFonts.cairo(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  // color: Theme.of(context).primaryColor,
                ),
              ),
            ),

            // ✅ زر التالي/ابدأ الآن مع أنيميشن
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: ElevatedButton(
                onPressed: () {
                  if (_currentPage < widget.newFeatures.length - 1) {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  } else {
                    Navigator.pushReplacementNamed(context, 'home');
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark
                      ? Theme.of(context).primaryColor
                      : KColors.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.symmetric(
                      horizontal:
                          ResponsiveUtil.isTablet(context) ? 15.w : 24.w,
                      vertical: 12.h),
                  elevation: 5,
                  shadowColor: Theme.of(context).primaryColor.withOpacity(0.4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _currentPage < widget.newFeatures.length - 1
                          ? 'التالي'
                          : 'ابدأ الآن',
                      style: GoogleFonts.cairo(
                        fontSize:
                            ResponsiveUtil.isTablet(context) ? 10.sp : 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    // ✅ أيقونة متحركة
                    AnimatedRotation(
                      duration: const Duration(milliseconds: 300),
                      turns: _currentPage < widget.newFeatures.length - 1
                          ? 0
                          : 0.5,
                      child: Icon(
                        _currentPage < widget.newFeatures.length - 1
                            ? Icons.arrow_forward_ios
                            : Icons.start,
                        color: Colors.white,
                        size: ResponsiveUtil.isTablet(context) ? 15.sp : 18.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    super.dispose();
  }
}
