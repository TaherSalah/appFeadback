import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'models/charity_models.dart';
import 'services/charity_service.dart';

class AddCharityScreen extends StatefulWidget {
  final CharityDonation? donation; // للتعديل

  const AddCharityScreen({super.key, this.donation});

  @override
  State<AddCharityScreen> createState() => _AddCharityScreenState();
}

class _AddCharityScreenState extends State<AddCharityScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  final CharityService _charityService = CharityService();

  CharityCategory _selectedCategory = CharityCategory.sadaqah;
  PaymentMethod? _selectedPaymentMethod;
  DateTime _selectedDate = DateTime.now();
  String _currency = 'EGP';
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _charityService.init();

    // إذا كان تعديل، املأ البيانات
    if (widget.donation != null) {
      _amountController.text = widget.donation!.amount.toString();
      _notesController.text = widget.donation!.notes ?? '';
      _selectedCategory = widget.donation!.category;
      _selectedPaymentMethod = widget.donation!.paymentMethod;
      _selectedDate = widget.donation!.date;
      _currency = widget.donation!.currency;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveDonation() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    final donation = CharityDonation.withCategory(
      id: widget.donation?.id ?? _charityService.generateId(),
      amount: double.parse(_amountController.text),
      category: _selectedCategory,
      date: _selectedDate,
      notes: _notesController.text.isEmpty ? null : _notesController.text,
      currency: 'EGP',
      paymentMethod: _selectedPaymentMethod,
    );

    if (widget.donation != null) {
      await _charityService.updateDonation(donation);
    } else {
      await _charityService.addDonation(donation);
    }

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.donation != null
                ? 'تم تحديث الصدقة بنجاح ✅'
                : 'تم إضافة الصدقة بنجاح ✅',
            style: GoogleFonts.cairo(),
          ),
          backgroundColor: const Color(0xFF10B981),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor:
            isDark ? const Color(0xFF1A1F36) : const Color(0xFFF5F7FA),
        appBar: AppBar(
          title: Text(
            widget.donation != null ? 'تعديل الصدقة' : 'إضافة صدقة جديدة',
            style: GoogleFonts.cairo(
              fontWeight: FontWeight.bold,
              fontSize: 20.sp,
            ),
          ),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // المبلغ
                _buildSectionTitle('💰 المبلغ'),
                SizedBox(height: 12.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF2D3748) : Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _amountController,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          style: GoogleFonts.cairo(fontSize: 18.sp),
                          decoration: InputDecoration(
                            hintText: 'أدخل المبلغ',
                            hintStyle: GoogleFonts.cairo(
                              color: Colors.grey,
                            ),
                            border: InputBorder.none,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'الرجاء إدخال المبلغ';
                            }
                            if (double.tryParse(value) == null) {
                              return 'الرجاء إدخال رقم صحيح';
                            }
                            if (double.parse(value) <= 0) {
                              return 'المبلغ يجب أن يكون أكبر من صفر';
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(width: 12.w),
                      DropdownButton<String>(
                        value: _currency,
                        underline: const SizedBox.shrink(),
                        items: ['EGP', 'SAR', 'USD', 'EUR']
                            .map((c) => DropdownMenuItem(
                                  value: c,
                                  child: Text(
                                    c,
                                    style: GoogleFonts.cairo(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ))
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _currency = value);
                          }
                        },
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 24.h),

                // الفئة
                _buildSectionTitle('📂 فئة الصدقة'),
                SizedBox(height: 12.h),
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: CharityCategory.values.map((category) {
                    final isSelected = category == _selectedCategory;
                    return InkWell(
                      onTap: () {
                        setState(() => _selectedCategory = category);
                      },
                      borderRadius: BorderRadius.circular(12.r),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 12.h,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF10B981)
                              : (isDark
                                  ? const Color(0xFF2D3748)
                                  : Colors.white),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF10B981)
                                : Colors.grey.shade300,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              category.emoji,
                              style: TextStyle(fontSize: 18.sp),
                            ),
                            SizedBox(width: 6.w),
                            Text(
                              category.arabicName,
                              style: GoogleFonts.cairo(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? Colors.white
                                    : (isDark ? Colors.white : Colors.black87),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),

                SizedBox(height: 24.h),

                // طريقة الدفع
                _buildSectionTitle('💳 طريقة الدفع (اختياري)'),
                SizedBox(height: 12.h),
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: PaymentMethod.values.map((method) {
                    final isSelected = method == _selectedPaymentMethod;
                    return InkWell(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            _selectedPaymentMethod = null;
                          } else {
                            _selectedPaymentMethod = method;
                          }
                        });
                      },
                      borderRadius: BorderRadius.circular(12.r),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 12.h,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF3B82F6)
                              : (isDark
                                  ? const Color(0xFF2D3748)
                                  : Colors.white),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF3B82F6)
                                : Colors.grey.shade300,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              method.icon,
                              style: TextStyle(fontSize: 18.sp),
                            ),
                            SizedBox(width: 6.w),
                            Text(
                              method.arabicName,
                              style: GoogleFonts.cairo(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? Colors.white
                                    : (isDark ? Colors.white : Colors.black87),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),

                SizedBox(height: 24.h),

                // التاريخ
                _buildSectionTitle('📅 التاريخ'),
                SizedBox(height: 12.h),
                InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: const ColorScheme.light(
                              primary: Color(0xFF10B981),
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (date != null) {
                      setState(() => _selectedDate = date);
                    }
                  },
                  borderRadius: BorderRadius.circular(16.r),
                  child: Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF2D3748) : Colors.white,
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today,
                            color: Color(0xFF10B981)),
                        SizedBox(width: 12.w),
                        Text(
                          '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                          style: GoogleFonts.cairo(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 24.h),

                // ملاحظات
                _buildSectionTitle('📝 ملاحظات (اختياري)'),
                SizedBox(height: 12.h),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF2D3748) : Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: TextFormField(
                    controller: _notesController,
                    maxLines: 4,
                    style: GoogleFonts.cairo(fontSize: 14.sp),
                    decoration: InputDecoration(
                      hintText: 'اكتب ملاحظات إضافية...',
                      hintStyle: GoogleFonts.cairo(color: Colors.grey),
                      border: InputBorder.none,
                    ),
                  ),
                ),

                SizedBox(height: 32.h),

                // زر الحفظ
                SizedBox(
                  width: double.infinity,
                  height: 56.h,
                  child: ElevatedButton(
                    onPressed: _saving ? null : _saveDonation,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      elevation: 0,
                    ),
                    child: _saving
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            widget.donation != null
                                ? 'تحديث الصدقة'
                                : 'حفظ الصدقة',
                            style: GoogleFonts.cairo(
                              fontSize: 18.sp,
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

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.cairo(
        fontSize: 16.sp,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
