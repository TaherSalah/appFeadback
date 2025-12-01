// import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:just_audio/just_audio.dart';
import 'package:lottie/lottie.dart';
import 'package:quran_library/quran.dart';
import 'package:rate_my_app/rate_my_app.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import 'app.dart';
import 'app/core/cache/shard_pref/shardpref_obj.dart';
import 'app/core/cubit/centralized_cubit.dart';
import 'app/core/localization/localization_manager.dart';
import 'app/features/azan_view/timeingScreen.dart';
import 'app/features/main_view/widget/IslamicCardWidget.dart';
import 'app/core/utils/services_locator.dart';
import 'app/core/utils/style/responsive_util.dart';
import 'app/core/widgets/custom_text_widget.dart';
import 'app/features/Khatmah/data/khatmah_model.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:workmanager/workmanager.dart';
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      // مهم جدًا مع الـ plugins في الخلفية
      WidgetsFlutterBinding.ensureInitialized();

      print("🔊 بدء تشغيل الأذان في الخلفية: $task");

      final prayerName = inputData?['prayerName'] ?? 'الفجر';
      final cityName = inputData?['cityName'] ?? '';

      // 1) تهيئة الـ notifications في هذا الـ isolate
      final FlutterLocalNotificationsPlugin notifications =
      FlutterLocalNotificationsPlugin();

      const androidSettings = AndroidInitializationSettings('ic_stat_logoapp');
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await notifications.initialize(initSettings);

      // 2) تشغيل صوت الأذان
      final audioPlayer = AudioPlayer();
      await audioPlayer.setAsset('assets/athan/athan.mp3');
      await audioPlayer.play();

      await audioPlayer.playerStateStream.firstWhere(
            (state) => state.processingState == ProcessingState.completed,
      );

      await audioPlayer.dispose();

      // 3) إظهار الإشعار بعد انتهاء الأذان
      await notifications.show(
        999,
        '✅ انتهى أذان $prayerName',
        'تم تشغيل الأذان - $cityName',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'adhan_complete_channel',
            'إشعارات اكتمال الأذان',
            channelDescription: 'إشعار يظهر بعد انتهاء الأذان',
            importance: Importance.low,
            priority: Priority.low,
            icon: 'ic_stat_logoapp',
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: false, // هنا لأن الصوت خلص أصلاً
          ),
        ),
      );

      print("✅ انتهى تشغيل الأذان وإظهار الإشعار بنجاح");
      return Future.value(true);
    } catch (e, s) {
      print("❌ خطأ في تشغيل الأذان: $e");
      print(s); // علشان تشوف الـ stacktrace
      return Future.value(false);
    }
  });
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // ← أول سطر دائمًا
  await QuranLibrary.init();
  // تهيئة خدمة الإشعارات
  await NotificationService().initialize();
  // تهيئة خدمة الأذان مع WorkManager
  await AdhanWorkManagerService().initialize();
  // جدولة الإشعارات الافتراضية
  await _setupDefaultNotifications();
  // SystemChrome و أي platform channels لازم بعد ensureInitialized
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarColor: Colors.transparent,
  ));

  // await Workmanager().initialize(
  //   callbackDispatcher,      // ← دي واحدة فقط من الملف اللي فوق
  //   isInDebugMode: false,
  // );
  HijriCalendar.setLocal('ar_SA');

  // لو عندك DI بيتعامل مع ملفات/قنوات منصة، خلّيه بعد ensureInitialized
  await Di.init();

  // Intl dates
  await initializeDateFormatting();
  await initializeDateFormatting('ar', null);
  await initializeDateFormatting('en', null);

  await SharedObj().init();

  // مكتبتك
  // QuranLibrary().initTafsir();

  // Hive
  await Hive.initFlutter();
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(KhatmahModelAdapter());
  }

  await Hive.openBox<KhatmahModel>('khatmahBox');

  if (!Hive.isBoxOpen('khatmahBox')) {
    await Hive.openBox<KhatmahModel>('khatmahBox');
  }
  if (!Hive.isBoxOpen('khatmahPlans')) {
    await Hive.openBox('khatmahPlans');
  }

    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(
        // DevicePreview(
        //   enabled: !kReleaseMode,
        //   builder: (context) => YaqeesApp(), // Wrap your app
        // ),

        BlocProvider<CentralizedCubit>(
            create: (context) =>
                CentralizedCubit(sharedPreferences: Di.sharedPreferences)
                  ..localization(),
            child: BlocBuilder<CentralizedCubit, CentralizedState>(
              builder: (context, state) {
                return const MashkahApp();
              },
            )));
  });
}




