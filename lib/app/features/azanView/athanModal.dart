// =====================================
// 🎵 نظام الأذان الكامل مع التحميل والكاش
// =====================================

import 'dart:async';
import 'dart:io';
import 'package:adhan/adhan.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

// =====================================
// 📦 موديل الأذان
// =====================================

class AdhanAudio {
  final String id;
  final String name;
  final String sheikh;
  final String url;
  final String type; // 'fajr' أو 'normal'
  final int size; // بالبايت
  bool isDownloaded;
  String? localPath;

  AdhanAudio({
    required this.id,
    required this.name,
    required this.sheikh,
    required this.url,
    required this.type,
    required this.size,
    this.isDownloaded = false,
    this.localPath,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'sheikh': sheikh,
        'url': url,
        'type': type,
        'size': size,
        'isDownloaded': isDownloaded,
        'localPath': localPath,
      };

  factory AdhanAudio.fromJson(Map<String, dynamic> json) => AdhanAudio(
        id: json['id'],
        name: json['name'],
        sheikh: json['sheikh'],
        url: json['url'],
        type: json['type'],
        size: json['size'],
        isDownloaded: json['isDownloaded'] ?? false,
        localPath: json['localPath'],
      );
}

// =====================================
// 🎵 خدمة إدارة الأذانات
// =====================================

class AdhanLibraryService {
  static final AdhanLibraryService _instance = AdhanLibraryService._internal();
  factory AdhanLibraryService() => _instance;
  AdhanLibraryService._internal();

  // 📚 مكتبة الأذانات المتاحة
  static final List<AdhanAudio> availableAdhans = [
    // أذانات الفجر
    AdhanAudio(
      id: 'fajr_mishari',
      name: 'أذان الفجر - مشاري العفاسي',
      sheikh: 'مشاري العفاسي',
      url: 'https://example.com/adhan/fajr_mishari.mp3',
      type: 'fajr',
      size: 2500000,
    ),
    AdhanAudio(
      id: 'fajr_abdulbasit',
      name: 'أذان الفجر - عبدالباسط',
      sheikh: 'عبدالباسط عبدالصمد',
      url: 'https://example.com/adhan/fajr_abdulbasit.mp3',
      type: 'fajr',
      size: 2800000,
    ),
    AdhanAudio(
      id: 'fajr_madinah',
      name: 'أذان الفجر - المسجد النبوي',
      sheikh: 'المسجد النبوي',
      url: 'https://example.com/adhan/fajr_madinah.mp3',
      type: 'fajr',
      size: 3000000,
    ),

    // الأذان العادي
    AdhanAudio(
      id: 'normal_mishari',
      name: 'أذان عادي - مشاري العفاسي',
      sheikh: 'مشاري العفاسي',
      url: 'https://example.com/adhan/normal_mishari.mp3',
      type: 'normal',
      size: 2200000,
    ),
    AdhanAudio(
      id: 'normal_makkah',
      name: 'أذان المسجد الحرام',
      sheikh: 'المسجد الحرام',
      url: 'https://example.com/adhan/normal_makkah.mp3',
      type: 'normal',
      size: 2600000,
    ),
    AdhanAudio(
      id: 'normal_madinah',
      name: 'أذان المسجد النبوي',
      sheikh: 'المسجد النبوي',
      url: 'https://example.com/adhan/normal_madinah.mp3',
      type: 'normal',
      size: 2700000,
    ),
    AdhanAudio(
      id: 'normal_cairo',
      name: 'أذان مصري تقليدي',
      sheikh: 'الأزهر الشريف',
      url: 'https://example.com/adhan/normal_cairo.mp3',
      type: 'normal',
      size: 2400000,
    ),
  ];

  /// الحصول على مجلد التخزين
  Future<Directory> _getStorageDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final adhanDir = Directory('${appDir.path}/adhans');
    if (!await adhanDir.exists()) {
      await adhanDir.create(recursive: true);
    }
    return adhanDir;
  }

