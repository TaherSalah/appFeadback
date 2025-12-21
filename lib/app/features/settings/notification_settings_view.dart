import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muslimdaily/app/core/services/settings_service.dart';

class NotificationSettingsView extends StatefulWidget {
  const NotificationSettingsView({super.key});

  @override
  State<NotificationSettingsView> createState() =>
      _NotificationSettingsViewState();
}

class _NotificationSettingsViewState extends State<NotificationSettingsView> {
  final SettingsService _settings = SettingsService();

  // الحالة المحلية للواجهة
  late bool isAdhanEnabled;
  late bool isAzkarSabahEnabled;
  late bool isAzkarMassaEnabled;
  late bool isAzkarSleepEnabled;
  late bool isQiyamEnabled;
  late bool isSalatAlaNabiEnabled;
  late int salatFrequency;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    setState(() {
      isAdhanEnabled = _settings.isAdhanEnabled;
      isAzkarSabahEnabled = _settings.isAzkarSabahEnabled;
      isAzkarMassaEnabled = _settings.isAzkarMassaEnabled;
      isAzkarSleepEnabled = _settings.isAzkarSleepEnabled;
      isQiyamEnabled = _settings.isQiyamEnabled;
      isSalatAlaNabiEnabled = _settings.isSalatAlaNabiEnabled;
      salatFrequency = _settings.getSalatAlaNabiMinutes();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: Text(
            'إعدادات التنبيهات',
            style: GoogleFonts.cairo(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: BackButton(color: isDark ? Colors.white : Colors.black87),
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isDark
                  ? [
                      const Color(0xFF0F172A),
                      const Color(0xFF1E293B),
                      const Color(0xFF0F172A)
                    ]
                  : [
                      const Color(0xFFF8F9FA),
                      const Color(0xFFE9ECEF),
                      const Color(0xFFF8F9FA)
                    ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView(
              children: [
                SizedBox(height: MediaQuery.of(context).padding.top + 60),

                // 🕋 الأذان
                _buildSectionHeader(context, 'الصلوات'),
                _buildSettingsCard(
                  context,
                  children: [
                    _buildSwitchTile(
                      context,
                      title: 'تنبيهات الأذان',
                      subtitle: 'تفعيل إشعارات الأذان لكل الصلوات',
                      icon: Icons.mosque_outlined,
                      iconColor: Colors.amber[700]!,
                      value: isAdhanEnabled,
                      onChanged: (val) async {
                        await _settings.setAdhanEnabled(val);
                        setState(() => isAdhanEnabled = val);
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // 📿 الأذكار
                _buildSectionHeader(context, 'الأذكار اليومية'),
                _buildSettingsCard(
                  context,
                  children: [
                    _buildSwitchTile(
                      context,
                      title: 'أذكار الصباح',
                      subtitle: 'تنبيه يومي الساعة 9:00 ص',
                      icon: Icons.wb_sunny_outlined,
                      iconColor: Colors.orange[400]!,
                      value: isAzkarSabahEnabled,
                      onChanged: (val) async {
                        await _settings.setAzkarSabahEnabled(val);
                        setState(() => isAzkarSabahEnabled = val);
                      },
                    ),
                    _buildDivider(isDark),
                    _buildSwitchTile(
                      context,
                      title: 'أذكار المساء',
                      subtitle: 'تنبيه يومي الساعة 6:00 م',
                      icon: Icons.nights_stay_outlined,
                      iconColor: Colors.indigo[400]!,
                      value: isAzkarMassaEnabled,
                      onChanged: (val) async {
                        await _settings.setAzkarMassaEnabled(val);
                        setState(() => isAzkarMassaEnabled = val);
                      },
                    ),
                    _buildDivider(isDark),
                    _buildSwitchTile(
                      context,
                      title: 'أذكار النوم',
                      subtitle: 'تنبيه يومي الساعة 10:00 م',
                      icon: Icons.bed_outlined,
                      iconColor: Colors.purple[400]!,
                      value: isAzkarSleepEnabled,
                      onChanged: (val) async {
                        await _settings.setAzkarSleepEnabled(val);
                        setState(() => isAzkarSleepEnabled = val);
                      },
                    ),
                    _buildDivider(isDark),
                    _buildSwitchTile(
                      context,
                      title: 'قيام الليل',
                      subtitle: 'تنبيه قبل الفجر',
                      icon: Icons.star_border,
                      iconColor: Colors.blue[300]!,
                      value: isQiyamEnabled,
                      onChanged: (val) async {
                        await _settings.setQiyamEnabled(val);
                        setState(() => isQiyamEnabled = val);
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // 🕌 الصلاة على النبي
                _buildSectionHeader(context, 'الصلاة على النبي ﷺ'),
                _buildSettingsCard(
                  context,
                  children: [
                    _buildSwitchTile(
                      context,
                      title: 'تفعيل التذكير',
                      subtitle: 'تنبيهات متكررة للصلاة على النبي',
                      icon: Icons.volunteer_activism_outlined,
                      iconColor: Colors.green[500]!,
                      value: isSalatAlaNabiEnabled,
                      onChanged: (val) async {
                        await _settings.setSalatAlaNabiEnabled(val);
                        setState(() => isSalatAlaNabiEnabled = val);
                      },
                    ),
                    if (isSalatAlaNabiEnabled) ...[
                      _buildDivider(isDark),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'تكرار التذكير كل:',
                              style: GoogleFonts.cairo(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white70 : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              height: 48, // Limit height for horizontal list
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                children: [
                                  _buildFrequencyChip(1),
                                  _buildFrequencyChip(5),
                                  _buildFrequencyChip(10),
                                  _buildFrequencyChip(15),
                                  _buildFrequencyChip(20),
                                  _buildFrequencyChip(30),
                                  _buildFrequencyChip(45),
                                  _buildFrequencyChip(60),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, right: 8.0),
      child: Text(
        title,
        style: GoogleFonts.cairo(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: isDark ? const Color(0xFFD4AF37) : const Color(0xFFB8860B),
        ),
      ),
    );
  }

  Widget _buildSettingsCard(BuildContext context,
      {required List<Widget> children}) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B).withOpacity(0.6) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Column(
            children: children,
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return SwitchListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      secondary: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: iconColor, size: 22),
      ),
      title: Text(
        title,
        style: GoogleFonts.cairo(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.cairo(
          fontSize: 11,
          color: Colors.grey,
        ),
      ),
      value: value,
      activeColor: const Color(0xFFD4AF37),
      onChanged: onChanged,
    );
  }

  Widget _buildFrequencyChip(int minutes) {
    bool isSelected = salatFrequency == minutes;
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: ChoiceChip(
        label: Text(
          '$minutes دقيقة',
          style: GoogleFonts.cairo(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected
                ? Colors.white
                : (isDark ? Colors.white70 : Colors.black87),
          ),
        ),
        selected: isSelected,
        selectedColor: const Color(0xFFD4AF37),
        backgroundColor:
            isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade100,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: isSelected
                  ? Colors.transparent
                  : Colors.grey.withOpacity(0.3),
            )),
        onSelected: (bool selected) async {
          if (selected) {
            await _settings.setSalatAlaNabiMinutes(minutes);
            setState(() => salatFrequency = minutes);
          }
        },
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Divider(
      height: 1,
      thickness: 1,
      color: isDark
          ? Colors.white.withOpacity(0.05)
          : Colors.grey.withOpacity(0.1),
      indent: 60,
    );
  }
}
