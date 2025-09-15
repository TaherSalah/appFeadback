
import 'package:muslimdaily/app/features/Khatmah/view/ComplateKhatmaView.dart';
import 'package:muslimdaily/app/features/Khatmah/view/KhatmahDashboard.dart';
import 'package:muslimdaily/app/features/quran/view/widget/AyaBookmarkScreen.dart';
import 'package:muslimdaily/app/features/quran/view/widget/JozzsListView.dart';
import 'package:muslimdaily/app/features/quran/view/widget/hezbListView.dart';
import 'package:muslimdaily/app/features/quran/view/widget/quranLoveView.dart';
import 'package:muslimdaily/app/features/quran/view/widget/surahListView.dart';

import '../../../features/about_view/about.dart';
import '../../../features/azan_view/timeingScreen.dart';
import '../../../features/categories/categories_view.dart';
import '../../../features/categories/view/categories_details.dart';
import '../../../features/counter_view/counter_azkar.dart';
import '../../../features/hadith/hadith_view.dart';
import '../../../features/hadithDetails/hadith_details_view.dart';
import '../../../features/main_view/home.dart';
import '../../../features/main_view/widget/AllAzkarListView.dart';
import '../../../features/main_view/widget/QiblaDirection.dart';
import '../../../features/messa_view/azkar_massa.dart';
import '../../../features/other_view/azkar_other.dart';
import '../../../features/prayer_view/post_prayer_azkar.dart';
import '../../../features/quran/quranView.dart';

import '../../../features/quran/view/widget/AyaSearchScreen.dart';
import '../../../features/quran/view/widget/TafsirquranView.dart';
import '../../../features/rokia_view/rokia.dart';
import '../../../features/sabah_view/azkar_sabah.dart';
import '../../../features/sleep_view/sleep_azkar.dart';
import '../../../features/splash_view/splash.dart';
import '../../shard/exports/all_exports.dart';



class Routes {
  static const String splashRoute = "/";
  static const String onBoardingRoute = "/onBoarding";
  static const String homeRoute = "/allAhadith";
  static const String quranLoveRoute = "/quranLove";

  static const String hadithDetailsRoute = "/hadithDetails";
  static const String cateDetailsRoute = "/cateDetails";
  static const String trainingRoute = "/trainingView";
  static const String searchRoute = "/search";
  static const String myFavorites = "/myFavorites";
  static const String myCard = "/myCard";
  static const String categoriesRoute = "/Categories";
  static const String activeRoute = "/activeAccount";
  static const String combinedRoute = "/combinedView";
  static const String mainRoute = "/mainView";
  static const String blogRoute = "/blogView";
  static const String blogDetailsRoute = "/blogDetailsView";
  static const String dashboardRoute = "/dashboardView";
  static const String forgetPasswordRoute = "/forgetPasswordView";
  static const String forgetPFormRoute = "/forgetPasswordForm";
  static const String newPassFormRoute = "/newPasswordForm";
  static const String editProfileRoute = "/editProfile";
  static const String examDetailsRoute = "/examDetails";
  static const String userExamRoute = "/userExam";
  static const String bookMarksRoute = "/bookMarks";
  static const String aboutRoute = "/aboutView";
  static const String examReportRoute = "/examReportView";
  static const String reviewExamAnswersRoute = "/reviewExamAnswersView";
  static const String moreRoute = "/moreView";
  static const String cartRoute = "/cartView";
  static const String hizbeListScreenRoute = "/HizbeList";
  static const String jozzaListScreenRoute = "/jozzaList";
  static const String packageInfoRoute = "/packageInfoView";
  static const String quranKhitamRoute = "/QuranKhitamView";
  static const String tafsirQuranRoute = "/TafsirQuranView";
}

class RouteGenerator {
  static Route<dynamic> getRoute(
      RouteSettings settings,
      BuildContext context,
      ) {
    final arguments = settings.arguments;

    switch (settings.name) {
      case Routes.splashRoute:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
        case Routes.quranKhitamRoute:
        return MaterialPageRoute(builder: (_) => const QuranKhitamView());
        case Routes.hizbeListScreenRoute:
        return MaterialPageRoute(builder: (_) => const HizbeListScreen());
        case Routes.jozzaListScreenRoute:
        return MaterialPageRoute(builder: (_) => const JozzsListScreen());
        case Routes.tafsirQuranRoute:
        return MaterialPageRoute(builder: (_) => const TafsirQuranView());


      case Routes.categoriesRoute:
        return MaterialPageRoute(builder: (_) => const CategoriesView());
      case Routes.homeRoute:
        return MaterialPageRoute(builder: (_) => const HadithView());
        case Routes.quranLoveRoute:
        return MaterialPageRoute(builder: (_) => const QuranLoveView());
      case Routes.hadithDetailsRoute:
        return MaterialPageRoute(
            builder: (_) => HadithDetailsView(
              hadithId: arguments as dynamic,
            ));
      case Routes.cateDetailsRoute:
        return MaterialPageRoute(
            builder: (_) => CategoriesDetailsView(
              categoriesDetailsPrams: arguments as CategoriesDetailsPrams,
            ));

      case 'home':
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case '/azkarSabah':
        return MaterialPageRoute(builder: (_) => const AzkarSabah());

        case '/compplateKhatna':
        return MaterialPageRoute(builder: (_) => const ComplateKhatmaView());

      case '/azkarMassa':
        return MaterialPageRoute(builder: (_) => const AzkarMassa());
      case '/prayerAzkar':
        return MaterialPageRoute(builder: (_) => const PrayerAzkar());
      case '/surahListScreen':
        return MaterialPageRoute(builder: (_) => const QuranView());
       case '/ListScreen':
        return MaterialPageRoute(builder: (_) =>  SurahListScreen());
      case '/ayaSearchScreen':
        return MaterialPageRoute(builder: (_) =>  AyaSearchScreen());
        case '/ayaBookmarkScreen':
        return MaterialPageRoute(builder: (_) =>  AyaBookmarkScreen());
      case '/timingScreen':
        return MaterialPageRoute(builder: (_) => const TimingScreen());

      case '/allazkarlistview':
        return MaterialPageRoute(builder: (_) => const Allazkarlistview());
      case '/qiblaDirection':
        return MaterialPageRoute(builder: (_) => const QiblaDirection());

      case '/azkarCounter':
        return MaterialPageRoute(builder: (_) => const AzkarCounter());
      case '/sleepAzkar':
        return MaterialPageRoute(builder: (_) => const SleepAzkar());

      case '/rokiaScreen':
        return MaterialPageRoute(builder: (_) => const RokiaScreen());
      case '/azkarOthers':
        return MaterialPageRoute(builder: (_) => const AzkarOthers());
        case '/KhatmahHome':
        return MaterialPageRoute(builder: (_) => const KhatmahDashboard());

      case '/about':
        return MaterialPageRoute(builder: (_) => const About());

      default:
        return unDefinedRoute();
    }
  }

  static Route unDefinedRoute() {
    return MaterialPageRoute(
      // ignore: deprecated_member_use
      builder: (context) => WillPopScope(
        onWillPop: () async {
          Navigator.pop(context, true);
          return false;
        },
        child: Scaffold(
          appBar: AppBar(title: const Text("Page Not Found")),
          body: const Center(
            child: Text("Page Not Found"),
          ),
        ),
      ),
    );
  }
}

