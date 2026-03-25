
import 'package:muslimdaily/app/core/utils/style/k_helper.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../shard/exports/all_exports.dart';
import '../shard/widgets/ui_animations.dart';

class AzkarProvider extends ChangeNotifier {
  Future<void> launchInWeb(Uri url) async {
    if (await launchUrl(
      url,
      mode: LaunchMode.externalNonBrowserApplication,
    )) {
      throw Exception('Could not launch $url');
    }
  }

  AzkarProvider() {
    // حفظ القيم الأصلية لكل نوع أذكار
    _initialSleepRepate = List<int>.from(Azkary.azkarSleepRepate);
    _initialSabahRepate = List<int>.from(Azkary.azkarSabahRepate);
    _initialMassaRepate = List<int>.from(Azkary.azkarMassaRepate);
    _initialOtherRepate = List<int>.from(Azkary.azkarRepate);
    _initialPrayerRepate = List<int>.from(Azkary.azkarPrayerRepate);
    _initialQuranRepate = List<int>.from(Azkary.rokiaQuranRepe);
    _initialHazbNawawiRepate = List<int>.from(Azkary.azkarHazbNawawiRepate);
  }

  late List<int> _initialSleepRepate;
  late List<int> _initialSabahRepate;
  late List<int> _initialMassaRepate;
  late List<int> _initialOtherRepate;
  late List<int> _initialPrayerRepate;
  late List<int> _initialQuranRepate;
  late List<int> _initialHazbNawawiRepate;
  bool get isSleepDone => Azkary.azkarSleepRepate.every((c) => c <= 0);
  bool get isSabahDone => Azkary.azkarSabahRepate.every((c) => c <= 0);
  bool get isMessaDone => Azkary.azkarMassaRepate.every((c) => c <= 0);
  bool get isOtherDone => Azkary.azkarRepate.every((c) => c <= 0);
  bool get isPrayerDone => Azkary.azkarPrayerRepate.every((c) => c <= 0);
  bool get isQuranDone => Azkary.rokiaQuranRepe.every((c) => c <= 0);
  bool get isHazbNawawiDone => Azkary.azkarHazbNawawiRepate.every((c) => c <= 0);

  AzkarRemoteServices azkarRemoteServices = AzkarRemoteServices();
  int counter = 0;

  AllAzkarModel allAzkarModel = AllAzkarModel();
  List<Content> azkarMassaList = [];
  List<Content> azkarSabahList = [];
  List<Content> azkarPostPrayerList = [];
  List<Empty> test = [];
  List<Color> prayerColor = [
    const Color(0xff5ACC05),
    const Color(0xffCE82FF),
    const Color(0xff1CB0F6),
    const Color(0xff5ACC05),
    const Color(0xff5ACC05),
    const Color(0xff3F2305),
  ];

  bool isLoading = false;
  double long = 0, lat = 0;

  fetchAzkarMassa() async {
    isLoading = true;
    notifyListeners();
    azkarMassaList =
        await azkarRemoteServices.fetchAzkarData('azkar_massa.json');
    isLoading = false;
    notifyListeners();
  }

  fetchAzkarSabah() async {
    isLoading = true;
    notifyListeners();
    azkarSabahList =
        await azkarRemoteServices.fetchAzkarData('azkar_sabah.json');
    isLoading = false;
    notifyListeners();
  }

  fetchAzkarPostPrayer() async {
    isLoading = true;
    notifyListeners();
    azkarPostPrayerList =
        await azkarRemoteServices.fetchAzkarData('PostPrayer_azkar.json');
    isLoading = false;
    notifyListeners();
  }

  fetchAzkar() async {
    isLoading = true;
    notifyListeners();
    test = await azkarRemoteServices.fetchAzkar();
    isLoading = false;
    notifyListeners();
  }

  int quranIndex = 0;
  int zSabahIndex = 0;
  int zMessaIndex = 0;
  int zSleepIndex = 0;
  int zOtherIndex = 0;
  int zPrayerIndex = 0;
  int zHazbNawawiIndex = 0;

  // decrementQuran(quranCurrentIndex) {
  //   if (quranCurrentIndex >= 0 &&
  //       quranCurrentIndex < Azkary.rokiaQuranRepe.length) {
  //     Azkary.rokiaQuranRepe[quranCurrentIndex] -= 1;
  //     notifyListeners();
  //   }
  // }
  //
  // decrementSabah(zSabahIndex) {
  //   if (zSabahIndex >= 0 && zSabahIndex < Azkary.azkarSabahRepate.length) {
  //     Azkary.azkarSabahRepate[zSabahIndex] -= 1;
  //     notifyListeners();
  //   }
  // }
  //
  // decrementMessa(zMessaIndex) {
  //   if (zMessaIndex >= 0 && zMessaIndex < Azkary.azkarMassaRepate.length) {
  //     Azkary.azkarMassaRepate[zMessaIndex] -= 1;
  //     notifyListeners();
  //   }
  // }
  //
  // decrementOther(zOtherIndex) {
  //   if (zOtherIndex >= 0 && zOtherIndex < Azkary.azkarRepate.length) {
  //     Azkary.azkarRepate[zOtherIndex] -= 1;
  //     notifyListeners();
  //   }
  // }
  //
  // decrementSleep(zSleepIndex) {
  //   if (zSleepIndex >= 0 && zSleepIndex < Azkary.azkarSleepRepate.length) {
  //     Azkary.azkarSleepRepate[zSleepIndex] -= 1;
  //     notifyListeners();
  //   }
  // }
  void decrementQuran(int index) {
    if (index < 0 || index >= Azkary.rokiaQuranRepe.length) return;
    if (Azkary.rokiaQuranRepe[index] > 0) {
      Azkary.rokiaQuranRepe[index]--;
      notifyListeners();
    }
  }

