import 'package:muslimdaily/app/core/utils/style/k_color.dart';

import '../../../core/cubit/centralized_cubit.dart';
import '../../../core/shard/exports/all_exports.dart';





class IslamicCardWidget extends StatelessWidget {
  final String title;
  final String iconPath;
  final VoidCallback? onTap;

  const IslamicCardWidget({
    super.key,
    required this.title,
    required this.iconPath,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.sizeOf(context).width > 600;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        // لون خلفية عند الوضع المظلم (اختياري)
        color: isDark ? Theme.of(context).scaffoldBackgroundColor : null,
        image: isDark
            ? null
            : const DecorationImage(
          opacity: 0.4,
          image: AssetImage("assets/images/8180jjj00005.webp"),
          fit: BoxFit.cover,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).cardColor,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: isDark ? Colors.white : const Color(0xFFD4AF37),
          width: 1.2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Image.asset(iconPath, width: isTablet ? 22.w : 40.w, height: isTablet ? 22.w : 40.w, fit: BoxFit.fill),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: isTablet ? 13 : 12.sp,
                fontWeight: FontWeight.w600,
                shadows: [Shadow(color: Colors.black.withOpacity(0.1), blurRadius: 2)],
              ),
            ),
          ],
        ),
      ),
    ));
  }
}





void showThemeSheet(BuildContext ctx) {
  final cubit = CentralizedCubit.get(ctx);
  final currentTheme = cubit.themeMode();
  final currentFont = cubit.azkarFontSize();

  // متغيرات مؤقتة تعيش طوال عمر الـ BottomSheet
  double tempFont = currentFont;
  ThemeMode tempTheme = currentTheme;
  final isDark = Theme.of(ctx).brightness == Brightness.dark;

  showModalBottomSheet(
    context: ctx,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (bc) {
      return SafeArea(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: StatefulBuilder(
            builder: (context, setState) {
              // هل حصل أي تغيير؟
              final bool hasChanges =
                  tempTheme != currentTheme || tempFont != currentFont;

              // نعرّف الـ ListTile هنا حتى نستخدم setState
              ListTile themeTile(String title, IconData icon, ThemeMode mode) {
                return ListTile(
                  leading: Icon(icon),
                  title: Text(title),
                  trailing: tempTheme == mode ? const Icon(Icons.check) : null,
                  onTap: () {
                    setState(() {
                      tempTheme = mode;
                    });
                  },
                );
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 8),
                    const Text(
                      'الاعدادت',
                      style: TextStyle(fontSize: 18, fontFamily: "cairo"),
                    ),

                    // اختيار الثيم
                    themeTile('فاتح', Icons.light_mode, ThemeMode.light),
                    themeTile('داكن', Icons.dark_mode, ThemeMode.dark),
                    themeTile(
                        'حسب النظام', Icons.phone_android, ThemeMode.system),

                    const Divider(),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 6.0),
                      child: Text(
                        'حجم خط الأذكار',
                        style: TextStyle(fontSize: 16, fontFamily: "cairo"),
                      ),
                    ),

                    // Slider التحكم في الخط
                    Padding(
                      padding:  EdgeInsets.symmetric(horizontal: 16.0),
                      child: Slider(
                        overlayColor: WidgetStatePropertyAll(isDark?AppColors.primary :Colors.blue),
                        activeColor: isDark?AppColors.primary :Colors.blue,
                        inactiveColor:isDark?Colors.black: Colors.grey.shade300,


                        value: tempFont,
                        min: 10,
                        max: 100,
                        divisions: 90,
                        label: tempFont.toInt().toString(),
                        onChanged: (v) {
                          setState(() {
                            tempFont = v;
                          });
                        },
                      ),
                    ),

                    Row(
                      children: [
                        const Spacer(),
                        TextButton(
                          onPressed: () => Navigator.pop(bc),
                          child: const Text('إلغاء'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          // Disabled لو مفيش أي تغيير
                          onPressed: hasChanges
                              ? () async {
                            await cubit.setThemeMode(tempTheme);
                            await cubit.setAzkarFontSize(tempFont);
                            Navigator.pop(bc);
                          }
                              : null,
                          child: const Text('حفظ'),
                        ),
                        const SizedBox(width: 12),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );
    },
  );
}
