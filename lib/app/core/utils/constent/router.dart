import 'package:muslimdaily/app/features/Khatmah/view/ComplateKhatmaView.dart';
import 'package:muslimdaily/app/features/Khatmah/view/KhatmahDashboard.dart';
import 'package:muslimdaily/app/features/channal/view/QuranChannalPlayerView.dart';
import 'package:muslimdaily/app/features/mainView/MainView.dart';
import 'package:muslimdaily/app/features/mainView/view/FajrAlarmScreen.dart';
import 'package:muslimdaily/app/features/mainView/widget/AllAzkarListView.dart';
import 'package:muslimdaily/app/features/otherView/azkar_other.dart';
import 'package:muslimdaily/app/features/prayerView/post_prayer_azkar.dart';
import 'package:muslimdaily/app/features/quran/view/widget/AyaBookmarkScreen.dart';
import 'package:muslimdaily/app/features/quran/view/widget/JozzsListView.dart';
import 'package:muslimdaily/app/features/quran/view/widget/hezbListView.dart';
import 'package:muslimdaily/app/features/quran/view/widget/quranLoveView.dart';
import 'package:muslimdaily/app/features/quran/view/widget/surahListView.dart';
import 'package:muslimdaily/app/features/radio/QuranRadioView.dart';
import 'package:muslimdaily/app/features/radio/view/QuranRadioPlayerView.dart';
import 'package:muslimdaily/app/features/radio/view/widget/RadioSearchScreen.dart';
import 'package:muslimdaily/app/features/rokiaView/rokia.dart';
import 'package:muslimdaily/app/features/sabahView/azkar_sabah.dart';
import 'package:muslimdaily/app/features/splashView/splash.dart';
import 'package:muslimdaily/app/features/zakatView/zakat_calculator_view.dart';
import 'package:muslimdaily/app/features/kids/view/KidsStoriesScreen.dart';

import '../../../features/WirdView/WirdHomeScreen.dart';
import '../../../features/aboutView/about.dart';
import '../../../features/aboutView/SupportDeveloperScreen.dart';
import '../../../features/azanView/azanView.dart';
import '../../../features/categories/categories_view.dart';
import '../../../features/categories/view/categories_details.dart';
import '../../../features/charity/RecurringCharityScreen.dart';
import '../../../features/counterView/counter_azkar.dart';
import '../../../features/hadith/hadith_view.dart';
import '../../../features/hadithDetails/hadith_details_view.dart';
import '../../../features/QiblaView/QiblaDirection.dart';
import '../../../features/messaView/azkar_massa.dart';
import '../../../features/quran/quranView.dart';
import '../../../features/hadith_books/presentation/nine_books_screen.dart';
import '../../../features/hadith_books/presentation/details/collection_details_screen.dart';
import '../../../features/hadith_books/presentation/read_view.dart';

import '../../../features/quran/view/widget/AyaSearchScreen.dart';
import '../../../features/quran/view/widget/TafsirquranView.dart';
import '../../../features/settings/settings_view.dart';
import '../../../features/sleep_view/sleep_azkar.dart';
import '../../../features/mosquesNearby/MosquesMapScreen.dart';
import '../../../features/charity/CharityDashboardScreen.dart';
import '../../../features/charity/AddCharityScreen.dart';
import '../../../features/charity/CharityHistoryScreen.dart';
import '../../../features/charity/CharityStoriesScreen.dart';
import '../../../features/charity/CharityPlatformsScreen.dart';
import '../../../features/achievements/AchievementsScreen.dart';
import '../../../features/achievements/ChallengesManagementScreen.dart';
import '../../../features/achievements/LeaderboardScreen.dart';
import '../../../features/duas/DuasMainScreen.dart';
import '../../../features/calendar/presentation/screens/calendar_screen.dart'; // [NEW]
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
  static const String zakatCalculatorRoute = "/ZakatCalculator";
  static const String settingsRoute = "/settings";
  static const String fajrAlarmRoute = "/fajrAlarm";
  static const String kidsStoriesRoute = "/kidsStories";
}

class QuranRadioPlayerArgs {
  final String title;
  final String streamUrl;
  final bool compact;
  const QuranRadioPlayerArgs({
    required this.title,
    required this.streamUrl,
    this.compact = false,
  });
}