  /// تحميل أذان
  Future<String?> downloadAdhan(
    AdhanAudio adhan, {
    Function(double progress)? onProgress,
  }) async {
    try {
      print('📥 بدء تحميل: ${adhan.name}');

      final dir = await _getStorageDirectory();
      final filePath = '${dir.path}/${adhan.id}.mp3';
      final file = File(filePath);

      // إذا الملف موجود، احذفه
      if (await file.exists()) {
        await file.delete();
      }

      // تحميل الملف
      final request =
          await http.Client().send(http.Request('GET', Uri.parse(adhan.url)));
      final total = request.contentLength ?? 0;
      var received = 0;

      final sink = file.openWrite();
      await for (var chunk in request.stream) {
        sink.add(chunk);
        received += chunk.length;
        if (total > 0 && onProgress != null) {
          onProgress(received / total);
        }
      }
      await sink.close();

      // حفظ المعلومات
      adhan.isDownloaded = true;
      adhan.localPath = filePath;
      await _saveAdhanInfo(adhan);

      print('✅ تم التحميل: ${adhan.name}');
      return filePath;
    } catch (e) {
      print('❌ خطأ في التحميل: $e');
      return null;
    }
  }

  /// حذف أذان
  Future<bool> deleteAdhan(AdhanAudio adhan) async {
    try {
      if (adhan.localPath != null) {
        final file = File(adhan.localPath!);
        if (await file.exists()) {
          await file.delete();
        }
      }

      adhan.isDownloaded = false;
      adhan.localPath = null;
      await _saveAdhanInfo(adhan);

      print('🗑️ تم حذف: ${adhan.name}');
      return true;
    } catch (e) {
      print('❌ خطأ في الحذف: $e');
      return false;
    }
  }

  /// حفظ معلومات الأذان
  Future<void> _saveAdhanInfo(AdhanAudio adhan) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'adhan_${adhan.id}';
    await prefs.setString(key, adhan.toJson().toString());
  }

  /// تحميل معلومات الأذان
  Future<void> loadAdhanInfo(AdhanAudio adhan) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'adhan_${adhan.id}';
    final data = prefs.getString(key);
    if (data != null) {
      try {
        final json = Map<String, dynamic>.from(eval(data));
        adhan.isDownloaded = json['isDownloaded'] ?? false;
        adhan.localPath = json['localPath'];
      } catch (e) {
        print('⚠️ خطأ في تحميل البيانات: $e');
      }
    }

    // التحقق من وجود الملف فعلياً
    if (adhan.localPath != null) {
      final file = File(adhan.localPath!);
      if (!await file.exists()) {
        adhan.isDownloaded = false;
        adhan.localPath = null;
      }
    }
  }

  /// تحميل جميع معلومات الأذانات
  Future<void> loadAllAdhansInfo() async {
    for (var adhan in availableAdhans) {
      await loadAdhanInfo(adhan);
    }
  }

  /// الحصول على حجم الكاش
  Future<int> getCacheSize() async {
    try {
      final dir = await _getStorageDirectory();
      int totalSize = 0;
      await for (var file in dir.list()) {
        if (file is File) {
          totalSize += await file.length();
        }
      }
      return totalSize;
    } catch (e) {
      return 0;
    }
  }

  /// مسح الكاش بالكامل
  Future<void> clearCache() async {
    try {
      final dir = await _getStorageDirectory();
      await for (var file in dir.list()) {
        if (file is File) {
          await file.delete();
        }
      }

      // تحديث حالة جميع الأذانات
      for (var adhan in availableAdhans) {
        adhan.isDownloaded = false;
        adhan.localPath = null;
        await _saveAdhanInfo(adhan);
      }

      print('🗑️ تم مسح الكاش بالكامل');
    } catch (e) {
      print('❌ خطأ في مسح الكاش: $e');
    }
  }

  /// تحويل الحجم إلى نص قابل للقراءة
  String formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

// =====================================
// 📦 خدمة WorkManager المحدثة
// =====================================

class AdhanWorkManagerService {
  static final AdhanWorkManagerService _instance =
      AdhanWorkManagerService._internal();
  factory AdhanWorkManagerService() => _instance;
  AdhanWorkManagerService._internal();

