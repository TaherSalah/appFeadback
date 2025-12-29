import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:muslimdaily/app/features/messaView/azkar_massa.dart';
import 'package:muslimdaily/app/features/radio/data/repo/QuranRadioRepoImmp.dart';
import 'package:muslimdaily/app/features/radio/view/controller/QuranRadioBloc.dart';
import 'package:muslimdaily/app/features/radio/view/controller/QuranRadioState.dart';

import '../../../../core/shard/exports/all_exports.dart';
import '../../../../core/utils/constent/router.dart';
import '../../../../core/utils/style/app_theme_colors.dart';
import '../../../../core/utils/style/k_color.dart';
import '../../../../core/utils/style/responsive_util.dart';
import '../../../../core/widgets/KLoading.dart';
import '../../../../core/widgets/custom_text_widget.dart';

class QuranRadioItemBuilder extends StatefulWidget {
  const QuranRadioItemBuilder({super.key});

  @override
  State<QuranRadioItemBuilder> createState() => _QuranRadioItemBuilderState();
}

class _QuranRadioItemBuilderState extends State<QuranRadioItemBuilder> {
  final _scrollCtrl = ScrollController();
  static const int _pageSize = 30;
  int _visibleCount = _pageSize;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollCtrl.removeListener(_onScroll);
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    // قربنا من آخر السكروول؟ زوّد الدُفعة الجاية
    if (_scrollCtrl.position.pixels >=
        _scrollCtrl.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  void _loadMore() {
    if (_isLoadingMore) return;
    setState(() => _isLoadingMore = true);

    // مفيش API call هنا — مجرد زيادة العرض من اللي متخزن بالفعل
    Future.microtask(() {
      setState(() {
        _visibleCount += _pageSize;
        _isLoadingMore = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount;
    double childAspectRatio;

    if (screenWidth < 600) {
      // Mobile
      crossAxisCount = 2;
      childAspectRatio = 2.50;
    } else if (screenWidth < 1200) {
      // Tablet
      crossAxisCount = 3;
      childAspectRatio = 1.70;
    } else {
      // Desktop
      crossAxisCount = 4;
      childAspectRatio = 0.7;
    }

    return BlocProvider<QuranRadioBloc>(
      create: (context) =>
          QuranRadioBloc(QuranRadioRepoImmp())..getQuranRadioData(),
      child: BlocBuilder<QuranRadioBloc, QuranRadioState>(
        builder: (context, state) {
          final bloc = QuranRadioBloc.get(context);
          final total = bloc.quranRadioModel?.radios.length ?? 0;

          // حدّ أقصى لما نعرضه حسب الإجمالي
          final itemCount =
              total == 0 ? 0 : (_visibleCount > total ? total : _visibleCount);
          final isDark = Theme.of(context).brightness == Brightness.dark;

          // لو لسه محمّل البيانات الأساسية
          final isInitialLoading =
              total == 0 && (state is QuranRadioStateLoading);

          return CustomScrollView(
            controller: _scrollCtrl,
            slivers: [
              SliverAppBar(
                centerTitle: true,
                title: Text(
                  "اذاعة القران الكريم",
                  style: GoogleFonts.cairo(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize:
                        MediaQuery.sizeOf(context).width > 600 ? 12.sp : 18.sp,
                  ),
                ),
                // leading:                   InkWell(
                //   onTap: () {
                //     Navigator.pushNamed(context, "/ayaSearchScreen");
                //   },
                //   child: const Padding(
                //     padding: EdgeInsets.symmetric(horizontal: 10),
                //     child: Icon(
                //       Icons.search,
                //       size: 30,
                //     ),
                //   ),
                // ),
                leading: const SizedBox(),
                actions: [
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: SvgPicture.asset(
                      "assets/icons/arrow.svg",
                      color: isDark ? Colors.white : Colors.black,
                      height: 25,
                    ),
                  )
                ],
              ),

              SliverToBoxAdapter(
                child: SizedBox(
                    height: ResponsiveUtil.isTablet(context) ? 20 : 15),
              ),

              if (isInitialLoading)
                SliverToBoxAdapter(
                  child: Center(
                    child: KLoading.progressIOSIndicator(context: context),
                  ),
                ),

              if (!isInitialLoading && itemCount == 0)
                const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Text("لا توجد بيانات متاحة حالياً."),
                    ),
                  ),
                ),

              if (itemCount > 0)
                SliverToBoxAdapter(
                  child: GridView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: itemCount,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      childAspectRatio: childAspectRatio,
                    ),
                    itemBuilder: (context, index) {
                      final item = bloc.quranRadioModel!.radios[index];
                      return InkWell(
                        onTap: () {
                          // TODO: اكتب تنقلك هنا
                          Navigator.pushNamed(context, "/QuranRadioPlayerView",
                              arguments: QuranRadioPlayerArgs(
                                  title: bloc
                                          .quranRadioModel?.radios[index].name
                                          .toString() ??
                                      "",
                                  streamUrl: bloc
                                          .quranRadioModel?.radios[index].url
                                          .toString() ??
                                      ""));
                        },
                        child: Card(
                          elevation: 4,
                          color: AppThemeColors.cardBackgroundColor(context),
                          shape: BeveledRectangleBorder(
                              borderRadius: BorderRadiusGeometry.circular(15)),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Image.asset(
                                  "assets/icons/radio.png",
                                  height: ResponsiveUtil.isTablet(context)
                                      ? 80
                                      : 30,
                                ),
                                const Spacer(),
                                TextWidget(
                                  color: isDark
                                      ? KColors.scoColor
                                      : KColors.primary2Color,
                                  fontWeight: FontWeight.w600,
                                  maxLines: 1,
                                  fontSize:
                                      MediaQuery.sizeOf(context).width > 600
                                          ? 6.sp
                                          : 10.sp,
                                  title: item.name.toString() ?? "",
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

              // Loader صغير تحت لما نزود الدُفعات
              if (_isLoadingMore && itemCount > 0 && itemCount < total)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                        child: KLoading.progressIOSIndicator(context: context)),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
