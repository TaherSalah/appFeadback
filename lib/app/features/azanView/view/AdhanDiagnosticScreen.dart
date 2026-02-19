import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:muslimdaily/app/core/services/AdhanDiagnosticHelper.dart';
import 'package:muslimdaily/app/features/azanView/adhan_workmanager_service.dart';
import 'package:permission_handler/permission_handler.dart';

class AdhanDiagnosticScreen extends StatefulWidget {
  const AdhanDiagnosticScreen({Key? key}) : super(key: key);

  @override
  State<AdhanDiagnosticScreen> createState() => _AdhanDiagnosticScreenState();
}

class _AdhanDiagnosticScreenState extends State<AdhanDiagnosticScreen> {
  Map<String, dynamic>? _diagnosticReport;
  Map<String, dynamic>? _scheduleInfo;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadDiagnostics();
  }

  Future<void> _loadDiagnostics() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final report = await AdhanDiagnosticHelper.getDiagnosticReport();
      final scheduleInfo = await AdhanDiagnosticHelper.getLastScheduleInfo();

      setState(() {
        _diagnosticReport = report;
        _scheduleInfo = scheduleInfo;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _rescheduleAdhan() async {
    setState(() => _isLoading = true);

    try {
      await AdhanWorkManagerService().initialize(forceReschedule: true);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ تم إعادة جدولة الأذان بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
      }

      await _loadDiagnostics();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ خطأ: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  Future<void> _testAdhan() async {
    try {
      await AdhanWorkManagerService().scheduleTestAdhan(secondsFromNow: 10);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🧪 تم جدولة أذان تجريبي بعد 10 ثواني'),
            backgroundColor: Colors.blue,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ خطأ: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _copyReport() async {
    try {
      final textReport = await AdhanDiagnosticHelper.generateTextReport();
      await Clipboard.setData(ClipboardData(text: textReport));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('📋 تم نسخ التقرير'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ خطأ: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _requestBatteryOptimization() async {
    try {
      final status = await Permission.ignoreBatteryOptimizations.request();

      if (mounted) {
        if (status.isGranted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ تم تعطيل تحسين البطارية'),
              backgroundColor: Colors.green,
            ),
          );
          _loadDiagnostics();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content:
                  Text('⚠️ لم يتم منح الإذن. يرجى تفعيله من إعدادات النظام'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 4),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ خطأ: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _requestDisplayOverApps() async {
    try {
      final status = await Permission.systemAlertWindow.request();

      if (mounted) {
        if (status.isGranted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ تم منح إذن الظهور فوق التطبيقات'),
              backgroundColor: Colors.green,
            ),
          );
          _loadDiagnostics();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content:
                  Text('⚠️ لم يتم منح الإذن. يرجى تفعيله من إعدادات النظام'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 4),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ خطأ: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor:
            isDark ? const Color(0xFF0B1E15) : const Color(0xFFF5F9F7),
        appBar: AppBar(
          title: const Text('تشخيص نظام الأذان'),
          backgroundColor:
              isDark ? const Color(0xFF0F2419) : const Color(0xFF178B74),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _isLoading ? null : _loadDiagnostics,
              tooltip: 'تحديث',
            ),
            IconButton(
              icon: const Icon(Icons.copy),
              onPressed: _isLoading ? null : _copyReport,
              tooltip: 'نسخ التقرير',
            ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
                ? _buildError()
                : _buildContent(isDark),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'حدث خطأ',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadDiagnostics,
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(bool isDark) {
    final settings = _diagnosticReport!['settings'] as Map<String, bool>;
    final permissions = _diagnosticReport!['permissions'] as Map<String, bool>;
    final scheduledCount = _diagnosticReport!['scheduled_count'] as int;
    final batteryOptDisabled =
        _diagnosticReport!['battery_optimization_disabled'] as bool;
    final errors = _diagnosticReport!['recent_errors'] as List<String>;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // حالة النظام العامة
          _buildStatusCard(isDark, settings, permissions, batteryOptDisabled,
              scheduledCount),
          const SizedBox(height: 16),

          // الإعدادات
          _buildSettingsCard(isDark, settings),
          const SizedBox(height: 16),

          // الأذونات
          _buildPermissionsCard(isDark, permissions, batteryOptDisabled),
          const SizedBox(height: 16),

          // معلومات الجدولة
          _buildScheduleCard(isDark, scheduledCount),
          const SizedBox(height: 16),

          // دليل خاص بنوع الجهاز
          _buildDeviceSpecificGuide(isDark),
          const SizedBox(height: 16),

          // الأخطاء
          if (errors.isNotEmpty) ...[
            _buildErrorsCard(isDark, errors),
            const SizedBox(height: 16),
          ],

          // الأزرار
          _buildActionButtons(isDark),
        ],
      ),
    );
  }

  Widget _buildStatusCard(
      bool isDark,
      Map<String, bool> settings,
      Map<String, bool> permissions,
      bool batteryOptDisabled,
      int scheduledCount) {
    final adhanEnabled = settings['adhan_enabled'] ?? false;
    final notificationsAllowed = permissions['notifications_allowed'] ?? false;

    final isHealthy = adhanEnabled &&
        notificationsAllowed &&
        batteryOptDisabled &&
        scheduledCount > 0;

    return Card(
      color: isDark ? const Color(0xFF0F2419) : Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(
              isHealthy ? Icons.check_circle : Icons.warning,
              size: 64,
              color: isHealthy ? Colors.green : Colors.orange,
            ),
            const SizedBox(height: 12),
            Text(
              isHealthy
                  ? 'النظام يعمل بشكل صحيح'
                  : 'يوجد مشاكل تحتاج إلى إصلاح',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              isHealthy
                  ? 'جميع الإعدادات والأذونات صحيحة'
                  : 'راجع التفاصيل أدناه لحل المشاكل',
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsCard(bool isDark, Map<String, bool> settings) {
    return Card(
      color: isDark ? const Color(0xFF0F2419) : Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.settings,
                    color: isDark ? Colors.tealAccent : Colors.teal),
                const SizedBox(width: 8),
                Text(
                  'الإعدادات',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...settings.entries.map((entry) => _buildCheckItem(
                  isDark,
                  _getSettingLabel(entry.key),
                  entry.value,
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionsCard(
      bool isDark, Map<String, bool> permissions, bool batteryOptDisabled) {
    return Card(
      color: isDark ? const Color(0xFF0F2419) : Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.security,
                    color: isDark ? Colors.tealAccent : Colors.teal),
                const SizedBox(width: 8),
                Text(
                  'الأذونات',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...permissions.entries.map((entry) => _buildCheckItem(
                  isDark,
                  _getPermissionLabel(entry.key),
                  entry.value,
                )),
            _buildCheckItem(
              isDark,
              'تحسين البطارية معطّل',
              batteryOptDisabled,
              onTap: !batteryOptDisabled ? _requestBatteryOptimization : null,
            ),
            _buildCheckItem(
              isDark,
              'الظهور فوق التطبيقات',
              permissions['display_over_apps'] ?? false,
              onTap: !(permissions['display_over_apps'] ?? false)
                  ? _requestDisplayOverApps
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleCard(bool isDark, int scheduledCount) {
    final lastScheduleTime = _scheduleInfo!['last_schedule_time'] as String;
    final daysSince = _scheduleInfo!['days_since_last_schedule'] as int;

    return Card(
      color: isDark ? const Color(0xFF0F2419) : Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.schedule,
                    color: isDark ? Colors.tealAccent : Colors.teal),
                const SizedBox(width: 8),
                Text(
                  'معلومات الجدولة',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow(isDark, 'عدد الإشعارات المجدولة', '$scheduledCount'),
            _buildInfoRow(isDark, 'آخر جدولة', lastScheduleTime),
            if (daysSince >= 0) _buildInfoRow(isDark, 'منذ', '$daysSince يوم'),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorsCard(bool isDark, List<String> errors) {
    return Card(
      color: isDark ? const Color(0xFF0F2419) : Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red),
                    const SizedBox(width: 8),
                    Text(
                      'آخر الأخطاء',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () async {
                    await AdhanDiagnosticHelper.clearErrors();
                    _loadDiagnostics();
                  },
                  child: const Text('مسح'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...errors.take(5).map((error) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    '• $error',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceSpecificGuide(bool isDark) {
    final deviceBrand =
        _diagnosticReport!['device_brand'] as String? ?? 'unknown';

    if (deviceBrand.contains('realme') || deviceBrand.contains('oppo')) {
      return _buildGuideCard(
        isDark,
        title: 'إرشادات لمستخدمي Realme / Oppo',
        icon: Icons.lightbulb_outline,
        color: Colors.orange,
        steps: [
          'اذهب إلى إعدادات الهاتف > التطبيقات > إدارة التطبيقات.',
          'ابحث عن تطبيق "رفيق المسلم" واضغط عليه.',
          'تأكد من تفعيل "التشغيل التلقائي" (Auto-start).',
          'اضغط على "استهلاك البطارية" واختر "السماح بالنشاط في الخلفية".',
          'تأكد من تفعيل "العرض فوق التطبيقات الأخرى" و"العرض على قفل الشاشة".',
        ],
      );
    } else if (deviceBrand.contains('xiaomi')) {
      return _buildGuideCard(
        isDark,
        title: 'إرشادات لمستخدمي Xiaomi',
        icon: Icons.lightbulb_outline,
        color: Colors.orange,
        steps: [
          'اذهب إلى الإعدادات > التطبيقات > إذن التشغيل التلقائي.',
          'قم بتفعيل "التشغيل التلقائي" لتطبيق "رفيق المسلم".',
          'اذهب إلى الإعدادات > البطارية > ترو فير البطارية (App Battery Saver).',
          'اختر تطبيق "رفيق المسلم" وحدد "لا توجد قيود" (No restrictions).',
        ],
      );
    } else if (deviceBrand.contains('huawei')) {
      return _buildGuideCard(
        isDark,
        title: 'إرشادات لمستخدمي Huawei',
        icon: Icons.lightbulb_outline,
        color: Colors.orange,
        steps: [
          'اذهب إلى الإعدادات > البطارية > تشغيل التطبيقات (App Launch).',
          'ابحث عن "رفيق المسلم" وأوقف التشغيل التلقائي له.',
          'ستظهر قائمة، تأكد من تفعيل "التشغيل في الخلفية".',
        ],
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildGuideCard(bool isDark,
      {required String title,
      required IconData icon,
      required Color color,
      required List<String> steps}) {
    return Card(
      color: isDark ? const Color(0xFF1A1A00) : const Color(0xFFFFFDE7),
      elevation: 2,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: color.withOpacity(0.3))),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...steps.map((step) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('• ',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: color)),
                      Expanded(
                        child: Text(
                          step,
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.4,
                            color: isDark ? Colors.white70 : Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton.icon(
          onPressed: _isLoading ? null : _rescheduleAdhan,
          icon: const Icon(Icons.refresh),
          label: const Text('إعادة جدولة الأذان'),
          style: ElevatedButton.styleFrom(
            backgroundColor:
                isDark ? const Color(0xFF178B74) : const Color(0xFF178B74),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: _isLoading ? null : _testAdhan,
          icon: const Icon(Icons.science),
          label: const Text('اختبار الأذان (10 ثواني)'),
          style: OutlinedButton.styleFrom(
            foregroundColor:
                isDark ? Colors.tealAccent : const Color(0xFF178B74),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            side: BorderSide(
              color: isDark ? Colors.tealAccent : const Color(0xFF178B74),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCheckItem(bool isDark, String label, bool value,
      {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(
              value ? Icons.check_circle : Icons.cancel,
              color: value ? Colors.green : Colors.red,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
              ),
            ),
            if (onTap != null)
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: isDark ? Colors.white38 : Colors.black38,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(bool isDark, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  String _getSettingLabel(String key) {
    switch (key) {
      case 'adhan_enabled':
        return 'الأذان مفعّل';
      case 'pre_prayer_enabled':
        return 'التنبيه قبل الصلاة مفعّل';
      case 'iqamah_enabled':
        return 'تنبيه الإقامة مفعّل';
      case 'sunrise_enabled':
        return 'تنبيه الشروق مفعّل';
      case 'post_prayer_enabled':
        return 'تذكير أذكار بعد الصلاة مفعّل';
      case 'adhan_vibration_enabled':
        return 'اهتزاز الأذان مفعّل';
      default:
        return key;
    }
  }

  String _getPermissionLabel(String key) {
    switch (key) {
      case 'notifications_allowed':
        return 'صلاحية الإشعارات';
      case 'schedule_exact_alarm':
        return 'صلاحية المنبهات الدقيقة';
      case 'ignore_battery_optimizations':
        return 'تجاهل تحسين البطارية';
      case 'display_over_apps':
        return 'الظهور فوق التطبيقات';
      default:
        return key;
    }
  }
}
