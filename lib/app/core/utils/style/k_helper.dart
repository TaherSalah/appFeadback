// ignore_for_file: deprecated_member_use

import 'dart:io';

import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart' as intl;
import 'package:muslimdaily/app/core/utils/style/responsive_util.dart';

import 'package:path_provider/path_provider.dart';

import '../../localization/localization_manager.dart';
import '../../widgets/custom_text_widget.dart';
import '../log.dart';
import 'k_color.dart';

class KHelper {
  static BuildContext? _context;
  static KHelper? _instance;

  KHelper._internal() {
    _instance = this;
  }

  static KHelper of(BuildContext context) {
    _context = context;
    return _instance ?? KHelper._internal();
  }

  /// Icons data *****************************
  static const IconData calculate = Icons.calculate_outlined;
  static const IconData fingerprint = Icons.local_fire_department_outlined;
  static const IconData home = Icons.home;
  static const double btnRadius = 8.0;
  static double hPadding = 26;
  static double listPadding = 15;
  static ShapeBorder btnShape =
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(btnRadius));

  BoxDecoration get shimmerBox {
    return BoxDecoration(
        color: KColors.of(_context!).elevatedBox.withOpacity(.2),
        borderRadius: BorderRadius.circular(btnRadius));
  }

  BoxDecoration get elevatedBox {
    return BoxDecoration(
        color: KColors.of(_context!).elevatedBox.withOpacity(.6),
        borderRadius: BorderRadius.circular(KHelper.btnRadius),
        border: Border.all(color: KColors.of(_context!).border));
  }

  Gradient get shimmerGradient {
    return LinearGradient(
      colors: [
        KColors.of(_context!).shadow.withOpacity(.2),
        KColors.of(_context!).shadow.withOpacity(.5)
      ],
    );
  }

  ///***  Show Toast message ***///
  static showError(
      {required String message,
      Color? backgroundColor,
      ToastGravity? gravity,
      Toast? toastLength,
      Color? textColor,
      double? fontSize}) async {
    Fluttertoast.showToast(
        msg: message,
        toastLength: toastLength ?? Toast.LENGTH_LONG,
        gravity: gravity ?? ToastGravity.SNACKBAR,
        timeInSecForIosWeb: 2,
        backgroundColor: backgroundColor ?? Colors.redAccent,
        textColor: textColor ?? Colors.white,
        fontSize: fontSize ?? 16.sp);
  }

  static showSuccess(
      {required String message,
      Color? backgroundColor,
      ToastGravity? gravity,
      Toast? toastLength,
      Color? textColor,
      double? fontSize}) async {
    Fluttertoast.showToast(
        msg: message,
        toastLength: toastLength ?? Toast.LENGTH_LONG,
        gravity: gravity ?? ToastGravity.SNACKBAR,
        timeInSecForIosWeb: 2,
        backgroundColor: backgroundColor ?? Colors.green,
        textColor: textColor ?? Colors.white,
        fontSize: fontSize ?? 16.sp);
  }

  static showErrorFlushBar(BuildContext context, String message) {
    Color backgroundColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.red.shade900 // داكن في الوضع الليلي
        : Colors.redAccent; // فاتح في الوضع النهاري

    Flushbar(
      message: message,
      icon: const Icon(Icons.error_outline, color: Colors.white),
      backgroundColor: backgroundColor,
      flushbarPosition: FlushbarPosition.TOP,
      duration: const Duration(seconds: 3),
      flushbarStyle: FlushbarStyle.FLOATING,
      margin: const EdgeInsets.all(8),
      borderRadius: BorderRadius.circular(8),
    ).show(context);
  }

  static showSuccessFlushBar(BuildContext context, String message) {
    Color backgroundColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.green.shade900 // داكن في الوضع الليلي
        : Colors.green; // فاتح في الوضع النهاري

    Flushbar(
      message: message,
      icon: const Icon(Icons.check_circle_outline, color: Colors.white),
      backgroundColor: backgroundColor,
      flushbarPosition: FlushbarPosition.TOP,
      duration: const Duration(seconds: 3),
      flushbarStyle: FlushbarStyle.FLOATING,
      margin: const EdgeInsets.all(8),
      borderRadius: BorderRadius.circular(8),
    ).show(context);
  }

  static showWarningFlushBar(BuildContext context, String message) {
    Color backgroundColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.amber.shade800 // داكن في الوضع الليلي
        : Colors.amber; // فاتح في الوضع النهاري

    Flushbar(
      message: message,
      icon: const Icon(Icons.warning_amber_rounded, color: Colors.white),
      backgroundColor: backgroundColor,
      flushbarPosition: FlushbarPosition.TOP,
      duration: const Duration(seconds: 3),
      flushbarStyle: FlushbarStyle.FLOATING,
      margin: const EdgeInsets.all(8),
      borderRadius: BorderRadius.circular(8),
    ).show(context);
  }

  static showNeutralFlushBar(BuildContext context, String message) {
    Color backgroundColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.grey.shade700 // داكن في الوضع الليلي
        : Colors.grey.shade300; // فاتح في الوضع النهاري

    Flushbar(
      message: message,
      icon: const Icon(Icons.info_outline, color: Colors.white),
      backgroundColor: backgroundColor,
      flushbarPosition: FlushbarPosition.TOP,
      duration: const Duration(seconds: 3),
      flushbarStyle: FlushbarStyle.FLOATING,
      margin: const EdgeInsets.all(8),
      borderRadius: BorderRadius.circular(8),
    ).show(context);
  }

  ///***  get time AmOrPm ***///
  static final timeAmOrPm = DateTime.now().hour < 12 ? 'am' : "pm";

  ///*** says good morning ***///
  static final String greeting = DateTime.now().hour < 12
      ? 'good morning'
      : DateTime.now().hour < 17
          ? "good afternoon"
          : "good evening";

  ///*** get just  first character from name  ***///
  static String shortName(String name) {
    List<String> names = name.trim().split(" ");
    return names.map((e) => e[0]).join();
  }

  ///*** get days Between  ***///
  static int daysBetween({required DateTime to}) {
    return to.difference(DateTime.now()).inDays;
  }

  ///*** show Bottom Sheet ***///

  static showBottomSheetCustomWidget({
    bool showDivider = true,
    required BuildContext context,
    required Widget child,
    bool? isDismissible = true,
    Color? backgroundColor,
    double? minChildSize,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: backgroundColor ?? Colors.transparent,
      isScrollControlled: true,
      isDismissible: isDismissible ?? true,
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.5, // Start with half the screen height
          minChildSize: minChildSize ?? 0.2, // Minimum height when collapsed
          maxChildSize: 0.9, // Maximum height when expanded
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(50)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.17),
                    offset: const Offset(0.0, 3.0),
                    blurRadius: 6.0,
                    spreadRadius: 6.0,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize
                    .min, // Make the column take only the space it needs
                children: [
                  const SizedBox(height: 12.0),
                  showDivider
                      ? Container(
                          width: 70.0,
                          height: 3.0,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(2.0),
                          ),
                        )
                      : const SizedBox(),
                  const SizedBox(height: 24.0),
                  Expanded(
                    child: SingleChildScrollView(
                      controller:
                          scrollController, // Connect the scroll controller
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 13.0),
                        child: child,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  static showBottomSheetCustomWidget2({
    bool showDivider = true,
    required BuildContext context,
    bool? isDismissible = true,
    Color? backgroundColor,
    double? maxChildSize,
    required Widget Function(BuildContext sheetContext) child,
    double? titleSize,
    double? minChildSize,
    double? initialChildSize,
    String? modelSheetTitle,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: backgroundColor ?? Colors.transparent,
      isScrollControlled: true, // ✅ لازم
      isDismissible: isDismissible ?? true,
      useSafeArea: true, // ✅ يحترم الحواف
      builder: (BuildContext sheetContext) {
        final bottomInset = MediaQuery.of(sheetContext)
            .viewInsets
            .bottom; // ✅ خُد ارتفاع الكيبورد

        return AnimatedPadding(
          // ✅ يرفع الـsheet فوق الكيبورد
          padding: EdgeInsets.only(bottom: bottomInset),
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          child: DraggableScrollableSheet(
            expand: false, // ✅ مهم مع الكيبورد
            initialChildSize: initialChildSize ?? 0.6,
            minChildSize: minChildSize ?? 0.3,
            maxChildSize: maxChildSize ?? 0.95, // ✅ اسمح بارتفاع كبير
            builder: (ctx, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: Theme.of(sheetContext).cardColor,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(50)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      offset: const Offset(0, 3),
                      blurRadius: 8,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    if (showDivider)
                      Container(
                        width: 70,
                        height: 3,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: TextWidget(
                        title: modelSheetTitle ?? "",
                        fontSize: titleSize,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // ✅ خلي المحتوى قابل للتمرير ويقفل الكيبورد عند السحب
                    Expanded(
                      child: SingleChildScrollView(
                        controller: scrollController,
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag, // ✅
                        padding: const EdgeInsets.symmetric(horizontal: 13),
                        child:
                            child(sheetContext), // ✅ مرّر sheetContext الصحيح
                      ),
                    ),

                    const SizedBox(height: 12), // مسافة صغيرة أسفل
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  ///***Cupertino Full Width Alert Dialog ***///
  static void showFullWidthAlertDialog({
    required BuildContext context,
    String? title,
    String? noAction,
    String? yesAction,
    required String message,
    required String content,
    required void Function() onPressed,
  }) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => Container(
        width: ResponsiveUtil.isTablet(context)
            ? MediaQuery.sizeOf(context).width / 1.5
            : MediaQuery.sizeOf(context).width / 1,
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 40.h),
        child: CupertinoPopupSurface(
          isSurfacePainted: true,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (title != null && title.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: TextWidget(
                      title: title,
                      fontSize: ResponsiveUtil.isTablet(context) ? 8.sp : 14.sp,
                      textAlign: TextAlign.center,
                    ),
                  ),
                TextWidget(
                  title: content,
                  fontSize: ResponsiveUtil.isTablet(context) ? 7.5.sp : 14.sp,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    CupertinoButton(
                      color: KColors.greyLightColor,
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: TextWidget(
                          fontSize:
                              ResponsiveUtil.isTablet(context) ? 7.sp : 11.sp,
                          title: noAction ?? LocalizationManager.call('no')),
                    ),
                    ResponsiveUtil.isTablet(context)
                        ? const SizedBox(width: 0)
                        : const SizedBox(width: 10),
                    CupertinoButton(
                      color: KColors.primaryColor,
                      onPressed: onPressed,
                      child: TextWidget(
                          fontSize:
                              ResponsiveUtil.isTablet(context) ? 7.sp : 11.sp,
                          color: KColors.whiteColor,
                          title: yesAction ?? LocalizationManager.call('yes')),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  ///*** Cupertino Alert Dialog  ***///
  static void showAlertDialog({
    required BuildContext context,
    Widget? header,
    content,
    void Function()? yesOnPressed,
    void Function()? btn2OnPressed,
    String? btn1,
    String? btn2,
  }) {
    showCupertinoDialog<void>(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
                title: header ?? const SizedBox(),
                content: TextWidget(
                    title: content.toString(),
                    fontSize: ResponsiveUtil.isTablet(context) ? 7.sp : 14.sp),
                actions: <CupertinoDialogAction>[
                  CupertinoDialogAction(

                      /// This parameter indicates this action is the default,
                      /// and turns the action's text to bold text.
                      isDefaultAction: true,
                      onPressed: btn2OnPressed ??
                          () {
                            Navigator.pop(context);
                          },
                      child: TextWidget(
                          title: btn1 ?? LocalizationManager.call('no'),
                          fontSize:
                              ResponsiveUtil.isTablet(context) ? 8.sp : 12.sp)),
                  CupertinoDialogAction(

                      /// This parameter indicates the action would perform
                      /// a destructive action such as deletion, and turns
                      /// the action's text color to red.
                      isDestructiveAction: true,
                      onPressed: yesOnPressed ??
                          () {
                            Navigator.pop(context);
                          },
                      child: TextWidget(
                          title: btn2 ?? LocalizationManager.call('yes'),
                          fontSize:
                              ResponsiveUtil.isTablet(context) ? 8.sp : 12.sp))
                ]));
  }

  ///*** get Image Source ***///
  static Future<bool?> _getImageSource(BuildContext context) async {
    bool? isGallery;
    await showCupertinoModalPopup(
        context: context,
        barrierDismissible: true,
        useRootNavigator: true,
        builder: (context) {
          return CupertinoAlertDialog(
            title: Padding(
              padding: EdgeInsets.all(10.w),
              child: const TextWidget(title: 'اختيار الصورة'),
            ),
            actions: [
              Material(
                  color: KColors.greyColor.withOpacity(.1),
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                      isGallery = true;
                    },
                    child: Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.symmetric(
                            horizontal: 10.w, vertical: 20.h),
                        child: const TextWidget(title: 'من المعرض')),
                  )),
              Material(
                  color: KColors.greyColor.withOpacity(.1),
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                      isGallery = false;
                    },
                    child: Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.symmetric(
                            horizontal: 10.w, vertical: 20.h),
                        child: const TextWidget(title: 'من الكاميرا')),
                  )),
            ],
          );
        });
    return isGallery;
  }

  // ///*** pick Image ***///
  // static Future<File?> pickImage({required BuildContext context}) async {
  //   bool? isGallery = await KHelper._getImageSource(context);
  //   if (isGallery == null) return null;
  //   final XFile? file = await ImagePicker().pickImage(
  //       source: isGallery ? ImageSource.gallery : ImageSource.camera);
  //   print('file${file?.path}');
  //
  //   if (file != null) return File(file.path);
  //   return null;
  // }
  //
  // ///*** pick Images ***///
  // static Future<List<File>> pickImages({required BuildContext context}) async {
  //   final List<XFile> files =
  //       await ImagePicker().pickMultiImage(imageQuality: 75);
  //   return files.map((e) => File(e.path)).toList();
  // }
  //
  // ///*** pick Video ***///
  // static Future<File?> pickVideo({required BuildContext context}) async {
  //   bool? isGallery = await KHelper._getImageSource(context);
  //   if (isGallery == null) return null;
  //   final XFile? file = await ImagePicker().pickVideo(
  //       source: isGallery ? ImageSource.gallery : ImageSource.camera);
  //   if (file != null) return File(file.path);
  //   return null;
  // }

  ///*** get File From Url ***///
  static Future<File?> getFileFromUrl(String? url) async {
    if (url == null) return null;
    try {
      final filename = url.substring(url.lastIndexOf("/") + 1);
      var request = await HttpClient().getUrl(Uri.parse(url));
      var response = await request.close();
      var bytes = await consolidateHttpClientResponseBytes(response);
      var dir = await getApplicationDocumentsDirectory();
      File file = File("${dir.path}/$filename");
      return await file.writeAsBytes(bytes, flush: true);
    } catch (e) {
      return null;
    }
  }

  ///*** get File Size ***///
  static String getFileSize(File? file) {
    if (file == null) return "0";
    return (file.lengthSync() / 1024).toStringAsFixed(2);
  }

  ///*** get File Name ***///
  static String getFileName(File? file) {
    if (file == null) return "0";
    return file.path.split("/").last;
  }

  ///*** get Online File Size ***///
  static Future getOnlineFileSize(String? url) async {
    if (url == null) return null;
    http.Response r = await http.head(Uri.parse(url));
    return r.headers["content-length"];
  }

  ///*** pick Date ***///
  static Future<DateTime> pickDate({required BuildContext context}) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: KColors.primaryColor,
              onPrimary: KColors.whiteColor,
              onSurface: KColors.blackColor,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      return picked;
    }
    return DateTime.now();
  }

  ///*** pick Time ***///
  static Future<TimeOfDay> pickTime(context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: KColors.primaryColor,
              onPrimary: KColors.whiteColor,
              onSurface: KColors.blackColor,
            ),
          ),
          child: child!,
        );
      },
    );
    if (pickedTime != null) {
      return pickedTime;
    }
    return TimeOfDay.now();
  }

  static handelDate({required String parcDate, bool? isEng}) {
    DateTime parsedDate = DateTime.parse(parcDate);
    String formattedDate =
        intl.DateFormat('d MMM yyyy  EEEE', isEng == true ? "en" : "ar")
            .format(parsedDate);
    return formattedDate;
  }

  ///*** is Link Image ***///
  static bool isLinkImage(String? link) {
    if (link == null) return false;
    List extensions = [".jpg", ".gif", ".png", ".jpeg"];
    for (var value in extensions) {
      if (link.toLowerCase().contains(value.toLowerCase())) return true;
    }
    return false;
  }

  ///*** is Link Sound ***///
  static bool isLinkSound(String? link) {
    if (link == null) return false;
    List extensions = [".mp4", ".m4a", ".WebM", ".wav", ".MP3", ".AAC"];
    for (String value in extensions) {
      if (link.toLowerCase().contains(value.toLowerCase())) return true;
    }
    return false;
  }

  ///*** download file ***///
  // static Future download(String url, String finalName,
  //     {required void Function(int, int) updateProgress,
  //     required void Function(String url) onDone}) async {
  //   String path = await _getPath();
  //   path = '$path/$finalName';
  //   final options = DownloaderUtils(
  //     progressCallback: updateProgress,
  //     file: File(path),
  //     progress: ProgressImplementation(),
  //     onDone: () {
  //       log('on  Done');
  //       openFile(path);
  //       onDone(path);
  //     },
  //     deleteOnCancel: true,
  //   );
  //   await Flowder.download(
  //     url,
  //     options,
  //   );
  // }

  static Future<String> _getPath() async {
    Directory path;
    path = await getTemporaryDirectory();

    log("Platform.pathSeparator : ${Platform.pathSeparator}");
    String localPath = path.path;

    final savedDir = Directory(localPath);
    bool hasExisted = await savedDir.exists();
    log("hasExisted: $hasExisted");
    if (!hasExisted) {
      savedDir.create();
    }

    return localPath;
  }

  ///*** open File ***///
  // static void openFile(String? path) async {
  //   if (await Permission.storage.request().isGranted || !Platform.isAndroid) {
  //     log("open path", msg: path);
  //     OpenFile.open(path).then((value) {
  //       log("Open file");
  //     });
  //   }
  // }
}

