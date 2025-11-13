import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

import '../../../../core/cubit/centralized_cubit.dart';
import '../../../../core/localization/localization_manager.dart';
import '../../../../core/utils/constent/router.dart';
import '../../../../core/utils/style/k_color.dart';
import '../../../../core/utils/style/responsive_util.dart';
import '../../../../core/widgets/KLoading.dart';
import '../../../../core/widgets/custom_divider_widget.dart';
import '../../../../core/widgets/custom_text_widget.dart';
import '../../../../core/widgets/image_widget.dart';
import '../../../../core/widgets/kButtons.dart';
import '../categories_details.dart';
import '../controller/categories_bloc.dart';
import '../controller/categories_state.dart';


class CategoriesViewItemBuilder extends StatelessWidget {
  const CategoriesViewItemBuilder({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount;
    double childAspectRatio;

    if (screenWidth < 600) {
      // Mobile
      crossAxisCount = 2;
      childAspectRatio = 2.35;
    } else if (screenWidth < 1200) {
      // Tablet
      crossAxisCount = 2;
      childAspectRatio = 3.40;
    } else {
      // Desktop
      crossAxisCount = 4;
      childAspectRatio = 0.7;
    }
    return CustomScrollView(

      slivers: [
        SliverAppBar(
          centerTitle: true,
          title: Text(
            "كل اقسام الاحاديث",
            style: GoogleFonts.cairo(
                color: Colors.green,
                fontWeight: FontWeight.bold,
                fontSize:
                MediaQuery.sizeOf(context).width > 600 ? 12.sp : 18.sp),
          ),
          leading: const SizedBox(),
          actions: [
            InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: SvgPicture.asset("assets/icons/arrow.svg",color: Theme.of(context).brightness == Brightness.dark ?Colors.white:Colors.black,height: 25,))
          ],
        ),

        // SliverToBoxAdapter(
        //     child: Container(
        //         padding: EdgeInsets.zero,
        //         height: ResponsiveUtil.isTablet(context)
        //             ? MediaQuery.sizeOf(context).height / 5.5
        //             : MediaQuery.sizeOf(context).height / 8,
        //         decoration: BoxDecoration(
        //             color: CentralizedCubit.isDarkMode
        //                 ? const Color(0xff1d1b20)
        //                 : Theme.of(context).cardColor,
        //             borderRadius: BorderRadius.only(
        //                 bottomRight: Radius.circular(
        //                     ResponsiveUtil.isTablet(context) ? 30.r : 20.r),
        //                 bottomLeft: Radius.circular(
        //                     ResponsiveUtil.isTablet(context) ? 30.r : 20.r))),
        //         child: Padding(
        //             padding: EdgeInsets.symmetric(
        //                 vertical: ResponsiveUtil.isTablet(context) ? 20 : 12,
        //                 horizontal: ResponsiveUtil.isTablet(context) ? 20 : 12),
        //             child: Column(
        //                 crossAxisAlignment: CrossAxisAlignment.center,
        //                 mainAxisAlignment: MainAxisAlignment.center,
        //                 children: [
        //
        //                   // BlocBuilder<CategoriesBloc, CategoriesState>(
        //                   //   builder: (context, state) {
        //                   //     CategoriesBloc bloc = CategoriesBloc.get(context);
        //                   //     return Row(
        //                   //       children: [
        //                   //         Expanded(
        //                   //           flex: 8,
        //                   //           child: Padding(
        //                   //               padding: const EdgeInsets.only(
        //                   //                   right: 12, left: 8),
        //                   //               child: CupertinoSearchTextField(
        //                   //                   onSuffixTap: () {
        //                   //                     bloc.searchKeyboardController
        //                   //                         .clear();
        //                   //                     bloc.getAllCategories();
        //                   //                   },
        //                   //                   controller:
        //                   //                       bloc.searchKeyboardController,
        //                   //                   decoration: BoxDecoration(
        //                   //                       color: CentralizedCubit.isDarkMode
        //                   //                           ? const Color(0xff1d1b20)
        //                   //                           : Theme.of(context)
        //                   //                               .cardColor,
        //                   //                       border: Border.all(
        //                   //                           color: CentralizedCubit.isDarkMode
        //                   //                               ? Colors.white
        //                   //                               : KColors.scoColor),
        //                   //                       borderRadius: BorderRadius.all(
        //                   //                           Radius.circular(5.r))),
        //                   //                   padding: EdgeInsets.symmetric(
        //                   //                       vertical:
        //                   //                           ResponsiveUtil.isTablet(context)
        //                   //                               ? 10
        //                   //                               : 8,
        //                   //                       horizontal:
        //                   //                           ResponsiveUtil.isTablet(context)
        //                   //                               ? 15
        //                   //                               : 7),
        //                   //                   onChanged: (value) {
        //                   //                     Future.delayed(
        //                   //                       const Duration(seconds: 4),
        //                   //                       () {
        //                   //                         bloc.getHadithSearch(
        //                   //                             wordKey: value);
        //                   //                         print(value);
        //                   //                       },
        //                   //                     );
        //                   //                   },
        //                   //                   itemSize:
        //                   //                       ResponsiveUtil.isTablet(context)
        //                   //                           ? 15.sp
        //                   //                           : 17,
        //                   //                   prefixInsets: const EdgeInsets.symmetric(horizontal: 10),
        //                   //                   onSubmitted: (value) {
        //                   //                     bloc.getHadithSearch(
        //                   //                         wordKey: value);
        //                   //                   },
        //                   //                   placeholder: LocalizationManager.call('exams-search'),
        //                   //                   style: TextStyle(fontFamily: 'cairo', color: CentralizedCubit.isDarkMode ? KColors.whiteColor : KColors.blackColor, fontSize: ResponsiveUtil.isTablet(context) ? 15 : 10))),
        //                   //         ),
        //                   //         Card(
        //                   //             color: CentralizedCubit.isDarkMode
        //                   //                 ? KColors.primaryColor
        //                   //                 : KColors.primary2Color,
        //                   //             child: InkWell(
        //                   //                 onTap: () {
        //                   //                   bloc.getHadithSearch();
        //                   //                 },
        //                   //                 child: Padding(
        //                   //                     padding: EdgeInsets.symmetric(
        //                   //                         vertical:
        //                   //                             ResponsiveUtil.isTablet(
        //                   //                                     context)
        //                   //                                 ? 15
        //                   //                                 : 10,
        //                   //                         horizontal:
        //                   //                             ResponsiveUtil.isTablet(
        //                   //                                     context)
        //                   //                                 ? 10
        //                   //                                 : 10),
        //                   //                     child: Icon(Icons.search,
        //                   //                         color:
        //                   //                             CentralizedCubit.isDarkMode
        //                   //                                 ? KColors.whiteColor
        //                   //                                 : KColors.whiteColor,
        //                   //                         size: ResponsiveUtil.isTablet(
        //                   //                                 context)
        //                   //                             ? 25
        //                   //                             : 18))))
        //                   //       ],
        //                   //     );
        //                   //   },
        //                   // ),
        //                 ])))),

        const SliverToBoxAdapter(child: SizedBox(height: 15)),
        SliverToBoxAdapter(child: BlocBuilder<CategoriesBloc, CategoriesState>(

          builder: (BuildContext context, state) {

         if (state is CategoriesStateSuccess) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    TextWidget(
                        fontWeight: FontWeight.w700,
                        title: LocalizationManager.call("all-departments"),
                        fontSize: 10.sp),
                    const Spacer(),
                  ],
                ),
              );
            } else {
              return const SizedBox.shrink();
            }
          },
        )),
        SliverToBoxAdapter(child: BlocBuilder<CategoriesBloc, CategoriesState>(
          builder: (BuildContext context, state) {
            if (state is HadithSearchStateSuccess) {
              String responseContent =
                  state.searchResultModal?.ahadith.result ?? "";
              // Check if the response indicates "not found" or is empty
              if (!responseContent.contains("search-keys")) {
                // Display a 'Not Found' message if no results are found
                return Column(
                  children: [
                    SizedBox(
                        height: 200,
                        width: 200,
                        child: Lottie.asset("assets/json/file-searching.json")),
                    Center(
                      child: Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 10.w, vertical: 5),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextWidget(
                              title:
                                  "${LocalizationManager.call("notSearchFound")} ",
                              fontSize:
                                  ResponsiveUtil.isTablet(context) ? 8.sp : 10,
                            ),
                            TextWidget(
                              fontWeight: FontWeight.w600,
                              fontSize:
                                  ResponsiveUtil.isTablet(context) ? 8.sp : 10,
                              color: CentralizedCubit.isDarkMode
                                  ? KColors.primary
                                  : KColors.primary2Color,
                              title:
                                  "${CategoriesBloc.get(context).searchKeyboardController.text} ",
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: MediaQuery.sizeOf(context).width / 3,
                      child: CustomButton(
                        radius: 6.r,
                        title: LocalizationManager.call('goCatePage'),
                        fontSize:
                            ResponsiveUtil.isTablet(context) ? 8.sp : 12.sp,
                        backgroundColor: CentralizedCubit.isDarkMode
                            ? KColors.blackColor
                            : KColors.primary2Color,
                        onTap: () async {
                          CategoriesBloc.get(context).getAllCategories();
                        },
                      ),
                    ),
                  ],
                );
              }

              // If results are found, render the HTML content
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5),
                child: HtmlWidget(
                  customStylesBuilder: (element) {
                    if (element.classes.contains('search-keys')) {
                      // You can modify the inline CSS like this using textStyle for that class.
                      return {
                        'color':
                            '#178B74', // Set the color to green for this class
                      };
                    } else if (element.classes.contains('hadith-info')) {
                      return {
                        'border-radius': '13px',
                        'background-color':
                            CentralizedCubit.isDarkMode ? '#313131' : '#F9F9F9',
                        'margin-top': '15px',
                        'padding': '8px',
                        'margin-bottom': '15px',
                      };
                    }
                    return null; // If not matching, return null
                  },
                  textStyle: const TextStyle(fontFamily: "cairo", height: 2.0),
                  responseContent,
                ),
              );
            } else if (state is HadithSearchStateLoading) {
              return Center(child: KLoading.progressIOSIndicator(context: context));
            } else {
              return state.maybeMap(
                error: (value) => TextWidget(title: value.failure),
                loading: (value) => KLoading.progressIOSIndicator(radius: 15,context: context),
                success: (value) {
                  final isDark = Theme.of(context).brightness == Brightness.dark;

                  return GridView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: value.categoriesModal?.length,
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
                                // print(value.categoriesModal?[index].id);
                                Navigator.pushNamed(
                                    context, Routes.cateDetailsRoute,
                                    arguments: CategoriesDetailsPrams(
                                      categoriesId:
                                          value.categoriesModal?[index].id,
                                      subCategoriesCount: value
                                          .categoriesModal?[index]
                                          .hadeethsCount,
                                      subCategoriesName:
                                          value.categoriesModal?[index].title,
                                    ));
                              },
                              child: Card(
                                // shadowColor:
                                //     KColors.whiteColor.withOpacity(0.6),
                                // elevation: 2,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 8, horizontal: 10),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment:MainAxisAlignment.spaceBetween,
                                    children: [
                                      TextWidget(
                                        maxLines: 1,
                                        title: value
                                                .categoriesModal?[index].title
                                                .toString() ??
                                            "",
                                        color: isDark
                                            ? KColors.whiteColor
                                            : KColors.blackColor,
                                        fontWeight: FontWeight.w600,

                                        fontSize:
                                        MediaQuery.sizeOf(context).width > 600
                                            ? 6.sp
                                            : 13.sp,
                                      ),
                                      const Spacer(),
                                      Row(
                                        children: [
                                          TextWidget(
                                              title: LocalizationManager.call(
                                                  "count-hadiths"),
                                            fontSize:
                                            MediaQuery.sizeOf(context).width >
                                                600
                                                ? 5.5.sp
                                                : 10.sp,
                                            color: isDark
                                                ? KColors.circularPercentBg
                                                : KColors.greyColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          const Spacer(),
                                          TextWidget(
                                            title:
                                                "${value.categoriesModal?[index].hadeethsCount}",
                                            fontSize:
                                            MediaQuery.sizeOf(context).width >
                                                600
                                                ? 5.5.sp
                                                : 10.sp,
                                            color: isDark
                                                ? KColors.accentColorD
                                                : KColors.greyColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              )),
                        );
                      });
                },
                orElse: () {
                  return const TextWidget(title: 'other error ');
                },
              );
            }
          },
        )),
      ],
    );
  }
}