class RouteGenerator {
  static Route<dynamic> getRoute(
    RouteSettings settings,
    BuildContext context,
  ) {
    final arguments = settings.arguments;

    switch (settings.name) {
      case Routes.splashRoute:
        return MaterialPageRoute(builder: (_) => const SplashView());
      case Routes.quranKhitamRoute:
        return MaterialPageRoute(builder: (_) => const QuranKhitamView());
      case Routes.hizbeListScreenRoute:
        return MaterialPageRoute(builder: (_) => const HizbeListScreen());
      case Routes.jozzaListScreenRoute:
        return MaterialPageRoute(builder: (_) => const JozzsListScreen());
      case Routes.tafsirQuranRoute:
        return MaterialPageRoute(builder: (_) => const TafsirQuranView());

      // ⬇️ الروت الجديد للبلاير
      case "/QuranRadioPlayerView":
        final args = arguments is QuranRadioPlayerArgs ? arguments : null;
        if (args == null) {
          return _badArgsRoute("QuranRadioPlayerArgs مفقودة");
        }
        return MaterialPageRoute(
          builder: (_) => QuranRadioPlayerView(
            title: args.title,
            streamUrl: args.streamUrl,
            compact: args.compact,
          ),
        );

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
      // ⬇️ الروت الجديد للبلاير
      case "/QuranChannalPlayerView":
        return MaterialPageRoute(
          builder: (_) => const QuranChannalPlayerView(),
        );

      case 'home':
        return MaterialPageRoute(builder: (_) => const MainView());
      case '/azkarSabah':
        return MaterialPageRoute(builder: (_) => const AzkarSabah());

      case '/compplateKhatna':
        return MaterialPageRoute(builder: (_) => const ComplateKhatmaView());

      case '/settingsRoute':
        return MaterialPageRoute(builder: (_) => const SettingsView());

      case '/WirdHomeScreen':
        return MaterialPageRoute(builder: (_) => WirdHomeScreen());

      case '/azkarMassa':
        return MaterialPageRoute(builder: (_) => const AzkarMassa());
      case '/prayerAzkar':
        return MaterialPageRoute(builder: (_) => const PrayerAzkar());
      case '/surahListScreen':
        return MaterialPageRoute(builder: (_) => const QuranView());
      case '/ListScreen':
        return MaterialPageRoute(builder: (_) => const SurahListScreen());
      case '/RadioSearchScreen':
        return MaterialPageRoute(builder: (_) => const RadioSearchScreen());
      case '/ayaSearchScreen':
        return MaterialPageRoute(builder: (_) => const AyaSearchScreen());
      case '/ayaBookmarkScreen':
        return MaterialPageRoute(builder: (_) => const AyaBookmarkScreen());
      case '/timingScreen':
        return MaterialPageRoute(builder: (_) => const AzanView());

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
      case '/supportDeveloper':
        return MaterialPageRoute(
            builder: (_) => const SupportDeveloperScreen());
      case Routes.fajrAlarmRoute:
        return MaterialPageRoute(builder: (_) => const FajrAlarmScreen());
      case '/QuranRadioView':
        return MaterialPageRoute(builder: (_) => const QuranRadioView());

      case '/NineBooksScreen':
        return MaterialPageRoute(builder: (_) => const NineBooksScreen());
      case '/CollectionDetailsScreen':
        return MaterialPageRoute(
            builder: (_) => const CollectionDetailsScreen());
      case '/ReadView':
        return MaterialPageRoute(builder: (_) => ReadView());

      case Routes.zakatCalculatorRoute:
        return MaterialPageRoute(builder: (_) => const ZakatCalculatorView());

      case '/mosquesMap':
        return MaterialPageRoute(builder: (_) => const MosquesMapScreen());

      // === Charity Routes ===
      case '/charityDashboard':
        return MaterialPageRoute(
            builder: (_) => const CharityDashboardScreen());
      case '/addCharity':
        return MaterialPageRoute(builder: (_) => const AddCharityScreen());
      case '/charityHistory':
        return MaterialPageRoute(builder: (_) => const CharityHistoryScreen());
      case '/charityStories':
        return MaterialPageRoute(builder: (_) => const CharityStoriesScreen());
      case '/charityPlatforms':
        return MaterialPageRoute(
            builder: (_) => const CharityPlatformsScreen());
      case '/recurring-charity': // Added route for RecurringCharityScreen
        return MaterialPageRoute(
            builder: (_) => const RecurringCharityScreen());

      // === Achievements Routes ===
      case '/achievements':
        return MaterialPageRoute(builder: (_) => const AchievementsScreen());
      case '/challenges':
        return MaterialPageRoute(
            builder: (_) => const ChallengesManagementScreen());
      case '/leaderboard':
        return MaterialPageRoute(builder: (_) => const LeaderboardScreen());

      // === Duas Routes ===
      case '/duasMain':
        return MaterialPageRoute(builder: (_) => const DuasMainScreen());

      // === Kids Corner ===
      case Routes.kidsStoriesRoute:
        return MaterialPageRoute(builder: (_) => const KidsStoriesScreen());

      // === Calendar ===
      case '/calendar':
        return MaterialPageRoute(builder: (_) => const CalendarScreen());

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

  static Route _badArgsRoute(String msg) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text("Bad Arguments")),
        body: Center(child: Text(msg)),
      ),
    );
  }
}
