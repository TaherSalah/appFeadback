import 'dart:ui' as ui;

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/shard/exports/all_exports.dart';
import '../../core/shard/widgets/ui_animations.dart';



class AzkarSabah extends StatefulWidget {
  const AzkarSabah({super.key});
  @override
  State<AzkarSabah> createState() => _AzkarSabahState();
}

int index = 0;

class _AzkarSabahState extends State<AzkarSabah> {
  var selectedFontSize;

  @override
  void initState() {
    super.initState();
    selectedFontSize = "20";
  }

  @override
  Widget build(BuildContext context) {
    final con = Provider.of<AzkarProvider>(context);
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
                                    color: isDark? Colors.white:Colors.black,
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
                                color:isDark? Theme.of(context).cardColor :  Color(0xfffaedcd),

                                // Set the background color for the dropdown menu
                                borderRadius: BorderRadius.circular(
                                    10.0), // Optional: rounded corners
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // const SizedBox(
                    //   width: 5,
                    // ),
                    // SizedBox(
                    //   width: 80,
                    //
                    //   child: AnimatedWrapper(
                    //     type: UiAnimationType.slideRight,
                    //     duration: const Duration(seconds: 1),
                    //     child: DropdownButtonHideUnderline(
                    //       child: DropdownButton2<String>(
                    //         isExpanded: true,
                    //         hint:  TextDefaultWidget(
                    //           textAlign: TextAlign.right,
                    //           title:selectedFontSize ,
                    //           fontSize: 15,
                    //           color: Color(0xff1A1A1A),
                    //         ),
                    //         items: const [
                    //           DropdownMenuItem(
                    //               value: "30",
                    //               child: TextDefaultWidget(
                    //                 textAlign: TextAlign.right,
                    //                 title: "30",
                    //                 fontSize: 12.5,
                    //               )),
                    //           DropdownMenuItem(
                    //               value: "15",
                    //
                    //               child: TextDefaultWidget(
                    //                 textAlign: TextAlign.right,
                    //                 title: "20",
                    //                 fontSize: 12.5,
                    //               )),
                    //           DropdownMenuItem(
                    //               value: "25",
                    //
                    //
                    //               child: TextDefaultWidget(
                    //                 textAlign: TextAlign.right,
                    //                 title: "25",
                    //                 fontSize: 12.5,
                    //               )),
                    //         ],
                    //         value: selectedFontSize,
                    //         // onChanged: (value) {
                    //         //   setState(() {
                    //         //     selectedFontSize = value!;
                    //         //   });
                    //         // },
                    //         onChanged: onChanged,
                    //         buttonStyleData: ButtonStyleData(
                    //           decoration: BoxDecoration(
                    //               border: Border.all(
                    //                   color: AppStyle.scondColors, width: 1.5),
                    //               color: Theme.of(context).cardColor,
                    //               borderRadius: BorderRadius.circular(10.0)),
                    //           padding:
                    //           const EdgeInsets.symmetric(horizontal: 16),
                    //           height: 50,
                    //           width: MediaQuery.of(context).size.width / 1.2,
                    //         ),
                    //         menuItemStyleData: MenuItemStyleData(
                    //           overlayColor: MaterialStateProperty.all(
                    //             Colors.grey.withOpacity(0.5),
                    //           ), // Use MaterialStateProperty
                    //           height: 50,
                    //         ),
                    //         dropdownStyleData: DropdownStyleData(
                    //           elevation: 1,
                    //           decoration: BoxDecoration(
                    //             color: const Color(0xfffaedcd),
                    //
                    //             // Set the background color for the dropdown menu
                    //             borderRadius: BorderRadius.circular(
                    //                 10.0), // Optional: rounded corners
                    //           ),
                    //         ),
                    //       ),
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ),
            ),
          ],
          title: Text(
            AppString.Ksabah,
            style: GoogleFonts.cairo(
                color: Colors.green,
                fontWeight: FontWeight.bold,
                fontSize:
                    MediaQuery.sizeOf(context).width > 600 ? 12.sp : 18.sp),
          ),
        ),
      ),

      // floatingActionButton: FloatingActionButton(
      //   backgroundColor: const Color(AppStyle.primaryColor),
      //   onPressed: () {
      //     navigate(context, const DoneScreen());
      //   },
      //   child: const Icon(
      //     Icons.done_all,
      //     color: Color(AppStyle.whiteColor),
      //   ),
      // ),
      // backgroundColor:
      //     Azkary.azkarMassaRepate.isEmpty ? Colors.white : AppStyle.bgColors,
      body: Azkary.azkarSabahRepate.isEmpty
          ? Center(
              child: SingleChildScrollView(
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
                      AppString.KSabahDaialogText,
                      style: GoogleFonts.cairo(
                          fontWeight: FontWeight.bold, fontSize: 15.sp),
                    ),
                    SizedBox(
                      height: 15.h,
                    ),
                    Text(
                      AppString.KZakarSabahFeaturesTitle,
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
                        AppString.doneText,
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
            )
          : Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0.w),
                  // child:   Directionality(
                  //   textDirection: ui.TextDirection.rtl,
                  //   child: Row(
                  //     children: [
                  //       Expanded(
                  //         child: AnimatedWrapper(
                  //           type: UiAnimationType.slideRight,
                  //           duration: const Duration(seconds: 1),
                  //           child: DropdownButtonHideUnderline(
                  //             child: DropdownButton2<String>(
                  //               isExpanded: true,
                  //               hint: const TextDefaultWidget(
                  //                 textAlign: TextAlign.right,
                  //                 title: 'اختر الدولة',
                  //                 fontSize: 15,
                  //                 color: Color(0xff1A1A1A),
                  //               ),
                  //               items: const [
                  //                 DropdownMenuItem(
                  //                   value: "30",
                  //                     child: TextDefaultWidget(
                  //                   textAlign: TextAlign.right,
                  //                   title: "30",
                  //                   fontSize: 12.5,
                  //                 )),
                  //                 DropdownMenuItem(
                  //                     value: "15",
                  //
                  //                     child: TextDefaultWidget(
                  //                   textAlign: TextAlign.right,
                  //                   title: "20",
                  //                   fontSize: 12.5,
                  //                 )),
                  //                 DropdownMenuItem(
                  //                     value: "25",
                  //
                  //
                  //                     child: TextDefaultWidget(
                  //                   textAlign: TextAlign.right,
                  //                   title: "25",
                  //                   fontSize: 12.5,
                  //                 )),
                  //               ],
                  //               value: selectedFontSize,
                  //               onChanged: (value) {
                  //                 setState(() {
                  //                   selectedFontSize = value!;
                  //                 });
                  //               },
                  //               buttonStyleData: ButtonStyleData(
                  //                 decoration: BoxDecoration(
                  //                     border: Border.all(
                  //                         color: AppStyle.scondColors, width: 1.5),
                  //                     color: Theme.of(context).cardColor,
                  //                     borderRadius: BorderRadius.circular(10.0)),
                  //                 padding:
                  //                 const EdgeInsets.symmetric(horizontal: 16),
                  //                 height: 50,
                  //                 width: MediaQuery.of(context).size.width / 1.2,
                  //               ),
                  //               menuItemStyleData: MenuItemStyleData(
                  //                 overlayColor: MaterialStateProperty.all(
                  //                   Colors.grey.withOpacity(0.5),
                  //                 ), // Use MaterialStateProperty
                  //                 height: 50,
                  //               ),
                  //               dropdownStyleData: DropdownStyleData(
                  //                 elevation: 1,
                  //                 decoration: BoxDecoration(
                  //                   color: const Color(0xfffaedcd),
                  //
                  //                   // Set the background color for the dropdown menu
                  //                   borderRadius: BorderRadius.circular(
                  //                       10.0), // Optional: rounded corners
                  //                 ),
                  //               ),
                  //             ),
                  //           ),
                  //         ),
                  //       ),
                  //       const SizedBox(
                  //         width: 10,
                  //       ),
                  //     ],
                  //   ),
                  // ),
                ),
                Expanded(
                  child: ListView.separated(
                      shrinkWrap: true,
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (context, zSabahIndex) {
                        return ScrollAppearAnimation(
                          duration: const Duration(milliseconds: 700),
                          child: GestureDetector(
                            onTap: () {
                              con.decrementSabah(zSabahIndex);
                            },
                            child: AzkerItemBuilder(
                              azkarTitle: Azkary.azkarSabah[zSabahIndex],
                              azkarDes: Azkary.azkarSabahDes[zSabahIndex],
                              fontSize: double.parse(selectedFontSize),
                              azkarRepate: con.zSabahIndex >=
                                      Azkary.azkarSabahRepate[zSabahIndex]
                                  ? '0'
                                  : '${Azkary.azkarSabahRepate[zSabahIndex]}',
                              color: con.zSabahIndex >=
                                      Azkary.azkarSabahRepate[zSabahIndex]
                                  ? const Color(AppStyle.yellowColor)
                                  : isDark?Colors.black: Color(AppStyle.primaryColor),
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (context, zSabahIndex) => SizedBox(
                            height: 15.h,
                          ),
                      itemCount: Azkary.azkarSabah.length),
                )
              ],
            ),

    );
  }
}







