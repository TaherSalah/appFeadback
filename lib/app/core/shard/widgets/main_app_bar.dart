import 'dart:ui' as ui;

import 'package:muslimdaily/app/core/shard/widgets/ui_animations.dart';

import '../exports/all_exports.dart';

PreferredSizeWidget mainAppBarWidget(
    context, selectedFontSize, void Function(String?)? onChanged) {
  final bool isTablate = MediaQuery.sizeOf(context).width > 600;

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
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return AppBar(
    systemOverlayStyle: const SystemUiOverlayStyle(
      // statusBarColor: Color(0xffE1ECC8),
      statusBarColor: AppStyle.scondColors,
    ),
    title: Text(
      'رَفِيقُ المُسْلِمِ اليَوْمِيُّ',
      style: GoogleFonts.cairo(
          fontSize: isTablate ? 12.sp : 17.sp, fontWeight: FontWeight.bold),
    ),
    // backgroundColor: Colors.amber.withOpacity(0.8),
    // backgroundColor: const Color(0xffE1ECC8),
    backgroundColor: AppStyle.scondColors,
    actions: [
      Directionality(
        textDirection: ui.TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            children: [
              SizedBox(
                width: 100,
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
                              color: isDark ? Colors.white : Colors.black,
                            ));
                      }).toList(),
                      value: selectedFontSize,
                      onChanged: onChanged,
                      buttonStyleData: ButtonStyleData(
                        decoration: BoxDecoration(
                            border: Border.all(
                                color: AppStyle.scondColors, width: 1.5),
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(10.0)),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        height: 50,
                        width: MediaQuery.of(context).size.width / 1.2,
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
    centerTitle: true,
    bottom: TabBar(
        tabAlignment: TabAlignment.start,
        padding: EdgeInsets.all(isTablate ? 0 : 10),
        // indicator: BoxDecoration(
        // color: const Color(AppStyle.whiteColor),
        // borderRadius: BorderRadius.only(
        //     bottomLeft: Radius.circular(30.r),
        //     topRight: Radius.circular(30.r))),
        isScrollable: true,
        physics: const BouncingScrollPhysics(),
        tabs: [
          Tab(
            child: Text("القرأن الكريم",
                style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
          ),
          Tab(
            child: Text(AppString.KAzan,
                style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
          ),
          Tab(
            child: Text(AppString.Ksabah,
                style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
          ),
          Tab(
            child: Text(AppString.KMessa,
                style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
          ),
          Tab(
            child: Text(AppString.KPrayer,
                style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
          ),
          Tab(
            child: Text(AppString.KSleep,
                style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
          ),
          Tab(
            child: Text(AppString.KOtherZakar,
                style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
          ),
          Tab(
            child: Text(AppString.KRokia,
                style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
          ),
          Tab(
            child: Text(AppString.KCounter,
                style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
          ),
          Tab(
            child: Text(AppString.KAbout,
                style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
          ),
        ]),
  );
}
