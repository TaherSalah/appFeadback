import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:muslimdaily/app/core/services/notification_manager.dart';
import 'package:hijri/hijri_calendar.dart';

import 'app.dart';
import 'app/core/cache/shard_pref/shardpref_obj.dart';
import 'app/core/cubit/centralized_cubit.dart';
import 'app/core/utils/services_locator.dart';
import 'app/features/Khatmah/data/khatmah_model.dart';
import 'app/features/charity/models/charity_models.dart';
import 'app/features/achievements/models/achievement_models.dart';
import 'app/features/duas/models/dua_models.dart';

import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:quran_library/quran.dart';

Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await  QuranLibrary.init();
  try {
    await _initAppServices();
  } catch (e, s) {
    print('❌ خطأ في تهيئة التطبيق: $e\n$s');
    // We can't do much here if the root app fails to start,
    // but the error will be handled by the MashkahApp if needed or just crash.
  }

  runApp(
    BlocProvider<CentralizedCubit>(
      create: (context) => CentralizedCubit(
        sharedPreferences: Di.sharedPreferences,
      )..localization(),
      child: BlocBuilder<CentralizedCubit, CentralizedState>(
        builder: (context, state) => const MashkahApp(),
      ),
    ),
  );
}

Future<void> _initAppServices() async {
  // ✅ 1) تخصيصات النظام
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarColor: Colors.transparent,
  ));

  // ✅ 2) تهيئة البيانات
  HijriCalendar.setLocal('ar_SA');
  await Di.init();
  await initializeDateFormatting();
  await initializeDateFormatting('ar', null);
  await initializeDateFormatting('en', null);
  await SharedObj().init();

  // ✅ 3) Hive
  await Hive.initFlutter();

  // Register existing adapters
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(KhatmahModelAdapter());
  }
  if (!Hive.isAdapterRegistered(22)) {
    Hive.registerAdapter(MonthlyGoalAdapter());
  }
  if (!Hive.isAdapterRegistered(23)) {
    Hive.registerAdapter(CharityAchievementAdapter());
  }

  // Register new feature adapters
  if (!Hive.isAdapterRegistered(10)) {
    Hive.registerAdapter(CharityDonationAdapter());
  }
  if (!Hive.isAdapterRegistered(11)) {
    Hive.registerAdapter(AchievementAdapter());
  }
  if (!Hive.isAdapterRegistered(12)) {
    Hive.registerAdapter(UserProgressAdapter());
  }
  if (!Hive.isAdapterRegistered(13)) {
    Hive.registerAdapter(ChallengeAdapter());
  }
  if (!Hive.isAdapterRegistered(14)) {
    Hive.registerAdapter(CustomDuaAdapter());
  }
  if (!Hive.isAdapterRegistered(15)) {
    Hive.registerAdapter(DuaReminderAdapter());
  }
  if (!Hive.isAdapterRegistered(21)) {
    Hive.registerAdapter(RecurringCharityAdapter());
  }
  if (!Hive.isAdapterRegistered(16)) {
    Hive.registerAdapter(AchievementTypeAdapter());
  }
  if (!Hive.isAdapterRegistered(17)) {
    Hive.registerAdapter(AchievementRarityAdapter());
  }
  if (!Hive.isAdapterRegistered(18)) {
    Hive.registerAdapter(ChallengeTypeAdapter());
  }

  // Note: CharityCategory enum is handled automatically by CharityDonationAdapter

  // Open existing boxes
  await Hive.openBox<KhatmahModel>('khatmahBox');
  if (!Hive.isBoxOpen('khatmahPlans')) {
    await Hive.openBox('khatmahPlans');
  }

  // ✅ Note: Charity, Achievements, and Duas boxes are opened by their respective services

  // NotificationManager replaces all local notification logic
  final notificationManager = NotificationManager();
  await notificationManager.initialize();
  await notificationManager.rescheduleAll();
}

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
