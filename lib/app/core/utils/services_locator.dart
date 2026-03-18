import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:get_storage/get_storage.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../apis_services/api_client/api_client_impl.dart';
import '../apis_services/api_services.dart';
import '../cache/shard_pref/shardpref_obj.dart';
import '../cubit/api_client/api_client_bloc.dart';
import '../cubit/bloc_observer.dart';
import 'objectbox.dart';
import '../../features/hadith_books/controllers/books_controller.dart';
import '../../features/achievements/services/achievement_service.dart';
import '../services/content_service.dart';

// final sl = GetIt.instance;

// Future<void> servicesInit() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   Bloc.observer = MyBlocObserver();
//   await GetStorage.init();
//
//   await SharedObj().init();
//   sl.registerSingleton<ApiServicess>(ApiServicess());
//   final SharedPreferences sharedPreferences =
//       await SharedPreferences.getInstance();
//   sl.registerLazySingleton(() => sharedPreferences);
//   static DioClientImpl get dioClient => _i.get<DioClientImpl>();
//
//   static ApiClientBloc get apiClientBloc => _i.get<ApiClientBloc>();
// }

abstract class Di {
  static final GetIt _i = GetIt.instance;

  static Future<void> init() async {
    // ✅ Parallelize non-dependent initializations
    await Future.wait<dynamic>([
      GetStorage.init(),
      SharedObj().init(),
    ]);

    Bloc.observer = MyBlocObserver();
    _i.registerSingleton<ApiServicess>(ApiServicess());

    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    _i.registerLazySingleton(() => sharedPreferences);
    _i.registerLazySingleton(() => DioClientImpl(apiClientBloc: _i()));
    _i.registerLazySingleton(() => ApiClientBloc());

    // ObjectBox, AchievementService, ContentService can be initialized in parallel
    final achievementService = AchievementService();
    final results = await Future.wait<dynamic>([
      ObjBox.create(),
      achievementService.init(),
    ]);

    final objBox = results[0] as ObjBox;

    _i.registerSingleton<ObjBox>(objBox);
    Get.put<ObjBox>(objBox);

    if (Get.isRegistered<BooksController>()) {
      Get.find<BooksController>().setStore(objBox.store);
    }

    _i.registerSingleton<AchievementService>(achievementService);

    // Content Service
    final contentService = ContentService();
    _i.registerSingleton<ContentService>(contentService);
  }

  static DioClientImpl get dioClient => _i.get<DioClientImpl>();

  static ApiClientBloc get apiClientBloc => _i.get<ApiClientBloc>();

  static SharedPreferences get sharedPreferences => _i.get<SharedPreferences>();
}