void checkWhatsNew(BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();
  final lastVersion = prefs.getString("last_version");

  // هات معلومات التطبيق
  final info = await PackageInfo.fromPlatform();
  final currentVersion = info.version; // هنا بقت String تلقائيًا
print("currentVersion $currentVersion");
print("lastVersion $lastVersion");
  if (lastVersion != currentVersion) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // showWhatsNew(context);
    });

    prefs.setString("last_version", currentVersion);
  }
}

// void showWhatsNew(BuildContext context) {
//   showModalBottomSheet(
//     context: context,
//     backgroundColor: Colors.transparent,
//     isScrollControlled: true,
//     builder: (_) {
//       return DraggableScrollableSheet(
//         initialChildSize: 0.55,
//         maxChildSize: 0.85,
//         minChildSize: 0.4,
//         builder: (context, scrollController) {
//           return Container(
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
//             ),
//             child: ListView(
//               controller: scrollController,
//               padding: EdgeInsets.all(20),
//               children: [
//                 Center(
//                   child: Container(
//                     width: 40,
//                     height: 5,
//                     decoration: BoxDecoration(
//                       color: Colors.grey[300],
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                   ),
//                 ),
//                 SizedBox(height: 15),
//                 Text(
//                   "🌟 ما الجديد في التحديث؟",
//                   style: TextStyle(
//                     fontSize: 22,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 SizedBox(height: 20),
//                 whatsNewItem(
//                   Icons.star,
//                   "تحسين واجهة قراءة القرآن",
//                   "تم إضافة وضع ليلي محسن + تحسين حجم الخط + تقليل استهلاك البطارية.",
//                 ),
//                 whatsNewItem(
//                   Icons.bookmark,
//                   "إدارة العلامات المرجعية",
//                   "تقدر تحفظ، تعدل، وتمسح العلامات بسهولة وسرعة.",
//                 ),
//                 whatsNewItem(
//                   Icons.search,
//                   "بحث أسرع",
//                   "تحسين سرعة البحث داخل السور والآيات.",
//                 ),
//                 whatsNewItem(
//                   Icons.bug_report,
//                   "إصلاحات أخطاء",
//                   "إصلاح مشكلة تحميل الصفحات وتحسين الأداء العام.",
//                 ),
//                 SizedBox(height: 20),
//                 ElevatedButton(
//                   onPressed: () => Navigator.pop(context),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.green,
//                     minimumSize: Size(double.infinity, 50),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(15),
//                     ),
//                   ),
//                   child: Text(
//                     "تمام، فهمت 👍",
//                     style: TextStyle(fontSize: 18, color: Colors.white),
//                   ),
//                 ),
//               ],
//             ),
//           );
//         },
//       );
//     },
//   );
// }
//
// Widget whatsNewItem(IconData icon, String title, String desc) {
//   return Container(
//     margin: EdgeInsets.only(bottom: 15),
//     child: Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Icon(icon, color: Colors.green, size: 28),
//         SizedBox(width: 12),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 title,
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//               ),
//               SizedBox(height: 4),
//               Text(
//                 desc,
//                 style: TextStyle(fontSize: 15, color: Colors.grey[700]),
//               ),
//             ],
//           ),
//         )
//       ],
//     ),
//   );
// }
//