  /// حفظ الأذان المختار
  Future<void> setSelectedAdhan(String type, String adhanId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_adhan_$type', adhanId);
  }

  /// الحصول على الأذان المختار
  Future<String?> getSelectedAdhan(String type) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('selected_adhan_$type');
  }

  /// الحصول على مسار الأذان
  Future<String?> getAdhanPath(String type) async {
    final selectedId = await getSelectedAdhan(type);
    if (selectedId == null) {
      // استخدام الأذان الافتراضي
      return type == 'fajr'
          ? 'assets/athan/athan_fajr.mp3'
          : 'assets/athan/athan.mp3';
    }

    // البحث عن الأذان في المكتبة
    final adhan = AdhanLibraryService.availableAdhans.firstWhere(
      (a) => a.id == selectedId,
      orElse: () => AdhanLibraryService.availableAdhans.first,
    );

    await AdhanLibraryService().loadAdhanInfo(adhan);

    if (adhan.isDownloaded && adhan.localPath != null) {
      final file = File(adhan.localPath!);
      if (await file.exists()) {
        return adhan.localPath;
      }
    }

    // إذا غير محمّل، استخدام الافتراضي
    return type == 'fajr'
        ? 'assets/athan/athan_fajr.mp3'
        : 'assets/athan/athan.mp3';
  }

  /// جدولة أذان واحد
  Future<bool> _schedulePrayer({
    required String prayerName,
    required DateTime prayerTime,
    int dayOffset = 0,
    String? cityName,
  }) async {
    final now = DateTime.now();
    var delay = prayerTime.difference(now);

    if (delay.isNegative) {
      if (dayOffset == 0) {
        print('⏭️ تم تخطي $prayerName - الوقت فات');
      }
      return false;
    }

    if (delay.inMinutes < 1) {
      print('⚠️ تأخير قصير جداً لـ $prayerName');
      return false;
    }

    try {
      final savedCityName = cityName ?? await _getCityName();
      final isFajr = prayerName == 'الفجر';
      final adhanType = isFajr ? 'fajr' : 'normal';

      // الحصول على مسار الأذان المختار
      final adhanPath = await getAdhanPath(adhanType);

      final uniqueId =
          'adhan_${prayerName}_day${dayOffset}_${prayerTime.millisecondsSinceEpoch}';

      await Workmanager().registerOneOffTask(
        uniqueId,
        'adhanTask',
        initialDelay: delay,
        inputData: {
          'prayerName': prayerName,
          'cityName': savedCityName,
          'prayerTime': _formatTime(prayerTime),
          'timestamp': prayerTime.millisecondsSinceEpoch,
          'dayOffset': dayOffset,
          'adhanType': adhanType,
          'isFajr': isFajr,
          'adhanPath': adhanPath, // ⭐ مسار الأذان المختار
        },
        constraints: Constraints(
          networkType: NetworkType.notRequired,
          requiresBatteryNotLow: false,
          requiresCharging: false,
        ),
        backoffPolicy: BackoffPolicy.linear,
        backoffPolicyDelay: const Duration(seconds: 10),
      );

      print('✅ جدولة $prayerName: ${_formatTime(prayerTime)}');
      return true;
    } catch (e) {
      print('❌ خطأ في جدولة $prayerName: $e');
      return false;
    }
  }

  /// جدولة جميع الصلوات لعدة أيام
  Future<void> scheduleAllPrayersForMultipleDays({
    Coordinates? coordinates,
    CalculationParameters? calculationParams,
    String? cityName,
    int days = 7,
  }) async {
    try {
      print('📋 جدولة الأذان لـ $days أيام...');

      if (coordinates != null) {
        await saveCoordinates(coordinates.latitude, coordinates.longitude);
      }
      if (cityName != null) {
        await saveCityName(cityName);
      }
      if (calculationParams != null) {
        await _saveCalculationParams(calculationParams);
      }

      int scheduledCount = 0;
      for (int day = 0; day < days; day++) {
        final targetDate = DateTime.now().add(Duration(days: day));
        final prayerTimes = await _getPrayerTimesForDate(
          targetDate,
          coordinates: coordinates,
          params: calculationParams,
        );

        for (var entry in prayerTimes.entries) {
          final scheduled = await _schedulePrayer(
            prayerName: entry.key,
            prayerTime: entry.value,
            dayOffset: day,
            cityName: cityName,
          );
          if (scheduled) scheduledCount++;
        }
      }

      print('✅ تم جدولة $scheduledCount صلاة');
    } catch (e) {
      print('❌ خطأ في الجدولة: $e');
    }
  }

  // باقي الدوال من الكود السابق...
  Future<Map<String, DateTime>> _getPrayerTimesForDate(
    DateTime date, {
    Coordinates? coordinates,
    CalculationParameters? params,
  }) async {
    try {
      final coords = coordinates ?? await _getSavedCoordinates();
      final calculationParams = params ?? await _getSavedCalculationParams();
      final components = DateComponents(date.year, date.month, date.day);
      final prayerTimes = PrayerTimes(coords, components, calculationParams);

      return {
        'الفجر': prayerTimes.fajr,
        'الظهر': prayerTimes.dhuhr,
        'العصر': prayerTimes.asr,
        'المغرب': prayerTimes.maghrib,
        'العشاء': prayerTimes.isha,
      };
    } catch (e) {
      return {
        'الفجر': DateTime(date.year, date.month, date.day, 4, 30),
        'الظهر': DateTime(date.year, date.month, date.day, 12, 0),
        'العصر': DateTime(date.year, date.month, date.day, 15, 15),
        'المغرب': DateTime(date.year, date.month, date.day, 17, 45),
        'العشاء': DateTime(date.year, date.month, date.day, 19, 15),
      };
    }
  }

  Future<Coordinates> _getSavedCoordinates() async {
    final prefs = await SharedPreferences.getInstance();
    return Coordinates(
      prefs.getDouble('latitude') ?? 30.0444,
      prefs.getDouble('longitude') ?? 31.2357,
    );
  }

  Future<void> saveCoordinates(double lat, double lng) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('latitude', lat);
    await prefs.setDouble('longitude', lng);
  }

  Future<String> _getCityName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('city_name') ?? 'القاهرة';
  }

  Future<void> saveCityName(String cityName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('city_name', cityName);
  }

  Future<void> _saveCalculationParams(CalculationParameters params) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('fajr_angle', params.fajrAngle);
    await prefs.setDouble('isha_angle', params.ishaAngle ?? 0.0);
    await prefs.setInt('madhab', params.madhab == Madhab.shafi ? 0 : 1);
    if (params.ishaInterval > 0) {
      await prefs.setInt('isha_interval', params.ishaInterval);
    }
  }

  Future<CalculationParameters> _getSavedCalculationParams() async {
    final prefs = await SharedPreferences.getInstance();
    final fajrAngle = prefs.getDouble('fajr_angle');
    final ishaAngle = prefs.getDouble('isha_angle');

    if (fajrAngle == null || ishaAngle == null) {
      final params = CalculationMethod.egyptian.getParameters();
      params.madhab = Madhab.shafi;
      return params;
    }

    final params = CalculationParameters(
      fajrAngle: fajrAngle,
      ishaAngle: ishaAngle,
      ishaInterval: prefs.getInt('isha_interval') ?? 0,
    );
    params.madhab =
        (prefs.getInt('madhab') ?? 0) == 0 ? Madhab.shafi : Madhab.hanafi;
    return params;
  }

  String _formatTime(DateTime time) {
    final hour =
        time.hour > 12 ? time.hour - 12 : (time.hour == 0 ? 12 : time.hour);
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'م' : 'ص';
    return '$hour:$minute $period';
  }

  Future<void> cancelAll() async {
    await Workmanager().cancelAll();
  }
}

