import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/cubit/centralized_cubit.dart';
import '../../../../core/localization/localization_manager.dart';
import '../../../../core/shard/exports/all_exports.dart';
import '../../../../core/shard/widgets/ui_animations.dart';
import '../../../../core/utils/constent/router.dart';
import '../../../../core/utils/style/k_color.dart';
import '../../../../core/utils/style/responsive_util.dart';
import '../../../../core/widgets/KLoading.dart';
import '../../../../core/widgets/custom_divider_widget.dart';
import '../../../../core/widgets/custom_text_widget.dart';
import '../../../../core/widgets/head_title_item_builder.dart';
import '../../../../core/widgets/image_widget.dart';
import '../../../messa_view/azkar_massa.dart';
import '../../hadith_details_view.dart';
import '../controller/hadith_details_bloc.dart';
import '../controller/hadith_details_state.dart';

class DetailsViewItemBuilder extends StatefulWidget {
  const DetailsViewItemBuilder({super.key, this.hadithContentShare});
  final HadithContentShare? hadithContentShare;

  @override
  State<DetailsViewItemBuilder> createState() => _DetailsViewItemBuilderState();
}

class _DetailsViewItemBuilderState extends State<DetailsViewItemBuilder> {
  var selectedFontSize;

  bool isChangeFontSize = false;

  @override
  void initState() {
    super.initState();
    selectedFontSize = "20";
  }