// static Future<File?> pickFile( {required BuildContext context}) async {
//    final  pickedFile = await FilePicker.platform.pickFiles(allowMultiple: false);
//   if (pickedFile == null) return null;
//   if (pickedFile.files.first.path != null) {
//     return File(pickedFile.files.first.path!);
//   }
//   return null;
// }

// static String getTimeAgo(DateTime? time, {bool short = false}) {
//   if (time == null) return "";
//   String currentLng = SharedPref.getCurrentLang() ?? "ar";
//   bool isAr = currentLng == "ar";
//   timeago.setLocaleMessages(
//     "$currentLng${short ? "_short" : ""}",
//     (short && isAr)? timeago.ArShortMessages():
//     (short && !isAr)? timeago.EnShortMessages():
//     (isAr)? timeago.ArMessages(): timeago.EnMessages(),
//   );
//   return timeago.format(time, locale: "$currentLng${short ? "_short" : ""}");
// }

// extension HexColor on Color {
//   String toHex({bool leadingHashSign = true}) => '${leadingHashSign ? '#' : ''}'
//       '${alpha.toRadixString(16).padLeft(2, '0')}'
//       '${red.toRadixString(16).padLeft(2, '0')}'
//       '${green.toRadixString(16).padLeft(2, '0')}'
//       '${blue.toRadixString(16).padLeft(2, '0')}';
// }
//
// extension ContextExtensions on BuildContext {
//   bool get mounted {
//     try {
//       widget;
//       return true;
//     } catch (e) {
//       return false;
//     }
//   }
// }
//
// extension OnTapImageExtension on Image {
//   Widget showOnTap() {
//     return InkWell(
//       // onTap: (){
//       //   Modular.to.push(MaterialPageRoute(builder: (_)=> ShowImagesWidget(
//       //     images: const [],
//       //     image: image,
//       //   )));
//       // },
//       child: this,
//     );
//   }
// }
//
// extension OnTapFadeImageExtension on FadeInImage {
//   Widget showOnTap() {
//     return InkWell(
//       // onTap: (){
//       //   Modular.to.push(MaterialPageRoute(builder: (_)=> ShowImagesWidget(
//       //     images: const [],
//       //     image: image,
//       //   )));
//       // },
//       child: this,
//     );
//   }
// }
