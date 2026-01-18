import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muslimdaily/app/core/utils/style/k_color.dart';
import '../../core/utils/style/responsive_util.dart';
import 'models/charity_models.dart';
import 'services/charity_service.dart';

class MonthlyGoalScreen extends StatefulWidget {
  const MonthlyGoalScreen({super.key});

  @override
  State<MonthlyGoalScreen> createState() => _MonthlyGoalScreenState();
}

class _MonthlyGoalScreenState extends State<MonthlyGoalScreen> {
  final _charityService = CharityService();
  final _goalController = TextEditingController();
  MonthlyGoal? _currentGoal;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    await _charityService.init();
    _currentGoal = _charityService.getMonthlyGoal();
    if (_currentGoal != null) {
      _goalController.text = _currentGoal!.amount.toStringAsFixed(0);
    }
    setState(() => _loading = false);
  }

  Future<void> _saveGoal() async {
    final amount = double.tryParse(_goalController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء إدخال مبلغ صحيح')),
      );
      return;
    }

    await _charityService.setMonthlyGoal(amount);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم حفظ الهدف الشهري بنجاح 🎯'),
          backgroundColor: Color(0xFF10B981),
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    bool isTab = ResponsiveUtil.isTablet(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(

        // appBar: AppBar(
        //   title: Text(
        //     'هدف الصدقة الشهري 🎯',
        //     style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        //   ),
        //   centerTitle: true,
        //   elevation: 0,
        //   backgroundColor: Colors.transparent,
        // ),
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(
              MediaQuery.sizeOf(context).width > 600 ? 70 : 50),
          child: AppBar(
            leading: CupertinoNavigationBarBackButton(
              color: isDark ? Colors.white : Colors.black,
            ),
            // actions: [
            //   IconButton(
            //     onPressed: () => Navigator.push(
            //       context,
            //       MaterialPageRoute(
            //         builder: (context) => CreateKhatmahScreen(),
            //       ),
            //     ),
            //     icon: const Icon(Icons.add),
            //   )
            // ],
            centerTitle: true,
            title: Text(
              'هدف الصدقة الشهري',
              style: GoogleFonts.cairo(
                color: Colors.green,
                fontWeight: FontWeight.bold,
                fontSize:
                MediaQuery.sizeOf(context).width > 600 ? 12.sp : 18.sp,
              ),
            ),
          ),
        ),

        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: EdgeInsets.all(20.w),
                child: SafeArea(
                  bottom: true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'حدد هدفك المالي للصدقة هذا الشهر',
                        style: GoogleFonts.cairo(
                          fontSize:isTab?10.sp :16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'تحديد هدف يساعدك على المداومة والتحفيز على العطاء المستمر.',
                        style: GoogleFonts.cairo(
                          fontSize:isTab?9.sp :12.sp,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(height: 24.h),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF2D3748) : Colors.white,
                          borderRadius: BorderRadius.circular(16.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: TextFormField(
                          controller: _goalController,
                          keyboardType: TextInputType.number,
                          style: GoogleFonts.cairo(
                            fontSize: isTab?10.sp:24.sp,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF10B981),
                          ),
                          decoration: InputDecoration(
                            hintText: 'مثلاً: 1000',
                            suffixText: 'جنيه',
                            hintStyle: TextStyle(fontSize: isTab?9.sp:16.sp,),
                            suffixStyle: GoogleFonts.cairo(
                              fontSize: isTab?10.sp:16.sp,
                              color: Colors.grey,
                            ),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      const Spacer(),
                      SizedBox(
                        width: double.infinity,
                        height: 56.h,
                        child: ElevatedButton(
                          onPressed: _saveGoal,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: KColors.primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            'حفظ الهدف الشهري',
                            style: GoogleFonts.cairo(
                              fontSize:isTab?12.sp:18.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
