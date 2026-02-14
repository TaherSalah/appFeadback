import 'package:flutter/cupertino.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';

import 'package:muslimdaily/app/core/shard/widgets/ui_animations.dart';
import '../../../core/shard/exports/all_exports.dart';
import '../../../core/utils/constent/lists.dart';
import '../../../core/utils/style/k_color.dart';
import '../controllers/books_controller.dart';
import 'widgets/books_cover.dart';

import 'package:showcaseview/showcaseview.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NineBooksScreen extends StatefulWidget {
  const NineBooksScreen({super.key});

  @override
  State<NineBooksScreen> createState() => _NineBooksScreenState();
}

class _NineBooksScreenState extends State<NineBooksScreen> {
  final GlobalKey _hadithKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _checkFirstLaunch();
  }

  Future<void> _checkFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    final bool hasShownShowcase =
        prefs.getBool('showcase_hadith_books') ?? false;

    if (!hasShownShowcase) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ShowCaseWidget.of(context).startShowCase([_hadithKey]);
        prefs.setBool('showcase_hadith_books', true);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Ensure controller is initialized
    final BooksController booksCtrl = Get.put(BooksController());
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ShowCaseWidget(
      builder: (context) => Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(
            MediaQuery.sizeOf(context).width > 600 ? 70 : 50,
          ),
          child: AppBar(
            leading: Navigator.canPop(context)
                ? CupertinoNavigationBarBackButton(
                    color: isDark ? Colors.white : Colors.black,
                  )
                : null,
            centerTitle: true,
            title: Text(
              "المكتبة الإسلامية",
              style: GoogleFonts.cairo(
                color: Colors.green,
                fontWeight: FontWeight.bold,
                fontSize:
                    MediaQuery.sizeOf(context).width > 600 ? 12.sp : 18.sp,
              ),
            ),
          ),
        ),
        body: Directionality(
          textDirection: TextDirection.rtl,
          child: CustomScrollView(
            slivers: [
              // SliverAppBar(
              //   expandedHeight: 120.h,
              //   floating: false,
              //   pinned: true,
              //   backgroundColor: isDark ? const Color(0xFF1a1a2e) : AppColors.primary,
              //   elevation: 0,
              //   leading: IconButton(
              //     icon: Icon(CupertinoIcons.back, color: Colors.white),
              //     onPressed: () => Navigator.pop(context),
              //   ),
              //   flexibleSpace: FlexibleSpaceBar(
              //     centerTitle: true,
              //     title: Text(
              //       "المكتبة الإسلامية",
              //       style: GoogleFonts.cairo(
              //         color: Colors.white,
              //         fontWeight: FontWeight.bold,
              //         fontSize: 18.sp,
              //       ),
              //     ),
              //     background: Stack(
              //       fit: StackFit.expand,
              //       children: [
              //         if (!isDark)
              //           Image.asset(
              //             "assets/images/8180jjj00005.webp",
              //             fit: BoxFit.cover,
              //             opacity: const AlwaysStoppedAnimation(0.2),
              //           ),
              //         Container(
              //           decoration: BoxDecoration(
              //             gradient: LinearGradient(
              //               begin: Alignment.topCenter,
              //               end: Alignment.bottomCenter,
              //               colors: [
              //                 Colors.black.withOpacity(0.3),
              //                 Colors.transparent,
              //               ],
              //             ),
              //           ),
              //         ),
              //       ],
              //     ),
              //   ),
              // ),
              SliverToBoxAdapter(
                child: GetBuilder<BooksController>(
                  builder: (controller) {
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 20.h),
                      child: Column(
                        children: [
                          Showcase(
                            key: _hadithKey,
                            description:
                                'هنا تجد الكتب التسعة المشهورة في الحديث النبوي الشريف',
                            child: FadeAnimation(
                              delay: const Duration(milliseconds: 100),
                              child: BooksCover(
                                title: Constants.collectionsGroupsTitles[0],
                              ),
                            ),
                          ),
                          const Gap(15),
                          FadeAnimation(
                            delay: const Duration(milliseconds: 300),
                            child: BooksCover(
                              title: Constants.collectionsGroupsTitles[1],
                            ),
                          ),
                          const Gap(15),
                          FadeAnimation(
                            delay: const Duration(milliseconds: 500),
                            child: BooksCover(
                              title: Constants.collectionsGroupsTitles[2],
                            ),
                          ),
                          const Gap(30),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
