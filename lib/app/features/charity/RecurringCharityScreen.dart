import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muslimdaily/app/core/utils/style/k_helper.dart';
import 'package:muslimdaily/app/features/messaView/azkar_massa.dart';

import '../../core/utils/style/k_color.dart';
import '../../core/utils/style/app_theme_colors.dart';
import '../../core/utils/style/responsive_util.dart';
import '../../core/widgets/KLoading.dart';
import 'models/charity_models.dart';
import 'services/charity_service.dart';

class RecurringCharityScreen extends StatefulWidget {
  const RecurringCharityScreen({super.key});

  @override
  State<RecurringCharityScreen> createState() => _RecurringCharityScreenState();
}

class _RecurringCharityScreenState extends State<RecurringCharityScreen> {
  final CharityService _charityService = CharityService();
  bool _isLoading = true;
  List<RecurringCharity> _recurringCharities = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _charityService.init();
    setState(() {
      _recurringCharities = _charityService.getAllRecurringCharities();
      _isLoading = false;
    });
  }

  Future<void> _addOrEditRecurring(RecurringCharity? existing) async {
    final titleController = TextEditingController(text: existing?.title ?? '');
    final amountController = TextEditingController(text: existing?.amount.toString() ?? '');
    int selectedDay = existing?.dayOfMonth ?? 1;
    CharityCategory selectedCategory = existing?.category ?? CharityCategory.sadaqah;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    bool isTab = ResponsiveUtil.isTablet(context);

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Directionality(
          textDirection: TextDirection.rtl,
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
              border: Border.all(color: AppThemeColors.cardBorderColor(context), width: 1.5),
            ),
            padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, MediaQuery.of(context).viewInsets.bottom + 24.h),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40.w,
                      height: 4.h,
                      margin: EdgeInsets.only(bottom: 20.h),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Icon(Icons.calendar_month, color: AppColors.primary, size: 24.sp),
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        existing == null ? 'إضافة التزام صدقة جديد' : 'تعديل التزام الصدقة',
                        style: GoogleFonts.cairo(
                          fontWeight: FontWeight.bold, 
                          fontSize: isTab?10.sp: 16.sp,
                          color: AppThemeColors.cardHeaderColor(context),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24.h),
                  
                  _buildTextField(isDark, titleController, 'اسم الصدقة (مثلاً: كفالة يتيم)', Icons.text_fields_rounded),
                  SizedBox(height: 16.h),
                  _buildTextField(isDark, amountController, 'المقدار الشهري (جنيه)', Icons.payments_rounded, isNumber: true),

                  SizedBox(height: 24.h),
                  _buildSectionHeader(isDark, 'الفئة', ''),
                  SizedBox(height: 12.h),
                  SizedBox(
                    height: 50.h,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: CharityCategory.values.length,
                      itemBuilder: (context, index) {
                        final category = CharityCategory.values[index];
                        final isSelected = selectedCategory == category;
                        return _buildChoiceChip(
                          isDark,
                          category.arabicName,
                          category.emoji,
                          isSelected,
                          () => setModalState(() => selectedCategory = category)
                        );
                      },
                    ),
                  ),

                  SizedBox(height: 24.h),
                  _buildSectionHeader(isDark, 'يوم التذكير', '(يُكرر كل شهر)'),
                  SizedBox(height: 16.h),
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: AppThemeColors.patternOpacity(context),
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade200),
                    ),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 7,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                      ),
                      itemCount: 31,
                      itemBuilder: (context, index) {
                        final day = index + 1;
                        final isSelected = selectedDay == day;
                        return InkWell(
                          onTap: () => setModalState(() => selectedDay = day),
                          borderRadius: BorderRadius.circular(12.r),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primary : AppThemeColors.patternOpacity(context),
                              borderRadius: BorderRadius.circular(12.r),
                              border: isSelected ? Border.all(color: const Color(0xFFD4AF37), width: 1.5) : null,
                              boxShadow: isSelected ? [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                )
                              ] : null,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              day.toString(),
                              style: GoogleFonts.cairo(
                                color: isSelected ? Colors.white : (isDark ? Colors.white70 : const Color(0xFF64748B)),
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                fontSize: 13.sp,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  
                  SizedBox(height: 32.h),
                  SizedBox(
                    width: double.infinity,
                    height: 54.h,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (titleController.text.isEmpty || amountController.text.isEmpty) {
                          // _showErrorSnackBar(context, 'برجاء أكمل البيانات المطلوبة');
                          KHelper.showError(message: 'برجاء أكمل البيانات المطلوبة');
                          return;
                        }

                        double? amount = double.tryParse(amountController.text);
                        if (amount == null || amount <= 0) {
                          // _showErrorSnackBar(context, 'برجاء إدخال مبلغ صحيح');
                          KHelper.showError(message: 'برجاء إدخال مبلغ صحيح');
                          return;
                        }

                        final recurring = RecurringCharity(
                          id: existing?.id ?? _charityService.generateId(),
                          title: titleController.text,
                          amount: amount,
                          categoryIndex: selectedCategory.index,
                          dayOfMonth: selectedDay,
                          isActive: existing?.isActive ?? true,
                        );

                        if (existing == null) {
                          await _charityService.addRecurringCharity(recurring);
                        } else {
                          await _charityService.updateRecurringCharity(recurring);
                        }

                        if (mounted) Navigator.pop(context);
                        _loadData();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                        elevation: 4,
                        shadowColor: AppColors.primary.withOpacity(0.4),
                      ),
                      child: Text(
                        existing == null ? 'تفعيل الالتزام' : 'حفظ التعديلات',
                        style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize:isTab?10.sp: 16.sp)
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(bool isDark, String title, String subtitle) {
    bool isTab = ResponsiveUtil.isTablet(context);

    return Row(
      children: [
        Text(
          title, 
          style: GoogleFonts.cairo(
            fontSize: isTab ? 10.sp : 15.sp,
            fontWeight: FontWeight.bold,
            color: AppThemeColors.cardHeaderColor(context),
          )
        ),
        if (subtitle.isNotEmpty) ...[
          SizedBox(width: 8.w),
          Text(
            subtitle, 
            style: GoogleFonts.cairo(
              fontSize: 11.sp, 
              color: isDark ? Colors.white38 : Colors.black38,
            )
          ),
        ],
      ],
    );
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.cairo()),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        // appBar: AppBar(
        //   title: Text('الصدقات الدورية', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
        //   centerTitle: true,
        //   actions: [
        //     IconButton(
        //       tooltip: 'تجربة الإشعارات',
        //       icon: const Icon(Icons.notification_add_outlined),
        //       onPressed: () async {
        //         // Testing notifications logic was removed from service, so this will either do nothing or we should remove the button too.
        //         // Keeping it for now but removing the call if service method is gone.
        //       },
        //     ),
        //   ],
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
              //     tooltip: 'تجربة الإشعارات',
              //     icon: const Icon(Icons.notification_add_outlined),
              //     onPressed: () async {
              //       await _charityService.testNotification();
              //       if (mounted) {
              //         ScaffoldMessenger.of(context).showSnackBar(
              //           SnackBar(
              //             content: Text('تم إرسال إشعار تجريبي ✨', style: GoogleFonts.cairo()),
              //             backgroundColor: AppColors.primary,
              //           ),
              //         );
              //       }
              //     },
              //   ),
              // ],

            centerTitle: true,
            title: Text(
              'الصدقات الدورية',
              style: GoogleFonts.cairo(
                color: Colors.green,
                fontWeight: FontWeight.bold,
                fontSize:
                MediaQuery.sizeOf(context).width > 600 ? 12.sp : 18.sp,
              ),
            ),
          ),
        ),

        floatingActionButton: FloatingActionButton(
          onPressed: () => _addOrEditRecurring(null),
          backgroundColor: const Color(0xFF10B981),
          child: const Icon(Icons.add),
        ),
        body: Stack(
          children: [
            // Subtle Pattern Background
            Positioned.fill(
              child: Opacity(
                opacity: isDark ? 0.05 : 0.08,
                child: Image.asset(
                  'assets/images/8180jjj00005.webp',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            _isLoading
                ?  Center(child:  KLoading.progressIOSIndicator(context: context))
                : _recurringCharities.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: EdgeInsets.all(16.w),
                        itemCount: _recurringCharities.length,
                        itemBuilder: (context, index) {
                          final item = _recurringCharities[index];
                          return _buildRecurringCard(item, isDark);
                        },
                      ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    bool isTab = ResponsiveUtil.isTablet(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_month, size:isTab? 65.sp:80.sp, color: Colors.grey.withOpacity(0.5)),
          SizedBox(height: 16.h),
          Text(
            'لا توجد صدقات دورية مضافة بعد',
            style: GoogleFonts.cairo(fontSize:isTab? 10.sp:16.sp, color: Colors.grey),
          ),
          SizedBox(height: 8.h),
          Text(
            'أضف صدقاتك الشهرية لتذكيرك بها',
            style: GoogleFonts.cairo(fontSize:isTab? 8.sp: 14.sp, color: Colors.grey.withOpacity(0.8)),
          ),
        ],
      ),
    );
  }

  Widget _buildRecurringCard(RecurringCharity item, bool isDark) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: AppThemeColors.cardBackgroundColor(context),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: AppThemeColors.cardBorderColor(context),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                Container(
                  width: 54.w,
                  height: 54.h,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                  ),
                  child: Center(
                    child: Text(item.category.emoji, style: TextStyle(fontSize: 26.sp)),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: GoogleFonts.cairo(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.sp,
                          color: AppThemeColors.cardHeaderColor(context),
                        ),
                      ),
                      Text(
                        '${item.amount} ${item.currency}',
                        style: GoogleFonts.cairo(
                          fontSize: 14.sp,
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                CupertinoSwitch(
                  value: item.isActive,
                  activeColor: AppColors.primary,
                  onChanged: (val) async {
                    final updated = item.copyWith(isActive: val);
                    await _charityService.updateRecurringCharity(updated);
                    _loadData();
                  },
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: AppThemeColors.patternOpacity(context),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(20.r)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.notifications_active_outlined, size: 16.sp, color: Colors.orange),
                    SizedBox(width: 6.w),
                    Text(
                      'تذكير يوم ${item.dayOfMonth} من كل شهر',
                      style: GoogleFonts.cairo(
                        fontSize: 12.sp,
                        color: isDark ? Colors.orange.shade300 : Colors.orange.shade800,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    _buildIconButton(
                      icon: Icons.edit_outlined,
                      color: Colors.blue,
                      onTap: () => _addOrEditRecurring(item),
                    ),
                    SizedBox(width: 8.w),
                    _buildIconButton(
                      icon: Icons.delete_outline,
                      color: Colors.red,
                      onTap: () async {
                        final confirm = await _showDeleteConfirm(context);
                        if (confirm == true) {
                          await _charityService.deleteRecurringCharity(item.id);
                          _loadData();
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton({required IconData icon, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        padding: EdgeInsets.all(6.w),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Icon(icon, size: 18.sp, color: color),
      ),
    );
  }

  Future<bool?> _showDeleteConfirm(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: Text('حذف الالتزام', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
          content: Text('هل أنت متأكد من حذف هذا الالتزام؟', style: GoogleFonts.cairo()),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('إلغاء', style: GoogleFonts.cairo(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text('حذف', style: GoogleFonts.cairo(color: Colors.red, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(bool isDark, TextEditingController controller, String label, IconData icon, {bool isNumber = false}) {
    bool isTab = ResponsiveUtil.isTablet(context);

    return Container(
      decoration: BoxDecoration(
        color: AppThemeColors.patternOpacity(context),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade200),
      ),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        style: GoogleFonts.cairo(
          fontSize:isTab? 9.sp:14.sp,
          color: AppThemeColors.cardHeaderColor(context),
        ),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: AppColors.primary, size: isTab?15.sp: 20.sp),
          labelStyle: GoogleFonts.cairo(
            fontSize: isTab? 10.sp:13.sp,
            color: isDark ? Colors.white38 : Colors.black38,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        ),
      ),
    );
  }

  Widget _buildChoiceChip(bool isDark, String label, String icon, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(left: 10.w),
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : AppThemeColors.patternOpacity(context),
          borderRadius: BorderRadius.circular(15.r),
          border: Border.all(
            color: isSelected ? AppColors.primary : (isDark ? Colors.white10 : Colors.grey.shade200),
            width: 1.5,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            )
          ] : null,
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Text(icon, style: TextStyle(fontSize: 18.sp)),
            // SizedBox(width: 8.w),  // Text(icon, style: TextStyle(fontSize: 18.sp)),
            // SizedBox(width: 8.w),
            Text(
              label, 
              style: GoogleFonts.cairo(
                fontSize: 13.sp, 
                color: isSelected ? AppColors.primary : (isDark ? Colors.white60 : const Color(0xFF64748B)), 
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              )
            ),
          ],
        ),
      ),
    );
  }
}
