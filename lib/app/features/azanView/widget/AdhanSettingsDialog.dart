import '../../../core/shard/exports/all_exports.dart';
import '../adhan_workmanager_service.dart';

class AdhanSettingsDialog extends StatefulWidget {
  const AdhanSettingsDialog({super.key});

  @override
  State<AdhanSettingsDialog> createState() => _AdhanSettingsDialogState();
}

class _AdhanSettingsDialogState extends State<AdhanSettingsDialog> {
  bool enableFajr = true;
  bool enableNormal = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await AdhanWorkManagerService().getAdhanPreferences();
    setState(() {
      enableFajr = prefs.getBool('enableFajrAdhan') ?? true;
      enableNormal = prefs.getBool('enableNormalAdhan') ?? true;
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
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إغلاق'),
        ),
      ],
    );
  }
}
