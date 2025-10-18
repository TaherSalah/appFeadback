import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:muslimdaily/app/core/shard/widgets/ui_animations.dart';

import '../../core/shard/exports/all_exports.dart';



class RokiaScreen extends StatefulWidget {
  const RokiaScreen({super.key});
  @override
  State<RokiaScreen> createState() => _RokiaScreenState();
}

class _RokiaScreenState extends State<RokiaScreen> {
  var selectedFontSize;

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
    final con = Provider.of<AzkarProvider>(context);
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(MediaQuery.sizeOf(context).width>600? 70:50),
        child: AppBar(
          leading:  CupertinoNavigationBarBackButton(color:   Theme.of(context).brightness == Brightness.dark
              ? Colors.white
              : Colors.black,),
          centerTitle: true,
          actions: [
            Directionality(
              textDirection: ui.TextDirection.rtl,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0,vertical: 8),

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
                                  ));
                            }).toList(),
                            value: selectedFontSize,
                            onChanged: (value) {
                              selectedFontSize = value;
                              setState(() {});
                            },
                            buttonStyleData: ButtonStyleData(
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color: AppStyle.scondColors, width: 1.5),
                                  color: Theme.of(context).cardColor,
                                  borderRadius: BorderRadius.circular(10.0)),
                              padding:
                              const EdgeInsets.symmetric(horizontal: 16),
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
                                color: const Color(0xfffaedcd),

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
          title: Text(
            AppString.KRokia,
            style: GoogleFonts.cairo(
                color: Colors.green,
                fontWeight: FontWeight.bold,
                fontSize:
                MediaQuery.sizeOf(context).width > 600 ? 12.sp : 18.sp),
          ),
        ),
      ),
      // backgroundColor: Azkary.azkarMassaRepate.isEmpty? Colors.white :        AppStyle.bgColors,
      body: Azkary.rokiaQuranRepe.isEmpty? Center(
        child:  SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                  child: Image.asset(
                    doneZakar,
                  )),
              SizedBox(
                height: 10.h,
              ),
              Text(
                AppString.KRokiaDaialogText,
                style: GoogleFonts.cairo(
                    fontWeight: FontWeight.bold, fontSize: 15.sp),
              ),
              SizedBox(
                height: 15.h,
              ),
              Text(
                AppString.KRokiaFeaturesTitle,
                style: GoogleFonts.cairo(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 18.sp),
              ),
              SizedBox(
                height: 10.h,
              ),
              const Divider(
                color: Color(AppStyle.primaryColor),
                thickness: 2,
                indent: 150,
                endIndent: 150,
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  AppString.KZakarRokiaFeaturesDes,
                  textAlign: TextAlign.justify,
                  style: TextStyle(
                      fontFamily: AppStyle.fontFamily,
                      height: 1.8.h,
                      fontSize: 17.5.sp),
                ),
              )
            ],
          ),
        ),
      ) :  Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0.w),
          ),
          Expanded(
            child: ListView.separated(
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, quranCurrentIndex) {
                  return ScrollAppearAnimation(
                    duration: const Duration(milliseconds: 700),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          con.decrementQuran(quranCurrentIndex);
                        });
                      },
                      child: Directionality(
                        textDirection: TextDirection.rtl,
                        child: AzkerItemBuilder(
                          azkarTitle: Azkary.rokiaQuranTitle[quranCurrentIndex],
                          azkarDes: Azkary.rokiaQuranRawi[quranCurrentIndex],
                          fontSize: double.parse(selectedFontSize),
                          azkarRepate: con.quranIndex >=
                                  Azkary.rokiaQuranRepe[quranCurrentIndex]
                              ? '0'
                              : '${Azkary.rokiaQuranRepe[quranCurrentIndex]}',
                          color: con.quranIndex >=
                                  Azkary.rokiaQuranRepe[quranCurrentIndex]
                              ? const Color(AppStyle.yellowColor)
                              : const Color(AppStyle.primaryColor),
                        ),
                      ),
                    ),
                  );
                },
                separatorBuilder: (context, index) => SizedBox(
                      height: 15.h,
                    ),
                itemCount: Azkary.rokiaQuranTitle.length),
          )
        ],
      ),
    );
  }
}