// إعداد الإشعارات الافتراضية
Future<void> _setupDefaultNotifications() async {
  final notificationService = NotificationService();

  // جدولة أذكار الصباح - الساعة 6 صباحاً
  await notificationService.scheduleMorningAthkar(6, 0);

  // جدولة أذكار المساء - الساعة 6 مساءً
  await notificationService.scheduleEveningAthkar(18, 0);

  // جدولة ورد القرآن - الساعة 8 مساءً
  await notificationService.scheduleDailyQuranWird(20, 0);

  // جدولة حديث اليوم - الساعة 12 ظهراً
  await notificationService.scheduleDailyHadith(12, 0);
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  // تهيئة الإشعارات
  Future<void> initialize() async {
    tz.initializeTimeZones();

    // إعدادات Android
    const androidSettings = AndroidInitializationSettings('@drawable/ic_stat_logoapp');

    // إعدادات iOS
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // طلب الأذونات
    await _requestPermissions();
  }

  // طلب الأذونات
  Future<void> _requestPermissions() async {
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
  }

  // عند النقر على الإشعار
  void _onNotificationTapped(NotificationResponse response) {
    // يمكنك هنا التنقل إلى صفحة معينة
    print('تم النقر على الإشعار: ${response.payload}');
  }

  // جدولة أذكار الصباح
  Future<void> scheduleMorningAthkar(int hour, int minute) async {
    await _scheduleNotification(
      id: 1,
      title: '🌅 أذكار الصباح',
      body: 'حان وقت أذكار الصباح، بارك الله في صباحك',
      hour: hour,
      minute: minute,
      payload: 'morning_athkar',
    );
  }

  // جدولة أذكار المساء
  Future<void> scheduleEveningAthkar(int hour, int minute) async {
    await _scheduleNotification(
      id: 2,
      title: '🌙 أذكار المساء',
      body: 'حان وقت أذكار المساء، جعل الله مساءك مباركاً',
      hour: hour,
      minute: minute,
      payload: 'evening_athkar',
    );
  }

  // جدولة ورد قراني يومي
  Future<void> scheduleDailyQuranWird(int hour, int minute) async {
    await _scheduleNotification(
      id: 3,
      title: '📖 ورد القرآن اليومي',
      body: 'لا تنسَ وردك اليومي من القرآن الكريم',
      hour: hour,
      minute: minute,
      payload: 'quran_wird',

    );
  }

  // جدولة تنبيه بعد صلاة
  Future<void> scheduleAfterPrayerReminder(String prayerName, int afterMinutes) async {
    // هنا يمكنك حساب الوقت بناءً على وقت الصلاة
    // مثال: بعد صلاة الفجر بـ 15 دقيقة
    await _scheduleNotification(
      id: 10,
      title: '🤲 تذكير بعد صلاة $prayerName',
      body: 'وقت الأذكار والدعاء بعد الصلاة',
      hour: 6, // مثال
      minute: 15,
      payload: 'after_prayer',
    );
  }

  // جدولة تنبيه بحديث يومي
  Future<void> scheduleDailyHadith(int hour, int minute) async {
    await _scheduleNotification(
      id: 4,
      title: '📿 حديث اليوم',
      body: 'اطلع على الحديث الشريف لهذا اليوم',
      hour: hour,
      minute: minute,
      payload: 'daily_hadith',
    );
  }

  // الدالة الأساسية للجدولة
  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
    String? payload,
  }) async {
    await _notifications.zonedSchedule(
      id,
      title,
      body,
      _nextInstanceOfTime(hour, minute),
      NotificationDetails(
        android: AndroidNotificationDetails(
          'athkar_channel',
          'أذكار وأوراد',
          channelDescription: 'إشعارات الأذكار والأوراد اليومية',
          importance: Importance.high,
          priority: Priority.high,
          icon: 'ic_stat_logoapp',
          // استخدام الصوت الافتراضي
          playSound: true,
          enableVibration: true,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: payload,
    );
  }

  // حساب الوقت التالي للتنبيه
  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // إذا كان الوقت قد مضى اليوم، جدوله لليوم التالي
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  // إلغاء إشعار معين
  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  // إلغاء جميع الإشعارات
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  // عرض إشعار فوري (للتجربة)
  Future<void> showInstantNotification(String title, String body) async {
    const androidDetails = AndroidNotificationDetails(
      'instant_channel',
      'إشعارات فورية',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    await _notifications.show(
      0,
      title,
      body,
      const NotificationDetails(android: androidDetails, iOS: iosDetails),
    );
  }

  // الحصول على الإشعارات المجدولة
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }

  // دالة عامة للجدولة (للاستخدام المرن)
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
    String? payload,
  }) async {
    await _scheduleNotification(
      id: id,
      title: title,
      body: body,
      hour: hour,
      minute: minute,
      payload: payload,
    );
  }
}