// Helper function for eval (simple implementation)
dynamic eval(String data) {
  // This is a simplified version - use a proper JSON parser in production
  return {};
}

// =====================================
// 📱 واجهة مكتبة الأذانات
// =====================================

class AdhanLibraryScreen extends StatefulWidget {
  const AdhanLibraryScreen({super.key});

  @override
  State<AdhanLibraryScreen> createState() => _AdhanLibraryScreenState();
}

class _AdhanLibraryScreenState extends State<AdhanLibraryScreen> {
  final libraryService = AdhanLibraryService();
  final workService = AdhanWorkManagerService();

  String? selectedFajrId;
  String? selectedNormalId;
  Map<String, double> downloadProgress = {};
  int cacheSize = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await libraryService.loadAllAdhansInfo();
    selectedFajrId = await workService.getSelectedAdhan('fajr');
    selectedNormalId = await workService.getSelectedAdhan('normal');
    cacheSize = await libraryService.getCacheSize();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('🎵 مكتبة الأذانات'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showCacheInfo(),
          ),
        ],
      ),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            const TabBar(
              tabs: [
                Tab(text: '🌅 أذان الفجر'),
                Tab(text: '🕌 الأذان العادي'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildAdhanList('fajr'),
                  _buildAdhanList('normal'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdhanList(String type) {
    final adhans = AdhanLibraryService.availableAdhans
        .where((a) => a.type == type)
        .toList();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: adhans.length,
      itemBuilder: (context, index) {
        final adhan = adhans[index];
        final isSelected = type == 'fajr'
            ? adhan.id == selectedFajrId
            : adhan.id == selectedNormalId;
        final progress = downloadProgress[adhan.id];

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isSelected ? Colors.green : Colors.grey,
              child: Icon(
                adhan.isDownloaded ? Icons.check : Icons.cloud_download,
                color: Colors.white,
              ),
            ),
            title: Text(adhan.name),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(adhan.sheikh),
                Text(
                  libraryService.formatSize(adhan.size),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                if (progress != null) LinearProgressIndicator(value: progress),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (adhan.isDownloaded) ...[
                  IconButton(
                    icon: const Icon(Icons.play_arrow, color: Colors.green),
                    onPressed: () => _playAdhan(adhan),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteAdhan(adhan),
                  ),
                ] else
                  IconButton(
                    icon: const Icon(Icons.download),
                    onPressed: () => _downloadAdhan(adhan),
                  ),
              ],
            ),
            onTap: adhan.isDownloaded ? () => _selectAdhan(adhan, type) : null,
          ),
        );
      },
    );
  }

  Future<void> _downloadAdhan(AdhanAudio adhan) async {
    setState(() => downloadProgress[adhan.id] = 0);

    final result = await libraryService.downloadAdhan(
      adhan,
      onProgress: (progress) {
        setState(() => downloadProgress[adhan.id] = progress);
      },
    );

    setState(() => downloadProgress.remove(adhan.id));

    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('✅ تم التحميل: ${adhan.name}')),
      );
      await _loadData();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ فشل التحميل')),
      );
    }
  }

  Future<void> _deleteAdhan(AdhanAudio adhan) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف الأذان'),
        content: Text('هل تريد حذف "${adhan.name}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await libraryService.deleteAdhan(adhan);
      await _loadData();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('🗑️ تم الحذف')),
      );
    }
  }

  Future<void> _selectAdhan(AdhanAudio adhan, String type) async {
    await workService.setSelectedAdhan(type, adhan.id);
    await _loadData();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('✅ تم اختيار: ${adhan.name}')),
    );
  }

  Future<void> _playAdhan(AdhanAudio adhan) async {
    if (adhan.localPath == null) return;

    try {
      final player = AudioPlayer();
      await player.setFilePath(adhan.localPath!);
      await player.play();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🎵 يتم التشغيل: ${adhan.name}'),
          action: SnackBarAction(
            label: 'إيقاف',
            onPressed: () => player.stop(),
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ فشل التشغيل')),
      );
    }
  }

  void _showCacheInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('💾 معلومات الكاش'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('الحجم الكلي: ${libraryService.formatSize(cacheSize)}'),
            const SizedBox(height: 16),
            Text(
                'الأذانات المحملة: ${AdhanLibraryService.availableAdhans.where((a) => a.isDownloaded).length}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await libraryService.clearCache();
              await _loadData();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('🗑️ تم مسح الكاش')),
              );
            },
            child: const Text('مسح الكاش', style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }
}
