import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/cubit/centralized_cubit.dart';
import '../../../../core/localization/localization_manager.dart';
import '../../../../core/utils/style/k_color.dart';
import '../../../../core/utils/style/responsive_util.dart';
import '../../../../core/widgets/KLoading.dart';
import '../../../../core/widgets/custom_text_widget.dart';
import '../../../categories/view/controller/categories_bloc.dart';
import '../../../categories/view/controller/categories_state.dart';
import '../controller/hadith_details_bloc.dart';
import '../controller/quran_audio_state.dart';

class QuranAudioListViewItemBuilder extends StatelessWidget {
  const QuranAudioListViewItemBuilder({super.key, required this.recitersId});
  final String recitersId;

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
      crossAxisCount = 4;
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
            "كل  القرائ",
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
            child: Container(
                padding: EdgeInsets.zero,
                height: ResponsiveUtil.isTablet(context)
                    ? MediaQuery.sizeOf(context).height / 5.5
                    : MediaQuery.sizeOf(context).height / 8,
                decoration: BoxDecoration(
                    color: CentralizedCubit.isDarkMode
                        ? const Color(0xff1d1b20)
                        : Theme.of(context).cardColor,
                    borderRadius: BorderRadius.only(
                        bottomRight: Radius.circular(
                            ResponsiveUtil.isTablet(context) ? 30.r : 20.r),
                        bottomLeft: Radius.circular(
                            ResponsiveUtil.isTablet(context) ? 30.r : 20.r))),
                child: Padding(
                    padding: EdgeInsets.symmetric(
                        vertical: ResponsiveUtil.isTablet(context) ? 20 : 12,
                        horizontal: ResponsiveUtil.isTablet(context) ? 20 : 12),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [

                          BlocBuilder<CategoriesBloc, CategoriesState>(
                            builder: (context, state) {
                              CategoriesBloc bloc = CategoriesBloc.get(context);
                              return Row(
                                children: [
                                  Expanded(
                                    flex: 8,
                                    child: Padding(
                                        padding: const EdgeInsets.only(
                                            right: 12, left: 8),
                                        child: CupertinoSearchTextField(
                                            onSuffixTap: () {
                                              bloc.searchKeyboardController
                                                  .clear();
                                              bloc.getAllCategories();
                                            },
                                            controller:
                                            bloc.searchKeyboardController,
                                            decoration: BoxDecoration(
                                                color: CentralizedCubit.isDarkMode
                                                    ? const Color(0xff1d1b20)
                                                    : Theme.of(context)
                                                    .cardColor,
                                                border: Border.all(
                                                    color: CentralizedCubit.isDarkMode
                                                        ? Colors.white
                                                        : KColors.scoColor),
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(5.r))),
                                            padding: EdgeInsets.symmetric(
                                                vertical:
                                                ResponsiveUtil.isTablet(context)
                                                    ? 10
                                                    : 8,
                                                horizontal:
                                                ResponsiveUtil.isTablet(context)
                                                    ? 15
                                                    : 7),
                                            onChanged: (value) {
                                              Future.delayed(
                                                const Duration(seconds: 4),
                                                    () {
                                                  bloc.getHadithSearch(
                                                      wordKey: value);
                                                },
                                              );
                                            },
                                            itemSize:
                                            ResponsiveUtil.isTablet(context)
                                                ? 15.sp
                                                : 17,
                                            prefixInsets: const EdgeInsets.symmetric(horizontal: 10),
                                            onSubmitted: (value) {
                                              bloc.getHadithSearch(
                                                  wordKey: value);
                                            },
                                            placeholder: LocalizationManager.call('exams-search'),
                                            style: TextStyle(fontFamily: 'cairo', color: CentralizedCubit.isDarkMode ? KColors.whiteColor : KColors.blackColor, fontSize: ResponsiveUtil.isTablet(context) ? 15 : 10))),
                                  ),
                                  Card(
                                      color: CentralizedCubit.isDarkMode
                                          ? KColors.primaryColor
                                          : KColors.primary2Color,
                                      child: InkWell(
                                          onTap: () {
                                            bloc.getHadithSearch();
                                          },
                                          child: Padding(
                                              padding: EdgeInsets.symmetric(
                                                  vertical:
                                                  ResponsiveUtil.isTablet(
                                                      context)
                                                      ? 15
                                                      : 10,
                                                  horizontal:
                                                  ResponsiveUtil.isTablet(
                                                      context)
                                                      ? 10
                                                      : 10),
                                              child: Icon(Icons.search,
                                                  color:
                                                  CentralizedCubit.isDarkMode
                                                      ? KColors.whiteColor
                                                      : KColors.whiteColor,
                                                  size: ResponsiveUtil.isTablet(
                                                      context)
                                                      ? 25
                                                      : 18))))
                                ],
                              );
                            },
                          ),
                        ])))),

        const SliverToBoxAdapter(child: SizedBox(height: 15)),
        SliverToBoxAdapter(child: BlocBuilder<QuranAudioBloc, QuranAudioState>(
          builder: (BuildContext context, state) {
            if (state is QuranDetailsStateSuccess) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    TextWidget(
                        fontWeight: FontWeight.w700,
                        title: LocalizationManager.call("all-res"),
                        fontSize: 10.sp),
                    const Spacer(),
                  ],
                ),
              );
            } else if (state is QuranDetailsStateSuccess) {
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
        SliverToBoxAdapter(child: BlocBuilder<QuranAudioBloc, QuranAudioState>(
          builder: (BuildContext context, state) {




            if (state is QuranDetailsStateLoading) {
              return Center(child: KLoading.progressIOSIndicator());
            } else {
              return state.maybeMap(

                errorDetailsQuran: (value) => TextWidget(title: value.failure),
                quranDetailsLoading: (value) => KLoading.progressIOSIndicator(radius: 15),
                successDetailsQuran: (value) {
                  return GridView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: value.quranDetailsModal?.audioUrls.length,
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
                                // Navigator.pushNamed(
                                //     context, Routes.quranListRoute,
                                //     arguments: value.quranDetailsModal?.audioUrls[index].surahId);
                              },
                              child: Card(
                                shadowColor:
                                KColors.whiteColor.withOpacity(0.6),
                                elevation: 2,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 8, horizontal: 10),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment:MainAxisAlignment.center,
                                    children: [
                                      TextWidget(
                                        maxLines: 2,
                                        title:
                                      value.quranDetailsModal?.audioUrls[index].surahNameAr.toString()??"",
                                        color: CentralizedCubit.isDarkMode
                                            ? KColors.scoColor
                                            : KColors.primary2Color,
                                        fontWeight: FontWeight.w600,

                                        fontSize:
                                        MediaQuery.sizeOf(context).width > 600
                                            ? 6.sp
                                            : 10.sp,
                                      ),
                                    ],
                                  ),
                                ),
                              )),
                        );
                      });
                },
                orElse: () {
                  return const TextWidget(title: 'other errro ');
                },
              );
            }
          },
        )),
      ],
    );
  }
}
