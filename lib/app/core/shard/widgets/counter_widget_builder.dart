
import 'package:muslimdaily/app/features/counterView/counter_azkar.dart';

import '../exports/all_exports.dart';

class CounterWidgetBuilder extends StatefulWidget {
  const CounterWidgetBuilder({super.key});

  @override
  State<CounterWidgetBuilder> createState() => _CounterWidgetBuilderState();
}

class _CounterWidgetBuilderState extends State<CounterWidgetBuilder> {
  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<AzkarProvider>(context);
    final bool isTablate = MediaQuery.sizeOf(context).width > 600;

    return GestureDetector(
      onTap: () {
        controller.incrementCount();
      },
      child: Stack(alignment: Alignment.center, children: [
        Image.asset(
          'assets/images/countBg.jpg',
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
        ),
        Column(
          // crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const SizedBox(
              height: 10,
            ),
            SizedBox(
              height: MediaQuery.sizeOf(context).height / 5.6,
              width: MediaQuery.of(context).size.width,
              child: ListView.separated(
                  separatorBuilder: (context, index) => SizedBox(
                        width: 10.w,
                      ),
                  physics: const BouncingScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  itemCount: Azkary.azkarContent.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return Container(
                      color: Colors.transparent,
                      child: GestureDetector(
                        // onTap:() {
                        //   showDialog(
                        //     context: context,
                        //     builder: (BuildContext context) {
                        //       return AnimatedWrapper(type: UiAnimationType.slideBottom,
                        //         duration: const Duration(milliseconds: 600),
                        //         child: Dialog(
                        //           backgroundColor: AppStyle.bgColors,
                        //           shape: RoundedRectangleBorder(
                        //             borderRadius: BorderRadius.circular(12.0),
                        //             side: BorderSide(
                        //               color: AppStyle.primColors,
                        //               width: 2.w,
                        //             ),
                        //           ),
                        //           child: Container(
                        //             height: MediaQuery.of(context).size.height /4.5, // هنا بتحكم في الارتفاع
                        //             padding: const EdgeInsets.all(16),
                        //             child: Column(
                        //               mainAxisSize: MainAxisSize.min,
                        //               children: [
                        //                 Text(
                        //                   AppString.KFadlZakar,
                        //                   textAlign: TextAlign.center,
                        //                   style: GoogleFonts.cairo(
                        //                     color: Colors.black,
                        //                     fontSize: 19.sp,
                        //                   ),
                        //                 ),
                        //                 const SizedBox(height: 16),
                        //                 SingleChildScrollView(
                        //                   child: Text(
                        //                     Azkary.azkarContent[index],
                        //                     style: GoogleFonts.cairo(fontSize: 14.sp),
                        //                     textDirection: TextDirection.rtl,
                        //                   ),
                        //                 ),
                        //                 const SizedBox(height: 16),
                        //                 ElevatedButton(
                        //                   onPressed: () {
                        //                     Navigator.pop(context, 'OK');
                        //                   },
                        //                   style: ElevatedButton.styleFrom(
                        //                     backgroundColor: const Color(0xffF7FFE5),
                        //                   ),
                        //                   child: const Text(AppString.KDone),
                        //                 ),
                        //               ],
                        //             ),
                        //           ),
                        //         ),
                        //       );
                        //     },
                        //   );
                        //
                        // } ,
                        child: Card(
                            shape: OutlineInputBorder(
                                borderSide: BorderSide(
                              color: const Color(AppStyle.whiteColor),
                              width: 3.5.w,
                            )),
                            color: Colors.black.withOpacity(0.5),
                            elevation: 10,
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8.w, vertical: 10.h),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(Azkary.azkarDescription[index],
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.cairo(
                                          fontSize: isTablate ? 9.sp : 15.sp,
                                          color: Colors.white)),
                                  Text(
                                      '  مرات التسبيح(${Azkary.azkarCount[index]}) مرة',
                                      style: GoogleFonts.cairo(
                                          fontSize: isTablate ? 9.sp : 12.sp,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600)),
                                ],
                              ),
                            )),
                      ),
                    );
                  }),
            ),
            // Text(AppString.KCounter,
            //     style: GoogleFonts.cairo(
            //         fontSize: 30.sp,
            //         color: const Color(AppStyle.whiteColor),
            //         fontWeight: FontWeight.bold)),
            // countDivider(),
            // SizedBox(
            //   height: 12.h,
            // ),
            // Card(
            //   elevation: 10,
            //   color: Colors.black.withOpacity(0.5),
            //   shape: const OutlineInputBorder(
            //       borderSide: BorderSide(
            //           color: Color(AppStyle.whiteColor), width: 5)),
            //   child: Container(
            //     decoration: BoxDecoration(
            //       borderRadius: BorderRadius.circular(22),
            //     ),
            //     padding: const EdgeInsets.all(25),
            //     child: Text('${controller.counter}',
            //         textAlign: TextAlign.center,
            //         style: GoogleFonts.cairo(
            //             fontWeight: FontWeight.bold,
            //             fontSize: 25.sp,
            //             color: Colors.white)),
            //   ),
            // ),
            SizedBox(
              height: 20.h,
            ),
            const Expanded(
                child: SizedBox(height: 130, child: TasbeehRealPlus())),

            // Row(
            //   crossAxisAlignment: CrossAxisAlignment.center,
            //   mainAxisAlignment: MainAxisAlignment.center,
            //   children: [
            //     InkWell(
            //       onTap: () {
            //         controller.incrementCount();
            //       },
            //       child: CircleAvatar(
            //           radius:isTablate?50: 35,
            //           backgroundColor: Colors.white,
            //           child: Text(AppString.KSabhText,
            //               style: GoogleFonts.cairo(
            //                   fontSize: isTablate ? 17.sp :23.sp, color: Colors.black))),
            //     ),
            //     SizedBox(
            //       width: 85.w,
            //     ),
            //     InkWell(
            //       onTap: () {
            //         controller.restCount();
            //       },
            //       child: CircleAvatar(
            //           backgroundColor: Colors.deepOrange,
            //           radius:isTablate ?20.r: 25.r,
            //           child: Text(AppString.KRestText,
            //               style: GoogleFonts.cairo(
            //                   fontSize:isTablate?11.sp : 15.sp,
            //                   color: Colors.white,
            //                   fontWeight: FontWeight.w500))),
            //     ),
            //     //
            //     // ElevatedButton(
            //     //     style: ButtonStyle(
            //     //         shape: MaterialStatePropertyAll(
            //     //             BeveledRectangleBorder(
            //     //                 borderRadius:
            //     //                     const BorderRadius.all(Radius.circular(
            //     //                   0,
            //     //                 )),
            //     //                 side: BorderSide(
            //     //                     width: 1.5.w,
            //     //                     color:
            //     //                         const Color(AppStyle.whiteColor)))),
            //     //         backgroundColor: const MaterialStatePropertyAll(
            //     //             Color(AppStyle.secondaryColor))),
            //     //     onPressed: () {
            //     //       controller.incrementCount();
            //     //     },
            //     //     child: Text(AppString.KSabahText,
            //     //         style: GoogleFonts.cairo(
            //     //             fontSize: 25.sp, color: Colors.black))),
            //
            //     // ElevatedButton(
            //     //     style: ButtonStyle(
            //     //         shape: MaterialStatePropertyAll(
            //     //             BeveledRectangleBorder(
            //     //                 borderRadius:
            //     //                     const BorderRadius.all(Radius.circular(
            //     //                   8,
            //     //                 )),
            //     //                 side: BorderSide(
            //     //                     width: 1.5.w,
            //     //                     color:
            //     //                         const Color(AppStyle.whiteColor)))),
            //     //         elevation: const MaterialStatePropertyAll(8),
            //     //         backgroundColor: MaterialStatePropertyAll(
            //     //             const Color(AppStyle.primaryColor)
            //     //                 .withOpacity(0.8))),
            //     //     onPressed: () {
            //     //       controller.restCount();
            //     //     },
            //     //     child: Row(
            //     //       children: [
            //     //         Text('تصفير',
            //     //             style: GoogleFonts.cairo(
            //     //                 fontSize: 25.sp, color: Colors.black)),
            //     //       ],
            //     //     ))
            //   ],
            // ),
          ],
        ),
      ]),
    );
  }
}