  List<String> sizes = <String>[
    "10",
    "20",
    "30",
    "40",
    "50",
    "60",
    "70",
    "80",
    "90",
    "100",
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HadithDetailsBloc, HadithDetailsState>(
      builder: (BuildContext context, state) {
        if (state is HadithDetailsStateSuccess ||
            state is MoreHadithDetailsStateSuccess) {
          HadithDetailsBloc bloc = HadithDetailsBloc.get(context);
          final isDark = Theme.of(context).brightness == Brightness.dark;

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                // floating: true,
                pinned: true,
                expandedHeight: 40,
                // bottom: PreferredSize(
                //   preferredSize: const Size.fromHeight(40),
                //   child: Padding(
                //     padding:
                //         const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                //     child: Row(
                //       children: [
                //         Expanded(
                //           child: TextWidget(
                //             fontSize: ResponsiveUtil.isTablet(context)
                //                 ? 7.1.sp
                //                 : 10.sp,
                //             fontWeight: FontWeight.w500,
                //             maxLines: 2,
                //             title:
                //                 '${LocalizationManager.call("source")} :- ${bloc.hadithDetailsModal?.attribution ?? ""}',
                //             color: CentralizedCubit.isDarkMode
                //                 ? KColors.primaryColor
                //                 : KColors.primary2Color,
                //           ),
                //         ),
                //         const Spacer(),
                //         Expanded(
                //           child: TextWidget(
                //             fontSize: ResponsiveUtil.isTablet(context)
                //                 ? 7.1.sp
                //                 : 10.sp,
                //             fontWeight: FontWeight.w500,
                //             title:
                //                 '${LocalizationManager.call("hadith-degree")} :- ${bloc.hadithDetailsModal?.grade ?? "غير متوفر"}',
                //             color: CentralizedCubit.isDarkMode
                //                 ? KColors.primaryColor
                //                 : KColors.primary2Color,
                //           ),
                //         ),
                //       ],
                //     ),
                //   ),
                // ),
                leading: CupertinoNavigationBarBackButton(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black,
                ),
                actions: [
                  Directionality(
                    textDirection: ui.TextDirection.rtl,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 8),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 85,
                            child: AnimatedWrapper(
                              type: UiAnimationType.slideRight,
                              duration: const Duration(seconds: 1),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton2<String>(
                                  isExpanded: true,
                                  hint: const TextDefaultWidget(
                                    textAlign: TextAlign.right,
                                    title: "حجم الخط",
                                    fontSize: 15,
                                    color: Color(0xff1A1A1A),
                                  ),
                                  items: sizes.map((e) {
                                    return DropdownMenuItem(
                                        value: e,
                                        child: TextDefaultWidget(
                                          textAlign: TextAlign.right,
                                          title: e,
                                          fontSize: 12.5,
                                          color: isDark
                                              ? Colors.white
                                              : Colors.black,
                                        ));
                                  }).toList(),
                                  value: selectedFontSize,
                                  onChanged: (value) {
                                    selectedFontSize = value;
                                    setState(() {});
                                    isChangeFontSize = true;
                                  },
                                  buttonStyleData: ButtonStyleData(
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            color: AppStyle.scondColors,
                                            width: 1.5),
                                        color: Theme.of(context).cardColor,
                                        borderRadius:
                                            BorderRadius.circular(10.0)),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16),
                                    height: 50,
                                    width:
                                        MediaQuery.of(context).size.width / 1.2,
                                  ),
                                  menuItemStyleData: MenuItemStyleData(
                                    overlayColor: MaterialStateProperty.all(
                                      Colors.grey.withOpacity(0.5),
                                    ), // Use MaterialStateProperty
                                    height: 50,
                                  ),
                                  dropdownStyleData: DropdownStyleData(
                                    elevation: 1,
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? Theme.of(context).cardColor
                                          : const Color(0xfffaedcd),

                                      // Set the background color for the dropdown menu
                                      borderRadius: BorderRadius.circular(
                                          10.0), // Optional: rounded corners
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              // SliverToBoxAdapter(
              //   child: Padding(
              //     padding:
              //     const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              //     child: Row(
              //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //       children: [
              //         Expanded(
              //           child: TextWidget(
              //             fontSize: ResponsiveUtil.isTablet(context)
              //                 ? 7.1.sp
              //                 : 14.sp,
              //             fontWeight: FontWeight.bold,
              //             maxLines: 2,
              //             title:
              //             '${LocalizationManager.call("source")} :- ${bloc.hadithDetailsModal?.attribution ?? ""}',
              //             color: CentralizedCubit.isDarkMode
              //                 ? KColors.primaryColor
              //                 : KColors.primary2Color,
              //           ),
              //         ),
              //         Spacer(),
              //         Expanded(
              //           child: TextWidget(
              //             fontSize: ResponsiveUtil.isTablet(context)
              //                 ? 7.1.sp
              //                 : 15.sp,
              //             fontWeight: FontWeight.w500,
              //             title:
              //             '${LocalizationManager.call("hadith-degree")} :- ${bloc.hadithDetailsModal?.grade ?? "غير متوفر"}',
              //             color: CentralizedCubit.isDarkMode
              //                 ? KColors.primaryColor
              //                 : KColors.primary2Color,
              //           ),
              //         ),
              //       ],
              //     ),
              //   ),
              // ),
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: HeadTitleItemBuilder(
                          icon: Icons.menu_book_sharp,
                          fontSize: isChangeFontSize == false
                              ? 10
                              : double.parse(selectedFontSize),
                          iconSize: ResponsiveUtil.isTablet(context) ? 20 : 15,
                          headTitle: LocalizationManager.call("hadith-text"),
                          lineColor: KColors.scoColor),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Container(
                          width: MediaQuery.sizeOf(context).width,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              color:
                                  AppThemeColors.cardBackgroundColor(context),
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(20.r),
                                  bottomLeft: Radius.circular(20.r)),
                              border: Border(
                                  right: BorderSide(
                                      color: KColors.primaryColor, width: 4))),
                          child: Column(
                            children: [
                              TextWidget(
                                  title: bloc.hadithDetailsModal?.hadeeth
                                          .toString()
                                          .replaceAll("،", "")
                                          .replaceAll("؛", "")
                                          .replaceAll("؟", "") ??
                                      "",
                                  height: 2,
                                  fontFamily: "me",
                                  fontSize: isChangeFontSize == false
                                      ? (ResponsiveUtil.isTablet(context)
                                          ? 8.sp
                                          : 15.sp)
                                      : double.parse(selectedFontSize))
                            ],
                          )),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: HeadTitleItemBuilder(
                          icon: Icons.rotate_90_degrees_ccw_sharp,
                          fontSize: isChangeFontSize == false
                              ? 10
                              : double.parse(selectedFontSize),
                          iconSize: ResponsiveUtil.isTablet(context) ? 20 : 15,
                          headTitle: LocalizationManager.call("source"),
                          lineColor: KColors.scoColor),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Container(
                          width: MediaQuery.sizeOf(context).width,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              // color: isDark
                              //     ? KColors.blackColor
                              //     : Theme.of(context).cardColor,
                              color:
                                  AppThemeColors.cardBackgroundColor(context),
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(20.r),
                                  bottomLeft: Radius.circular(20.r)),
                              border: Border(
                                  right: BorderSide(
                                      color: KColors.yalloColor, width: 4))),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextWidget(
                                  title: bloc.hadithDetailsModal?.attribution ??
                                      "غير متوفر",
                                  height: 2,
                                  fontFamily: "me",
                                  fontSize: isChangeFontSize == false
                                      ? (ResponsiveUtil.isTablet(context)
                                          ? 8.sp
                                          : 15.sp)
                                      : double.parse(selectedFontSize)),
                            ],
                          )),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: HeadTitleItemBuilder(
                          icon: Icons.soup_kitchen_rounded,
                          fontSize: isChangeFontSize == false
                              ? 10
                              : double.parse(selectedFontSize),
                          iconSize: ResponsiveUtil.isTablet(context) ? 20 : 15,
                          headTitle: LocalizationManager.call("hadith-degree"),
                          lineColor: KColors.scoColor),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Container(
                          width: MediaQuery.sizeOf(context).width,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              color:
                                  AppThemeColors.cardBackgroundColor(context),
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(20.r),
                                  bottomLeft: Radius.circular(20.r)),
                              border: Border(
                                  right: BorderSide(
                                      color: KColors.yalloColor, width: 4))),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextWidget(
                                  title: bloc.hadithDetailsModal?.grade ??
                                      "غير متوفر",
                                  height: 2,
                                  fontFamily: "me",
                                  fontSize: isChangeFontSize == false
                                      ? (ResponsiveUtil.isTablet(context)
                                          ? 8.sp
                                          : 15.sp)
                                      : double.parse(selectedFontSize)),
                            ],
                          )),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: HeadTitleItemBuilder(
                          icon: Icons.lightbulb_outlined,
                          fontSize: isChangeFontSize == false
                              ? 10
                              : double.parse(selectedFontSize),
                          iconSize: ResponsiveUtil.isTablet(context) ? 20 : 15,
                          headTitle:
                              LocalizationManager.call("hadith-explanation"),
                          lineColor: KColors.scoColor),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Container(
                          width: MediaQuery.sizeOf(context).width,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              color:
                                  AppThemeColors.cardBackgroundColor(context),
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(20.r),
                                  bottomLeft: Radius.circular(20.r)),
                              border: Border(
                                  right: BorderSide(
                                      color: KColors.yalloColor, width: 4))),
                          child: Column(
                            children: [
                              TextWidget(
                                  title: bloc.hadithDetailsModal?.explanation
                                          .toString()
                                          .replaceAll("،", "")
                                          .replaceAll("؛", "")
                                          .replaceAll("؟", "") ??
                                      "",
                                  height: 2,
                                  fontFamily: "me",
                                  fontSize: isChangeFontSize == false
                                      ? (ResponsiveUtil.isTablet(context)
                                          ? 8.sp
                                          : 15.sp)
                                      : double.parse(selectedFontSize)),
                            ],
                          )),
                    ),
                    Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: HeadTitleItemBuilder(
                            icon: Icons.search_rounded,
                            fontSize: isChangeFontSize == false
                                ? 10
                                : double.parse(selectedFontSize),
                            iconSize:
                                ResponsiveUtil.isTablet(context) ? 20 : 15,
                            headTitle:
                                LocalizationManager.call("hadith-vocabulary"),
                            lineColor: KColors.scoColor)),
                    bloc.hadithDetailsModal?.wordsMeanings?.isNotEmpty == true
                        ? Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 10),
                            child: Wrap(
                              children: bloc.hadithDetailsModal?.wordsMeanings
                                      ?.map((word) {
                                    return Padding(
                                      padding: EdgeInsets.symmetric(
                                          vertical:
                                              ResponsiveUtil.isTablet(context)
                                                  ? 5.h
                                                  : 1.5.h),
                                      child: Container(
                                        width: MediaQuery.sizeOf(context).width,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 8),
                                        decoration: BoxDecoration(
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(10)),
                                          color: AppThemeColors
                                              .cardBackgroundColor(context),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            TextWidget(
                                                color: KColors.primaryColor,
                                                title: '${word.word} :-',
                                                fontWeight: FontWeight.w700,
                                                height: 1.8,
                                                fontFamily: "me",
                                                fontSize: isChangeFontSize ==
                                                        false
                                                    ? (ResponsiveUtil.isTablet(
                                                            context)
                                                        ? 8.sp
                                                        : 15.sp)
                                                    : double.parse(
                                                        selectedFontSize)),
                                            Expanded(
                                                child: TextWidget(
                                                    title: word.meaning
                                                        .toString()
                                                        .replaceAll("،", "")
                                                        .replaceAll("؛", "")
                                                        .replaceAll("؟", ""),
                                                    height: 1.8,
                                                    fontFamily: "me",
                                                    fontSize: isChangeFontSize ==
                                                            false
                                                        ? (ResponsiveUtil
                                                                .isTablet(
                                                                    context)
                                                            ? 8.sp
                                                            : 11.5.sp)
                                                        : double.parse(
                                                            selectedFontSize))),
                                          ],
                                        ),
                                      ),
                                    );
                                  }).toList() ??
                                  [],
                            ),
                          )
                        : Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Center(
                              child: TextWidget(
                                  fontSize: isChangeFontSize == false
                                      ? (ResponsiveUtil.isTablet(context)
                                          ? 8.sp
                                          : 11.5.sp)
                                      : double.parse(selectedFontSize),
                                  fontWeight: FontWeight.w600,
                                  color: KColors.primary2Color,
                                  title: LocalizationManager.call(
                                      "hadith-vocabulary-not")),
                            ),
                          ),
                    Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: HeadTitleItemBuilder(
                            icon: Icons.featured_play_list_sharp,
                            fontSize: isChangeFontSize == false
                                ? 10
                                : double.parse(selectedFontSize),
                            iconSize:
                                ResponsiveUtil.isTablet(context) ? 20 : 15,
                            headTitle:
                                LocalizationManager.call("hadith-benefits"),
                            lineColor: KColors.scoColor)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Container(
                          width: MediaQuery.sizeOf(context).width,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              color:
                                  AppThemeColors.cardBackgroundColor(context),
                              borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(20.r),
                                  topLeft: Radius.circular(20.r)),
                              border: Border(
                                  right: BorderSide(
                                      color: KColors.primary2Color, width: 4))),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: bloc.hadithDetailsModal?.hints?.map((e) {
                                  return TextWidget(
                                      title:
                                          "📌 ${e.toString().replaceAll("[", "").replaceAll("]", "").replaceAll("،", "").replaceAll("؛", "").replaceAll("؟", "")}",
                                      height: 2,
                                      fontFamily: "me",
                                      fontSize: isChangeFontSize == false
                                          ? (ResponsiveUtil.isTablet(context)
                                              ? 8.sp
                                              : 15.sp)
                                          : double.parse(selectedFontSize));
                                }).toList() ??
                                [],
                          )),
                    ),
                    Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: HeadTitleItemBuilder(
                            icon: Icons.room_preferences_outlined,
                            fontSize: isChangeFontSize == false
                                ? 10
                                : double.parse(selectedFontSize),
                            iconSize:
                                ResponsiveUtil.isTablet(context) ? 20 : 15,
                            headTitle:
                                LocalizationManager.call("hadith-references"),
                            lineColor: KColors.scoColor)),
                    bloc.hadithDetailsModal?.reference
                                .toString()
                                .replaceAll("،", "") !=
                            null
                        ? Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                    color: AppThemeColors.cardBackgroundColor(
                                        context),
                                    borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(20.r),
                                        topLeft: Radius.circular(20.r)),
                                    border: Border(
                                        right: BorderSide(
                                            color: KColors.primary2Color,
                                            width: 4))),
                                child: TextWidget(
                                    title:
                                        "${bloc.hadithDetailsModal?.reference.toString().replaceAll("،", "").replaceAll("؛", "").replaceAll("؟", "")}",
                                    height: 2,
                                    fontFamily: "me",
                                    fontSize: isChangeFontSize == false
                                        ? (ResponsiveUtil.isTablet(context)
                                            ? 8.sp
                                            : 15.sp)
                                        : double.parse(selectedFontSize))),
                          )
                        : Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Center(
                              child: TextWidget(
                                  fontSize: isChangeFontSize == false
                                      ? (ResponsiveUtil.isTablet(context)
                                          ? 8.sp
                                          : 11.5.sp)
                                      : double.parse(selectedFontSize),
                                  fontWeight: FontWeight.w600,
                                  color: KColors.primary2Color,
                                  title: LocalizationManager.call(
                                      "hadith-references-not")),
                            ),
                          ),
                    Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: HeadTitleItemBuilder(
                            icon: Icons.more,
                            fontSize: isChangeFontSize == false
                                ? 10
                                : double.parse(selectedFontSize),
                            iconSize:
                                ResponsiveUtil.isTablet(context) ? 20 : 15,
                            headTitle: LocalizationManager.call("more"),
                            lineColor: KColors.scoColor)),
                  ],
                ),
              ),
              SliverToBoxAdapter(
                child: Column(
                  children: bloc.allHadithCategorieModalList?.map((item) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: item.data?.map((data) {
                                return InkWell(
                                  onTap: () {
                                    Navigator.pushNamed(
                                        context, Routes.hadithDetailsRoute,
                                        arguments: data.id
                                        // value.allHadithCategorieModal
                                        //     ?.data?[index].id
                                        );
                                  },
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: Card(
                                      color: AppThemeColors.cardBackgroundColor(
                                          context),
                                      shape: BeveledRectangleBorder(
                                          borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(12.r))),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 5, vertical: 8),
                                        child: TextWidget(
                                            title:
                                                '- ${data.title.toString().replaceAll("،", "").replaceAll("؛", "").replaceAll("؟", "")}',
                                            height: 2,
                                            color: isDark
                                                ? KColors.scoColor
                                                : KColors.greyColor,
                                            fontFamily: "me",
                                            fontSize: isChangeFontSize == false
                                                ? (ResponsiveUtil.isTablet(
                                                        context)
                                                    ? 8.sp
                                                    : 15.sp)
                                                : double.parse(
                                                    selectedFontSize)),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList() ??
                              [],
                        );
                      }).toList() ??
                      [],
                ),
              ),
            ],
          );
        } else if (state is HadithDetailsStateLoading) {
          return KLoading.progressIOSIndicator(context: context);
        } else if (state is HadithDetailsStateError) {
          return const TextWidget(title: 'error');
        } else {
          return const TextWidget(title: 'error in state');
        }
      },
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
