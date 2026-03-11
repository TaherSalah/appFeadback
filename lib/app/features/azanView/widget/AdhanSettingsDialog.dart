import '../../../core/shard/exports/all_exports.dart';
import '../adhan_workmanager_service.dart';
import '../../../core/services/settings_service.dart';
import '../../../core/services/adhan_logic/prayer_background_manager.dart';

class AdhanSettingsDialog extends StatefulWidget {
  const AdhanSettingsDialog({super.key});

  @override
  State<AdhanSettingsDialog> createState() => _AdhanSettingsDialogState();
}

class _AdhanSettingsDialogState extends State<AdhanSettingsDialog> {
  bool enableFajr = true;
  bool enableNormal = true;
  bool autoLocation = true;
  bool homeWidget = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await AdhanWorkManagerService().getAdhanPreferences();
    final settings = SettingsService();
    await settings.init();

    setState(() {
      enableFajr = prefs.getBool('enableFajrAdhan') ?? true;
      enableNormal = prefs.getBool('enableNormalAdhan') ?? true;
      autoLocation = settings.isAutoLocationEnabled;
      homeWidget = settings.isHomeWidgetEnabled;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('⚙️ إعدادات الأذان'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SwitchListTile(
            title: const Text('🌅 أذان الفجر'),
            value: enableFajr,
            onChanged: (v) async {
              setState(() => enableFajr = v);
              await AdhanWorkManagerService().saveAdhanPreferences(
                enableFajrAdhan: v,
              );
            },
          ),
          SwitchListTile(
            title: const Text('🕌 الأذان العادي'),
            value: enableNormal,
            onChanged: (v) async {
              setState(() => enableNormal = v);
              await AdhanWorkManagerService().saveAdhanPreferences(
                enableNormalAdhan: v,
              );
            },
          ),
          SwitchListTile(
            title: const Text('📍 تحديث الموقع تلقائياً'),
            subtitle: const Text('تغيير مواعيد الصلاة عند السفر'),
            value: autoLocation,
            onChanged: (v) async {
              setState(() => autoLocation = v);
              await SettingsService().setAutoLocationEnabled(v);
            },
          ),
          SwitchListTile(
            title: const Text('🏠 ويدجت الشاشة الرئيسية'),
            value: homeWidget,
            onChanged: (v) async {
              setState(() => homeWidget = v);
              await SettingsService().setHomeWidgetEnabled(v);
              if (v) {
                await PrayerBackgroundManager.updateHomeWidget();
              }
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => context.pop(),
          child: const Text('إغلاق'),
        ),
      ],
    );
  }
}
