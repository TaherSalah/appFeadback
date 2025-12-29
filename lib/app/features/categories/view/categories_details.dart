import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:muslimdaily/app/features/categories/data/repo/categories_repo_immp.dart';

import '../../../core/localization/localization_manager.dart';
import '../../../core/utils/constent/router.dart';
import '../../../core/utils/style/app_theme_colors.dart';
import '../../../core/utils/style/k_color.dart';
import '../../../core/utils/style/responsive_util.dart';
import '../../../core/widgets/KLoading.dart';
import '../../../core/widgets/custom_text_widget.dart';
import '../../hadithDetails/data/repo/hadith_details_repo_immp.dart';
import '../../hadithDetails/view/controller/hadith_details_bloc.dart';
import '../../messaView/azkar_massa.dart';
import 'controller/categories_bloc.dart';
import 'controller/categories_state.dart';

class CategoriesDetailsView extends StatelessWidget {
  final CategoriesDetailsPrams? categoriesDetailsPrams;

  const CategoriesDetailsView({super.key, this.categoriesDetailsPrams});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CategoriesBloc>(
        create: (BuildContext context) => CategoriesBloc(CategoriesRepoImmp())
          ..getAllHadithFromCategories(
              categoriesId: categoriesDetailsPrams?.categoriesId),
        child: Directionality(
            textDirection: LocalizationManager.isEn
                ? TextDirection.ltr
                : TextDirection.rtl,
            child: Scaffold(
                // backgroundColor: AppStyle.bgColors,
                body: SafeArea(
                    child: CategoriesDetailsItemBuilder(
                        categoriesDetailsPrams: categoriesDetailsPrams)))));
  }
}

class CategoriesDetailsItemBuilder extends StatelessWidget {
  const CategoriesDetailsItemBuilder({super.key, this.categoriesDetailsPrams});

  final CategoriesDetailsPrams? categoriesDetailsPrams;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount;
    double childAspectRatio;

    if (screenWidth < 600) {
      // Mobile
      crossAxisCount = 1;
      childAspectRatio = 3.80;
    } else if (screenWidth < 1200) {
      // Tablet
      crossAxisCount = 2;
      childAspectRatio = 2.60;
    } else {
      // Desktop
      crossAxisCount = 4;
      childAspectRatio = 0.7;
    }
    return BlocProvider<HadithDetailsBloc>(
      create: (BuildContext context) {
        return HadithDetailsBloc(HadithDetailsRepoImmp());
      },
      child: BlocBuilder<CategoriesBloc, CategoriesState>(
        builder: (BuildContext context, state) {
          final isDark = Theme.of(context).brightness == Brightness.dark;

          return state.maybeMap(
            orElse: () {
              return const TextWidget(title: 'other error ');
            },
            hadithCatrgoriesLoading: (value) =>
                KLoading.progressIOSIndicator(context: context),
            hadithCatrgoriesError: (value) => TextWidget(title: value.failure),
            hadithCatrgoriesSuccess: (value) {
              List ids = value.allHadithCategorieModal?.data
                      ?.map((e) => e.id)
                      .toList() ??
                  [];
              HadithDetailsBloc.get(context)
                  .getHadithDetailsList(hadithId: ids);

              return CustomScrollView(
                slivers: [
                  SliverAppBar(
                      leading: CupertinoNavigationBarBackButton(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black,
                      ),
                      title: TextWidget(
                        title: categoriesDetailsPrams?.subCategoriesName,
                        color: isDark ? KColors.whiteColor : KColors.blackColor,
                        fontWeight: FontWeight.bold,
                        fontFamily: "me",
                        fontSize:
                            ResponsiveUtil.isTablet(context) ? 8.sp : 18.sp,
                      ),
                      actions: [
                        Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: Card(
                                shape: const BeveledRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                        topRight: Radius.circular(5),
                                        bottomLeft: Radius.circular(5))),
                                color: isDark
                                    ? KColors.blackColor
                                    : KColors.lightYellowColor,
                                child: Padding(
                                    padding: const EdgeInsets.all(5),
                                    child: TextWidget(
                                        title:
                                            '${LocalizationManager.call("count-hadiths")} : ${categoriesDetailsPrams?.subCategoriesCount}',
                                        color: isDark
                                            ? Colors.white
                                            : KColors.blackColor,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: "me",
                                        fontSize:
                                            ResponsiveUtil.isTablet(context)
                                                ? 8.sp
                                                : 16.sp))))
                      ]),
                  SliverToBoxAdapter(
                      child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      children: [
                        TextWidget(
                            fontWeight: FontWeight.w700,
                            title: LocalizationManager.call("all-departments"),
                            fontSize: 10.sp),
                        const Spacer(),
                      ],
                    ),
                  )),
                  SliverToBoxAdapter(
                    child: GridView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: value.allHadithCategorieModal?.data?.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            childAspectRatio: childAspectRatio),
                        itemBuilder: (context, index) {
                          return Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 2, horizontal: 2),
                              child: InkWell(
                                  onTap: () {
                                    Navigator.pushNamed(
                                        context, Routes.hadithDetailsRoute,
                                        arguments: value.allHadithCategorieModal
                                            ?.data?[index].id);
                                  },
                                  child: Card(
                                      shape: BeveledRectangleBorder(
                                          borderRadius:
                                              BorderRadiusGeometry.circular(
                                                  15)),
                                      color: AppThemeColors.cardBackgroundColor(
                                          context),
                                      shadowColor:
                                          KColors.whiteColor.withOpacity(0.6),
                                      elevation: 2,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8, horizontal: 10),
                                        child: TextWidget(
                                            color: isDark
                                                ? KColors.whiteColor
                                                : KColors.blackColor,
                                            maxLines: 2,
                                            textAlign: TextAlign.justify,
                                            title:
                                                "${value.allHadithCategorieModal?.data?[index].title}",
                                            fontSize:
                                                ResponsiveUtil.isTablet(context)
                                                    ? 7.sp
                                                    : 14.sp,
                                            height: 2.5),
                                      ))));
                        }),
                  )
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class CategoriesDetailsPrams {
  final dynamic categoriesId;
  final dynamic subCategoriesName;
  final dynamic subCategoriesCount;

  CategoriesDetailsPrams(
      {this.categoriesId, this.subCategoriesName, this.subCategoriesCount});
}
