import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'models/charity_models.dart';
import 'services/charity_service.dart';
import 'AddCharityScreen.dart';

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

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Directionality(
          textDirection: TextDirection.rtl,
          child: SafeArea(
            bottom: true,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
              ),
              padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, MediaQuery.of(context).viewInsets.bottom + 20.h),
              child: SingleChildScrollView( // الحل لمشكلة الـ Overflow
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 50.w,
                        height: 5.h,
                        margin: EdgeInsets.symmetric(vertical: 10.h),
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                    ),
                    Text(
                      existing == null ? 'إضافة التزام صدقة جديد 🤲' : 'تعديل التزام الصدقة',
                      style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 18.sp),
                    ),
                    SizedBox(height: 15.h),
                    _buildTextField(titleController, 'اسم الصدقة (مثلاً: كفالة يتيم)', Icons.title),
                    SizedBox(height: 12.h),
                    _buildTextField(amountController, 'المقدار الشهري (جنيه)', Icons.attach_money, isNumber: true),

                    SizedBox(height: 20.h),
                    Text('الفئة 📁:', style: GoogleFonts.cairo(fontSize: 14.sp, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8.h),
                    SizedBox(
                      height: 45.h,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: CharityCategory.values.length,
                        itemBuilder: (context, index) {
                          final category = CharityCategory.values[index];
                          final isSelected = selectedCategory == category;
                          return _buildChoiceChip(
                            category.arabicName,
                            category.emoji,
                            isSelected,
                            () => setModalState(() => selectedCategory = category)
                          );
                        },
                      ),
                    ),

                    SizedBox(height: 20.h),
                    Text('يوم التذكير (1-31) 📅:', style: GoogleFonts.cairo(fontSize: 14.sp, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8.h),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 7,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                      ),
                      itemCount: 31, // تم التحديث لـ 31 يوم
                      itemBuilder: (context, index) {
                        final day = index + 1;
                        final isSelected = selectedDay == day;
                        return GestureDetector(
                          onTap: () => setModalState(() => selectedDay = day),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFF10B981) : Colors.grey.withOpacity(0.1),
                              shape: BoxShape.circle,
                              border: isSelected ? Border.all(color: Colors.white, width: 2) : null,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              day.toString(),
                              style: GoogleFonts.cairo(
                                color: isSelected ? Colors.white : Colors.black,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                fontSize: 12.sp,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 25.h),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (titleController.text.isEmpty || amountController.text.isEmpty) return;

                          final recurring = RecurringCharity(
                            id: existing?.id ?? _charityService.generateId(),
                            title: titleController.text,
                            amount: double.parse(amountController.text).toDouble(),
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
                          backgroundColor: const Color(0xFF10B981),
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
                          elevation: 2,
                        ),
                        child: Text('حفظ الالتزام', style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16.sp)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
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
              actions: [
                IconButton(
                  tooltip: 'تجربة الإشعارات',
                  icon: const Icon(Icons.notification_add_outlined),
                  onPressed: () async {
                    // Testing notifications logic was removed from service, so this will either do nothing or we should remove the button too.
                    // Keeping it for now but removing the call if service method is gone.
                  },
                ),
              ],

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
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _recurringCharities.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: EdgeInsets.all(16.w),
                    itemCount: _recurringCharities.length,
                    itemBuilder: (context, index) {
                      final item = _recurringCharities[index];
                      return _buildRecurringCard(item);
                    },
                  ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_month, size: 80.sp, color: Colors.grey.withOpacity(0.5)),
          SizedBox(height: 16.h),
          Text(
            'لا توجد صدقات دورية مضافة بعد',
            style: GoogleFonts.cairo(fontSize: 16.sp, color: Colors.grey),
          ),
          SizedBox(height: 8.h),
          Text(
            'أضف صدقاتك الشهرية لتذكيرك بها',
            style: GoogleFonts.cairo(fontSize: 14.sp, color: Colors.grey.withOpacity(0.8)),
          ),
        ],
      ),
    );
  }

  Widget _buildRecurringCard(RecurringCharity item) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 50.w,
                height: 50.h,
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(item.category.emoji, style: TextStyle(fontSize: 24.sp)),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 16.sp),
                    ),
                    Row(
                      children: [
                        Text(
                          '${item.amount} ${item.currency}',
                          style: GoogleFonts.cairo(fontSize: 14.sp, color: const Color(0xFF10B981), fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Switch(
                value: item.isActive,
                activeColor: const Color(0xFF10B981),
                onChanged: (val) async {
                  final updated = item.copyWith(isActive: val);
                  await _charityService.updateRecurringCharity(updated);
                  _loadData();
                },
              ),
            ],
          ),
          SizedBox(height: 12.h),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.notifications_active_outlined, size: 16.sp, color: Colors.orange),
                  SizedBox(width: 4.w),
                  Text(
                    'تذكير يوم ${item.dayOfMonth} من كل شهر',
                    style: GoogleFonts.cairo(fontSize: 12.sp, color: Colors.orange),
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.edit_outlined, size: 20.sp, color: Colors.blue),
                    onPressed: () => _addOrEditRecurring(item),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete_outline, size: 20.sp, color: Colors.red),
                    onPressed: () async {
                      await _charityService.deleteRecurringCharity(item.id);
                      _loadData();
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isNumber = false}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF10B981), size: 20.sp),
        labelStyle: GoogleFonts.cairo(fontSize: 14.sp),
        filled: true,
        fillColor: Colors.grey.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.r),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      ),
    );
  }

  Widget _buildChoiceChip(String label, String icon, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w),
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF10B981).withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(15.r),
          border: Border.all(color: isSelected ? const Color(0xFF10B981) : Colors.grey.withOpacity(0.3)),
        ),
        alignment: Alignment.center,
        child: Row(
          children: [
            Text(icon, style: TextStyle(fontSize: 16.sp)),
            SizedBox(width: 6.w),
            Text(label, style: GoogleFonts.cairo(fontSize: 12.sp, color: isSelected ? const Color(0xFF10B981) : Colors.grey, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
          ],
        ),
      ),
    );
  }
}
