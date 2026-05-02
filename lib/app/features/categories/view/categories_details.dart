import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:muslimdaily/app/core/extensions/context_extension.dart';
import 'package:muslimdaily/app/features/categories/data/repo/categories_repo_immp.dart';

import '../../../core/localization/localization_manager.dart';
import '../../../core/utils/constent/router.dart';
import '../../../core/utils/style/app_theme_colors.dart';
import '../../../core/utils/style/k_color.dart';
import '../../../core/widgets/KLoading.dart';
import '../../../core/widgets/custom_form_faild.dart';
import '../../../core/widgets/custom_text_widget.dart';
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
                body: CategoriesDetailsItemBuilder(
                        categoriesDetailsPrams: categoriesDetailsPrams))));
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
    return BlocBuilder<CategoriesBloc, CategoriesState>(
        builder: (BuildContext context, state) {
          final isDark = context.isDark;
          CategoriesBloc bloc = CategoriesBloc.get(context);

          return state.maybeMap(
            orElse: () {
              return const TextWidget(title: 'other error ');
            },
            hadithCatrgoriesLoading: (value) =>
                KLoading.progressIOSIndicator(context: context),
            hadithCatrgoriesError: (value) => TextWidget(title: value.failure),
            hadithCatrgoriesSuccess: (value) {


              return CustomScrollView(
                slivers: [
                  SliverAppBar(
                      pinned: true,
                      elevation: 0,
                      systemOverlayStyle: SystemUiOverlayStyle(
                        statusBarColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
                        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
                      ),
                      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                      leading: CupertinoNavigationBarBackButton(
                        color: isDark ? Colors.white : Colors.black,
                      ),
                      title: TextWidget(
                        title: categoriesDetailsPrams?.subCategoriesName,
                        color: isDark ? KColors.whiteColor : KColors.blackColor,
                        fontWeight: FontWeight.bold,
                        fontFamily: "me",
                        fontSize: context.isTab ? 8.sp : 18.sp,
                      ),
                      actions: const [
                        SizedBox(width: 48), // Minimal spacing
                      ]),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      child: CustomTextFieldWidget(
                        controller: bloc.localSearchController,
                        hint: LocalizationManager.call("search"),
                        prefixIcon:
                            const Icon(Icons.search, color: Colors.grey),
                        suffixIcon: bloc.localSearchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, color: Colors.grey),
                                onPressed: () {
                                  bloc.localSearchController.clear();
                                  bloc.searchHadiths("");
                                },
                              )
                            : null,
                        onchange: (value) {
                          bloc.searchHadiths(value);
                        },
                      ),
                    ),
                  ),
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
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white.withOpacity(0.05) : KColors.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: TextWidget(
                            title: ' ${LocalizationManager.call("count-hadiths")}: ${categoriesDetailsPrams?.subCategoriesCount}',
                            fontSize: context.isTab ? 6.sp : 9.sp,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white70 : KColors.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  )),
                  if (value.allHadithCategorieModal?.data?.isEmpty ?? true)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                              height: 150.h,
                              child: Lottie.asset(
                                  "assets/json/file-searching.json")),
                          TextWidget(
                            title: LocalizationManager.call("notSearchFound"),
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ],
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      sliver: SliverGrid(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          childAspectRatio: childAspectRatio,
                          mainAxisSpacing: 8,
                          crossAxisSpacing: 8,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final item = value.allHadithCategorieModal?.data?[index];
                            return InkWell(
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  Routes.hadithDetailsRoute,
                                  arguments: item?.id,
                                );
                              },
                              child: Card(
                                shape: BeveledRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                color: AppThemeColors.cardBackgroundColor(context),
                                shadowColor: KColors.whiteColor.withOpacity(0.6),
                                elevation: 2,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 8, horizontal: 10),
                                  child: TextWidget(
                                    color: isDark ? KColors.whiteColor : KColors.blackColor,
                                    maxLines: 2,
                                    textAlign: TextAlign.justify,
                                    title: "${item?.title}",
                                    fontSize: context.isTab ? 7.sp : 14.sp,
                                    height: 2.5,
                                  ),
                                ),
                              ),
                            );
                          },
                          childCount: value.allHadithCategorieModal?.data?.length ?? 0,
                        ),
                      ),
                    ),
                ],
              );
            },
          );
        },
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
