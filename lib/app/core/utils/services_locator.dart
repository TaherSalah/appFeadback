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

// Communities imports
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:muslimdaily/app/features/communities/data/datasources/communities_remote_data_source.dart';
import 'package:muslimdaily/app/features/communities/data/datasources/communities_local_data_source.dart';
import 'package:muslimdaily/app/features/communities/data/repositories/communities_repository_impl.dart';
import '../../features/communities/domain/repositories/communities_repository.dart';
import '../../features/communities/presentation/cubit/communities_cubit.dart';
import '../../features/communities/presentation/cubit/community_details_cubit.dart';

// Push Notifications imports
import '../services/push_notifications/unified_push_service.dart';
import '../services/push_notifications/presentation/cubit/notification_cubit.dart';

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

    // Communities
    _i.registerLazySingleton<CommunitiesRemoteDataSource>(
      () => CommunitiesRemoteDataSourceImpl(supabase: Supabase.instance.client),
    );
    _i.registerLazySingleton<CommunitiesLocalDataSource>(
      () => CommunitiesLocalDataSource(),
    );
    _i.registerLazySingleton<CommunitiesRepository>(
      () => CommunitiesRepositoryImpl(
        remoteDataSource: _i(),
        localDataSource: _i(),
      ),
    );

    // ─────────────────────────────────────────────────────────────
    // 🔔 Push Notifications — FCM + HMS + iOS
    // ─────────────────────────────────────────────────────────────
    await UnifiedPushService.setup(
      sharedPreferences: sharedPreferences,
      supabaseClient: Supabase.instance.client,
    );

    // تسجيل الـ NotificationCubit في GetIt ليمكن الوصول إليه من أي مكان
    _i.registerSingleton<NotificationCubit>(UnifiedPushService.cubit);
  }

  // ─────────────────────────────────────────────────────────────────
  //  Accessors
  // ─────────────────────────────────────────────────────────────────

  static DioClientImpl get dioClient => _i.get<DioClientImpl>();
  static ApiClientBloc get apiClientBloc => _i.get<ApiClientBloc>();
  static SharedPreferences get sharedPreferences => _i.get<SharedPreferences>();

  /// الـ Cubit الجاهز للاستخدام في BlocProvider
  static NotificationCubit get notificationCubit =>
      _i.get<NotificationCubit>();
}