  void decrementSabah(int index) {
    if (index < 0 || index >= Azkary.azkarSabahRepate.length) return;
    if (Azkary.azkarSabahRepate[index] > 0) {
      Azkary.azkarSabahRepate[index]--;
      notifyListeners();
    }
  }

  void decrementMessa(int index) {
    if (index < 0 || index >= Azkary.azkarMassaRepate.length) return;
    if (Azkary.azkarMassaRepate[index] > 0) {
      Azkary.azkarMassaRepate[index]--;
      notifyListeners();
    }
  }

  void decrementOther(int index) {
    if (index < 0 || index >= Azkary.azkarRepate.length) return;
    if (Azkary.azkarRepate[index] > 0) {
      Azkary.azkarRepate[index]--;
      notifyListeners();
    }
  }

  void decrementSleep(int index) {
    if (index < 0 || index >= Azkary.azkarSleepRepate.length) return;
    if (Azkary.azkarSleepRepate[index] > 0) {
      Azkary.azkarSleepRepate[index]--;
      notifyListeners();
    }
  }

  void decrementPrayer(int index) {
    if (index < 0 || index >= Azkary.azkarPrayerRepate.length) return;
    if (Azkary.azkarPrayerRepate[index] > 0) {
      Azkary.azkarPrayerRepate[index]--;
      notifyListeners();
    }
  }

  void decrementHazbNawawi(int index) {
    if (index < 0 || index >= Azkary.azkarHazbNawawiRepate.length) return;
    if (Azkary.azkarHazbNawawiRepate[index] > 0) {
      Azkary.azkarHazbNawawiRepate[index]--;
      notifyListeners();
    }
  }

  void resetSleep() {
    Azkary.azkarSleepRepate = List<int>.from(_initialSleepRepate);
    KHelper.showSuccess(message: "تم إعادة تعيين الأذكار إلى الصفر بنجاح.");

    notifyListeners();
  }

  void resetSabah() {
    Azkary.azkarSabahRepate = List<int>.from(_initialSabahRepate);
    KHelper.showSuccess(message: "تم إعادة تعيين الأذكار إلى الصفر بنجاح.");

    notifyListeners();
  }

  void resetMessa() {
    Azkary.azkarMassaRepate = List<int>.from(_initialMassaRepate);
    KHelper.showSuccess(message: "تم إعادة تعيين الأذكار إلى الصفر بنجاح.");

    notifyListeners();
  }

  void resetOther() {
    Azkary.azkarRepate = List<int>.from(_initialOtherRepate);
    KHelper.showSuccess(message: "تم إعادة تعيين الأذكار إلى الصفر بنجاح.");

    notifyListeners();
  }

  void resetPrayer() {
    Azkary.azkarPrayerRepate = List<int>.from(_initialPrayerRepate);
    notifyListeners();
    KHelper.showSuccess(message: "تم إعادة تعيين الأذكار إلى الصفر بنجاح.");
  }

  void resetQuran() {
    Azkary.rokiaQuranRepe = List<int>.from(_initialQuranRepate);
    KHelper.showSuccess(message: "تم إعادة تعيين الرقية إلى الصفر بنجاح.");

    notifyListeners();
  }

  void resetHazbNawawi() {
    Azkary.azkarHazbNawawiRepate = List<int>.from(_initialHazbNawawiRepate);
    KHelper.showSuccess(message: "تم إعادة تعيين الأذكار إلى الصفر بنجاح.");

    notifyListeners();
  }

  ///**** counter methods ****///

  incrementCount() {
    counter++;

    notifyListeners();
  }

  restCount() {
    counter = 0;
    notifyListeners();
  }

  removeCount() {
    counter = 0;

    notifyListeners();
  }

  //
  // notificationPlay() async {
  //
  //   notifyListeners();
  // }

  ///******      *******//////

  Widget showDialog() {
    // if(counter ==10){
    // var count = (counter/10+1);
    if (counter == 10) {
      return alertDefDialog('10', 'تسبيحات');
    } else if (counter == 50) {
      return alertDefDialog('50', 'تسبيحة');
    } else if (counter == 100) {
      return alertDefDialog('100', 'تسبيحة');
    } else if (counter == 300) {
      return alertDefDialog('300', 'تسبيحة');
    } else if (counter == 500) {
      return alertDefDialog('500', 'تسبيحة');
    } else if (counter == 1000) {
      return alertDefDialog('1000', 'تسبيحة');
    } else if (counter == 10000) {
      return alertDefDialog('10000', 'تسبيحة');
    } else if (counter == 20000) {
      return alertDefDialog('20000', 'تسبيحة');
    }
    return const SizedBox();
    // }
  }
}

zakarShared(
    {required String azkarConten,
    required String azkarContenDes,
    required String azkarContenRepate,
    required zakarType,
    required subjectType}) {
  Share.share(
    subject: subjectType,
    ' من $zakarType \n\n$azkarConten\n\n$azkarContenDes  \n\nمرات التكرار:  $azkarContenRepate',
  );
}

Widget alertDefDialog(String number, String type) {
  return AnimatedWrapper(
    type: UiAnimationType.shake,
    duration: const Duration(seconds: 5),
    child: AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 20,
        title: Column(
          children: [
            Image.asset(doneGif),
            Text(
              ' رائع لقد وصلت الي $number $type ',
              style:
                  TextStyle(
                  fontFamily: "cairo",fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ],
        )),
  );
}