class CardPackagesExamBuilderWidget extends StatelessWidget {
  const CardPackagesExamBuilderWidget({
    super.key,
    this.cardImgUrl,
    required this.cardTitle,
    this.textAlign,
    this.widget,
    this.fontSize,
    this.fontWight,
    this.description,
    this.titleSize,
    this.desSize,
    this.titleColor,
    this.descColor,
    this.cardImg,
  });

  final String? cardImgUrl;
  final String? cardImg;
  final String cardTitle;
  final TextAlign? textAlign;
  final Widget? widget;
  final double? fontSize;
  final double? titleSize;
  final double? desSize;
  final FontWeight? fontWight;
  final String? description;
  final Color? titleColor;
  final Color? descColor;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      double calculatedHeight = ResponsiveHelper.calculateHeight(constraints);
      return Padding(
          padding: EdgeInsets.symmetric(vertical: 7.h, horizontal: 4.w),
          child: Card(
              // elevation: 7,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      height: MediaQuery.sizeOf(context).width > 600
                          ? constraints.maxHeight * 0.65
                          : calculatedHeight,
                      child: cardImgUrl != null
                          ? KImageWidget(imageUrl: cardImgUrl.toString())
                          : Image.asset(
                              width: double.infinity,
                              cardImg.toString(),
                              fit: BoxFit.cover,
                            ),
                    ),
                    Expanded(
                        child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 10),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextWidget(
                                title: cardTitle,
                                color: titleColor,
                                textAlign: textAlign,
                                fontSize: titleSize,
                                maxLines: 3,
                                fontWeight: FontWeight.w700),
                            TextWidget(
                                title: description.toString(),
                                textAlign: textAlign,
                                fontSize: desSize,
                                maxLines: 2,
                                color: descColor,
                                fontWeight: FontWeight.w400),
                            customDividerWidget(
                                color: KColors.greyColor.withOpacity(0.2),
                                thickness: 1.5)
                          ]),
                    ))
                  ])));
    });
  }
}

class ResponsiveHelper {
  static int getCrossAxisCount(double screenWidth) {
    if (screenWidth < 600) {
      return 2; // Mobile
    } else if (screenWidth < 1200) {
      return 2; // Tablet
    } else {
      return 4; // Desktop
    }
  }

  static double getChildAspectRatio(double screenWidth) {
    if (screenWidth < 600) {
      return 0.70; // Mobile
    } else if (screenWidth < 1200) {
      return 0.75; // Tablet
    } else {
      return 0.7; // Desktop
    }
  }

  static double getFontSize(double screenWidth,
      {double mobileSize = 11.5, double tabletSize = 14.0}) {
    return screenWidth < 600 ? mobileSize : tabletSize;
  }

  static EdgeInsets getPadding(
      {double mobilePadding = 10.0, double tabletPadding = 15.0}) {
    return EdgeInsets.symmetric(
        horizontal: mobilePadding, vertical: tabletPadding);
  }

  static double calculateHeight(BoxConstraints constraints) {
    return constraints.maxHeight * 0.50;
  }
}
