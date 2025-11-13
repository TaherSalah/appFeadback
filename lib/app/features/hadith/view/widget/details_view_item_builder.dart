import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
import '../../../categories/view/categories_details.dart';
import '../../../categories/view/controller/categories_bloc.dart';
import '../../../categories/view/controller/categories_state.dart';

class HadithViewItemBuilder extends StatelessWidget {
  const HadithViewItemBuilder({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount;
    double childAspectRatio;
    double childAspectRatio2;

    if (screenWidth < 600) {
      // Mobile
      crossAxisCount = 2;
      childAspectRatio = 2.50;
      childAspectRatio2 = 2.0;
    } else if (screenWidth < 1200) {
      // Tablet
      crossAxisCount = 2;
      childAspectRatio = 3.99;
    } else {
      // Desktop
      crossAxisCount = 4;
      childAspectRatio = 0.7;
    }
    return CustomScrollView(

      slivers: [
        SliverAppBar(
          centerTitle: true,
          // title: Text("موسوعة الاحاديث"),
          title: Text(
            "موسوعة الاحاديث",

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
                child: SvgPicture.asset("assets/icons/arrow.svg",color: Colors.black,height: 25,))
          ],
        ),
        SliverToBoxAdapter(
            child:
            SizedBox(height: ResponsiveUtil.isTablet(context) ? 20 : 15)),
        SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  TextWidget(
                      fontWeight: FontWeight.w700,
                      title: LocalizationManager.call("all-departments"),
                      fontSize: 10.sp),
                  const Spacer(),
                  InkWell(
                    onTap: () {
                      Navigator.pushNamed(context, Routes.categoriesRoute);
                    },
                    child: TextWidget(
                        fontWeight: FontWeight.w700,
                        color: CentralizedCubit.isDarkMode
                            ? KColors.greenColor
                            : KColors.primaryColor,
                        title: LocalizationManager.call("view-all"),
                        fontSize: ResponsiveUtil.isTablet(context) ? 8.sp : 10.sp),
                  ),
                ],
              ),
            )),
        SliverToBoxAdapter(child: BlocBuilder<CategoriesBloc, CategoriesState>(
          builder: (BuildContext context, state) {
            CategoriesBloc bloc = CategoriesBloc.get(context);
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
                      width: ResponsiveUtil.isTablet(context)
                          ? MediaQuery.sizeOf(context).width / 3
                          : MediaQuery.sizeOf(context).width / 2.5,
                      child: CustomButton(
                        horizontalPadding: 2,
                        verticalPadding:
                        ResponsiveUtil.isTablet(context) ? 14.h : 7,
                        radius: 6.r,
                        title: LocalizationManager.call('goCatePage'),
                        fontSize:
                        ResponsiveUtil.isTablet(context) ? 8.sp : 10.sp,
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
              return Directionality(
                textDirection: LocalizationManager.isEn?TextDirection.rtl:TextDirection.rtl,
                child: Padding(
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
                ),
              );
            } else if (state is HadithSearchStateLoading) {
              return Center(child: KLoading.progressIOSIndicator(context: context));
            } else {
              return state.maybeMap(
                orElse: () {
                  return const TextWidget(title: "error");
                },
                success: (value) {
                  return GridView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: 10,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          childAspectRatio: childAspectRatio),
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () {
                            Navigator.pushNamed(
                                context, Routes.cateDetailsRoute,
                                arguments: CategoriesDetailsPrams(
                                  categoriesId: bloc.categoriesModal?[index].id,
                                  subCategoriesCount: bloc
                                      .categoriesModal?[index].hadeethsCount,
                                  subCategoriesName:
                                  bloc.categoriesModal?[index].title,
                                ));
                          },
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextWidget(
                                    color: CentralizedCubit.isDarkMode
                                        ? KColors.scoColor
                                        : KColors.primary2Color,
                                    fontWeight: FontWeight.w600,
                                    maxLines: 2,
                                    fontSize:
                                    MediaQuery.sizeOf(context).width > 600
                                        ? 6.sp
                                        : 10.sp,
                                    title: value.categoriesModal?[index].title
                                        .toString() ??
                                        "",
                                  ),
                                  const Spacer(),
                                  Row(
                                    children: [
                                      TextWidget(
                                        fontSize:
                                        MediaQuery.sizeOf(context).width >
                                            600
                                            ? 5.5.sp
                                            : 9.sp,
                                        color: CentralizedCubit.isDarkMode
                                            ? KColors.circularPercentBg
                                            : KColors.greyColor,
                                        fontWeight: FontWeight.w500,
                                        title: LocalizationManager.call(
                                            "count-hadiths"),
                                      ),
                                      const Spacer(),
                                      TextWidget(
                                        fontSize:
                                        MediaQuery.sizeOf(context).width >
                                            600
                                            ? 5.5.sp
                                            : 9.sp,
                                        color: CentralizedCubit.isDarkMode
                                            ? KColors.circularPercentBg
                                            : KColors.greyColor,
                                        fontWeight: FontWeight.w500,
                                        title: value.categoriesModal?[index]
                                            .hadeethsCount
                                            .toString() ??
                                            "",
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      });
                },
                loading: (value) => KLoading.progressIOSIndicator(context: context),
                error: (value) => TextWidget(title: value.failure),
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
              elevation: 7,
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
