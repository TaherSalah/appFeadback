import 'package:muslimdaily/app/core/model/all_azkar_modal.dart';
import 'package:muslimdaily/app/core/model/azkar_massa_model.dart';
import 'package:muslimdaily/app/core/services/azkar_services.dart';
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
  }  AzkarProvider() {
    // حفظ القيم الأصلية مرة واحدة عند إنشاء الـ Provider
    _initialSleepRepate = List<int>.from(Azkary.azkarSleepRepate);
  }
  late List<int> _initialSleepRepate;
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

  decrementQuran(quranCurrentIndex) {
    if (quranCurrentIndex >= 0 &&
        quranCurrentIndex < Azkary.rokiaQuranRepe.length) {
      Azkary.rokiaQuranRepe[quranCurrentIndex] -= 1;
      notifyListeners();
    }
  }

  decrementSabah(zSabahIndex) {
    if (zSabahIndex >= 0 && zSabahIndex < Azkary.azkarSabahRepate.length) {
      Azkary.azkarSabahRepate[zSabahIndex] -= 1;
      notifyListeners();
    }
  }

  decrementMessa(zMessaIndex) {
    if (zMessaIndex >= 0 && zMessaIndex < Azkary.azkarMassaRepate.length) {
      Azkary.azkarMassaRepate[zMessaIndex] -= 1;
      notifyListeners();
    }
  }

  decrementOther(zOtherIndex) {
    if (zOtherIndex >= 0 && zOtherIndex < Azkary.azkarRepate.length) {
      Azkary.azkarRepate[zOtherIndex] -= 1;
      notifyListeners();
    }
  }

  // decrementSleep(zSleepIndex) {
  //   if (zSleepIndex >= 0 && zSleepIndex < Azkary.azkarSleepRepate.length) {
  //     Azkary.azkarSleepRepate[zSleepIndex] -= 1;
  //     notifyListeners();
  //   }
  // }
  void decrementSleep(int index) {
    if (index < 0 || index >= Azkary.azkarSleepRepate.length) return;

    if (Azkary.azkarSleepRepate[index] > 0) {
      Azkary.azkarSleepRepate[index]--;
      notifyListeners();
    }
  }

  void resetSleep() {
    Azkary.azkarSleepRepate = List<int>.from(_initialSleepRepate);
    notifyListeners();
  }
  decrementPrayer(zPrayerIndex) {
    if (zPrayerIndex >= 0 && zPrayerIndex < Azkary.azkarPrayerRepate.length) {
      Azkary.azkarPrayerRepate[zPrayerIndex] -= 1;
      notifyListeners();
    }
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
    duration: Duration(seconds: 5),
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
                  GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ],
        )),
  );
}
