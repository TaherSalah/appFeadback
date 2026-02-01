import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/utils/style/responsive_util.dart';
import 'kids_data/duas_data.dart';
import '../../../core/utils/style/k_dialog_helper.dart';

class DailyDuasScreen extends StatelessWidget {
  const DailyDuasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'أدعية يومية 🤲',
            style: GoogleFonts.cairo(
              fontWeight: FontWeight.bold,
              fontSize: ResponsiveUtil.isTablet(context) ? 14.sp : 20.sp,
            ),
          ),
          centerTitle: true,
        ),
        body: GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.85,
          ),
          itemCount: DuasData.allDuas.length,
          itemBuilder: (context, index) {
            final dua = DuasData.allDuas[index];

            return GestureDetector(
              onTap: () => _showDuaDialog(context, dua),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.purple.shade400,
                      Colors.deepPurple.shade600,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.purple.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      dua.emoji,
                      style: const TextStyle(fontSize: 50),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      dua.title,
                      style: GoogleFonts.cairo(
                        fontSize:
                            ResponsiveUtil.isTablet(context) ? 11.sp : 14.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showDuaDialog(BuildContext context, DuaForKids dua) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    KDialogHelper.showCustomDialog(
      context: context,
      type: KDialogType.info,
      icon: Icons.auto_awesome_rounded,
      title: dua.title,
      description: dua.meaning,
      additionalContent: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color:
              isDark ? Colors.purple.withOpacity(0.1) : Colors.purple.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.purple.withOpacity(0.2)),
        ),
        child: Text(
          dua.arabic,
          style: GoogleFonts.cairo(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            height: 2.0,
            color: isDark ? Colors.white : Colors.purple.shade900,
          ),
          textAlign: TextAlign.center,
        ),
      ),
      actions: [
        KDialogHelper.buildButton(
          context: context,
          label: 'حفظته!',
          color: Colors.purple,
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }
}