//# دليل إعداد WorkManager للأذان التلقائي
//
//## ✅ ما تم عمله:
//
//### 1. WorkManager
//- يشغل الأذان **تلقائياً في الخلفية**
//- يعمل حتى لو التطبيق **مقفول تماماً**
//- يعمل حتى لو الهاتف في **وضع السكون**
//
//### 2. المميزات:
//- ✅ أذان تلقائي بدون تدخل المستخدم
//- ✅ يعمل لـ 7 أيام قادمة
//- ✅ تنبيه قبل الأذان بـ 5 دقائق (اختياري)
//- ✅ يحدّث نفسه عند تغيير الموقع
//
//---
//
//## 📱 الإعدادات المطلوبة على الهاتف:
//
//### أ) تعطيل توفير البطارية للتطبيق:
//1. إعدادات الهاتف → البطارية
//2. تحسين استهلاك البطارية
//3. ابحث عن التطبيق
//4. اختر **"لا تحسّن"** أو **"غير مقيد"**
//
//### ب) السماح بالعمل في الخلفية:
//1. إعدادات الهاتف → التطبيقات
//2. اختر التطبيق
//3. الأذونات → **السماح بالعمل في الخلفية**
//
//### ج) تفعيل التشغيل التلقائي (للهواتف الصينية):
//**Xiaomi/Redmi/POCO:**
//- الإعدادات → الأمان → الأذونات → التشغيل التلقائي
//- فعّل التطبيق
//
//**Huawei:**
//- الإعدادات → التطبيقات → إدارة التطبيقات
//- اختر التطبيق → التشغيل التلقائي
//
//**Oppo/Realme:**
//- الإعدادات → البطارية → تحسين استخدام البطارية
//- اختر التطبيق → لا تحسّن
//
//**Samsung:**
//- الإعدادات → البطارية وصيانة الجهاز
//- التطبيقات غير المراقبة → أضف التطبيق
//
//---
//
//## 🔧 إعدادات للمطورين:
//
//### 1. تفعيل Debug Mode:
//في `adhan_workmanager_service.dart`:
//```dart
//await Workmanager().initialize(
//callbackDispatcher,
//isInDebugMode: true, // غيّرها لـ true للتجربة
//);
//```
//
//### 2. اختبار الأذان فوراً:
//```dart
//// تشغيل الأذان بعد 10 ثواني للتجربة
//await Workmanager().registerOneOffTask(
//'test_adhan',
//'playAdhan',
//initialDelay: Duration(seconds: 10),
//inputData: {
//'prayerName': 'الفجر',
//'cityName': 'القاهرة',
//},
//);
//```
//
//### 3. عرض سجل الأحداث:
//في Android Studio:
//```
//Run → Flutter → Run
//ثم افتح Logcat وابحث عن:
//- 🔊 (لتتبع تشغيل الأذان)
//- ✅ (للعمليات الناجحة)
//- ❌ (للأخطاء)
//```
//
//---
//
//## ⚠️ ملاحظات مهمة:
//
//### 1. صوت الأذان:
//- **يجب** وضع الملف في: `assets/athan/athan.mp3`
//- أضفه في `pubspec.yaml`:
//```yaml
//flutter:
//assets:
//- assets/athan/athan.mp3
//```
//
//### 2. القيود في Android 12+:
//- Android 12 وما فوق يحتاج إذن `SCHEDULE_EXACT_ALARM`
//- التطبيق سيطلبه تلقائياً عند أول تشغيل
//
//### 3. مدة الأذان:
//- الأذان يشتغل كاملاً ثم يتوقف تلقائياً
//- لو عايز توقفه يدوياً، ممكن تضيف زر في الإشعار
//
//### 4. استهلاك البطارية:
//- WorkManager مُحسّن ولا يستهلك بطارية كثيرة
//- يعمل فقط عند موعد الأذان بالضبط
//
//---
//
//## 🐛 حل المشاكل الشائعة:
//
//### المشكلة: الأذان ما يشتغلش
//**الحل:**
//1. تأكد من تعطيل توفير البطارية
//2. تأكد من أن ملف `athan.mp3` موجود
//3. راجع الـ Logcat للأخطاء
//
//### المشكلة: الأذان يتأخر
//**الحل:**
//1. تأكد من إذن `SCHEDULE_EXACT_ALARM`
//2. أغلق تطبيقات توفير البطارية الخارجية
//3. فعّل التشغيل التلقائي (للهواتف الصينية)
//
//### المشكلة: الأذان يتوقف بعد يوم
//**الحل:**
//- التطبيق يجدول لـ 7 أيام
//- افتح التطبيق مرة كل أسبوع لتجديد الجدولة
//- أو استخدم `BOOT_COMPLETED` receiver
//
//---
//
//## 🎯 الخطوات التالية (اختيارية):
//
//1. **إضافة زر إيقاف الأذان** في الإشعار
//2. **تطبيق Foreground Service** للموثوقية الأعلى
//3. **جدولة تلقائية** بعد إعادة تشغيل الجهاز
//4. **إعدادات مخصصة** لصوت الأذان لكل صلاة
//
//---
//
//## 📊 اختبار الجودة:
//
//```dart
//// في TimingScreen، أضف هذا الزر للاختبار:
//ElevatedButton(
//onPressed: () async {
//// اختبار فوري
//await Workmanager().registerOneOffTask(
//'test_now',
//'playAdhan',
//initialDelay: Duration(seconds: 5),
//inputData: {
//'prayerName': 'اختبار',
//'cityName': 'القاهرة',
//},
//);
//
//ScaffoldMessenger.of(context).showSnackBar(
//const SnackBar(content: Text('سيبدأ الأذان بعد 5 ثواني')),
//);
//},
//child: const Text('اختبار الأذان الآن'),
//)
//```